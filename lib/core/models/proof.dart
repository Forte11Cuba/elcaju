import 'dart:typed_data';

/// Modelo de un proof Cashu local.
/// Representa una "nota" de ecash con una denominación específica.
class LocalProof {
  /// Primary key (Y point)
  final Uint8List y;

  /// URL del mint que emitió este proof
  final String mintUrl;

  /// Estado del proof
  final ProofState state;

  /// Unidad (sat, usd, eur)
  final String unit;

  /// Denominación (1, 2, 4, 8, 16, 32, 64, 128, 256, 512...)
  final BigInt amount;

  /// ID del keyset
  final String keysetId;

  /// Secret del proof
  final String secret;

  /// Signature (C point)
  final Uint8List c;

  /// Witness (opcional, para P2PK)
  final String? witness;

  /// DLEQ proof components (opcional)
  final Uint8List? dleqE;
  final Uint8List? dleqS;
  final Uint8List? dleqR;

  LocalProof({
    required this.y,
    required this.mintUrl,
    required this.state,
    required this.unit,
    required this.amount,
    required this.keysetId,
    required this.secret,
    required this.c,
    this.witness,
    this.dleqE,
    this.dleqS,
    this.dleqR,
  });

  /// Crea un LocalProof desde un row de SQLite.
  factory LocalProof.fromSqlite(Map<String, dynamic> row) {
    return LocalProof(
      y: row['y'] as Uint8List,
      mintUrl: row['mint_url'] as String,
      state: ProofState.fromString(row['state'] as String),
      unit: row['unit'] as String,
      amount: BigInt.from(row['amount'] as int),
      keysetId: row['keyset_id'] as String,
      secret: row['secret'] as String,
      c: row['c'] as Uint8List,
      witness: row['witness'] as String?,
      dleqE: row['dleq_e'] as Uint8List?,
      dleqS: row['dleq_s'] as Uint8List?,
      dleqR: row['dleq_r'] as Uint8List?,
    );
  }

  /// Convierte a formato JSON para token V3.
  Map<String, dynamic> toTokenProof() {
    final proof = <String, dynamic>{
      'id': keysetId,
      'amount': amount.toInt(),
      'secret': secret,
      'C': _bytesToHex(c),
    };

    // Agregar DLEQ si existe
    if (dleqE != null && dleqS != null) {
      proof['dleq'] = {
        'e': _bytesToHex(dleqE!),
        's': _bytesToHex(dleqS!),
        if (dleqR != null) 'r': _bytesToHex(dleqR!),
      };
    }

    // Agregar witness si existe
    if (witness != null && witness!.isNotEmpty) {
      proof['witness'] = witness;
    }

    return proof;
  }

  /// Convierte bytes a hex string.
  static String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Convierte Y a hex para identificación.
  String get yHex => _bytesToHex(y);

  @override
  String toString() => 'LocalProof(amount: $amount, unit: $unit, state: $state)';
}

/// Estados posibles de un proof.
enum ProofState {
  unspent,
  spent,
  pending,
  reserved,
  pendingSpent;

  static ProofState fromString(String s) {
    switch (s.toUpperCase()) {
      case 'UNSPENT':
        return ProofState.unspent;
      case 'SPENT':
        return ProofState.spent;
      case 'PENDING':
        return ProofState.pending;
      case 'RESERVED':
        return ProofState.reserved;
      case 'PENDING_SPENT':
        return ProofState.pendingSpent;
      default:
        return ProofState.unspent;
    }
  }

  String toSqlite() {
    switch (this) {
      case ProofState.unspent:
        return 'UNSPENT';
      case ProofState.spent:
        return 'SPENT';
      case ProofState.pending:
        return 'PENDING';
      case ProofState.reserved:
        return 'RESERVED';
      case ProofState.pendingSpent:
        return 'PENDING_SPENT';
    }
  }
}
