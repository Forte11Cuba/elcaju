import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cbor/cbor.dart';
import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/transaction_meta_storage.dart';
import '../data/pending_token.dart';
import '../data/pending_token_storage.dart';

/// Helper class para info de token parseado
class TokenInfo {
  final BigInt amount;
  final String mintUrl;
  final String encoded;
  final String? unit; // Unidad detectada del token (sat, usd, eur, etc.)

  TokenInfo({
    required this.amount,
    required this.mintUrl,
    required this.encoded,
    this.unit,
  });
}

/// Provider que gestiona todas las operaciones del wallet Cashu.
/// Soporta múltiples unidades (sat, usd, eur) por mint.
/// Usa múltiples instancias de Wallet compartiendo una sola DB.
class WalletProvider extends ChangeNotifier {
  WalletDatabase? _db;
  String? _mnemonic;

  /// Storage para metadata de transacciones (tipo, token, invoice)
  final TransactionMetaStorage _txMetaStorage = TransactionMetaStorage();

  /// Storage para tokens pendientes de reclamar (Receive Later)
  final PendingTokenStorage _pendingTokenStorage = PendingTokenStorage();

  /// Generador de UUIDs
  static const _uuid = Uuid();

  /// Mints conocidos con sus unidades soportadas.
  /// Ejemplo: {'mint.cubabitcoin.org': ['sat', 'usd']}
  final Map<String, List<String>> _mintUnits = {};

  /// Wallets por mint:unidad (lazy loading).
  /// Clave: 'mintUrl:unit', Ejemplo: 'https://mint.cubabitcoin.org:sat'
  final Map<String, Wallet> _wallets = {};

  /// Caché de keyset_id → unit para detectar unidad de tokens.
  /// Ejemplo: {'00abc123': 'sat', '00def456': 'usd'}
  final Map<String, String> _keysetUnits = {};

  /// Caché de MintInfo por URL (nombre, logo, contactos, etc.)
  final Map<String, MintInfo> _mintInfoCache = {};

  /// Mint activo actualmente
  String? _activeMintUrl;

  /// Unidad activa actualmente
  String _activeUnit = 'sat';

  /// Claves para persistencia en SharedPreferences
  static const _mintsKey = 'wallet_mints';
  static const _activeMintKey = 'wallet_active_mint';
  static const _activeUnitKey = 'wallet_active_unit';

  /// Mint de Cuba Bitcoin - siempre aparece primero en la lista
  static const cubaBitcoinMint = 'https://mint.cubabitcoin.org';

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

  /// Lista de URLs de mints conocidos (orden de inserción)
  List<String> get mintUrls => _mintUnits.keys.toList();

  // ============================================================
  // PENDING TOKENS GETTERS
  // ============================================================

  /// Cantidad de tokens pendientes de reclamar
  int get pendingTokenCount => _pendingTokenStorage.count;

  /// Verifica si hay tokens pendientes
  bool get hasPendingTokens => _pendingTokenStorage.hasPendingTokens;

  /// Stream de cambios en pending tokens
  Stream<void> get pendingTokenChanges => _pendingTokenStorage.changes;

  /// Lista de mints ordenados por balance.
  /// Cuba Bitcoin siempre primero, luego ordenados por: sats → usd → eur → otros.
  Future<List<String>> getSortedMintUrls() async {
    final mints = _mintUnits.keys.toList();

    if (mints.length <= 1) return mints;

    // Obtener balances de cada mint
    final mintBalances = <String, Map<String, BigInt>>{};
    for (final mint in mints) {
      mintBalances[mint] = await getBalancesForMint(mint);
    }

    // Orden de prioridad de unidades
    const unitPriority = ['sat', 'usd', 'eur'];

    // Ordenar mints (excepto Cuba Bitcoin)
    final otherMints = mints.where((m) => m != cubaBitcoinMint).toList();

    otherMints.sort((a, b) {
      final balancesA = mintBalances[a] ?? {};
      final balancesB = mintBalances[b] ?? {};

      // Comparar por cada unidad en orden de prioridad
      for (final unit in unitPriority) {
        final balA = balancesA[unit] ?? BigInt.zero;
        final balB = balancesB[unit] ?? BigInt.zero;
        if (balA != balB) {
          return balB.compareTo(balA); // Mayor primero
        }
      }

      // Si empatan en las prioritarias, comparar otras unidades alfabéticamente
      final otherUnitsA = balancesA.keys.where((u) => !unitPriority.contains(u)).toList()..sort();
      final otherUnitsB = balancesB.keys.where((u) => !unitPriority.contains(u)).toList()..sort();

      for (final unit in {...otherUnitsA, ...otherUnitsB}) {
        final balA = balancesA[unit] ?? BigInt.zero;
        final balB = balancesB[unit] ?? BigInt.zero;
        if (balA != balB) {
          return balB.compareTo(balA);
        }
      }

      return 0;
    });

    // Cuba Bitcoin siempre primero
    final result = <String>[];
    if (mints.contains(cubaBitcoinMint)) {
      result.add(cubaBitcoinMint);
    }
    result.addAll(otherMints);

    return result;
  }

