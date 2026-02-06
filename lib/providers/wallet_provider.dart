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
/// Capa intermedia entre la UI y cdk_flutter (Rust).
class WalletProvider extends ChangeNotifier {
  MultiMintWallet? _multiWallet;
  Wallet? _activeWallet;
  WalletDatabase? _db;
  String? _activeMintUrl;

  // Getters
  bool get isInitialized => _multiWallet != null;
  Wallet? get activeWallet => _activeWallet;
  String? get activeMintUrl => _activeMintUrl;
  MultiMintWallet? get multiWallet => _multiWallet;

  // ============================================================
  // INICIALIZACION
  // ============================================================

  /// Inicializa el wallet con un mnemonic.
  /// MultiMintWallet carga automaticamente los mints guardados en la DB.
  Future<void> initialize(String mnemonic) async {
    // Obtener directorio de documentos (path absoluto requerido)
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/elcaju_wallet.sqlite';

    // Crear base de datos (se crea automaticamente si no existe)
    _db = await WalletDatabase.newInstance(path: dbPath);

    // Crear multi-mint wallet (carga mints de DB automaticamente)
    _multiWallet = await MultiMintWallet.newInstance(
      unit: 'sat',
      mnemonic: mnemonic,
      db: _db!,
    );

    // Verificar si es primera vez (sin mints)
    final mints = await _multiWallet!.listMints();

    if (mints.isEmpty) {
      // Primera vez: agregar mint por defecto
      await addMint('https://mint.cubabitcoin.org');
      await setActiveMint('https://mint.cubabitcoin.org');
    } else {
      // Restauracion: usar primer mint como activo
      await setActiveMint(mints.first.url);
    }

    notifyListeners();
  }

  /// Detecta si es primera vez (sin mints en la DB).
  /// Usar despues de initialize().
  Future<bool> isFirstTime() async {
    if (_multiWallet == null) return true;
    final mints = await _multiWallet!.listMints();
    return mints.isEmpty;
  }

  /// Genera un nuevo mnemonic de 12 palabras BIP39.
  /// Funcion global de cdk_flutter.
  String generateNewMnemonic() {
    return generateMnemonic();
  }

  // ============================================================
  // MULTI-MINT OPERATIONS
  // ============================================================

  /// Agrega un mint. Idempotente (no error si ya existe).
  Future<void> addMint(String mintUrl) async {
    if (_multiWallet == null) return;
    await _multiWallet!.addMint(mintUrl: mintUrl);
    notifyListeners();
  }

  /// Lista los mints conectados.
  /// Retorna List de Mint con propiedades: url, balance, info.
  Future<List<Mint>> listMints() async {
    if (_multiWallet == null) return [];
    return await _multiWallet!.listMints();
  }

  /// Obtiene las URLs de los mints como lista de Strings.
  Future<List<String>> getMintUrls() async {
    final mints = await listMints();
    return mints.map((m) => m.url).toList();
  }

  /// Remueve un mint. Lanza error si balance > 0.
  Future<void> removeMint(String mintUrl) async {
    if (_multiWallet == null) return;
    await _multiWallet!.removeMint(mintUrl: mintUrl);

    // Si era el mint activo, cambiar a otro
    if (_activeMintUrl == mintUrl) {
      final mints = await listMints();
      if (mints.isNotEmpty) {
        await setActiveMint(mints.first.url);
      } else {
        _activeWallet = null;
        _activeMintUrl = null;
      }
    }

    notifyListeners();
  }

  /// Cambia el mint activo.
  /// Usa createOrGetWallet para garantizar que exista.
  Future<void> setActiveMint(String mintUrl) async {
    if (_multiWallet == null) return;

    // createOrGetWallet nunca retorna null (crea si no existe)
    _activeWallet = await _multiWallet!.createOrGetWallet(mintUrl: mintUrl);
    _activeMintUrl = mintUrl;

    notifyListeners();
  }

  // ============================================================
  // BALANCE
  // ============================================================

  /// Stream de balance del wallet activo (reactivo).
  Stream<BigInt>? streamBalance() {
    return _activeWallet?.streamBalance();
  }

  /// Stream de balance total de todos los mints.
  /// Nota: En MultiMintWallet el método es streamBalance() (no streamTotalBalance).
  Stream<BigInt>? streamTotalBalance() {
    return _multiWallet?.streamBalance();
  }

  /// Obtiene el balance total de todos los mints.
  Future<BigInt> getTotalBalance() async {
    if (_multiWallet == null) return BigInt.zero;
    return await _multiWallet!.totalBalance();
  }

  /// Obtiene el balance de un mint especifico.
  Future<BigInt> getBalanceForMint(String mintUrl) async {
    if (_multiWallet == null) return BigInt.zero;
    final wallet = await _multiWallet!.getWallet(mintUrl: mintUrl);
    if (wallet == null) return BigInt.zero;
    return await wallet.balance();
  }

