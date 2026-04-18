/// Estado del envío dentro del storage propio.
///
/// - [active]  : el receptor aún no reclamó; los proofs están PendingSpent
///               localmente. Mostrar con acción de cancelar/reclamar.
/// - [settled] : la reconciliación con el mint confirmó que los proofs
///               fueron gastados (receptor reclamó) o que una reconciliación
///               previa ya los procesó. Mostrar como tx saliente histórica,
///               sin acción de cancel.
enum PendingSendStatus {
  active,
  settled;

  String get wireName => name;

  static PendingSendStatus fromWire(String? raw) {
    switch (raw) {
      case 'settled':
        return PendingSendStatus.settled;
      case 'active':
      case null:
      default:
        return PendingSendStatus.active;
    }
  }
}

/// Modelo para rastrear envíos offline.
///
/// Los envíos offline no crean una Transaction en CDK (porque se hacen con
/// selección manual de proofs + createOfflineToken), por lo que necesitamos
/// un storage propio para poder mostrarlos en el historial y permitir
/// cancelar/reclamar por transacción.
///
/// Los proofs se identifican por sus Y values (hex) — mismos que acepta
/// Wallet.reclaimProofsByYs() en el bridge Rust.
class PendingSend {
  /// UUID único
  final String id;

  /// Token codificado completo (cashuA... o cashuB...)
  final String encoded;

  /// Monto total del envío (suma de los proofs)
  final BigInt amount;

  /// URL del mint
  final String mintUrl;

  /// Unidad (sat, usd, eur, etc.)
  final String unit;

  /// Y values de los proofs incluidos (hex). Se usan para reclamar.
  final List<String> proofYs;

  /// Fecha de creación del envío
  final DateTime createdAt;

  /// Memo opcional
  final String? memo;

  /// Estado del envío. Ver [PendingSendStatus].
  final PendingSendStatus status;

  /// Timestamp de cuando el envío pasó a [PendingSendStatus.settled].
  /// Null mientras esté activo. Se usa para ordenar en el historial.
  final DateTime? settledAt;

  PendingSend({
    required this.id,
    required this.encoded,
    required this.amount,
    required this.mintUrl,
    required this.unit,
    required List<String> proofYs,
    required this.createdAt,
    this.memo,
    this.status = PendingSendStatus.active,
    this.settledAt,
  }) : proofYs = List.unmodifiable(proofYs);

  bool get isActive => status == PendingSendStatus.active;
  bool get isSettled => status == PendingSendStatus.settled;

  /// Para ordenar en el historial: si está settled, usar settledAt; si no,
  /// usar createdAt.
  DateTime get effectiveTimestamp => settledAt ?? createdAt;

  PendingSend copyWith({
    String? id,
    String? encoded,
    BigInt? amount,
    String? mintUrl,
    String? unit,
    List<String>? proofYs,
    DateTime? createdAt,
    String? memo,
    PendingSendStatus? status,
    DateTime? settledAt,
  }) {
    return PendingSend(
      id: id ?? this.id,
      encoded: encoded ?? this.encoded,
      amount: amount ?? this.amount,
      mintUrl: mintUrl ?? this.mintUrl,
      unit: unit ?? this.unit,
      proofYs: proofYs ?? this.proofYs,
      createdAt: createdAt ?? this.createdAt,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encoded': encoded,
      'amount': amount.toString(),
      'mint_url': mintUrl,
      'unit': unit,
      'proof_ys': proofYs.join(','),
      'created_at': createdAt.millisecondsSinceEpoch,
      'memo': memo,
      'status': status.wireName,
      'settled_at': settledAt?.millisecondsSinceEpoch,
    };
  }

  factory PendingSend.fromMap(Map<String, dynamic> map) {
    final ysRaw = map['proof_ys'] as String? ?? '';
    final ys = ysRaw.isEmpty
        ? <String>[]
        : ysRaw.split(',').where((s) => s.isNotEmpty).toList();
    final settledAtRaw = map['settled_at'] as int?;
    return PendingSend(
      id: map['id'] as String,
      encoded: map['encoded'] as String,
      amount: BigInt.parse(map['amount'] as String),
      mintUrl: map['mint_url'] as String,
      unit: map['unit'] as String,
      proofYs: ys,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      memo: map['memo'] as String?,
      status: PendingSendStatus.fromWire(map['status'] as String?),
      settledAt: settledAtRaw == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(settledAtRaw),
    );
  }

  @override
  String toString() =>
      'PendingSend(id: $id, amount: $amount $unit, mintUrl: $mintUrl, ys: ${proofYs.length}, status: ${status.name})';
}
