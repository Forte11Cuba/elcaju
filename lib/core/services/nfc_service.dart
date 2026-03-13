import 'dart:typed_data';
import 'package:flutter/services.dart';
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
  static const _hceChannel = MethodChannel('me.elcaju/nfc_hce');

  // ─── HCE (phone-to-phone) ───

  /// Start emulating an NFC tag with the given text payload.
  /// The phone will appear as an NFC tag to other devices.
  static Future<void> startEmulating(String text) async {
    final ndefMessage = _buildNdefTextMessage(text);
    await _hceChannel.invokeMethod('setPayload', {'payload': ndefMessage});
  }

  /// Stop emulating an NFC tag.
  static Future<void> stopEmulating() async {
    await _hceChannel.invokeMethod('clearPayload');
  }

  /// Build an NDEF message with a Text Record.
  /// Uses Short Record (SR) for payloads ≤ 255 bytes,
  /// Long Record for > 255 bytes (compatible with Numo).
  static Uint8List _buildNdefTextMessage(String text) {
    final textBytes = Uint8List.fromList(text.codeUnits);
    final languageCode = Uint8List.fromList('en'.codeUnits);

    // NDEF Text Record payload: [status byte][lang code][text]
    final recordPayload = Uint8List(1 + languageCode.length + textBytes.length);
    recordPayload[0] = languageCode.length;
    recordPayload.setRange(1, 1 + languageCode.length, languageCode);
    recordPayload.setRange(1 + languageCode.length, recordPayload.length, textBytes);

    final payloadLength = recordPayload.length;
    final isShortRecord = payloadLength <= 255;

    if (isShortRecord) {
      // Short Record: flags(1) + typeLen(1) + payloadLen(1) + type(1) + payload
      final record = Uint8List(4 + payloadLength);
      record[0] = 0xD1; // MB|ME|SR|TNF=well-known
      record[1] = 1;    // type length
      record[2] = payloadLength;
      record[3] = 0x54; // 'T'
      record.setRange(4, 4 + payloadLength, recordPayload);
      return record;
    } else {
      // Long Record: flags(1) + typeLen(1) + payloadLen(4) + type(1) + payload
      final record = Uint8List(7 + payloadLength);
      record[0] = 0xC1; // MB|ME|TNF=well-known (no SR flag)
      record[1] = 1;    // type length
      record[2] = (payloadLength >> 24) & 0xFF;
      record[3] = (payloadLength >> 16) & 0xFF;
      record[4] = (payloadLength >> 8) & 0xFF;
      record[5] = payloadLength & 0xFF;
      record[6] = 0x54; // 'T'
      record.setRange(7, 7 + payloadLength, recordPayload);
      return record;
    }
  }

  // ─── Tag read/write ───

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
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          final ndef = NdefAndroid.from(tag);
          if (ndef == null || !ndef.isWritable) {
            onError('Tag is not writable');
            await NfcManager.instance.stopSession();
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
            await NfcManager.instance.stopSession();
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
            await NfcManager.instance.stopSession();
          } catch (e) {
            onError(e.toString());
            await NfcManager.instance.stopSession();
          }
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Stop any active NFC session.
  static Future<void> stopWrite() async {
    await NfcManager.instance.stopSession();
  }

  /// Start reading NFC tags for Cashu tokens.
  /// Tries IsoDep APDU first (phone-to-phone HCE, bypasses manufacturer
  /// NFC services), falls back to NDEF (physical tags).
  static Future<void> startRead({
    required void Function(String token) onTokenRead,
    required void Function(String error) onError,
  }) async {
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          try {
            final diagnostics = <String>[];

            // 1. Try IsoDep first (HCE phone-to-phone)
            final isoDep = IsoDepAndroid.from(tag);
            if (isoDep != null) {
              final (token, isoInfo) = await _readViaIsoDep(isoDep);
              if (token != null) {
                onTokenRead(token);
                await NfcManager.instance.stopSession();
                return;
              }
              diagnostics.add('IsoDep: $isoInfo');
            } else {
              diagnostics.add('IsoDep: not available');
            }

            // 2. Fallback: NDEF (physical tags)
            final ndef = NdefAndroid.from(tag);
            if (ndef != null) {
              final message = ndef.cachedNdefMessage ?? await ndef.getNdefMessage();
              if (message != null) {
                final token = _extractToken(message);
                if (token != null) {
                  onTokenRead(token);
                  await NfcManager.instance.stopSession();
                  return;
                }
                diagnostics.add('NDEF: ${message.records.length} records, no Cashu token');
              } else {
                diagnostics.add('NDEF: no message');
              }
            } else {
              diagnostics.add('NDEF: not available');
            }

            onError('No Cashu token found [${diagnostics.join('; ')}]');
            await NfcManager.instance.stopSession();
          } catch (e) {
            onError(e.toString());
            await NfcManager.instance.stopSession();
          }
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Read NDEF from HCE via IsoDep APDU commands (like Numo).
  /// Bypasses manufacturer NFC services (Xiaomi, Samsung, etc).
  /// Returns (token, diagnosticInfo) tuple.
  static Future<(String?, String)> _readViaIsoDep(IsoDepAndroid isoDep) async {
    String _hex(Uint8List bytes) =>
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

    try {
    // Set longer timeout (5s) to avoid TagLostException
    await isoDep.setTimeout(5000);

    // Try ElCaju proprietary AID first (avoids Xiaomi/Samsung conflicts)
    final selectElCaju = await isoDep.transceive(Uint8List.fromList([
      0x00, 0xA4, 0x04, 0x00, 0x07,
      0xF0, 0x45, 0x43, 0x41, 0x4A, 0x55, 0x00,
      0x00,
    ]));
    final bool elCajuSelected = _isOk(selectElCaju);

    // Fallback: standard NDEF Application AID
    if (!elCajuSelected) {
      final selectApp = await isoDep.transceive(Uint8List.fromList([
        0x00, 0xA4, 0x04, 0x00, 0x07,
        0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01,
        0x00,
      ]));
      if (!_isOk(selectApp)) {
        return (null, 'SELECT APP failed (both AIDs): elcaju=${_hex(selectElCaju)}, ndef=${_hex(selectApp)}');
      }
    }

    // SELECT NDEF file (E104)
    final selectNdef = await isoDep.transceive(Uint8List.fromList([
      0x00, 0xA4, 0x00, 0x0C, 0x02,
      0xE1, 0x04,
    ]));
    if (!_isOk(selectNdef)) {
      return (null, 'SELECT NDEF failed: ${_hex(selectNdef)}');
    }

    // READ NLEN (first 2 bytes)
    final nlenResponse = await isoDep.transceive(Uint8List.fromList([
      0x00, 0xB0, 0x00, 0x00, 0x02,
    ]));
    if (nlenResponse.length < 4 || !_isOk(nlenResponse)) {
      return (null, 'READ NLEN failed: ${_hex(nlenResponse)}');
    }

    final ndefLen = (nlenResponse[0] << 8) | nlenResponse[1];
    if (ndefLen == 0) {
      return (null, 'NLEN=0 (no payload set on emitter)');
    }

    // READ NDEF message in chunks (max 255 bytes per read)
    final ndefBytes = BytesBuilder();
    var offset = 2; // skip NLEN
    var remaining = ndefLen;

    while (remaining > 0) {
      final chunkSize = remaining > 255 ? 255 : remaining;
      final readCmd = Uint8List.fromList([
        0x00, 0xB0,
        (offset >> 8) & 0xFF,
        offset & 0xFF,
        chunkSize,
      ]);
      final chunk = await isoDep.transceive(readCmd);
      if (chunk.length < 2 || !_isOk(chunk)) {
        return (null, 'READ chunk at offset=$offset failed: ${_hex(chunk)}');
      }

      // Response = data + SW1 SW2 (last 2 bytes are status)
      ndefBytes.add(chunk.sublist(0, chunk.length - 2));
      final bytesRead = chunk.length - 2;
      offset += bytesRead;
      remaining -= bytesRead;
    }

    // Parse NDEF message from raw bytes
    final raw = ndefBytes.toBytes();
    if (raw.isEmpty) {
      return (null, 'read ${ndefLen}B but empty after parsing');
    }

    final token = _parseNdefAndExtractToken(Uint8List.fromList(raw));
    if (token != null) {
      return (token, 'OK');
    }
    return (null, 'NDEF parsed (${raw.length}B) but no Cashu token, hex: ${_hex(Uint8List.fromList(raw.length > 40 ? raw.sublist(0, 40) : raw))}...');

    } catch (e) {
      final msg = e.toString();
      if (msg.contains('TagLostException')) {
        return (null, 'connection lost (hold phones together longer)');
      }
      return (null, 'error: $msg');
    }
  }

  /// Check if APDU response ends with 90 00 (OK).
  static bool _isOk(Uint8List response) {
    if (response.length < 2) return false;
    return response[response.length - 2] == 0x90 &&
           response[response.length - 1] == 0x00;
  }

  /// Parse raw NDEF bytes and extract Cashu token.
  static String? _parseNdefAndExtractToken(Uint8List raw) {
    if (raw.isEmpty) return null;

    var pos = 0;
    while (pos < raw.length) {
      if (pos + 3 > raw.length) break;

      final flags = raw[pos];
      final tnf = flags & 0x07;
      final isShortRecord = (flags & 0x10) != 0;
      final hasIdLength = (flags & 0x08) != 0;

      pos++;
      final typeLength = raw[pos]; pos++;

      int payloadLength;
      if (isShortRecord) {
        payloadLength = raw[pos]; pos++;
      } else {
        if (pos + 4 > raw.length) break;
        payloadLength = (raw[pos] << 24) | (raw[pos+1] << 16) |
                        (raw[pos+2] << 8) | raw[pos+3];
        pos += 4;
      }

      int idLength = 0;
      if (hasIdLength) {
        idLength = raw[pos]; pos++;
      }

      // Type
      if (pos + typeLength > raw.length) break;
      final type = raw.sublist(pos, pos + typeLength); pos += typeLength;

      // ID (skip)
      pos += idLength;

      // Payload
      if (pos + payloadLength > raw.length) break;
      final payload = raw.sublist(pos, pos + payloadLength);
      pos += payloadLength;

      // Check: Text Record (TNF=0x01, type='T')
      if (tnf == 0x01 && typeLength == 1 && type[0] == 0x54) {
        if (payload.isNotEmpty) {
          final langLen = payload[0] & 0x3F;
          if (payload.length > 1 + langLen) {
            final text = String.fromCharCodes(payload.sublist(1 + langLen));
            if (_isCashuToken(text)) return text;
          }
        }
      }

      // Check: URI Record (TNF=0x01, type='U')
      if (tnf == 0x01 && typeLength == 1 && type[0] == 0x55) {
        if (payload.isNotEmpty) {
          const prefixes = ['', 'http://www.', 'https://www.', 'http://', 'https://'];
          final prefixIdx = payload[0];
          final prefix = prefixIdx < prefixes.length ? prefixes[prefixIdx] : '';
          final rest = String.fromCharCodes(payload.sublist(1));
          final uri = '$prefix$rest';
          final token = _extractTokenFromUri(uri);
          if (token != null) return token;
        }
      }

      // If ME (Message End) flag set, stop
      if ((flags & 0x40) != 0) break;
    }

    return null;
  }

  /// Stop any active NFC read session.
  static Future<void> stopRead() async {
    await NfcManager.instance.stopSession();
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
        final token = fragment.substring(6);
        if (_isCashuToken(token)) return token;
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
