/// Utilidades para detección de P2PK en tokens Cashu
///
/// Soporta:
/// - Tokens V3 (cashuA - base64 JSON)
/// - Tokens V4 (cashuB - CBOR)
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:cbor/cbor.dart';

class P2PKUtils {
  /// Extrae la pubkey bloqueada de un token P2PK (si existe)
  /// Retorna null si el token no es P2PK o no se puede parsear
  static String? extractLockedPubkey(String encodedToken) {
    try {
      String token = encodedToken.trim();

      // Remover prefijo cashu: si existe
      if (token.startsWith('cashu:')) {
        token = token.substring(6);
      }

      if (token.startsWith('cashuA')) {
        return _extractFromV3(token);
      } else if (token.startsWith('cashuB')) {
        return _extractFromV4(token);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verifica si un token está bloqueado con P2PK
  static bool isP2PKLocked(String encodedToken) {
    return extractLockedPubkey(encodedToken) != null;
  }

  // ============ V3 TOKEN (cashuA - base64 JSON) ============

  static String? _extractFromV3(String token) {
    try {
      final base64Part = token.substring(6);
      final jsonStr = utf8.decode(base64.decode(base64Part));
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Estructura: { token: [{ proofs: [...] }] }
      final tokenList = data['token'] as List?;
      if (tokenList == null || tokenList.isEmpty) return null;

      final proofs = tokenList[0]['proofs'] as List?;
      if (proofs == null || proofs.isEmpty) return null;

      final secret = proofs[0]['secret'];
      return _parseP2PKSecret(secret);
    } catch (e) {
      return null;
    }
  }

  // ============ V4 TOKEN (cashuB - CBOR) ============

  static String? _extractFromV4(String token) {
    try {
      final cborPart = token.substring(6);
      // V4 usa base64url
      final bytes = base64Url.decode(_padBase64(cborPart));
      final decoded = cbor.decode(bytes);

      if (decoded is! CborMap) return null;

      // Estructura CBOR: { t: [{ p: [...] }] } o { p: [...] }
      final tokenData = decoded.toObject() as Map<dynamic, dynamic>;

      List<dynamic>? proofs;
      if (tokenData.containsKey('t')) {
        final t = tokenData['t'] as List?;
        if (t != null && t.isNotEmpty) {
          final firstToken = t[0];
          if (firstToken is Map) {
            proofs = firstToken['p'] as List?;
          }
        }
      } else if (tokenData.containsKey('p')) {
        proofs = tokenData['p'] as List?;
      }

      if (proofs == null || proofs.isEmpty) return null;

      final firstProof = proofs[0];
      if (firstProof is! Map) return null;

      final secret = firstProof['s'];
      return _parseP2PKSecret(secret);
    } catch (e) {
      return null;
    }
  }

  // ============ PARSER DE SECRET P2PK (NUT-10) ============

  /// Parsea el secret de un proof para extraer la pubkey P2PK
  /// Estructura P2PK: ["P2PK", { "nonce": "...", "data": "<pubkey>", "tags": [...] }]
  static String? _parseP2PKSecret(dynamic secret) {
    if (secret == null) return null;

    String secretStr;
    if (secret is String) {
      secretStr = secret;
    } else if (secret is List<int>) {
      // Uint8List también es List<int>, así que este branch cubre ambos
      secretStr = utf8.decode(secret);
    } else {
      return null;
    }

    try {
      final parsed = jsonDecode(secretStr);
      if (parsed is List && parsed.length >= 2 && parsed[0] == 'P2PK') {
        final data = parsed[1];
        if (data is Map && data.containsKey('data')) {
          final pubkey = data['data'];
          // Validar que sea hex de 64 chars (x-only) o 66 chars (SEC1 comprimido)
          if (pubkey is String &&
              (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(pubkey) ||
               RegExp(r'^0[23][0-9a-fA-F]{64}$').hasMatch(pubkey))) {
            return pubkey.toLowerCase();
          }
        }
      }
    } catch (e) {
      // No es P2PK o formato inválido
    }

    return null;
  }

  /// Agrega padding a base64url si es necesario
  static String _padBase64(String input) {
    final remainder = input.length % 4;
    if (remainder == 0) return input;
    return input + '=' * (4 - remainder);
  }
}
