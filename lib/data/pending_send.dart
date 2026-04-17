/// Modelo para rastrear envíos offline pendientes.
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

  PendingSend({
    required this.id,
    required this.encoded,
    required this.amount,
    required this.mintUrl,
    required this.unit,
    required this.proofYs,
    required this.createdAt,
    this.memo,
  });

  PendingSend copyWith({
    String? id,
    String? encoded,
    BigInt? amount,
    String? mintUrl,
    String? unit,
    List<String>? proofYs,
    DateTime? createdAt,
    String? memo,
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
    };
  }

  factory PendingSend.fromMap(Map<String, dynamic> map) {
    final ysRaw = map['proof_ys'] as String? ?? '';
    final ys = ysRaw.isEmpty
        ? <String>[]
        : ysRaw.split(',').where((s) => s.isNotEmpty).toList();
    return PendingSend(
      id: map['id'] as String,
      encoded: map['encoded'] as String,
      amount: BigInt.parse(map['amount'] as String),
      mintUrl: map['mint_url'] as String,
      unit: map['unit'] as String,
      proofYs: ys,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      memo: map['memo'] as String?,
    );
  }

  @override
  String toString() =>
      'PendingSend(id: $id, amount: $amount $unit, mintUrl: $mintUrl, ys: ${proofYs.length})';
}
