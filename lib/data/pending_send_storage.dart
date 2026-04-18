import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pending_send.dart';

/// Storage persistente para envíos offline.
///
/// Los envíos offline no crean una Transaction en CDK, así que necesitamos
/// rastrearlos nosotros para poder:
///   - Mostrarlos en el historial como activos (cancelables) o como
///     liquidados (settled, display-only).
///   - Reclamar las proofs por transacción si el receptor no reclamó.
///
/// Mirrors PendingTokenStorage (singleton + cache + SQLite + change stream).
class PendingSendStorage {
  static const _dbName = 'pending_sends.db';
  static const _tableName = 'pending_sends';
  static const _schemaVersion = 2;

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
  int get activeCount =>
      _cache.values.where((s) => s.isActive).length;
  bool get hasActivePendingSends => activeCount > 0;

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
      version: _schemaVersion,
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
            memo TEXT,
            status TEXT NOT NULL DEFAULT 'active',
            settled_at INTEGER
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_ps_mint_unit ON $_tableName(mint_url, unit)',
        );
        await db.execute(
          'CREATE INDEX idx_ps_created_at ON $_tableName(created_at)',
        );
        await db.execute(
          'CREATE INDEX idx_ps_status ON $_tableName(status)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // v2: status + settled_at. Los records existentes quedan 'active'.
          await db.execute(
            "ALTER TABLE $_tableName ADD COLUMN status TEXT NOT NULL DEFAULT 'active'",
          );
          await db.execute(
            'ALTER TABLE $_tableName ADD COLUMN settled_at INTEGER',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_ps_status ON $_tableName(status)',
          );
        }
      },
    );

    await _loadFromDb();
    _isInitialized = true;
    debugPrint(
      'PendingSendStorage inicializado: ${_cache.length} envíos '
      '($activeCount activos)',
    );
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
      // status default = active
    );
    // Persistencia primero: si SQLite falla, la cache no queda contaminada
    // con un record que el reinicio no va a encontrar.
    await _db?.insert(_tableName, send.toMap());
    _cache[send.id] = send;
    _changesController.add(null);
    return send;
  }

  /// Marca un envío como liquidado (settled). Se usa cuando la reconciliación
  /// confirmó que el receptor reclamó o el envío ya no es actionable.
  /// Si no existe el record, no hace nada.
  Future<void> markSettled(String id) async {
    final current = _cache[id];
    if (current == null) return;
    if (current.isSettled) return; // idempotente
    final updated = current.copyWith(
      status: PendingSendStatus.settled,
      settledAt: DateTime.now(),
    );
    // Persistencia primero: si SQLite falla, la cache queda activa y un
    // próximo reconcile reintenta. Con el orden inverso, la idempotencia
    // (`isSettled → early return`) impediría el retry tras una falla.
    await _db?.update(
      _tableName,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    _cache[id] = updated;
    _changesController.add(null);
  }

  /// Borrado permanente. Reservado para "dismiss manual" (no implementado
  /// hoy en UI) o cleanup explícito del wallet (`clear`). Para el caso
  /// "receptor reclamó", usar `markSettled` en vez de este.
  Future<void> remove(String id) async {
    // Persistencia primero: igual que add/markSettled, la cache no se
    // adelanta al storage.
    await _db?.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    _cache.remove(id);
    _changesController.add(null);
  }

  List<PendingSend> listAll() {
    final list = _cache.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Envíos activos (el receptor aún no reclamó). Ordenados por creación
  /// descendente. Renderizables en el historial con botón cancel.
  List<PendingSend> listActive() {
    return _cache.values.where((s) => s.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Envíos liquidados (el receptor ya reclamó). Ordenados por `settledAt`
  /// descendente — representa la línea temporal de finalización.
  List<PendingSend> listSettled() {
    return _cache.values.where((s) => s.isSettled).toList()
      ..sort((a, b) => b.effectiveTimestamp.compareTo(a.effectiveTimestamp));
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
