import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Helper class para info de token parseado
class TokenInfo {
  final BigInt amount;
  final String mintUrl;
  final String encoded;

  TokenInfo({
    required this.amount,
    required this.mintUrl,
    required this.encoded,
  });
}

/// Provider que gestiona todas las operaciones del wallet Cashu.
/// Soporta múltiples unidades (sat, usd, eur) por mint.
/// Usa múltiples instancias de Wallet compartiendo una sola DB.
class WalletProvider extends ChangeNotifier {
  WalletDatabase? _db;
  String? _mnemonic;

  /// Mints conocidos con sus unidades soportadas.
  /// Ejemplo: {'mint.cubabitcoin.org': ['sat', 'usd']}
  final Map<String, List<String>> _mintUnits = {};

  /// Wallets por mint:unidad (lazy loading).
  /// Clave: 'mintUrl:unit', Ejemplo: 'https://mint.cubabitcoin.org:sat'
  final Map<String, Wallet> _wallets = {};

  /// Mint activo actualmente
  String? _activeMintUrl;

  /// Unidad activa actualmente
  String _activeUnit = 'sat';

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isInitialized => _db != null && _mnemonic != null;
  String? get activeMintUrl => _activeMintUrl;
  String get activeUnit => _activeUnit;

  /// Unidades soportadas por el mint activo
  List<String> get activeUnits => _mintUnits[_activeMintUrl] ?? ['sat'];

  /// Wallet activo (mint + unidad actuales)
  Wallet? get activeWallet {
    if (_activeMintUrl == null) return null;
    final key = '$_activeMintUrl:$_activeUnit';
    return _wallets[key];
  }

  /// Todos los wallets creados (para verificación de proofs)
  Iterable<Wallet> get allWallets => _wallets.values;

  /// Lista de URLs de mints conocidos
  List<String> get mintUrls => _mintUnits.keys.toList();

  // ============================================================
  // INICIALIZACION
  // ============================================================

  /// Inicializa el provider con un mnemonic.
  /// Carga mints y unidades desde la información guardada.
  Future<void> initialize(String mnemonic) async {
    _mnemonic = mnemonic;

    // Obtener directorio de documentos (path absoluto requerido)
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/elcaju_wallet.sqlite';

    // Crear base de datos (se crea automáticamente si no existe)
    _db = await WalletDatabase.newInstance(path: dbPath);

    // Verificar si es primera vez
    // Creamos un wallet temporal para ver si hay mints guardados
    final tempWallet = Wallet(
      mintUrl: 'https://mint.cubabitcoin.org',
      unit: 'sat',
      mnemonic: mnemonic,
      db: _db!,
    );

    // Intentar obtener balance - si tiene datos, ya fue inicializado antes
    try {
      final balance = await tempWallet.balance();

      // Si llegamos aquí, el mint existe en la DB
      // Agregar mint por defecto con sus unidades
      await _detectAndAddMint('https://mint.cubabitcoin.org');

      // Guardar el wallet
      _wallets['https://mint.cubabitcoin.org:sat'] = tempWallet;

      // Establecer como activo
      _activeMintUrl = 'https://mint.cubabitcoin.org';
      _activeUnit = 'sat';

      // Si tiene balance > 0, definitivamente existía
      if (balance > BigInt.zero) {
        debugPrint('Wallet restaurado con balance: $balance');
      }
    } catch (e) {
      // Primera vez - agregar mint por defecto
      await addMint('https://mint.cubabitcoin.org');
    }

    notifyListeners();
  }

  /// Detecta si es primera vez (sin mints conocidos).
  bool isFirstTime() {
    return _mintUnits.isEmpty;
  }

  /// Genera un nuevo mnemonic de 12 palabras BIP39.
  String generateNewMnemonic() {
    return generateMnemonic();
  }

  // ============================================================
  // WALLET MANAGEMENT (Lazy Loading)
  // ============================================================

  /// Obtiene o crea un wallet para un mint y unidad específicos.
  /// Implementa lazy loading - solo crea el wallet cuando se necesita.
  Future<Wallet> getWallet(String mintUrl, String unit) async {
    if (_db == null || _mnemonic == null) {
      throw Exception('WalletProvider no inicializado');
    }

    final key = '$mintUrl:$unit';

    if (!_wallets.containsKey(key)) {
      _wallets[key] = Wallet(
        mintUrl: mintUrl,
        unit: unit,
        mnemonic: _mnemonic!,
        db: _db!,
      );
    }

    return _wallets[key]!;
  }

