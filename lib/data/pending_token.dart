/// Modelo de datos para tokens Cashu pendientes de reclamar.
/// Almacena tokens que el usuario quiere guardar para reclamar después.
class PendingToken {
  /// UUID único del token pendiente
  final String id;

  /// Token codificado completo (cashuA... o cashuB...)
  final String encoded;

  /// Monto del token en la unidad base
  final BigInt amount;

  /// URL del mint que emitió el token
  final String mintUrl;

  /// Unidad detectada del token (sat, usd, eur, etc.)
  final String? unit;

  /// Fecha en que se guardó el token
  final DateTime savedAt;

  /// Memo opcional del token
  final String? memo;

  /// Número de intentos fallidos de reclamo
  final int retryCount;

  /// Último error al intentar reclamar
  final String? lastError;

  /// Fecha del último intento de reclamo
  final DateTime? lastAttempt;

  PendingToken({
    required this.id,
    required this.encoded,
    required this.amount,
    required this.mintUrl,
    this.unit,
    required this.savedAt,
    this.memo,
    this.retryCount = 0,
    this.lastError,
    this.lastAttempt,
  });

  /// Verifica si el token ha expirado (30 días)
  bool get isExpired =>
      savedAt.add(const Duration(days: 30)).isBefore(DateTime.now());

  /// Días restantes antes de expirar
  int get daysRemaining {
    final expiresAt = savedAt.add(const Duration(days: 30));
    final remaining = expiresAt.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Verifica si el token tiene errores de reclamo
  bool get hasError => lastError != null && lastError!.isNotEmpty;

  /// Crea una copia con campos actualizados
  PendingToken copyWith({
    String? id,
    String? encoded,
    BigInt? amount,
    String? mintUrl,
    String? unit,
    DateTime? savedAt,
    String? memo,
    int? retryCount,
    String? lastError,
    DateTime? lastAttempt,
  }) {
    return PendingToken(
      id: id ?? this.id,
      encoded: encoded ?? this.encoded,
      amount: amount ?? this.amount,
      mintUrl: mintUrl ?? this.mintUrl,
      unit: unit ?? this.unit,
      savedAt: savedAt ?? this.savedAt,
      memo: memo ?? this.memo,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      lastAttempt: lastAttempt ?? this.lastAttempt,
    );
  }

  /// Convierte a Map para persistencia SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'encoded': encoded,
      'amount': amount.toString(),
      'mint_url': mintUrl,
      'unit': unit,
      'saved_at': savedAt.millisecondsSinceEpoch,
      'memo': memo,
      'retry_count': retryCount,
      'last_error': lastError,
      'last_attempt': lastAttempt?.millisecondsSinceEpoch,
    };
  }

  /// Crea desde Map de SQLite
  factory PendingToken.fromMap(Map<String, dynamic> map) {
    return PendingToken(
      id: map['id'] as String,
      encoded: map['encoded'] as String,
      amount: BigInt.parse(map['amount'] as String),
      mintUrl: map['mint_url'] as String,
      unit: map['unit'] as String?,
      savedAt: DateTime.fromMillisecondsSinceEpoch(map['saved_at'] as int),
      memo: map['memo'] as String?,
      retryCount: map['retry_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
      lastAttempt: map['last_attempt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_attempt'] as int)
          : null,
    );
  }

  @override
  String toString() {
    return 'PendingToken(id: $id, amount: $amount, unit: $unit, mintUrl: $mintUrl, daysRemaining: $daysRemaining)';
  }
}
