/// Utilidad para leer datos del SQLite de CDK.
/// Usado para:
/// - Debug de keyset counters
/// - Leer input_fee_ppk para cálculo de fees
/// - Contar proofs unspent para consolidación P2PK
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class KeysetDebug {
  static Database? _db;

  /// Abre la DB de CDK en modo solo lectura.
  static Future<Database> _getDb() async {
    if (_db != null && _db!.isOpen) return _db!;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/elcaju_wallet.sqlite';

    _db = await openDatabase(dbPath, readOnly: true);
    return _db!;
  }

  /// Lee todos los keysets con sus counters y los imprime.
  /// Retorna el counter del keyset activo (si hay uno).
  static Future<void> logCounters(String label) async {
    try {
      final db = await _getDb();

      final rows = await db.rawQuery(
        'SELECT id, unit, active, counter FROM keyset ORDER BY active DESC, unit ASC',
      );

      debugPrint('[COUNTER DEBUG] ===== $label =====');
      debugPrint('[COUNTER DEBUG] Total keysets: ${rows.length}');

      for (final row in rows) {
        final id = row['id'] as String?;
        final unit = row['unit'] as String?;
        final active = row['active'] as int?;
        final counter = row['counter'] as int?;
        final shortId = (id != null && id.length > 12) ? id.substring(0, 12) : id;

        debugPrint(
          '[COUNTER DEBUG]   keyset=$shortId  unit=$unit  active=$active  counter=$counter',
        );
      }
    } catch (e) {
      debugPrint('[COUNTER DEBUG] Error leyendo counters: $e');
    }
  }

  /// Lee el input_fee_ppk del keyset activo para un mint y unidad.
  /// Retorna 0 si no se encuentra o hay error.
  static Future<int> getInputFeePpk(String mintUrl, String unit) async {
    try {
      final db = await _getDb();
      final rows = await db.rawQuery(
        'SELECT input_fee_ppk FROM keyset WHERE active=1 AND unit=? AND mint_url=?',
        [unit, mintUrl],
      );
      if (rows.isEmpty) return 0;
      return (rows.first['input_fee_ppk'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[KEYSET DEBUG] Error leyendo input_fee_ppk: $e');
      return 0;
    }
  }

  /// Cuenta los proofs UNSPENT de un mint y unidad.
  /// Retorna 0 si no se encuentra o hay error.
  static Future<int> getUnspentProofCount(String mintUrl, String unit) async {
    try {
      final db = await _getDb();
      final rows = await db.rawQuery(
        'SELECT COUNT(*) as count FROM proof WHERE state=? AND mint_url=? AND unit=?',
        ['UNSPENT', mintUrl, unit],
      );
      if (rows.isEmpty) return 0;
      return (rows.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[KEYSET DEBUG] Error contando proofs: $e');
      return 0;
    }
  }

  /// Cierra la DB (llamar al final si es necesario).
  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
