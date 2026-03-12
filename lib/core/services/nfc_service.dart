import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:ndef_record/ndef_record.dart';

/// NFC availability state for UI rendering.
enum NfcState {
  /// Device does not have NFC hardware.
  unsupported,

  /// Device has NFC but it is disabled in settings.
  disabled,

  /// NFC is supported and enabled.
  enabled,
}

/// Service for reading and writing Cashu tokens via NFC.
///
/// Writes tokens as NDEF Text Records for maximum compatibility
/// with cashu.me and Numo. Reads both Text and URI records.
class NfcService {
  /// Check NFC state on the device.
  static Future<NfcState> checkState() async {
    try {
      final availability = await NfcManager.instance.checkAvailability();
      return switch (availability) {
        NfcAvailability.enabled => NfcState.enabled,
        NfcAvailability.disabled => NfcState.disabled,
        NfcAvailability.unsupported => NfcState.unsupported,
      };
    } catch (_) {
      return NfcState.unsupported;
    }
  }

  /// Write a Cashu token to an NFC tag as NDEF Text Record.
  static Future<void> startWrite({
    required String token,
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443},
      onDiscovered: (NfcTag tag) async {
        final ndef = NdefAndroid.from(tag);
        if (ndef == null || !ndef.isWritable) {
          onError('Tag is not writable');
          NfcManager.instance.stopSession();
          return;
        }

        // Build NDEF Text Record: [status byte][language code][text]
        final textBytes = Uint8List.fromList(token.codeUnits);
        final languageCode = Uint8List.fromList('en'.codeUnits);
        final payload = Uint8List(1 + languageCode.length + textBytes.length);
        payload[0] = languageCode.length; // status byte (UTF-8, no length)
        payload.setRange(1, 1 + languageCode.length, languageCode);
        payload.setRange(1 + languageCode.length, payload.length, textBytes);

        // Check size
        if (payload.length + 7 > ndef.maxSize) {
          onError('Token too large for this NFC tag '
              '(${payload.length + 7}B > ${ndef.maxSize}B)');
          NfcManager.instance.stopSession();
          return;
        }

        try {
          final message = NdefMessage(records: [
            NdefRecord(
              typeNameFormat: TypeNameFormat.wellKnown,
              type: Uint8List.fromList([0x54]), // 'T' = Text Record
              identifier: Uint8List(0),
              payload: payload,
            ),
          ]);
          await ndef.writeNdefMessage(message);
          onSuccess();
          NfcManager.instance.stopSession();
        } catch (e) {
          onError(e.toString());
          NfcManager.instance.stopSession();
        }
      },
    );
  }

  /// Stop any active NFC session.
  static void stopWrite() {
    NfcManager.instance.stopSession();
  }

  /// Start reading NFC tags for Cashu tokens.
  static Future<void> startRead({
    required void Function(String token) onTokenRead,
    required void Function(String error) onError,
  }) async {
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443},
      onDiscovered: (NfcTag tag) async {
        final ndef = NdefAndroid.from(tag);
        if (ndef == null) {
          onError('Tag does not contain NDEF data');
          NfcManager.instance.stopSession();
          return;
        }

        try {
          final message = ndef.cachedNdefMessage ?? await ndef.getNdefMessage();
          if (message == null) {
            onError('No NDEF message on tag');
            NfcManager.instance.stopSession();
            return;
          }

          final token = _extractToken(message);
          if (token != null) {
            onTokenRead(token);
            NfcManager.instance.stopSession();
          } else {
            onError('No Cashu token found on tag');
            NfcManager.instance.stopSession();
          }
        } catch (e) {
          onError(e.toString());
          NfcManager.instance.stopSession();
        }
      },
    );
  }

  /// Stop any active NFC read session.
  static void stopRead() {
    NfcManager.instance.stopSession();
  }

  /// Extract a Cashu token from an NDEF message.
  static String? _extractToken(NdefMessage message) {
    for (final record in message.records) {
      // Text Record
      if (record.typeNameFormat == TypeNameFormat.wellKnown &&
          record.type.length == 1 &&
          record.type[0] == 0x54) {
        final text = _decodeTextRecord(record);
        if (text != null && _isCashuToken(text)) {
          return text;
        }
      }

      // URI Record
      if (record.typeNameFormat == TypeNameFormat.wellKnown &&
          record.type.length == 1 &&
          record.type[0] == 0x55) {
        final uri = _decodeUriRecord(record);
        if (uri != null) {
          final token = _extractTokenFromUri(uri);
          if (token != null) return token;
        }
      }
    }
    return null;
  }

  /// Decode NDEF Text Record payload.
  static String? _decodeTextRecord(NdefRecord record) {
    if (record.payload.isEmpty) return null;
    final languageCodeLength = record.payload[0] & 0x3F;
    if (record.payload.length <= 1 + languageCodeLength) return null;
    return String.fromCharCodes(
        record.payload.sublist(1 + languageCodeLength));
  }

  /// Decode NDEF URI Record payload.
  static String? _decodeUriRecord(NdefRecord record) {
    if (record.payload.isEmpty) return null;
    const prefixes = [
      '', // 0x00
      'http://www.', // 0x01
      'https://www.', // 0x02
      'http://', // 0x03
      'https://', // 0x04
    ];
    final prefixIndex = record.payload[0];
    final prefix = prefixIndex < prefixes.length ? prefixes[prefixIndex] : '';
    final rest = String.fromCharCodes(record.payload.sublist(1));
    return '$prefix$rest';
  }

  /// Extract token from a URL like https://wallet.com/#token=cashuA...
  static String? _extractTokenFromUri(String uri) {
    try {
      final parsed = Uri.parse(uri);
      final fragment = parsed.fragment;
      if (fragment.startsWith('token=')) {
        return fragment.substring(6);
      }
      final tokenParam = parsed.queryParameters['token'];
      if (tokenParam != null && _isCashuToken(tokenParam)) {
        return tokenParam;
      }
    } catch (_) {}
    return null;
  }

  /// Check if a string looks like a Cashu token.
  static bool _isCashuToken(String text) {
    final lower = text.toLowerCase().trim();
    return lower.startsWith('cashua') ||
        lower.startsWith('cashub') ||
        lower.startsWith('creqa');
  }
}
