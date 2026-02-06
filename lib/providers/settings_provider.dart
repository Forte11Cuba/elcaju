import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider que gestiona preferencias y datos sensibles del usuario.
/// Usa FlutterSecureStorage para datos sensibles (mnemonic, PIN).
/// Usa SharedPreferences para preferencias generales.
class SettingsProvider extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Keys para almacenamiento
  static const _mnemonicKey = 'wallet_mnemonic';
  static const _pinKey = 'wallet_pin';
  static const _hasWalletKey = 'has_wallet';
  static const _defaultMintKey = 'default_mint';
  static const _localeKey = 'locale';
  static const _pinEnabledKey = 'pin_enabled';
  static const _activeUnitKey = 'active_unit';
  static const _activeMintUrlKey = 'active_mint_url';

  // Estado interno
  bool _isInitialized = false;
  bool _hasWallet = false;
  bool _pinEnabled = false;
  String? _pin;
  String _locale = 'es';
  String _defaultMint = 'https://mint.cubabitcoin.org';
  String _activeUnit = 'sat';
  String? _activeMintUrl;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get hasWallet => _hasWallet;
  bool get pinEnabled => _pinEnabled;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;
  String get locale => _locale;
  String get defaultMint => _defaultMint;
  String get activeUnit => _activeUnit;
  String? get activeMintUrl => _activeMintUrl;

  // ============================================================
  // INICIALIZACION
  // ============================================================

  /// Inicializa el provider cargando preferencias guardadas.
  /// Debe llamarse al inicio de la app.
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();

    // Cargar preferencias
    _hasWallet = _prefs?.getBool(_hasWalletKey) ?? false;
    _locale = _prefs?.getString(_localeKey) ?? 'es';
    _defaultMint = _prefs?.getString(_defaultMintKey) ?? 'https://mint.cubabitcoin.org';
    _pinEnabled = _prefs?.getBool(_pinEnabledKey) ?? false;
    _activeUnit = _prefs?.getString(_activeUnitKey) ?? 'sat';
    _activeMintUrl = _prefs?.getString(_activeMintUrlKey);

    // Cargar PIN si existe
    if (_pinEnabled) {
      _pin = await _secureStorage.read(key: _pinKey);
    }

    _isInitialized = true;
    notifyListeners();
  }

  // ============================================================
  // MNEMONIC (Almacenamiento seguro)
  // ============================================================

  /// Guarda el mnemonic de forma segura (encriptado).
  Future<void> saveMnemonic(String mnemonic) async {
    await _secureStorage.write(key: _mnemonicKey, value: mnemonic);
    await _prefs?.setBool(_hasWalletKey, true);
    _hasWallet = true;
    notifyListeners();
  }

  /// Lee el mnemonic guardado.
  /// Retorna null si no existe.
  Future<String?> getMnemonic() async {
    return await _secureStorage.read(key: _mnemonicKey);
  }

  /// Verifica si hay un mnemonic guardado.
  Future<bool> hasMnemonic() async {
    final mnemonic = await _secureStorage.read(key: _mnemonicKey);
    return mnemonic != null && mnemonic.isNotEmpty;
  }

  // ============================================================
  // PIN DE ACCESO
  // ============================================================

  /// Configura un nuevo PIN.
  Future<void> setPin(String pin) async {
    await _secureStorage.write(key: _pinKey, value: pin);
    await _prefs?.setBool(_pinEnabledKey, true);
    _pin = pin;
    _pinEnabled = true;
    notifyListeners();
  }

  /// Verifica si el PIN ingresado es correcto.
  bool verifyPin(String pin) {
    return _pin == pin;
  }

  /// Elimina el PIN.
  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
    await _prefs?.setBool(_pinEnabledKey, false);
    _pin = null;
    _pinEnabled = false;
    notifyListeners();
  }

  /// Cambia el PIN existente.
  /// Retorna true si el PIN anterior era correcto y se cambió.
  Future<bool> changePin(String oldPin, String newPin) async {
    if (!verifyPin(oldPin)) {
      return false;
    }
    await setPin(newPin);
    return true;
  }

  // ============================================================
  // PREFERENCIAS DE IDIOMA
  // ============================================================

  /// Cambia el idioma de la app.
  Future<void> setLocale(String locale) async {
    await _prefs?.setString(_localeKey, locale);
    _locale = locale;
    notifyListeners();
  }

  // ============================================================
  // MINT POR DEFECTO
  // ============================================================

  /// Establece el mint por defecto.
  Future<void> setDefaultMint(String mintUrl) async {
    await _prefs?.setString(_defaultMintKey, mintUrl);
    _defaultMint = mintUrl;
    notifyListeners();
  }

  // ============================================================
  // UNIDAD Y MINT ACTIVO
  // ============================================================

  /// Guarda la unidad activa (sat, usd, eur, etc.).
  Future<void> setActiveUnit(String unit) async {
    await _prefs?.setString(_activeUnitKey, unit);
    _activeUnit = unit;
    notifyListeners();
  }

  /// Guarda el mint activo.
  Future<void> setActiveMintUrl(String? mintUrl) async {
    if (mintUrl != null) {
      await _prefs?.setString(_activeMintUrlKey, mintUrl);
    } else {
      await _prefs?.remove(_activeMintUrlKey);
    }
    _activeMintUrl = mintUrl;
    notifyListeners();
  }

  // ============================================================
  // BORRAR WALLET
  // ============================================================

  /// Borra todos los datos del wallet (mnemonic, PIN, preferencias).
  /// NOTA: La base de datos SQLite debe borrarse desde WalletProvider.
  Future<void> deleteWallet() async {
    // Borrar datos sensibles
    await _secureStorage.delete(key: _mnemonicKey);
    await _secureStorage.delete(key: _pinKey);

    // Resetear preferencias
    await _prefs?.setBool(_hasWalletKey, false);
    await _prefs?.setBool(_pinEnabledKey, false);
    await _prefs?.remove(_activeUnitKey);
    await _prefs?.remove(_activeMintUrlKey);
    // Mantener locale y defaultMint (preferencias de app, no de wallet)

    // Resetear estado
    _hasWallet = false;
    _pinEnabled = false;
    _pin = null;
    _activeUnit = 'sat';
    _activeMintUrl = null;

    notifyListeners();
  }

  /// Borra TODAS las preferencias (para reset completo de la app).
  Future<void> clearAll() async {
    // Borrar todo de secure storage
    await _secureStorage.deleteAll();

    // Borrar todas las preferencias
    await _prefs?.clear();

    // Resetear estado
    _hasWallet = false;
    _pinEnabled = false;
    _pin = null;
    _locale = 'es';
    _defaultMint = 'https://mint.cubabitcoin.org';
    _activeUnit = 'sat';
    _activeMintUrl = null;

    notifyListeners();
  }
}
