/// Builds a BIP-321 unified payment URI.
///
/// Format: BITCOIN:?LIGHTNING=LNBC...&CREQ=CREQB1...
/// All uppercase for optimal QR encoding (alphanumeric mode).
///
/// Ref: NUT-26 "BIP-321 Integration" section.
String buildUnifiedUri({
  required String creqB,
  String? bolt11,
}) {
  final buffer = StringBuffer('bitcoin:?');
  if (bolt11 != null) {
    buffer.write('lightning=');
    buffer.write(bolt11.toUpperCase());
    buffer.write('&');
  }
  buffer.write('creq=');
  buffer.write(creqB.toUpperCase());
  return buffer.toString();
}