  // ============================================================
  // RECEIVE (Recibir tokens Cashu)
  // ============================================================

  /// Parsea un token sin reclamarlo. Retorna null si invalido.
  TokenInfo? parseToken(String encodedToken) {
    try {
      final token = Token.parse(encoded: encodedToken);
      return TokenInfo(
        amount: token.amount,
        mintUrl: token.mintUrl,
        encoded: token.encoded,
      );
    } catch (e) {
      // Token.parse lanza excepcion si invalido
      return null;
    }
  }

  /// Reclama un token Cashu. Retorna monto recibido.
  Future<BigInt> receiveToken(String encodedToken) async {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }

    // Parsear token (lanza excepcion si invalido)
    final token = Token.parse(encoded: encodedToken);

    // Reclamar token
    final amount = await _activeWallet!.receive(token: token);

    notifyListeners();
    return amount;
  }

  /// Reclama un token P2PK (bloqueado a una clave publica).
  /// Requiere la clave privada correspondiente para firmar.
  /// [signingKeys] lista de claves privadas en formato hex.
  Future<BigInt> receiveP2pkToken(
    String encodedToken,
    List<String> signingKeys,
  ) async {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }

    final token = Token.parse(encoded: encodedToken);

    // Reclamar con claves de firma para P2PK
    final amount = await _activeWallet!.receive(
      token: token,
      opts: ReceiveOptions(signingKeys: signingKeys),
    );

    notifyListeners();
    return amount;
  }

  // ============================================================
  // SEND (Enviar tokens Cashu)
  // ============================================================

  /// Prepara un envio (reserva proofs, calcula fees).
  /// Retorna PreparedSend para confirmar o cancelar.
  Future<PreparedSend> prepareSend(BigInt amount) async {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }
    return await _activeWallet!.prepareSend(amount: amount);
  }

  /// Prepara un envio P2PK (bloqueado a una clave publica).
  /// Solo el poseedor de la clave privada correspondiente puede reclamar.
  /// [pubkey] clave publica del receptor en formato hex.
  Future<PreparedSend> prepareSendP2pk(BigInt amount, String pubkey) async {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }
    return await _activeWallet!.prepareSend(
      amount: amount,
      opts: SendOptions(pubkey: pubkey),
    );
  }

  /// Confirma un envio preparado y retorna el token encoded.
  Future<String> confirmSend(PreparedSend prepared, String? memo) async {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }

    final token = await _activeWallet!.send(
      send: prepared,
      memo: memo,
      includeMemo: memo != null && memo.isNotEmpty,
    );

    notifyListeners();
    return token.encoded;
  }

  /// Cancela un envio preparado (libera proofs reservados).
  Future<void> cancelSend(PreparedSend prepared) async {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }
    await _activeWallet!.cancelSend(send: prepared);
  }

  /// Metodo de conveniencia: prepara y confirma en un solo paso.
  Future<String> sendTokens(BigInt amount, String? memo) async {
    final prepared = await prepareSend(amount);
    return await confirmSend(prepared, memo);
  }

  /// Envia tokens P2PK (bloqueados a una clave publica).
  /// Solo el poseedor de la clave privada correspondiente puede reclamar.
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

  /// Inicia un deposito via Lightning.
  /// Retorna Stream con estados: unpaid -> paid -> issued.
  /// quote.request contiene el invoice BOLT11 a pagar.
  Stream<MintQuote> mintTokens(BigInt amount, String? description) {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }

    return _activeWallet!.mint(
      amount: amount,
      description: description,
    );
  }

  // ============================================================
  // MELT (Retirar a Lightning)
  // ============================================================

  /// Obtiene quote para pagar un invoice BOLT11.
  /// MeltQuote contiene: amount, feeReserve, expiry.
  Future<MeltQuote> getMeltQuote(String bolt11Invoice) async {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }
    return await _activeWallet!.meltQuote(request: bolt11Invoice);
  }

  /// Ejecuta el pago del invoice.
  /// Retorna monto total pagado (incluyendo fee).
  Future<BigInt> melt(MeltQuote quote) async {
    if (_activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }

    final totalPaid = await _activeWallet!.melt(quote: quote);
    notifyListeners();
    return totalPaid;
  }

  // ============================================================
  // HISTORIAL
  // ============================================================

  /// Obtiene transacciones del wallet activo.
  /// Filtrable por direccion: incoming, outgoing.
  Future<List<Transaction>> getTransactions({
    TransactionDirection? direction,
  }) async {
    if (_activeWallet == null) return [];
    return await _activeWallet!.listTransactions(direction: direction);
  }

  /// Obtiene transacciones de todos los mints.
  Future<List<Transaction>> getAllTransactions({
    TransactionDirection? direction,
  }) async {
    if (_multiWallet == null) return [];
    return await _multiWallet!.listTransactions(direction: direction);
  }

  // ============================================================
  // RESTORE (NUT-13 + NUT-09)
  // ============================================================

  /// Escanea un mint específico para recuperar tokens usando NUT-13.
  /// Retorna el balance encontrado.
  Future<BigInt> restoreFromMint(String mintUrl) async {
    if (_multiWallet == null) {
      throw Exception('Wallet no inicializado');
    }

    // Obtener o crear wallet para este mint
    final wallet = await _multiWallet!.createOrGetWallet(mintUrl: mintUrl);

    // Obtener balance antes del restore
    final balanceBefore = await wallet.balance();

    // Ejecutar restore (NUT-13 + NUT-09)
    await wallet.restore();

    // Obtener balance después
    final balanceAfter = await wallet.balance();

    // Calcular tokens recuperados
    final recovered = balanceAfter - balanceBefore;

    notifyListeners();
    return recovered;
  }

  /// Escanea todos los mints conectados para recuperar tokens.
  /// Retorna mapa de mint -> balance recuperado.
  Future<Map<String, BigInt>> restoreAllMints() async {
    if (_multiWallet == null) {
      throw Exception('Wallet no inicializado');
    }

    final results = <String, BigInt>{};
    final mints = await _multiWallet!.listMints();

    for (final mint in mints) {
      try {
        final recovered = await restoreFromMint(mint.url);
        results[mint.url] = recovered;
      } catch (e) {
        // Si falla un mint, continuar con los demás
        debugPrint('Error restaurando ${mint.url}: $e');
        results[mint.url] = BigInt.from(-1); // Indica error
      }
    }

    return results;
  }

  /// Restaura tokens usando un mnemonic diferente y los transfiere al wallet actual.
  /// Útil para recuperar tokens de otra semilla.
  ///
  /// Flujo:
  /// 1. Crear wallet temporal con el mnemonic proporcionado
  /// 2. Escanear cada mint para recuperar tokens
  /// 3. Si encuentra tokens, enviarlos como token Cashu
  /// 4. Reclamar esos tokens en el wallet actual
  /// 5. Retornar total recuperado
  Future<BigInt> restoreWithMnemonic(String mnemonic, List<String> mintUrls) async {
    if (_multiWallet == null || _activeWallet == null) {
      throw Exception('Wallet no inicializado');
    }

    BigInt totalRecovered = BigInt.zero;

    // Normalizar mnemonic (espacios simples, minúsculas)
    final normalizedMnemonic = mnemonic.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    // Crear DB temporal para el wallet de recuperación
    final dir = await getApplicationDocumentsDirectory();
    final tempDbPath = '${dir.path}/temp_restore_${DateTime.now().millisecondsSinceEpoch}.sqlite';

    WalletDatabase? tempDb;

    try {
      // Crear base de datos temporal
      tempDb = await WalletDatabase.newInstance(path: tempDbPath);

      for (final mintUrl in mintUrls) {
        try {
          // Crear wallet temporal para este mint
          final tempWallet = Wallet(
            mintUrl: mintUrl,
            unit: 'sat',
            mnemonic: normalizedMnemonic,
            db: tempDb,
          );

          // Escanear el mint (NUT-13 + NUT-09)
          await tempWallet.restore();

          // Verificar si encontró balance
          final tempBalance = await tempWallet.balance();

          if (tempBalance > BigInt.zero) {
            // Preparar envío de todo el balance
            final prepared = await tempWallet.prepareSend(amount: tempBalance);

            // Crear token
            final token = await tempWallet.send(
              send: prepared,
              memo: 'Recuperación El Caju',
              includeMemo: true,
            );

            // Asegurar que tenemos wallet para este mint en nuestro wallet actual
            final ourWallet = await _multiWallet!.createOrGetWallet(mintUrl: mintUrl);

            // Reclamar el token en nuestro wallet
            final received = await ourWallet.receive(token: token);
            totalRecovered += received;
          }
        } catch (e) {
          debugPrint('Error restaurando desde $mintUrl: $e');
          // Continuar con el siguiente mint
        }
      }
    } finally {
      // Limpiar: cerrar y borrar DB temporal
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
  /// Debe llamarse ANTES de borrar el mnemonic en SettingsProvider.
  /// Retorna true si se borró correctamente.
  Future<bool> deleteDatabase() async {
    try {
      // Limpiar referencias internas primero
      _multiWallet = null;
      _activeWallet = null;
      _activeMintUrl = null;
      _db = null;

      // Obtener path de la base de datos
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = '${dir.path}/elcaju_wallet.sqlite';

      // Borrar archivo si existe
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
  /// Útil para logout sin borrar datos.
  void reset() {
    _multiWallet = null;
    _activeWallet = null;
    _activeMintUrl = null;
    _db = null;
    notifyListeners();
  }
}