  /// Obtiene el wallet activo, creándolo si no existe.
  Future<Wallet> getActiveWallet() async {
    if (_activeMintUrl == null) {
      throw Exception('No hay mint activo');
    }
    return await getWallet(_activeMintUrl!, _activeUnit);
  }

  // ============================================================
  // MULTI-MINT OPERATIONS
  // ============================================================

  /// Detecta las unidades soportadas por un mint y las registra.
  /// Usa mintInfo.nuts.nut04 (MintMethodSettings) para obtener las unidades.
  Future<List<String>> _detectAndAddMint(String mintUrl) async {
    try {
      // Obtener info del mint (función global de cdk_flutter)
      final mintInfo = await getMintInfo(mintUrl: mintUrl);

      // Extraer unidades de nut04 (mint methods)
      final units = <String>{};

      // nut04 contiene los métodos de mint con sus unidades
      final nut04 = mintInfo.nuts.nut04;
      for (final method in nut04.methods) {
        units.add(method.unit);
      }

      // Si no hay unidades detectadas, usar 'sat' por defecto
      final unitList = units.isEmpty ? ['sat'] : units.toList();

      // Ordenar: sat primero, luego alfabético
      unitList.sort((a, b) {
        if (a == 'sat') return -1;
        if (b == 'sat') return 1;
        return a.compareTo(b);
      });

      _mintUnits[mintUrl] = unitList;
      return unitList;
    } catch (e) {
      debugPrint('Error detectando unidades de $mintUrl: $e');
      // Fallback a sat
      _mintUnits[mintUrl] = ['sat'];
      return ['sat'];
    }
  }

  /// Agrega un mint, detectando automáticamente sus unidades.
  Future<void> addMint(String mintUrl) async {
    if (_db == null || _mnemonic == null) {
      throw Exception('WalletProvider no inicializado');
    }

    // Detectar unidades
    final units = await _detectAndAddMint(mintUrl);

    // Crear wallet para la primera unidad
    await getWallet(mintUrl, units.first);

    // Activar si es el primer mint
    _activeMintUrl ??= mintUrl;
    if (_activeMintUrl == mintUrl) {
      _activeUnit = units.first;
    }

    notifyListeners();
  }

  /// Refresca la información de un mint (keysets, unidades).
  /// Útil para detectar nuevas unidades agregadas por el mint.
  Future<List<String>> refreshMint(String mintUrl) async {
    final units = await _detectAndAddMint(mintUrl);
    notifyListeners();
    return units;
  }

  /// Obtiene las unidades soportadas por un mint.
  List<String> getUnitsForMint(String mintUrl) {
    return _mintUnits[mintUrl] ?? ['sat'];
  }

  /// Lista los mints conocidos con sus unidades.
  Map<String, List<String>> listMintsWithUnits() {
    return Map.unmodifiable(_mintUnits);
  }

  /// Remueve un mint y todos sus wallets asociados.
  /// Nota: Si hay balance, el usuario puede recuperarlo después con restore (NUT-13).
  Future<void> removeMint(String mintUrl) async {
    // Eliminar wallets de este mint
    final keysToRemove = _wallets.keys
        .where((key) => key.startsWith('$mintUrl:'))
        .toList();
    for (final key in keysToRemove) {
      _wallets.remove(key);
    }

    // Eliminar de mints conocidos
    _mintUnits.remove(mintUrl);

    // Si era el mint activo, cambiar a otro
    if (_activeMintUrl == mintUrl) {
      if (_mintUnits.isNotEmpty) {
        final newMint = _mintUnits.keys.first;
        _activeMintUrl = newMint;
        _activeUnit = _mintUnits[newMint]!.first;
      } else {
        _activeMintUrl = null;
        _activeUnit = 'sat';
      }
    }

    notifyListeners();
  }

  // ============================================================
  // ACTIVE MINT/UNIT SELECTION
  // ============================================================

  /// Cambia el mint activo.
  Future<void> setActiveMint(String mintUrl) async {
    if (!_mintUnits.containsKey(mintUrl)) {
      throw Exception('Mint no conocido: $mintUrl');
    }

    _activeMintUrl = mintUrl;

    // Si la unidad activa no está soportada por este mint, cambiar a la primera
    final units = _mintUnits[mintUrl]!;
    if (!units.contains(_activeUnit)) {
      _activeUnit = units.first;
    }

    // Asegurar que el wallet existe
    await getWallet(mintUrl, _activeUnit);

    notifyListeners();
  }

