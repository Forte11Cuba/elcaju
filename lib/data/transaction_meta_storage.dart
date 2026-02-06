import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Tipos de transacción
enum TransactionType {
  cashu,
  lightning,
}

/// Metadata adicional de una transacción.
/// Se usa para guardar datos que el CDK no persiste (token, invoice, tipo).
class TransactionMeta {
  final TransactionType type;
  final String? token;      // Solo para Cashu send
  final String? invoice;    // Solo para Lightning (mint/melt)
  final DateTime createdAt;

  TransactionMeta({
    required this.type,
    this.token,
    this.invoice,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'token': token,
    'invoice': invoice,
    'createdAt': createdAt.toIso8601String(),
  };

  factory TransactionMeta.fromJson(Map<String, dynamic> json) {
    return TransactionMeta(
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.cashu,
      ),
      token: json['token'] as String?,
      invoice: json['invoice'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

/// Storage para metadata de transacciones.
/// Complementa el historial del CDK con datos adicionales.
///
/// Uso:
/// ```dart
/// final storage = TransactionMetaStorage();
/// await storage.init();
///
/// // Guardar metadata
/// await storage.save('tx_123', TransactionMeta(type: TransactionType.cashu, token: 'cashuA...'));
///
/// // Obtener metadata
/// final meta = storage.get('tx_123');
/// ```
class TransactionMetaStorage {
  static const _storageKey = 'transaction_meta';

  SharedPreferences? _prefs;
  final Map<String, TransactionMeta> _cache = {};

  /// Singleton
  static final TransactionMetaStorage _instance = TransactionMetaStorage._internal();
  factory TransactionMetaStorage() => _instance;
  TransactionMetaStorage._internal();

  /// Inicializa el storage. Llamar antes de usar.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromDisk();
  }

  /// Carga datos desde SharedPreferences al cache en memoria.
  Future<void> _loadFromDisk() async {
    final jsonStr = _prefs?.getString(_storageKey);
    if (jsonStr == null || jsonStr.isEmpty) return;

    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      _cache.clear();

      for (final entry in decoded.entries) {
        _cache[entry.key] = TransactionMeta.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    } catch (e) {
      // Si hay error de parsing, empezar limpio
      _cache.clear();
    }
  }

  /// Guarda el cache en SharedPreferences.
  Future<void> _saveToDisk() async {
    final jsonMap = <String, dynamic>{};
    for (final entry in _cache.entries) {
      jsonMap[entry.key] = entry.value.toJson();
    }
    await _prefs?.setString(_storageKey, jsonEncode(jsonMap));
  }

  /// Guarda metadata para una transacción.
  Future<void> save(String transactionId, TransactionMeta meta) async {
    _cache[transactionId] = meta;
    await _saveToDisk();
  }

  /// Obtiene metadata de una transacción.
  TransactionMeta? get(String transactionId) {
    return _cache[transactionId];
  }

  /// Verifica si existe metadata para una transacción.
  bool has(String transactionId) {
    return _cache.containsKey(transactionId);
  }

  /// Elimina metadata de una transacción.
  Future<void> remove(String transactionId) async {
    _cache.remove(transactionId);
    await _saveToDisk();
  }

  /// Elimina todas las metadata.
  Future<void> clear() async {
    _cache.clear();
    await _prefs?.remove(_storageKey);
  }

  /// Obtiene el tipo de una transacción.
  /// Primero busca en metadata del CDK, luego en storage local.
  TransactionType getType(String transactionId, Map<String, String>? cdkMetadata) {
    // 1. Buscar en metadata del CDK
    final cdkType = cdkMetadata?['type'];
    if (cdkType == 'cashu') return TransactionType.cashu;
    if (cdkType == 'lightning') return TransactionType.lightning;

    // 2. Buscar en storage local
    final localMeta = get(transactionId);
    if (localMeta != null) return localMeta.type;

    // 3. Default: cashu (la mayoría de transacciones son cashu)
    return TransactionType.cashu;
  }

  /// Limpia entradas huérfanas (IDs que ya no existen en el CDK).
  /// Llamar periódicamente para no acumular basura.
  Future<int> cleanupOrphans(Set<String> validIds) async {
    final orphans = _cache.keys.where((id) => !validIds.contains(id)).toList();

    for (final id in orphans) {
      _cache.remove(id);
    }

    if (orphans.isNotEmpty) {
      await _saveToDisk();
    }

    return orphans.length;
  }
}
