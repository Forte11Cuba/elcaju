/// Provider para gestión de claves P2PK
///
/// Funcionalidades:
/// - Derivar clave principal desde mnemonic (NIP-06)
/// - Importar claves adicionales via nsec
/// - Detectar tokens P2PK bloqueados
/// - Verificar si podemos desbloquear un token
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:cdk_flutter/cdk_flutter.dart' as cdk;
import 'package:uuid/uuid.dart';

import '../models/p2pk_key.dart';
import '../core/utils/nostr_utils.dart';
import '../core/utils/p2pk_utils.dart';

/// Códigos de error para operaciones P2PK
enum P2PKErrorCode {
  maxKeysReached,
  invalidNsec,
  keyAlreadyExists,
  keyNotFound,
  cannotDeletePrimaryKey,
}

/// Excepción tipada para errores P2PK (traducir en UI con L10n)
class P2PKException implements Exception {
  final P2PKErrorCode code;

  const P2PKException(this.code);

  @override
  String toString() => 'P2PKException: $code';
}

class P2PKProvider extends ChangeNotifier {
  static const _storageKey = 'p2pk_keys';
  static const _maxImportedKeys = 10;

  final FlutterSecureStorage _secureStorage;

  List<P2PKKey> _keys = [];
  P2PKKey? _primaryKey;
  bool _isInitialized = false;

