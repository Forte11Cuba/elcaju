/// Peanut encoding/decoding for Cashu tokens.
///
/// Encodes Cashu tokens into invisible Unicode Variation Selectors
/// appended to a 🥜 emoji, compatible with cashu.me's implementation.
///
/// Each character of the base64 token is mapped to a Variation Selector:
/// - charCode 0-15  → VS1-VS16 (U+FE00 to U+FE0F)
/// - charCode 16-255 → VS17-VS256 (U+E0100 to U+E01EF)
class PeanutCodec {
  static const String _peanutEmoji = '🥜';

  /// Encodes a Cashu token string into peanut format (🥜 + variation selectors).
  static String encode(String token) {
    final buffer = StringBuffer(_peanutEmoji);

    for (int i = 0; i < token.length; i++) {
      final byte = token.codeUnitAt(i);

      if (byte < 16) {
        // VS1-VS16: U+FE00 to U+FE0F
        buffer.writeCharCode(0xFE00 + byte);
      } else if (byte < 256) {
        // VS17-VS256: U+E0100 to U+E01EF
        buffer.writeCharCode(0xE0100 + (byte - 16));
      }
    }

    return buffer.toString();
  }

  /// Decodes a peanut-encoded string back to the original Cashu token.
  /// Returns null if the input is not valid peanut format.
  static String? decode(String peanut) {
    if (!isPeanut(peanut)) return null;

    final buffer = StringBuffer();
    final runes = peanut.runes.toList();

    // Skip the first rune (🥜 emoji)
    for (int i = 1; i < runes.length; i++) {
      final codePoint = runes[i];

      if (codePoint >= 0xFE00 && codePoint <= 0xFE0F) {
        // VS1-VS16 → byte 0-15
        buffer.writeCharCode(codePoint - 0xFE00);
      } else if (codePoint >= 0xE0100 && codePoint <= 0xE01EF) {
        // VS17-VS256 → byte 16-255
        buffer.writeCharCode(codePoint - 0xE0100 + 16);
      }
      // Skip any other characters (whitespace, etc.)
    }

    final result = buffer.toString();
    return result.isNotEmpty ? result : null;
  }

  /// Returns true if the string starts with the 🥜 emoji.
  static bool isPeanut(String data) {
    return data.trimLeft().startsWith(_peanutEmoji);
  }
}
