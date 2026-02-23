import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'Tu wallet de ecash privado';

  @override
  String get loadingMessage1 => 'Cifrando tus monedas...';

  @override
  String get loadingMessage2 => 'Preparando tus e-tokens...';

  @override
  String get loadingMessage3 => 'Conectando con el Mint...';

  @override
  String get loadingMessage4 => 'Privacidad por defecto.';

  @override
  String get loadingMessage5 => 'Firmando tokens ciegamente...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = Privacidad + Libertad';

  @override
  String get aboutTagline => 'Privacidad sin fronteras.';

  @override
  String get welcomeTitle => 'Bienvenido a ElCaju';

  @override
  String get welcomeSubtitle => 'Cashu para el mundo. Hecho en Cuba.';

  @override
  String get createWallet => 'Crear nueva wallet';

  @override
  String get restoreWallet => 'Restaurar wallet';

  @override
  String get createWalletTitle => 'Crear wallet';

  @override
  String get creatingWallet => 'Creando tu wallet...';

  @override
  String get generatingSeed => 'Generando tu frase semilla de forma segura';

  @override
  String get createWalletDescription => 'Se generará una frase semilla de 12 palabras.\nGuárdala en un lugar seguro.';

  @override
  String get generateWallet => 'Generar wallet';

  @override
  String get walletCreated => '¡Wallet creada!';

  @override
  String get walletCreatedDescription => 'Tu wallet está lista. Te recomendamos hacer backup de tu frase semilla ahora.';

  @override
  String get backupWarning => 'Sin backup, perderás acceso a tus fondos si pierdes el dispositivo.';

  @override
  String get backupNow => 'Hacer backup ahora';

  @override
  String get backupLater => 'Hacerlo después';

  @override
  String get backupTitle => 'Backup';

  @override
  String get seedPhraseTitle => 'Tu frase semilla';

  @override
  String get seedPhraseDescription => 'Guarda estas 12 palabras en orden. Son la única forma de recuperar tu wallet.';

  @override
  String get revealSeedPhrase => 'Revelar frase semilla';

  @override
  String get tapToReveal => 'Toca el botón para revelar\ntu frase semilla';

  @override
  String get copyToClipboard => 'Copiar al portapapeles';

  @override
  String get seedCopied => 'Frase copiada al portapapeles';

  @override
  String get neverShareSeed => 'Nunca compartas tu frase semilla con nadie.';

  @override
  String get confirmBackup => 'He guardado mi frase semilla en un lugar seguro';

  @override
  String get continue_ => 'Continuar';

  @override
  String get restoreTitle => 'Restaurar wallet';

  @override
  String get enterSeedPhrase => 'Ingresa tu frase semilla';

  @override
  String get enterSeedDescription => 'Escribe las 12 o 24 palabras separadas por espacios.';

  @override
  String get seedPlaceholder => 'palabra1 palabra2 palabra3 ...';

  @override
  String wordCount(int count) {
    return '$count palabras';
  }

  @override
  String get needWords => '(necesitas 12 o 24)';

  @override
  String get restoreScanningMint => 'Escaneando mint en busca de tokens...';

  @override
  String restoreError(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get homeTitle => 'Inicio';

  @override
  String get receive => 'Recibir';

  @override
  String get send => 'Enviar';

  @override
  String get sendAction => 'Enviar ↗';

  @override
  String get receiveAction => '↘ Recibir';

  @override
  String get deposit => 'Depositar';

  @override
  String get withdraw => 'Retirar';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => 'Historial';

  @override
  String get noTransactions => 'Sin transacciones aún';

  @override
  String get depositOrReceive => 'Deposita o recibe sats para empezar';

  @override
  String get noMint => 'Sin mint';

  @override
  String get balance => 'Balance';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'Pegar token ecash';

  @override
  String get generateInvoiceToDeposit => 'Generar invoice para depositar';

  @override
  String get createEcashToken => 'Crear token ecash';

  @override
  String get payLightningInvoice => 'Pagar invoice Lightning';

  @override
  String get receiveCashu => 'Recibir Cashu';

  @override
  String get pasteTheCashuToken => 'Pega el token Cashu:';

  @override
  String get pasteFromClipboard => 'Pegar del portapapeles';

  @override
  String get validToken => 'Token válido';

  @override
  String get invalidToken => 'Token inválido o malformado';

  @override
  String get amount => 'Monto:';

  @override
  String get mint => 'Mint:';

  @override
  String get claiming => 'Reclamando...';

  @override
  String get claimTokens => 'Reclamar tokens';

  @override
  String get tokensReceived => 'Tokens recibidos';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get tokenAlreadyClaimed => 'Este token ya fue reclamado';

  @override
  String get unknownMint => 'Token de un mint desconocido';

  @override
  String claimError(String error) {
    return 'Error al reclamar: $error';
  }

  @override
  String get sendCashu => 'Enviar Cashu';

  @override
  String get selectNotesManually => 'Seleccionar notas manualmente';

  @override
  String get amountToSend => 'Monto a enviar:';

  @override
  String get available => 'Disponible:';

  @override
  String get max => '(Max)';

  @override
  String get memoOptional => 'Memo (opcional):';

  @override
  String get memoPlaceholder => '¿Para qué es este pago?';

  @override
  String get creatingToken => 'Creando token...';

  @override
  String get createToken => 'Crear token';

  @override
  String get noActiveMint => 'No hay mint activo';

  @override
  String get offlineModeMessage => 'Sin conexión. Usando modo offline...';

  @override
  String get confirmSend => 'Confirmar envío';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get insufficientBalance => 'Balance insuficiente';

  @override
  String tokenCreationError(String error) {
    return 'Error al crear token: $error';
  }

  @override
  String get tokenCreated => 'Token creado';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartir';

  @override
  String get tokenCashu => 'Token Cashu';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Token Cashu (QR animado - $fragments fragmentos UR)';
  }

  @override
  String get keepTokenWarning => 'Guarda este token hasta que el receptor lo reclame. Si lo pierdes, perderás los fondos.';

  @override
  String get tokenCopiedToClipboard => 'Token copiado al portapapeles';

  @override
  String get amountToDeposit => 'Monto a depositar:';

  @override
  String get descriptionOptional => 'Descripción (opcional):';

  @override
  String get depositPlaceholder => '¿Para qué es esta recarga?';

  @override
  String get generating => 'Generando...';

  @override
  String get generateInvoice => 'Generar invoice';

  @override
  String get depositLightning => 'Depositar Lightning';

  @override
  String get payInvoiceTitle => 'Pagar invoice';

  @override
  String get generatingInvoice => 'Generando invoice...';

  @override
  String get waitingForPayment => 'Esperando pago...';

  @override
  String get paymentReceived => 'Pago recibido';

  @override
  String get tokensIssued => 'Tokens emitidos!';

  @override
  String get error => 'Error';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get back => 'Volver';

  @override
  String get copyInvoice => 'Copiar invoice';

  @override
  String get description => 'Descripción:';

  @override
  String get invoiceCopiedToClipboard => 'Invoice copiado al portapapeles';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit depositados';
  }

  @override
  String get pasteLightningInvoice => 'Pega el invoice Lightning:';

  @override
  String get gettingQuote => 'Obteniendo quote...';

  @override
  String get validInvoice => 'Invoice válido';

  @override
  String get invalidInvoice => 'Invoice inválido';

  @override
  String get invalidInvoiceMalformed => 'Invoice inválido o malformado';

  @override
  String get feeReserved => 'Fee reservado:';

  @override
  String get total => 'Total:';

  @override
  String get paying => 'Pagando...';

  @override
  String get payInvoice => 'Pagar invoice';

  @override
  String get confirmPayment => 'Confirmar pago';

  @override
  String get pay => 'Pagar';

  @override
  String get fee => 'fee';

  @override
  String get invoiceExpired => 'Invoice expirado';

  @override
  String get amountOutOfRange => 'Monto fuera del rango permitido';

  @override
  String resolvingType(String type) {
    return 'Resolviendo $type...';
  }

  @override
  String get invoiceAlreadyPaid => 'Invoice ya fue pagado';

  @override
  String paymentError(String error) {
    return 'Error al pagar: $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit enviados';
  }

  @override
  String get filterAll => 'Todos';

  @override
  String get filterPending => 'Pendientes';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Recibe tokens Cashu para empezar';

  @override
  String get noPendingTransactions => 'Sin transacciones pendientes';

  @override
  String get allTransactionsCompleted => 'Todas tus transacciones están completadas';

  @override
  String get noEcashTransactions => 'Sin transacciones Ecash';

  @override
  String get sendOrReceiveTokens => 'Envía o recibe tokens Cashu';

  @override
  String get noLightningTransactions => 'Sin transacciones Lightning';

  @override
  String get depositOrWithdrawLightning => 'Deposita o retira via Lightning';

  @override
  String get pendingStatus => 'Pendiente';

  @override
  String get receivedStatus => 'Recibido';

  @override
  String get sentStatus => 'Enviado';

  @override
  String get now => 'Ahora';

  @override
  String agoMinutes(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String agoHours(int hours) {
    return 'Hace $hours h';
  }

  @override
  String agoDays(int days) {
    return 'Hace $days días';
  }

  @override
  String get lightningInvoice => 'Invoice Lightning';

  @override
  String get receivedEcash => 'Ecash Recibido';

  @override
  String get sentEcash => 'Ecash Enviado';

  @override
  String get outgoingLightningPayment => 'Pago Lightning Saliente';

  @override
  String get invoiceNotAvailable => 'Invoice no disponible';

  @override
  String get tokenNotAvailable => 'Token no disponible';

  @override
  String get unit => 'Unidad';

  @override
  String get status => 'Estado';

  @override
  String get pending => 'Pendiente';

  @override
  String get memo => 'Memo';

  @override
  String get copyInvoiceButton => 'COPIAR INVOICE';

  @override
  String get copyButton => 'COPIAR';

  @override
  String get invoiceCopied => 'Invoice copiado';

  @override
  String get tokenCopied => 'Token copiado';

  @override
  String get speed => 'VELOCIDAD:';

  @override
  String get settings => 'Configuración';

  @override
  String get walletSection => 'WALLET';

  @override
  String get backupSeedPhrase => 'Backup seed phrase';

  @override
  String get viewRecoveryWords => 'Ver tus palabras de recuperación';

  @override
  String get connectedMints => 'Mints conectados';

  @override
  String get manageCashuMints => 'Gestionar tus mints Cashu';

  @override
  String get pinAccess => 'PIN de acceso';

  @override
  String get pinEnabled => 'Activado';

  @override
  String get protectWithPin => 'Proteger la app con PIN';

  @override
  String get recoverTokens => 'Recuperar tokens';

  @override
  String get scanMintsWithSeed => 'Escanear mints con seed phrase';

  @override
  String get appearanceSection => 'IDIOMA';

  @override
  String get language => 'Idioma';

  @override
  String get informationSection => 'INFORMACIÓN';

  @override
  String get version => 'Versión';

  @override
  String get about => 'Acerca de';

  @override
  String get deleteWallet => 'Borrar wallet';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Português';

  @override
  String get french => 'Français';

  @override
  String get russian => 'Русский';

  @override
  String get german => 'Deutsch';

  @override
  String get italian => 'Italiano';

  @override
  String get korean => '한국어';

  @override
  String get chinese => '中文';

  @override
  String get japanese => '日本語';

  @override
  String get swahili => 'Kiswahili';

  @override
  String get mnemonicNotFound => 'No se encontró el mnemonic';

  @override
  String get createPin => 'Crear PIN';

  @override
  String get enterPinDigits => 'Ingresa un PIN de 4 dígitos';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get enterPinAgain => 'Ingresa el PIN nuevamente';

  @override
  String get pinMismatch => 'Los PIN no coinciden';

  @override
  String get pinActivated => 'PIN activado';

  @override
  String get pinDeactivated => 'PIN desactivado';

  @override
  String get verifyPin => 'Verificar PIN';

  @override
  String get enterCurrentPin => 'Ingresa tu PIN actual';

  @override
  String get incorrectPin => 'PIN incorrecto';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String languageChanged(String language) {
    return 'Idioma cambiado a $language';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get aboutDescription => 'Un wallet de Cashu con ADN cubano para el mundo entero. Hermano de La Chispa.';

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get deleteWalletQuestion => '¿Borrar wallet?';

  @override
  String get actionIrreversible => 'Esta acción es irreversible';

  @override
  String get deleteWalletWarning => 'Se eliminarán todos los datos incluyendo tu seed phrase y tokens. Asegúrate de tener un backup.';

  @override
  String get typeDeleteToConfirm => 'Escribe \"BORRAR\" para confirmar:';

  @override
  String get deleteConfirmWord => 'BORRAR';

  @override
  String deleteError(String error) {
    return 'Error al borrar: $error';
  }

  @override
  String get recoverTokensTitle => 'Recuperar tokens';

  @override
  String get recoverTokensDescription => 'Escanea los mints para recuperar tokens asociados a tu seed phrase (NUT-13)';

  @override
  String get useCurrentSeedPhrase => 'Usar mi seed phrase actual';

  @override
  String get scanWithSavedWords => 'Escanear mints con las 12 palabras guardadas';

  @override
  String get useOtherSeedPhrase => 'Usar otra seed phrase';

  @override
  String get recoverFromOtherWords => 'Recuperar tokens de otras 12 palabras';

  @override
  String get mintsToScan => 'Mints a escanear:';

  @override
  String allMints(int count) {
    return 'Todos los mints ($count)';
  }

  @override
  String get specificMint => 'Un mint específico';

  @override
  String get enterMnemonicWords => 'Ingresa las 12 palabras separadas por espacios...';

  @override
  String get scanMints => 'Escanear mints';

  @override
  String get selectMintToScan => 'Selecciona un mint para escanear';

  @override
  String get mnemonicMustHaveWords => 'El mnemonic debe tener 12 o 24 palabras';

  @override
  String get noConnectedMintsToScan => 'No hay mints conectados para escanear';

  @override
  String recoveredTokens(String tokens, int mints) {
    return '¡Recuperados $tokens de $mints mint(s)!';
  }

  @override
  String get scanCompleteNoTokens => 'Escaneo completado. No se encontraron tokens nuevos.';

  @override
  String mintsWithError(int count) {
    return '($count mint(s) con error)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return '¡Recuperados $tokens de $mint!';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return 'No se encontraron tokens en $mint.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return '¡Recuperados y transferidos $amount $unit a tu wallet!';
  }

  @override
  String get noTokensForMnemonic => 'No se encontraron tokens asociados a ese mnemonic.';

  @override
  String get noConnectedMints => 'No hay mints conectados';

  @override
  String get addMintToStart => 'Agrega un mint para comenzar';

  @override
  String get addMint => 'Agregar mint';

  @override
  String get mintDeleted => 'Mint eliminado';

  @override
  String get activeMintUpdated => 'Mint activo actualizado';

  @override
  String get mintUrl => 'URL del mint:';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'La URL debe comenzar con https://';

  @override
  String get connectingToMint => 'Conectando al mint...';

  @override
  String get mintAddedSuccessfully => 'Mint agregado correctamente';

  @override
  String get couldNotConnectToMint => 'No se pudo conectar al mint';

  @override
  String get add => 'Agregar';

  @override
  String get success => 'Éxito';

  @override
  String get loading => 'Cargando...';

  @override
  String get retry => 'Reintentar';

  @override
  String get activeMint => 'Mint activo';

  @override
  String get mintMessage => 'Mensaje del Mint';

  @override
  String get url => 'URL';

  @override
  String get currency => 'Moneda';

  @override
  String get unknown => 'Desconocido';

  @override
  String get useThisMint => 'Usar este mint';

  @override
  String get copyMintUrl => 'Copiar URL del mint';

  @override
  String get deleteMint => 'Eliminar mint';

  @override
  String copied(String label) {
    return '$label copiado';
  }

  @override
  String get deleteMintConfirmTitle => 'Eliminar mint';

  @override
  String get deleteMintConfirmMessage => 'Si tienes balance en este mint, se perderá. ¿Estás seguro?';

  @override
  String get delete => 'Eliminar';

  @override
  String get offlineSend => 'Envío Offline';

  @override
  String get selectAll => 'Todo';

  @override
  String get deselectAll => 'Ninguno';

  @override
  String get selectNotesToSend => 'Selecciona las notas que deseas enviar:';

  @override
  String get totalToSend => 'Total a enviar';

  @override
  String notesSelected(int count) {
    return '$count notas seleccionadas';
  }

  @override
  String loadingProofsError(String error) {
    return 'Error cargando proofs: $error';
  }

  @override
  String creatingTokenError(String error) {
    return 'Error creando token: $error';
  }

  @override
  String get unknownState => 'Estado desconocido';

  @override
  String depositAmountTitle(String amount, String unit) {
    return 'Depositar $amount $unit';
  }

  @override
  String get receiveNow => 'Recibir ahora';

  @override
  String get receiveLater => 'Recibir después';

  @override
  String get tokenSavedForLater => 'Token guardado para reclamar después';

  @override
  String get noConnectionTokenSaved => 'Sin conexión. Token guardado para reclamar después.';

  @override
  String get unknownMintOffline => 'Este token es de un mint desconocido. Conéctate a internet para agregarlo y reclamar el token.';

  @override
  String get noConnectionTryLater => 'Sin conexión al mint. Intenta más tarde.';

  @override
  String get saveTokenError => 'Error al guardar el token. Intenta de nuevo.';

  @override
  String get pendingTokenLimitReached => 'Límite de tokens pendientes alcanzado (max 50)';

  @override
  String get filterToReceive => 'Para recibir';

  @override
  String get noPendingTokens => 'Sin tokens pendientes';

  @override
  String get noPendingTokensHint => 'Guarda tokens para reclamar después';

  @override
  String get pendingBadge => 'PENDIENTE';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expira en $days días',
      one: 'Expira en 1 día',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count reintentos';
  }

  @override
  String get claimNow => 'Reclamar ahora';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return 'Reclamados $amount $unit';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reclamados $count tokens ($amount $unit)',
      one: 'Reclamado 1 token ($amount $unit)',
    );
    return '$_temp0';
  }

  @override
  String get scan => 'Escanear';

  @override
  String get scanQrCode => 'Escanear QR';

  @override
  String get scanCashuToken => 'Escanear token Cashu';

  @override
  String get scanLightningInvoice => 'Escanear invoice';

  @override
  String get scanningAnimatedQr => 'Escaneando QR animado...';

  @override
  String get pointCameraAtQr => 'Apunta la cámara al código QR';

  @override
  String get pointCameraAtCashuQr => 'Apunta la cámara al QR del token Cashu';

  @override
  String get pointCameraAtInvoiceQr => 'Apunta la cámara al QR del invoice';

  @override
  String get unrecognizedQrCode => 'Código QR no reconocido';

  @override
  String get scanCashuTokenHint => 'Escanea un token Cashu (cashuA... o cashuB...)';

  @override
  String get scanLightningInvoiceHint => 'Escanea un invoice Lightning (lnbc...)';

  @override
  String get addMintQuestion => '¿Agregar este mint?';

  @override
  String get cameraPermissionDenied => 'Permiso de cámara denegado';

  @override
  String get paymentRequestNotSupported => 'Los payment requests aún no están soportados';

  @override
  String get p2pkTitle => 'Claves P2PK';

  @override
  String get p2pkSettingsDescription => 'Recibir ecash bloqueado';

  @override
  String get p2pkExperimental => 'P2PK es experimental. Úsala con precaución.';

  @override
  String get p2pkPendingSendWarning => 'Tienes un envío P2PK pendiente. Ve al historial y presiona actualizar después de que el destinatario reclame el token.';

  @override
  String get p2pkExperimentalShort => 'Experimental';

  @override
  String get p2pkPrimaryKey => 'Clave Principal';

  @override
  String get p2pkDerived => 'Derivada';

  @override
  String get p2pkImported => 'Importada';

  @override
  String get p2pkImportedKeys => 'Claves Importadas';

  @override
  String get p2pkNoImportedKeys => 'No hay claves importadas';

  @override
  String get p2pkShowQR => 'Mostrar QR';

  @override
  String get p2pkCopy => 'Copiar';

  @override
  String get p2pkImportNsec => 'Importar nsec';

  @override
  String get p2pkImport => 'Importar';

  @override
  String get p2pkEnterLabel => 'Nombre para esta clave';

  @override
  String get p2pkLockToKey => 'Envío con firma P2PK';

  @override
  String get p2pkLockDescription => 'Solo el destinatario podrá reclamar';

  @override
  String get p2pkReceiverPubkey => 'npub1... o hex (64/66 caracteres)';

  @override
  String get p2pkInvalidPubkey => 'Clave pública inválida';

  @override
  String get p2pkInvalidPrivateKey => 'Clave privada inválida';

  @override
  String get p2pkLockedToYou => 'Bloqueado para ti';

  @override
  String get p2pkLockedToOther => 'Bloqueado para otra clave';

  @override
  String get p2pkCannotUnlock => 'No tienes la clave para desbloquear este token';

  @override
  String get p2pkEnterPrivateKey => 'Ingresa la clave privada (nsec)';

  @override
  String get p2pkDeleteTitle => 'Eliminar clave';

  @override
  String get p2pkDeleteConfirm => '¿Eliminar esta clave? No podrás recibir tokens bloqueados a ella.';

  @override
  String get p2pkRequiresConnection => 'P2PK requiere conexión al mint';

  @override
  String get p2pkErrorMaxKeysReached => 'Máximo de claves importadas alcanzado (10)';

  @override
  String get p2pkErrorInvalidNsec => 'nsec inválido';

  @override
  String get p2pkErrorKeyAlreadyExists => 'Esta clave ya existe';

  @override
  String get p2pkErrorKeyNotFound => 'Clave no encontrada';

  @override
  String get p2pkErrorCannotDeletePrimary => 'No se puede eliminar la clave principal';
}