  P2PKProvider({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ============ GETTERS ============

  /// Todas las claves (principal + importadas)
  List<P2PKKey> get keys => List.unmodifiable(_keys);

  /// Clave principal derivada del mnemonic
  P2PKKey? get primaryKey => _primaryKey;

  /// Solo claves importadas (no derivadas)
  List<P2PKKey> get importedKeys =>
      _keys.where((k) => !k.isDerived).toList();

  /// Si el provider está inicializado
  bool get isInitialized => _isInitialized;

  /// Cantidad de claves importadas
  int get importedCount => importedKeys.length;

  /// Si se pueden importar más claves
  bool get canImportMore => importedCount < _maxImportedKeys;

  // ============ INICIALIZACIÓN ============

  /// Inicializa el provider derivando la clave principal del mnemonic
  Future<void> initialize(String mnemonic) async {
    // Cargar claves guardadas
    await _loadKeys();

    // Siempre derivar para comparar con la almacenada
    final derived = await _deriveFromMnemonic(mnemonic);

    if (_primaryKey == null) {
      // Primera vez: guardar clave derivada
      _primaryKey = derived;
      _keys.insert(0, _primaryKey!);
      await _saveKeys();
    } else if (_primaryKey!.publicKey != derived.publicKey) {
      // Mnemonic cambió (ej: wallet restore) — reemplazar clave primaria
      _keys.removeWhere((k) => k.isDerived);
      _primaryKey = derived;
      _keys.insert(0, _primaryKey!);
      await _saveKeys();
    }

    _isInitialized = true;
    notifyListeners();

    debugPrint('[P2PKProvider] Inicializado con ${_keys.length} claves');
    debugPrint('[P2PKProvider] Clave principal: ${_primaryKey?.npub.substring(0, 20)}...');
  }

  // ============ GESTIÓN DE CLAVES ============

  /// Importa una clave desde nsec
  Future<P2PKKey> importFromNsec(String nsec, String label) async {
    if (!canImportMore) {
      throw const P2PKException(P2PKErrorCode.maxKeysReached);
    }

    // Limpiar input
    String cleanNsec = nsec.trim();
    if (cleanNsec.startsWith('nostr:')) {
      cleanNsec = cleanNsec.substring(6);
    }

    final privateKeyHex = NostrUtils.nsecToHex(cleanNsec);
    if (privateKeyHex == null) {
      throw const P2PKException(P2PKErrorCode.invalidNsec);
    }

    // Obtener pubkey usando cdk-flutter
    final publicKeyHex = cdk.getPubKey(secret: privateKeyHex);

    // Verificar que no exista ya
    if (_keys.any((k) => k.publicKey == publicKeyHex)) {
      throw const P2PKException(P2PKErrorCode.keyAlreadyExists);
    }

    final key = P2PKKey(
      id: const Uuid().v4(),
      publicKey: publicKeyHex,
      privateKey: privateKeyHex,
      isDerived: false,
      label: label.isEmpty ? 'Importada ${importedCount + 1}' : label,
      createdAt: DateTime.now(),
    );

    _keys.add(key);
    await _saveKeys();
    notifyListeners();

    debugPrint('[P2PKProvider] Clave importada: ${key.npub.substring(0, 20)}...');
    return key;
  }

  /// Elimina una clave importada (no la principal)
  Future<void> removeKey(String keyId) async {
    final key = _keys.cast<P2PKKey?>().firstWhere(
          (k) => k?.id == keyId,
          orElse: () => null,
        );

    if (key == null) {
      throw const P2PKException(P2PKErrorCode.keyNotFound);
    }

    if (key.isDerived) {
      throw const P2PKException(P2PKErrorCode.cannotDeletePrimaryKey);
    }

    _keys.removeWhere((k) => k.id == keyId);
    await _saveKeys();
    notifyListeners();

    debugPrint('[P2PKProvider] Clave eliminada: $keyId');
  }

  /// Actualiza el label de una clave
  Future<void> updateLabel(String keyId, String newLabel) async {
    final index = _keys.indexWhere((k) => k.id == keyId);
    if (index < 0) return;

    _keys[index] = _keys[index].copyWith(label: newLabel);
    await _saveKeys();
    notifyListeners();
  }

  // ============ DETECCIÓN DE TOKENS P2PK ============

  /// Verifica si un token está bloqueado con P2PK
  bool isTokenLocked(String encodedToken) {
    return P2PKUtils.isP2PKLocked(encodedToken);
  }

  /// Verifica si un token está bloqueado para alguna de nuestras claves
  bool isTokenLockedToUs(String encodedToken) {
    final lockedPubkey = P2PKUtils.extractLockedPubkey(encodedToken);
    if (lockedPubkey == null) return false;

    // Normalizar a x-only (64 chars) para comparación
    final normalizedLocked = _normalizeToXOnly(lockedPubkey);
    return _keys.any((k) => _normalizeToXOnly(k.publicKey) == normalizedLocked);
  }

  /// Obtiene la clave privada para desbloquear un token
  /// Prueba todas las claves automáticamente
  String? getPrivateKeyForToken(String encodedToken) {
    final lockedPubkey = P2PKUtils.extractLockedPubkey(encodedToken);
    if (lockedPubkey == null) return null;

    // Normalizar a x-only (64 chars) para comparación
    final normalizedLocked = _normalizeToXOnly(lockedPubkey);
    final key = _keys.cast<P2PKKey?>().firstWhere(
          (k) => k != null && _normalizeToXOnly(k.publicKey) == normalizedLocked,
          orElse: () => null,
        );

    return key?.privateKey;
  }

  /// Normaliza pubkey a formato x-only (64 chars) para comparación
  /// Si es SEC1 (66 chars con prefijo 02/03), quita el prefijo
  String _normalizeToXOnly(String pubkey) {
    final lower = pubkey.toLowerCase();
    if (lower.length == 66 && (lower.startsWith('02') || lower.startsWith('03'))) {
      return lower.substring(2);
    }
    return lower;
  }

  /// Extrae la pubkey bloqueada de un token
  String? extractLockedPubkey(String encodedToken) {
    return P2PKUtils.extractLockedPubkey(encodedToken);
  }

  // ============ VALIDACIONES ============

  /// Valida si un input es una pubkey válida (npub o hex)
  bool isValidPubkey(String input) {
    return NostrUtils.isValidPubkey(input);
  }

  /// Normaliza input (npub/hex/nostr:npub) a hex
  String? normalizeToHex(String input) {
    return NostrUtils.normalizeToHex(input);
  }

  // ============ MÉTODOS PRIVADOS ============

  /// Deriva la clave principal del mnemonic usando NIP-06
  /// Path: m/44'/1237'/0'/0/0
  Future<P2PKKey> _deriveFromMnemonic(String mnemonic) async {
    // 1. Mnemonic -> Seed (64 bytes) usando cdk-flutter
    final seed = cdk.mnemonicToSeed(mnemonic: mnemonic);

    // 2. Seed -> BIP32 root
    final root = bip32.BIP32.fromSeed(seed);

    // 3. Derivar con path NIP-06: m/44'/1237'/0'/0/0
    final child = root.derivePath("m/44'/1237'/0'/0/0");

    // 4. Obtener private key hex
    final privateKeyHex = _bytesToHex(child.privateKey!);

    // 5. Obtener public key usando cdk-flutter
    final publicKeyHex = cdk.getPubKey(secret: privateKeyHex);

    return P2PKKey(
      id: 'primary',
      publicKey: publicKeyHex,
      privateKey: privateKeyHex,
      isDerived: true,
      label: 'Principal',
      createdAt: DateTime.now(),
    );
  }

  Future<void> _loadKeys() async {
    try {
      final json = await _secureStorage.read(key: _storageKey);
      if (json != null) {
        final List<dynamic> list = jsonDecode(json);
        _keys = list.map((e) => P2PKKey.fromJson(e as Map<String, dynamic>)).toList();
        _primaryKey = _keys.cast<P2PKKey?>().firstWhere(
              (k) => k?.isDerived == true,
              orElse: () => null,
            );
      }
    } catch (e) {
      debugPrint('[P2PKProvider] Error cargando claves: $e');
      _keys = [];
      _primaryKey = null;
    }
  }

  Future<void> _saveKeys() async {
    final json = jsonEncode(_keys.map((k) => k.toJson()).toList());
    await _secureStorage.write(key: _storageKey, value: json);
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Limpia todas las claves (usado al borrar wallet)
  Future<void> clear() async {
    _keys = [];
    _primaryKey = null;
    _isInitialized = false;
    await _secureStorage.delete(key: _storageKey);
    notifyListeners();
    debugPrint('[P2PKProvider] Claves eliminadas');
  }
}
