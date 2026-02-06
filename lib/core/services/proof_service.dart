import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/proof.dart';

/// Servicio para acceder a los proofs locales en SQLite.
/// Permite leer proofs, crear tokens offline y actualizar estados.
class ProofService {
  Database? _db;
  static bool _ffiInitialized = false;

  /// Inicializa sqflite FFI para plataformas desktop (Linux, Windows, macOS).
  static void _initFfiIfNeeded() {
    if (_ffiInitialized) return;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      debugPrint('sqflite FFI initialized for desktop');
    }
    _ffiInitialized = true;
  }

  /// Obtiene la instancia de la base de datos.
  Future<Database> get database async {
    if (_db != null) return _db!;

    // Inicializar FFI para desktop
    _initFfiIfNeeded();

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/elcaju_wallet.sqlite';

    _db = await openDatabase(dbPath);
    return _db!;
  }

  /// Obtiene todos los proofs UNSPENT de un mint y unidad específicos.
  /// Ordenados de mayor a menor denominación.
  Future<List<LocalProof>> getUnspentProofs({
    required String mintUrl,
    required String unit,
  }) async {
    final db = await database;

    final rows = await db.query(
      'proof',
      where: 'mint_url = ? AND unit = ? AND state = ?',
      whereArgs: [mintUrl, unit, 'UNSPENT'],
      orderBy: 'amount DESC',
    );

    return rows.map((row) => LocalProof.fromSqlite(row)).toList();
  }

  /// Agrupa proofs por denominación.
  /// Retorna Map ordenado de mayor a menor.
  Map<BigInt, List<LocalProof>> groupByDenomination(List<LocalProof> proofs) {
    final grouped = <BigInt, List<LocalProof>>{};

    for (final proof in proofs) {
      grouped.putIfAbsent(proof.amount, () => []).add(proof);
    }

    // Ordenar por denominación descendente
    final sorted = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    return sorted;
  }

  /// Calcula el total de proofs seleccionados.
  BigInt calculateTotal(List<LocalProof> proofs) {
    return proofs.fold(BigInt.zero, (sum, p) => sum + p.amount);
  }

  /// Selecciona proofs que sumen exactamente el monto.
  /// Retorna null si no hay combinación exacta.
  List<LocalProof>? selectExactProofs(
    List<LocalProof> available,
    BigInt targetAmount,
  ) {
    final selected = <LocalProof>[];
    var remaining = targetAmount;

    // Ordenar de mayor a menor
    final sorted = List<LocalProof>.from(available)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // Greedy selection
    for (final proof in sorted) {
      if (remaining >= proof.amount) {
        selected.add(proof);
        remaining -= proof.amount;
      }
      if (remaining == BigInt.zero) break;
    }

    return remaining == BigInt.zero ? selected : null;
  }

  /// Marca proofs como PENDING_SPENT en la base de datos.
  Future<void> markProofsPendingSpent(List<LocalProof> proofs) async {
    final db = await database;

    await db.transaction((txn) async {
      for (final proof in proofs) {
        await txn.update(
          'proof',
          {'state': 'PENDING_SPENT'},
          where: 'y = ?',
          whereArgs: [proof.y],
        );
      }
    });

    debugPrint('Marked ${proofs.length} proofs as PENDING_SPENT');
  }

  /// Marca proofs como UNSPENT (para revertir si falla el envío).
  Future<void> markProofsUnspent(List<LocalProof> proofs) async {
    final db = await database;

    await db.transaction((txn) async {
      for (final proof in proofs) {
        await txn.update(
          'proof',
          {'state': 'UNSPENT'},
          where: 'y = ?',
          whereArgs: [proof.y],
        );
      }
    });

    debugPrint('Reverted ${proofs.length} proofs to UNSPENT');
  }

  /// Crea un token Cashu V3 desde proofs seleccionados.
  /// Formato: cashuA + base64(JSON)
  String createTokenV3({
    required String mintUrl,
    required List<LocalProof> proofs,
    String? memo,
    String? unit,
  }) {
    // Estructura del token V3
    final tokenData = <String, dynamic>{
      'token': [
        {
          'mint': mintUrl,
          'proofs': proofs.map((p) => p.toTokenProof()).toList(),
        }
      ],
    };

    // Agregar memo si existe
    if (memo != null && memo.isNotEmpty) {
      tokenData['memo'] = memo;
    }

    // Agregar unit si existe
    if (unit != null && unit.isNotEmpty) {
      tokenData['unit'] = unit;
    }

    // Codificar a JSON y luego base64
    final jsonStr = jsonEncode(tokenData);
    final base64Str = base64.encode(utf8.encode(jsonStr));

    return 'cashuA$base64Str';
  }

  /// Cierra la conexión a la base de datos.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
