import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pending_token.dart';

/// Storage para tokens Cashu pendientes de reclamar.
/// Usa SQLite para persistencia robusta con soporte para consultas complejas.
///
/// Características:
/// - Límite máximo de 50 tokens
/// - Expiración automática a 30 días
/// - Cache en memoria para acceso rápido
/// - Singleton para acceso global
class PendingTokenStorage {
  static const _dbName = 'pending_tokens.db';
  static const _tableName = 'pending_tokens';
  static const _maxTokens = 50;
  static const _expirationDays = 30;

  Database? _db;
  final Map<String, PendingToken> _cache = {};
  bool _isInitialized = false;

  /// Stream controller para notificar cambios
  StreamController<void> _changesController = StreamController<void>.broadcast();

  /// Stream de cambios para que la UI pueda reaccionar
  Stream<void> get changes => _changesController.stream;

  /// Singleton
  static final PendingTokenStorage _instance = PendingTokenStorage._internal();
  factory PendingTokenStorage() => _instance;
  PendingTokenStorage._internal();

  /// Verifica si está inicializado
  bool get isInitialized => _isInitialized;

  /// Cantidad de tokens pendientes
  int get count => _cache.length;

  /// Verifica si hay tokens pendientes
  bool get hasPendingTokens => _cache.isNotEmpty;

  /// Inicializa el storage. Llamar antes de usar.
  Future<void> init() async {
    if (_isInitialized) return;

    // Inicializar FFI para Linux/Windows
    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/$_dbName';

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            encoded TEXT NOT NULL,
            amount TEXT NOT NULL,
            mint_url TEXT NOT NULL,
            unit TEXT,
            saved_at INTEGER NOT NULL,
            memo TEXT,
            retry_count INTEGER DEFAULT 0,
            last_error TEXT,
            last_attempt INTEGER
          )
        ''');

        // Índices para consultas eficientes
        await db.execute(
          'CREATE INDEX idx_mint_url ON $_tableName(mint_url)',
        );
        await db.execute(
          'CREATE INDEX idx_saved_at ON $_tableName(saved_at)',
        );
      },
    );

    await _loadFromDb();
    await _cleanExpired();

    _isInitialized = true;
    debugPrint('PendingTokenStorage inicializado con ${_cache.length} tokens');
  }

  /// Carga todos los tokens desde la base de datos al cache
  Future<void> _loadFromDb() async {
    if (_db == null) return;

    final results = await _db!.query(
      _tableName,
      orderBy: 'saved_at DESC',
    );

    _cache.clear();
    for (final row in results) {
      final token = PendingToken.fromMap(row);
      _cache[token.id] = token;
    }
  }

  /// Agrega un token pendiente.
  /// Retorna el PendingToken creado o null si se alcanzó el límite.
  Future<PendingToken?> add({
    required String id,
    required String encoded,
    required BigInt amount,
    required String mintUrl,
    String? unit,
    String? memo,
  }) async {
    if (_db == null) {
      throw StateError('PendingTokenStorage no inicializado');
    }

    // Verificar límite
    if (_cache.length >= _maxTokens) {
      debugPrint('Límite de $_maxTokens tokens pendientes alcanzado');
      return null;
    }

    // Verificar si ya existe (mismo encoded)
    for (final existing in _cache.values) {
      if (existing.encoded == encoded) {
        debugPrint('Token ya existe en pending: ${existing.id}');
        return existing;
      }
    }

    final token = PendingToken(
      id: id,
      encoded: encoded,
      amount: amount,
      mintUrl: mintUrl,
      unit: unit,
      savedAt: DateTime.now(),
      memo: memo,
    );

    await _db!.insert(_tableName, token.toMap());
    _cache[id] = token;
    _notifyChanges();

    debugPrint('Token pendiente guardado: $id');
    return token;
  }

  /// Obtiene un token por ID
  PendingToken? get(String id) {
    return _cache[id];
  }

  /// Lista todos los tokens pendientes (ordenados por fecha, más reciente primero)
  List<PendingToken> listAll() {
    final tokens = _cache.values.toList();
    tokens.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return tokens;
  }

  /// Lista solo tokens válidos (no expirados)
  List<PendingToken> listValid() {
    return listAll().where((t) => !t.isExpired).toList();
  }

  /// Lista tokens por mint
  List<PendingToken> listByMint(String mintUrl) {
    return listAll().where((t) => t.mintUrl == mintUrl).toList();
  }

  /// Actualiza un token (para reintentos, errores, etc.)
  Future<void> update(PendingToken token) async {
    if (_db == null) return;
    if (!_cache.containsKey(token.id)) return;

    await _db!.update(
      _tableName,
      token.toMap(),
      where: 'id = ?',
      whereArgs: [token.id],
    );

    _cache[token.id] = token;
    _notifyChanges();
  }

  /// Registra un intento fallido de reclamo
  Future<void> recordFailedAttempt(String id, String error) async {
    final token = _cache[id];
    if (token == null) return;

    final updated = token.copyWith(
      retryCount: token.retryCount + 1,
      lastError: error,
      lastAttempt: DateTime.now(),
    );

    await update(updated);
  }

  /// Elimina un token por ID
  Future<void> remove(String id) async {
    if (_db == null) return;

    await _db!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    _cache.remove(id);
    _notifyChanges();

    debugPrint('Token pendiente eliminado: $id');
  }

  /// Limpia tokens expirados
  Future<int> cleanExpired() async {
    return await _cleanExpired();
  }

  Future<int> _cleanExpired() async {
    if (_db == null) return 0;

    final cutoff = DateTime.now()
        .subtract(const Duration(days: _expirationDays))
        .millisecondsSinceEpoch;

    final deleted = await _db!.delete(
      _tableName,
      where: 'saved_at < ?',
      whereArgs: [cutoff],
    );

    if (deleted > 0) {
      await _loadFromDb();
      _notifyChanges();
      debugPrint('Limpiados $deleted tokens expirados');
    }

    return deleted;
  }

  /// Elimina todos los tokens pendientes
  Future<void> clear() async {
    if (_db == null) return;

    await _db!.delete(_tableName);
    _cache.clear();
    _notifyChanges();

    debugPrint('Todos los tokens pendientes eliminados');
  }

  /// Notifica a los listeners de cambios
  void _notifyChanges() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

  /// Cierra la base de datos (llamar al cerrar la app si es necesario)
  Future<void> close() async {
    await _db?.close();
    _db = null;
    _isInitialized = false;
    await _changesController.close();
    // Recrear el controller para permitir re-inicialización del singleton
    _changesController = StreamController<void>.broadcast();
  }
}