  /// Cambia la unidad activa.
  Future<void> setActiveUnit(String unit) async {
    if (_activeMintUrl == null) return;

    final units = _mintUnits[_activeMintUrl]!;
    if (!units.contains(unit)) {
      throw Exception('Unidad $unit no soportada por el mint activo');
    }

    _activeUnit = unit;

    // Asegurar que el wallet existe
    await getWallet(_activeMintUrl!, unit);

    notifyListeners();
  }

  /// Cicla a la siguiente unidad del mint activo.
  /// Orden: sat → usd → eur → sat ...
  Future<void> cycleUnit() async {
    if (_activeMintUrl == null) return;

    final units = activeUnits;
    if (units.length <= 1) return;

    final currentIndex = units.indexOf(_activeUnit);
    final nextIndex = (currentIndex + 1) % units.length;

    await setActiveUnit(units[nextIndex]);
  }

  // ============================================================
  // BALANCE
  // ============================================================

  /// Stream de balance del wallet activo (reactivo).
  Stream<BigInt>? streamBalance() {
    return activeWallet?.streamBalance();
  }

  /// Obtiene el balance del wallet activo.
  Future<BigInt> getBalance() async {
    final wallet = activeWallet;
    if (wallet == null) return BigInt.zero;
    return await wallet.balance();
  }

  /// Obtiene el balance de un mint en una unidad específica.
  Future<BigInt> getBalanceForMintUnit(String mintUrl, String unit) async {
    final key = '$mintUrl:$unit';
    final wallet = _wallets[key];
    if (wallet == null) {
      // Crear wallet si no existe
      final newWallet = await getWallet(mintUrl, unit);
      return await newWallet.balance();
    }
    return await wallet.balance();
  }

  /// Obtiene el balance total de un mint (todas las unidades).
  /// Retorna Map con unit como clave y balance como valor.
  Future<Map<String, BigInt>> getBalancesForMint(String mintUrl) async {
    final units = _mintUnits[mintUrl] ?? [];
    final balances = <String, BigInt>{};

    for (final unit in units) {
      balances[unit] = await getBalanceForMintUnit(mintUrl, unit);
    }

    return balances;
  }

  // ============================================================
  // RECEIVE (Recibir tokens Cashu)
  // ============================================================

  /// Parsea un token sin reclamarlo. Retorna null si inválido.
  /// Nota: Token no contiene información de unidad.
  TokenInfo? parseToken(String encodedToken) {
    try {
      final token = Token.parse(encoded: encodedToken);
      return TokenInfo(
        amount: token.amount,
        mintUrl: token.mintUrl,
        encoded: token.encoded,
      );
    } catch (e) {
      return null;
    }
  }

  /// Reclama un token Cashu usando la unidad activa.
  /// Si el mint del token es diferente al activo, lo agrega y cambia a él.
  /// Retorna monto recibido.
  Future<BigInt> receiveToken(String encodedToken) async {
    // Parsear token
    final tokenInfo = parseToken(encodedToken);
    if (tokenInfo == null) {
      throw Exception('Token inválido');
    }

    final tokenMint = tokenInfo.mintUrl;

    // Verificar si conocemos este mint
    if (!_mintUnits.containsKey(tokenMint)) {
      // Agregar el mint automáticamente
      await addMint(tokenMint);
    }

    // Cambiar al mint del token (mantener unidad activa si es soportada)
    _activeMintUrl = tokenMint;

    // Verificar si la unidad activa es soportada por este mint
    final units = _mintUnits[tokenMint]!;
    if (!units.contains(_activeUnit)) {
      // Cambiar a la primera unidad soportada
      _activeUnit = units.first;
    }

    // Obtener wallet correcto
    final wallet = await getWallet(tokenMint, _activeUnit);

    // Parsear y reclamar
    final token = Token.parse(encoded: encodedToken);
    final amount = await wallet.receive(token: token);

    notifyListeners();
    return amount;
  }

  /// Reclama un token P2PK (bloqueado a una clave pública).
  Future<BigInt> receiveP2pkToken(
    String encodedToken,
    List<String> signingKeys,
  ) async {
    final tokenInfo = parseToken(encodedToken);
    if (tokenInfo == null) {
      throw Exception('Token inválido');
    }

    // Cambiar al mint del token
    if (!_mintUnits.containsKey(tokenInfo.mintUrl)) {
      await addMint(tokenInfo.mintUrl);
    }

    _activeMintUrl = tokenInfo.mintUrl;

    // Verificar si la unidad activa es soportada
    final units = _mintUnits[tokenInfo.mintUrl]!;
    if (!units.contains(_activeUnit)) {
      _activeUnit = units.first;
    }

    final wallet = await getWallet(tokenInfo.mintUrl, _activeUnit);
    final token = Token.parse(encoded: encodedToken);

    final amount = await wallet.receive(
      token: token,
      opts: ReceiveOptions(signingKeys: signingKeys),
    );

    notifyListeners();
    return amount;
  }

