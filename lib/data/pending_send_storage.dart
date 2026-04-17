import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pending_send.dart';

/// Storage persistente para envíos offline pendientes.
///
/// Los envíos offline no crean una Transaction en CDK, así que necesitamos
/// rastrearlos nosotros para poder:
///   - Mostrarlos en el historial como "pendientes de reclamo por el receptor".
///   - Reclamar las proofs por transacción si el receptor no reclamó.
///
/// Mirrors PendingTokenStorage (singleton + cache + SQLite + change stream).
class PendingSendStorage {
  static const _dbName = 'pending_sends.db';
  static const _tableName = 'pending_sends';

  Database? _db;
  final Map<String, PendingSend> _cache = {};
  bool _isInitialized = false;

  final StreamController<void> _changesController =
      StreamController<void>.broadcast();

  Stream<void> get changes => _changesController.stream;

  static final PendingSendStorage _instance = PendingSendStorage._internal();
  factory PendingSendStorage() => _instance;
  PendingSendStorage._internal();

  bool get isInitialized => _isInitialized;
  int get count => _cache.length;
  bool get hasPendingSends => _cache.isNotEmpty;

  Future<void> init() async {
    if (_isInitialized) return;

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
            unit TEXT NOT NULL,
            proof_ys TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            memo TEXT
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_ps_mint_unit ON $_tableName(mint_url, unit)',
        );
        await db.execute(
          'CREATE INDEX idx_ps_created_at ON $_tableName(created_at)',
        );
      },
    );

    await _loadFromDb();
    _isInitialized = true;
    debugPrint('PendingSendStorage inicializado con ${_cache.length} envíos');
  }

  Future<void> _loadFromDb() async {
    if (_db == null) return;
    final results = await _db!.query(_tableName, orderBy: 'created_at DESC');
    _cache.clear();
    for (final row in results) {
      final send = PendingSend.fromMap(row);
      _cache[send.id] = send;
    }
  }

  Future<PendingSend> add({
    required String id,
    required String encoded,
    required BigInt amount,
    required String mintUrl,
    required String unit,
    required List<String> proofYs,
    String? memo,
  }) async {
    final send = PendingSend(
      id: id,
      encoded: encoded,
      amount: amount,
      mintUrl: mintUrl,
      unit: unit,
      proofYs: proofYs,
      createdAt: DateTime.now(),
      memo: memo,
    );
    _cache[send.id] = send;
    await _db?.insert(_tableName, send.toMap());
    _changesController.add(null);
    return send;
  }

  Future<void> remove(String id) async {
    _cache.remove(id);
    await _db?.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    _changesController.add(null);
  }

  List<PendingSend> listAll() {
    final list = _cache.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  PendingSend? get(String id) => _cache[id];

  /// Filtra por mint+unit. Útil para mostrar pendientes específicos del
  /// wallet activo.
  List<PendingSend> listByMintUnit(String mintUrl, String unit) {
    return _cache.values
        .where((s) => s.mintUrl == mintUrl && s.unit == unit)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> clear() async {
    _cache.clear();
    await _db?.delete(_tableName);
    _changesController.add(null);
  }
}