  // ============================================================
  // CONNECTIVITY
  // ============================================================

  /// Verifica si podemos alcanzar un mint específico.
  /// Hace ping HTTP GET a {mintUrl}/v1/info con timeout de 3 segundos.
  /// Retorna true si responde 200, false en cualquier otro caso.
  Future<bool> canReachMint(String mintUrl) async {
    try {
      final uri = Uri.parse('$mintUrl/v1/info');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 3),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Ping to mint failed: $e');
      return false;
    }
  }

  // ============================================================
  // MINT INFO
  // ============================================================

  /// Obtiene la info de un mint (nombre, logo, contactos, etc.)
  /// Usa caché para evitar llamadas repetidas.
  Future<MintInfo?> fetchMintInfo(String mintUrl) async {
    // Revisar caché primero
    if (_mintInfoCache.containsKey(mintUrl)) {
      return _mintInfoCache[mintUrl];
    }

    try {
      final info = await getMintInfo(mintUrl: mintUrl);
      _mintInfoCache[mintUrl] = info;
      return info;
    } catch (e) {
      debugPrint('Error fetching mint info for $mintUrl: $e');
      return null;
    }
  }

  /// Obtiene MintInfo del caché (sin fetch)
  MintInfo? getCachedMintInfo(String mintUrl) {
    return _mintInfoCache[mintUrl];
  }

  /// Obtiene el nombre del mint (del caché o display name)
  String getMintName(String mintUrl) {
    final cached = _mintInfoCache[mintUrl];
    if (cached?.name != null && cached!.name!.isNotEmpty) {
      return cached.name!;
    }
    // Fallback: extraer nombre del URL
    return _getMintDisplayName(mintUrl);
  }

  /// Obtiene el URL del icono del mint (del caché)
  String? getMintIconUrl(String mintUrl) {
    return _mintInfoCache[mintUrl]?.iconUrl;
  }

  /// Helper: extrae nombre legible del URL del mint
  String _getMintDisplayName(String mintUrl) {
    try {
      final uri = Uri.parse(mintUrl);
      var host = uri.host;
      host = host.replaceFirst('mint.', '');
      host = host.replaceFirst('www.', '');
      return host;
    } catch (e) {
      return mintUrl;
    }
  }

  // ============================================================
  // PERSISTENCIA DE MINTS
  // ============================================================

  /// Guarda la lista de mints y sus unidades en SharedPreferences.
  Future<void> _saveMints() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar mints como JSON: {"url": ["sat", "usd"], ...}
    final mintsJson = jsonEncode(_mintUnits);
    await prefs.setString(_mintsKey, mintsJson);

    // Guardar mint y unidad activos
    if (_activeMintUrl != null) {
      await prefs.setString(_activeMintKey, _activeMintUrl!);
    }
    await prefs.setString(_activeUnitKey, _activeUnit);

    debugPrint('Mints guardados: ${_mintUnits.keys.length}');
  }

  /// Carga la lista de mints desde SharedPreferences.
  /// Retorna true si había mints guardados.
  Future<bool> _loadMints() async {
    final prefs = await SharedPreferences.getInstance();

    final mintsJson = prefs.getString(_mintsKey);
    if (mintsJson == null || mintsJson.isEmpty) {
      return false;
    }

    try {
      final decoded = jsonDecode(mintsJson) as Map<String, dynamic>;
      _mintUnits.clear();

      for (final entry in decoded.entries) {
        final units = (entry.value as List<dynamic>).cast<String>();
        _mintUnits[entry.key] = units;
      }

      // Cargar mint y unidad activos
      _activeMintUrl = prefs.getString(_activeMintKey);
      _activeUnit = prefs.getString(_activeUnitKey) ?? 'sat';

      // Verificar que el mint activo existe
      if (_activeMintUrl != null && !_mintUnits.containsKey(_activeMintUrl)) {
        _activeMintUrl = _mintUnits.keys.firstOrNull;
      }

      // Verificar que la unidad activa es válida para el mint
      if (_activeMintUrl != null) {
        final units = _mintUnits[_activeMintUrl]!;
        if (!units.contains(_activeUnit)) {
          _activeUnit = units.first;
        }
      }

      debugPrint('Mints cargados: ${_mintUnits.keys.length}');
      return _mintUnits.isNotEmpty;
    } catch (e) {
      debugPrint('Error cargando mints: $e');
      return false;
    }
  }

  // ============================================================
  // INICIALIZACION
  // ============================================================

  /// Inicializa el provider con un mnemonic.
  /// Carga mints y unidades desde SharedPreferences.
  Future<void> initialize(String mnemonic) async {
    _mnemonic = mnemonic;

    // Inicializar storage de metadata de transacciones
    await _txMetaStorage.init();

    // Inicializar storage de tokens pendientes
    await _pendingTokenStorage.init();

    // Obtener directorio de documentos (path absoluto requerido)
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/elcaju_wallet.sqlite';

    // Crear base de datos (se crea automáticamente si no existe)
    _db = await WalletDatabase.newInstance(path: dbPath);

    // Intentar cargar mints desde SharedPreferences
    final hasSavedMints = await _loadMints();

    if (hasSavedMints) {
      // Cargar keysets para cada mint guardado
      for (final mintUrl in _mintUnits.keys) {
        try {
          await _fetchKeysets(mintUrl);
          // Crear wallet para la primera unidad de cada mint
          final units = _mintUnits[mintUrl]!;
          await getWallet(mintUrl, units.first);
        } catch (e) {
          debugPrint('Error cargando mint $mintUrl: $e');
        }
      }
      debugPrint('Mints restaurados: ${_mintUnits.keys.length}');
    } else {
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

      // Obtener keysets para mapear keyset_id → unit
      await _fetchKeysets(mintUrl);

      return unitList;
    } catch (e) {
      debugPrint('Error detectando unidades de $mintUrl: $e');
      // Fallback a sat
      _mintUnits[mintUrl] = ['sat'];
      return ['sat'];
    }
  }

  /// Obtiene los keysets de un mint y los agrega al caché _keysetUnits.
  /// Llama a GET {mintUrl}/v1/keysets para obtener el mapping keyset_id → unit.
  Future<void> _fetchKeysets(String mintUrl) async {
    try {
      final response = await http.get(
        Uri.parse('$mintUrl/v1/keysets'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final keysets = data['keysets'] as List<dynamic>?;

        if (keysets != null) {
          for (final ks in keysets) {
            final id = ks['id'] as String?;
            final unit = ks['unit'] as String?;
            if (id != null && unit != null) {
              _keysetUnits[id] = unit;
            }
          }
          debugPrint('Keysets cargados para $mintUrl: ${keysets.length}');
        }
      } else {
        debugPrint('Error HTTP ${response.statusCode} al obtener keysets de $mintUrl');
      }
    } catch (e) {
      debugPrint('Error obteniendo keysets de $mintUrl: $e');
      // No lanzamos excepción, el caché simplemente no tendrá estos keysets
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

    // Persistir cambios
    await _saveMints();

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

    // Persistir cambios
    await _saveMints();

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

    // Persistir cambio
    await _saveMints();

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

    // Persistir cambio
    await _saveMints();

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
  /// Incluye detección de unidad si es posible.
  TokenInfo? parseToken(String encodedToken) {
    try {
      final token = Token.parse(encoded: encodedToken);
      final unit = detectTokenUnit(encodedToken);
      return TokenInfo(
        amount: token.amount,
        mintUrl: token.mintUrl,
        encoded: token.encoded,
        unit: unit,
      );
    } catch (e) {
      return null;
    }
  }

  /// Detecta la unidad de un token decodificando su keyset_id.
  /// Soporta tokens V3 (cashuA) y V4 (cashuB con fallback).
  /// Retorna null si no puede detectar la unidad.
  String? detectTokenUnit(String encodedToken) {
    try {
      // Limpiar prefijo "cashu:" si existe
      String token = encodedToken.trim();
      if (token.startsWith('cashu:')) {
        token = token.substring(6);
      }

      // Detectar versión por prefijo
      if (token.startsWith('cashuA')) {
        // Token V3: base64 JSON
        return _detectUnitFromV3(token);
      } else if (token.startsWith('cashuB')) {
        // Token V4: CBOR - intentar fallback
        return _detectUnitFromV4(token);
      }

      return null;
    } catch (e) {
      debugPrint('Error detectando unidad del token: $e');
      return null;
    }
  }

  /// Extrae keyset_id de un token V3 (cashuA + base64 JSON).
  String? _detectUnitFromV3(String token) {
    try {
      // Remover prefijo "cashuA"
      final base64Part = token.substring(6);

      // Decodificar base64
      final decoded = utf8.decode(base64.decode(base64Part));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      // Estructura V3: {"token": [{"mint": "...", "proofs": [{"id": "...", ...}]}]}
      final tokenList = json['token'] as List<dynamic>?;
      if (tokenList == null || tokenList.isEmpty) return null;

      final firstToken = tokenList[0] as Map<String, dynamic>?;
      if (firstToken == null) return null;

      final proofs = firstToken['proofs'] as List<dynamic>?;
      if (proofs == null || proofs.isEmpty) return null;

      final firstProof = proofs[0] as Map<String, dynamic>?;
      final keysetId = firstProof?['id'] as String?;

      if (keysetId != null) {
        // Lookup en caché
        final unit = _keysetUnits[keysetId];
        if (unit != null) {
          debugPrint('Token V3 detectado: keyset=$keysetId, unit=$unit');
          return unit;
        }
        debugPrint('Keyset $keysetId no encontrado en caché');
      }

      return null;
    } catch (e) {
      debugPrint('Error decodificando token V3: $e');
      return null;
    }
  }

  /// Intenta detectar unidad de un token V4 (cashuB + CBOR).
  /// Por ahora hace fallback a probar las unidades conocidas del mint.
  /// Detecta unidad de un token V4 (cashuB + base64url CBOR).
  /// V4 incluye la unidad directamente en el campo 'u'.
  String? _detectUnitFromV4(String token) {
    try {
      // Remover prefijo "cashuB"
      final base64Part = token.substring(6);

      // Decodificar base64url (V4 usa base64url, no base64 estándar)
      final normalized = base64Part
          .replaceAll('-', '+')
          .replaceAll('_', '/');
      // Agregar padding si es necesario
      final padded = normalized.padRight(
        (normalized.length + 3) & ~3,
        '=',
      );
      final bytes = base64.decode(padded);

      // Decodificar CBOR usando la API simple
      final decoded = cbor.decode(bytes);

      // V4 format: {m: mint_url, u: unit, t: [...]}
      if (decoded is CborMap) {
        // Buscar el campo 'u' (unit)
        for (final entry in decoded.entries) {
          final key = entry.key;
          if (key is CborString && key.toString() == 'u') {
            final value = entry.value;
            if (value is CborString) {
              final unit = value.toString();
              debugPrint('Token V4 detectado: unit=$unit');
              return unit;
            }
          }
        }
      }

      debugPrint('Token V4: no se encontró campo "u"');
      return null;
    } catch (e) {
      debugPrint('Error decodificando token V4: $e');
      return null;
    }
  }

  /// Reclama un token Cashu detectando automáticamente su unidad.
  /// Si el mint del token es diferente al activo, lo agrega.
  /// NO cambia la unidad activa (comportamiento similar a cashu.me).
  /// Retorna monto recibido.
  Future<BigInt> receiveToken(String encodedToken) async {
    // Parsear token (incluye detección de unidad)
    final tokenInfo = parseToken(encodedToken);
    if (tokenInfo == null) {
      throw Exception('Token inválido');
    }

    final tokenMint = tokenInfo.mintUrl;

    // Verificar si conocemos este mint
    if (!_mintUnits.containsKey(tokenMint)) {
      // Agregar el mint automáticamente (esto también carga keysets)
      await addMint(tokenMint);

      // Intentar detectar unidad de nuevo ahora que tenemos keysets
      final detectedUnit = detectTokenUnit(encodedToken);
      if (detectedUnit != null) {
        return await _receiveWithUnit(encodedToken, tokenMint, detectedUnit);
      }
    }

    // Si tenemos unidad detectada, usarla
    if (tokenInfo.unit != null) {
      return await _receiveWithUnit(encodedToken, tokenMint, tokenInfo.unit!);
    }

    // Fallback: intentar con cada unidad del mint hasta que funcione
    final units = _mintUnits[tokenMint] ?? ['sat'];
    Exception? lastError;

    for (final unit in units) {
      try {
        return await _receiveWithUnit(encodedToken, tokenMint, unit);
      } catch (e) {
        lastError = e as Exception;
        debugPrint('Receive falló con unidad $unit: $e');
        continue;
      }
    }

    // Si ninguna unidad funcionó, lanzar el último error
    throw lastError ?? Exception('No se pudo reclamar el token');
  }

  /// Recibe un token con una unidad específica.
  /// Guarda metadata type=cashu para identificar en historial.
  Future<BigInt> _receiveWithUnit(
    String encodedToken,
    String mintUrl,
    String unit,
  ) async {
    final wallet = await getWallet(mintUrl, unit);
    final token = Token.parse(encoded: encodedToken);
    final amount = await wallet.receive(token: token);

    // Guardar metadata para la transacción recién creada
    await _saveMetaForRecentReceive(wallet, encodedToken);

    debugPrint('Token recibido: $amount $unit en $mintUrl');
    notifyListeners();
    return amount;
  }

  /// Guarda metadata para la transacción de receive más reciente.
  Future<void> _saveMetaForRecentReceive(Wallet wallet, String tokenEncoded) async {
    try {
      final txs = await wallet.listTransactions(
        direction: TransactionDirection.incoming,
      );

      if (txs.isNotEmpty) {
        final recentTx = txs.first;

        await _txMetaStorage.save(
          recentTx.id,
          TransactionMeta(
            type: TransactionType.cashu,
            token: tokenEncoded,
          ),
        );
        debugPrint('Receive metadata guardada para tx ${recentTx.id}');
      }
    } catch (e) {
      debugPrint('Error guardando receive metadata: $e');
    }
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
    debugPrint('[WalletProvider] prepareSendP2pk: amount=$amount, pubkey=${pubkey.length > 16 ? pubkey.substring(0, 16) : pubkey}...');
    final wallet = await getActiveWallet();
    debugPrint('[WalletProvider] Got wallet, calling prepareSend with P2PK...');
    try {
      final prepared = await wallet.prepareSend(
        amount: amount,
        opts: SendOptions(pubkey: pubkey),
      );
      debugPrint('[WalletProvider] prepareSendP2pk SUCCESS');
      return prepared;
    } catch (e) {
      debugPrint('[WalletProvider] prepareSendP2pk ERROR: $e');
      rethrow;
    }
  }

  /// Confirma un envío preparado y retorna el token encoded.
  /// Guarda metadata type=cashu para identificar en historial.
  Future<String> confirmSend(PreparedSend prepared, String? memo) async {
    final wallet = await getActiveWallet();

    final token = await wallet.send(
      send: prepared,
      memo: memo,
      includeMemo: memo != null && memo.isNotEmpty,
    );

    // Guardar token en storage local para mostrar en detalles del historial.
    // Usamos hash del token como key temporal; después buscaremos la transacción.
    await _saveTokenForRecentTransaction(token.encoded);

    notifyListeners();
    return token.encoded;
  }

  /// Guarda el token para la transacción más reciente de tipo send.
  Future<void> _saveTokenForRecentTransaction(String tokenEncoded) async {
    try {
      // Obtener transacciones outgoing más recientes
      final wallet = await getActiveWallet();
      final txs = await wallet.listTransactions(
        direction: TransactionDirection.outgoing,
      );

      if (txs.isNotEmpty) {
        // La más reciente debería ser la que acabamos de crear
        final recentTx = txs.first;

        await _txMetaStorage.save(
          recentTx.id,
          TransactionMeta(
            type: TransactionType.cashu,
            token: tokenEncoded,
          ),
        );
        debugPrint('Token guardado para tx ${recentTx.id}');
      }
    } catch (e) {
      debugPrint('Error guardando token metadata: $e');
    }
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
  /// Guarda metadata type=lightning cuando se completa.
  Stream<MintQuote> mintTokens(BigInt amount, String? description) {
    final wallet = activeWallet;
    if (wallet == null) {
      throw Exception('No hay wallet activo');
    }

    String? invoiceBolt11;

    // Wrapper del stream para capturar el invoice y guardar metadata
    return wallet.mint(
      amount: amount,
      description: description,
    ).map((quote) {
      // Capturar el invoice cuando está en estado unpaid
      if (quote.state == MintQuoteState.unpaid) {
        invoiceBolt11 = quote.request;
      }

      // Cuando se completa, guardar metadata
      if (quote.state == MintQuoteState.issued && invoiceBolt11 != null) {
        _saveMintMetadata(wallet, invoiceBolt11!);
      }

      return quote;
    });
  }

  /// Guarda metadata para una transacción de mint (Lightning deposit).
  Future<void> _saveMintMetadata(Wallet wallet, String invoice) async {
    try {
      final txs = await wallet.listTransactions(
        direction: TransactionDirection.incoming,
      );

      if (txs.isNotEmpty) {
        final recentTx = txs.first;

        await _txMetaStorage.save(
          recentTx.id,
          TransactionMeta(
            type: TransactionType.lightning,
            invoice: invoice,
          ),
        );
        debugPrint('Mint metadata guardada para tx ${recentTx.id}');
      }
    } catch (e) {
      debugPrint('Error guardando mint metadata: $e');
    }
  }

  // ============================================================
  // MELT (Retirar a Lightning)
  // ============================================================

  /// Invoice temporal para guardar metadata después de melt
  String? _pendingMeltInvoice;

  /// Obtiene quote para pagar un invoice BOLT11.
  /// Guarda el invoice temporalmente para asociarlo a la transacción después.
  Future<MeltQuote> getMeltQuote(String bolt11Invoice) async {
    _pendingMeltInvoice = bolt11Invoice;
    final wallet = await getActiveWallet();
    return await wallet.meltQuote(request: bolt11Invoice);
  }

  /// Ejecuta el pago del invoice.
  /// Guarda metadata type=lightning para identificar en historial.
  Future<BigInt> melt(MeltQuote quote) async {
    final wallet = await getActiveWallet();
    final totalPaid = await wallet.melt(quote: quote);

    // Guardar metadata con el invoice
    if (_pendingMeltInvoice != null) {
      await _saveMeltMetadata(wallet, _pendingMeltInvoice!);
      _pendingMeltInvoice = null;
    }

    notifyListeners();
    return totalPaid;
  }

  /// Guarda metadata para una transacción de melt (Lightning withdrawal).
  Future<void> _saveMeltMetadata(Wallet wallet, String invoice) async {
    try {
      final txs = await wallet.listTransactions(
        direction: TransactionDirection.outgoing,
      );

      if (txs.isNotEmpty) {
        final recentTx = txs.first;

        await _txMetaStorage.save(
          recentTx.id,
          TransactionMeta(
            type: TransactionType.lightning,
            invoice: invoice,
          ),
        );
        debugPrint('Melt metadata guardada para tx ${recentTx.id}');
      }
    } catch (e) {
      debugPrint('Error guardando melt metadata: $e');
    }
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

  /// Obtiene el tipo de una transacción (cashu o lightning).
  /// Busca primero en metadata del CDK, luego en storage local.
  TransactionType getTransactionType(Transaction tx) {
    return _txMetaStorage.getType(tx.id, tx.metadata);
  }

  /// Obtiene metadata adicional de una transacción.
  TransactionMeta? getTransactionMeta(String transactionId) {
    return _txMetaStorage.get(transactionId);
  }

  /// Verifica si una transacción tiene metadata guardada.
  bool hasTransactionMeta(String transactionId) {
    return _txMetaStorage.has(transactionId);
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

      // Limpiar metadata de transacciones
      await _txMetaStorage.clear();

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

  // ============================================================
  // PENDING TOKENS (Receive Later)
  // ============================================================

  /// Guarda un token para reclamar después.
  /// Retorna el PendingToken creado o null si hay error/límite alcanzado.
  Future<PendingToken?> addPendingToken(String encodedToken) async {
    // Parsear token para validar y extraer info
    final tokenInfo = parseToken(encodedToken);
    if (tokenInfo == null) {
      debugPrint('Token inválido para pending');
      return null;
    }

    // Generar ID único
    final id = _uuid.v4();

    // Guardar en storage
    final pending = await _pendingTokenStorage.add(
      id: id,
      encoded: encodedToken,
      amount: tokenInfo.amount,
      mintUrl: tokenInfo.mintUrl,
      unit: tokenInfo.unit,
    );

    if (pending != null) {
      notifyListeners();
    }

    return pending;
  }

  /// Lista todos los tokens pendientes
  List<PendingToken> listPendingTokens() {
    return _pendingTokenStorage.listAll();
  }

  /// Lista solo tokens pendientes válidos (no expirados)
  List<PendingToken> listValidPendingTokens() {
    return _pendingTokenStorage.listValid();
  }

  /// Elimina un token pendiente por ID
  Future<void> removePendingToken(String id) async {
    await _pendingTokenStorage.remove(id);
    notifyListeners();
  }

  /// Intenta reclamar un token pendiente.
  /// Retorna el monto recibido si tiene éxito, o lanza excepción.
  /// Si el token está gastado o es inválido, lo elimina automáticamente.
  /// Verifica conectividad al mint antes de intentar reclamar.
  Future<BigInt> claimPendingToken(String id) async {
    final pending = _pendingTokenStorage.get(id);
    if (pending == null) {
      throw Exception('Token pendiente no encontrado');
    }

    // Verificar conectividad al mint primero (evita esperas largas sin conexión)
    final canReach = await canReachMint(pending.mintUrl);
    if (!canReach) {
      throw Exception('No connection to mint');
    }

    try {
      // Intentar reclamar usando el método existente
      final amount = await receiveToken(pending.encoded);

      // Éxito: eliminar de pending
      await _pendingTokenStorage.remove(id);
      notifyListeners();

      debugPrint('Token pendiente reclamado: $id, monto: $amount');
      return amount;
    } catch (e) {
      final errorStr = e.toString().toLowerCase();

      // Si el token ya fue gastado o es inválido, eliminarlo
      if (errorStr.contains('already spent') ||
          errorStr.contains('token already') ||
          errorStr.contains('invalid')) {
        await _pendingTokenStorage.remove(id);
        notifyListeners();
        debugPrint('Token pendiente eliminado (gastado/inválido): $id');
      } else {
        // Otro error: registrar intento fallido
        await _pendingTokenStorage.recordFailedAttempt(id, e.toString());
      }

      rethrow;
    }
  }

  /// Verifica y reclama automáticamente tokens pendientes.
  /// Retorna un mapa con estadísticas: claimed, failed, removed, totalClaimed, unit.
  Future<Map<String, dynamic>> checkPendingTokens() async {
    final tokens = _pendingTokenStorage.listValid();
    if (tokens.isEmpty) {
      return {'claimed': 0, 'failed': 0, 'removed': 0, 'totalClaimed': BigInt.zero, 'unit': _activeUnit};
    }

    int claimed = 0;
    int failed = 0;
    int removed = 0;
    BigInt totalClaimed = BigInt.zero;
    String? claimedUnit;

    for (final token in tokens) {
      try {
        final amount = await claimPendingToken(token.id);
        claimed++;
        totalClaimed += amount;
        claimedUnit ??= token.unit; // Usar la unidad del primer token reclamado
        debugPrint('Auto-claim exitoso: ${token.id}');
      } catch (e) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('already spent') ||
            errorStr.contains('token already') ||
            errorStr.contains('invalid')) {
          removed++;
          debugPrint('Auto-claim: token eliminado (gastado): ${token.id}');
        } else {
          failed++;
          debugPrint('Auto-claim fallido: ${token.id} - $e');
        }
      }
    }

    // Limpiar expirados también
    final expired = await _pendingTokenStorage.cleanExpired();
    removed += expired;

    if (claimed > 0 || removed > 0) {
      notifyListeners();
    }

    return {
      'claimed': claimed,
      'failed': failed,
      'removed': removed,
      'totalClaimed': totalClaimed,
      'unit': claimedUnit ?? _activeUnit,
    };
  }

  /// Limpia tokens pendientes expirados
  Future<int> cleanExpiredPendingTokens() async {
    final cleaned = await _pendingTokenStorage.cleanExpired();
    if (cleaned > 0) {
      notifyListeners();
    }
    return cleaned;
  }
}