  // ============================================================
  // SEND (Enviar tokens Cashu)
  // ============================================================

  /// Prepara un envío (reserva proofs, calcula fees).
  Future<PreparedSend> prepareSend(BigInt amount) async {
    final wallet = await getActiveWallet();
    return await wallet.prepareSend(amount: amount);
  }

  /// Prepara un envío P2PK (bloqueado a una clave pública).
  Future<PreparedSend> prepareSendP2pk(BigInt amount, String pubkey) async {
    final wallet = await getActiveWallet();
    return await wallet.prepareSend(
      amount: amount,
      opts: SendOptions(pubkey: pubkey),
    );
  }

  /// Confirma un envío preparado y retorna el token encoded.
  Future<String> confirmSend(PreparedSend prepared, String? memo) async {
    final wallet = await getActiveWallet();

    final token = await wallet.send(
      send: prepared,
      memo: memo,
      includeMemo: memo != null && memo.isNotEmpty,
    );

    notifyListeners();
    return token.encoded;
  }

  /// Cancela un envío preparado (libera proofs reservados).
  Future<void> cancelSend(PreparedSend prepared) async {
    final wallet = await getActiveWallet();
    await wallet.cancelSend(send: prepared);
  }

  /// Método de conveniencia: prepara y confirma en un solo paso.
  Future<String> sendTokens(BigInt amount, String? memo) async {
    final prepared = await prepareSend(amount);
    return await confirmSend(prepared, memo);
  }

  /// Envía tokens P2PK.
  Future<String> sendTokensP2pk(
    BigInt amount,
    String pubkey,
    String? memo,
  ) async {
    final prepared = await prepareSendP2pk(amount, pubkey);
    return await confirmSend(prepared, memo);
  }

  // ============================================================
  // MINT (Depositar via Lightning)
  // ============================================================

  /// Inicia un depósito via Lightning.
  /// Retorna Stream con estados: unpaid -> paid -> issued.
  Stream<MintQuote> mintTokens(BigInt amount, String? description) {
    final wallet = activeWallet;
    if (wallet == null) {
      throw Exception('No hay wallet activo');
    }

    return wallet.mint(
      amount: amount,
      description: description,
    );
  }

  // ============================================================
  // MELT (Retirar a Lightning)
  // ============================================================

  /// Obtiene quote para pagar un invoice BOLT11.
  Future<MeltQuote> getMeltQuote(String bolt11Invoice) async {
    final wallet = await getActiveWallet();
    return await wallet.meltQuote(request: bolt11Invoice);
  }

  /// Ejecuta el pago del invoice.
  Future<BigInt> melt(MeltQuote quote) async {
    final wallet = await getActiveWallet();
    final totalPaid = await wallet.melt(quote: quote);
    notifyListeners();
    return totalPaid;
  }

  // ============================================================
  // HISTORIAL
  // ============================================================

  /// Obtiene transacciones del wallet activo.
  Future<List<Transaction>> getTransactions({
    TransactionDirection? direction,
  }) async {
    final wallet = activeWallet;
    if (wallet == null) return [];
    return await wallet.listTransactions(direction: direction);
  }

  /// Obtiene transacciones de todos los wallets.
  Future<List<Transaction>> getAllTransactions({
    TransactionDirection? direction,
  }) async {
    final allTransactions = <Transaction>[];

    for (final wallet in _wallets.values) {
      try {
        final txs = await wallet.listTransactions(direction: direction);
        allTransactions.addAll(txs);
      } catch (e) {
        debugPrint('Error obteniendo transacciones: $e');
      }
    }

    // Ordenar por timestamp (más reciente primero)
    allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allTransactions;
  }

  // ============================================================
  // VERIFICACION DE PROOFS
  // ============================================================

  /// Verifica proofs pendientes en todos los wallets.
  /// Llamar en background al iniciar la app.
  Future<void> checkPendingTransactions() async {
    for (final wallet in _wallets.values) {
      try {
        await wallet.checkPendingTransactions();
      } catch (e) {
        // Silencioso - puede fallar offline
        debugPrint('Check pending failed: $e');
      }
    }
  }

  /// Verifica si un token específico fue gastado.
  Future<bool> isTokenSpent(String encodedToken) async {
    final wallet = activeWallet;
    if (wallet == null) return false;

    final token = Token.parse(encoded: encodedToken);
    return await wallet.isTokenSpent(token: token);
  }

  // ============================================================
  // RESTORE (NUT-13 + NUT-09)
  // ============================================================

  /// Escanea un mint para todas sus unidades usando NUT-13.
  /// Retorna Map con unit como clave y balance recuperado como valor.
  Future<Map<String, BigInt>> restoreFromMint(String mintUrl) async {
    if (_db == null || _mnemonic == null) {
      throw Exception('WalletProvider no inicializado');
    }

    final results = <String, BigInt>{};
    final units = _mintUnits[mintUrl] ?? ['sat'];

    for (final unit in units) {
      try {
        final wallet = await getWallet(mintUrl, unit);
        final balanceBefore = await wallet.balance();

        await wallet.restore();

        final balanceAfter = await wallet.balance();
        final recovered = balanceAfter - balanceBefore;
        results[unit] = recovered;
      } catch (e) {
        debugPrint('Error restaurando $mintUrl:$unit: $e');
        results[unit] = BigInt.from(-1); // Indica error
      }
    }

    notifyListeners();
    return results;
  }

  /// Escanea todos los mints conocidos para recuperar tokens.
  Future<Map<String, Map<String, BigInt>>> restoreAllMints() async {
    final results = <String, Map<String, BigInt>>{};

    for (final mintUrl in _mintUnits.keys) {
      results[mintUrl] = await restoreFromMint(mintUrl);
    }

    return results;
  }

  /// Restaura tokens usando otro mnemonic y los transfiere al wallet actual.
  Future<BigInt> restoreWithMnemonic(
    String mnemonic,
    List<String> mintUrls,
  ) async {
    if (_db == null || _mnemonic == null) {
      throw Exception('WalletProvider no inicializado');
    }

    BigInt totalRecovered = BigInt.zero;

    // Normalizar mnemonic
    final normalizedMnemonic =
        mnemonic.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    // Crear DB temporal
    final dir = await getApplicationDocumentsDirectory();
    final tempDbPath =
        '${dir.path}/temp_restore_${DateTime.now().millisecondsSinceEpoch}.sqlite';

    WalletDatabase? tempDb;

    try {
      tempDb = await WalletDatabase.newInstance(path: tempDbPath);

      for (final mintUrl in mintUrls) {
        // Obtener unidades del mint
        final units = _mintUnits[mintUrl] ?? ['sat'];

        for (final unit in units) {
          try {
            // Crear wallet temporal
            final tempWallet = Wallet(
              mintUrl: mintUrl,
              unit: unit,
              mnemonic: normalizedMnemonic,
              db: tempDb,
            );

            // Escanear
            await tempWallet.restore();
            final tempBalance = await tempWallet.balance();

            if (tempBalance > BigInt.zero) {
              // Enviar todo el balance
              final prepared =
                  await tempWallet.prepareSend(amount: tempBalance);
              final token = await tempWallet.send(
                send: prepared,
                memo: 'Recuperación El Caju',
                includeMemo: true,
              );

              // Reclamar en nuestro wallet
              final ourWallet = await getWallet(mintUrl, unit);
              final received = await ourWallet.receive(token: token);
              totalRecovered += received;
            }
          } catch (e) {
            debugPrint('Error restaurando $mintUrl:$unit: $e');
          }
        }
      }
    } finally {
      // Limpiar DB temporal
      tempDb = null;
      try {
        final tempFile = File(tempDbPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        debugPrint('Error limpiando DB temporal: $e');
      }
    }

    notifyListeners();
    return totalRecovered;
  }

  // ============================================================
  // BORRAR WALLET
  // ============================================================

  /// Borra la base de datos SQLite del wallet.
  Future<bool> deleteDatabase() async {
    try {
      // Limpiar referencias
      _wallets.clear();
      _mintUnits.clear();
      _activeMintUrl = null;
      _activeUnit = 'sat';
      _mnemonic = null;
      _db = null;

      // Borrar archivo
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = '${dir.path}/elcaju_wallet.sqlite';
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al borrar database: $e');
      return false;
    }
  }

  /// Resetea el estado del provider (sin borrar la DB).
  void reset() {
    _wallets.clear();
    _mintUnits.clear();
    _activeMintUrl = null;
    _activeUnit = 'sat';
    _mnemonic = null;
    _db = null;
    notifyListeners();
  }
}
