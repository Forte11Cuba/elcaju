import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('sw'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'ElCaju'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu wallet de ecash privado'**
  String get appTagline;

  /// No description provided for @loadingMessage1.
  ///
  /// In es, this message translates to:
  /// **'Cifrando tus monedas...'**
  String get loadingMessage1;

  /// No description provided for @loadingMessage2.
  ///
  /// In es, this message translates to:
  /// **'Preparando tus e-tokens...'**
  String get loadingMessage2;

  /// No description provided for @loadingMessage3.
  ///
  /// In es, this message translates to:
  /// **'Conectando con el Mint...'**
  String get loadingMessage3;

  /// No description provided for @loadingMessage4.
  ///
  /// In es, this message translates to:
  /// **'Privacidad por defecto.'**
  String get loadingMessage4;

  /// No description provided for @loadingMessage5.
  ///
  /// In es, this message translates to:
  /// **'Firmando tokens ciegamente...'**
  String get loadingMessage5;

  /// No description provided for @loadingMessage6.
  ///
  /// In es, this message translates to:
  /// **'Go full Calle...'**
  String get loadingMessage6;

  /// No description provided for @loadingMessage7.
  ///
  /// In es, this message translates to:
  /// **'Cashu + Bitchat = Privacidad + Libertad'**
  String get loadingMessage7;

  /// No description provided for @aboutTagline.
  ///
  /// In es, this message translates to:
  /// **'Privacidad sin fronteras.'**
  String get aboutTagline;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a ElCaju'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cashu para el mundo. Hecho en Cuba.'**
  String get welcomeSubtitle;

  /// No description provided for @createWallet.
  ///
  /// In es, this message translates to:
  /// **'Crear nueva wallet'**
  String get createWallet;

  /// No description provided for @restoreWallet.
  ///
  /// In es, this message translates to:
  /// **'Restaurar wallet'**
  String get restoreWallet;

  /// No description provided for @createWalletTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear wallet'**
  String get createWalletTitle;

  /// No description provided for @creatingWallet.
  ///
  /// In es, this message translates to:
  /// **'Creando tu wallet...'**
  String get creatingWallet;

  /// No description provided for @generatingSeed.
  ///
  /// In es, this message translates to:
  /// **'Generando tu frase semilla de forma segura'**
  String get generatingSeed;

  /// No description provided for @createWalletDescription.
  ///
  /// In es, this message translates to:
  /// **'Se generará una frase semilla de 12 palabras.\nGuárdala en un lugar seguro.'**
  String get createWalletDescription;

  /// No description provided for @generateWallet.
  ///
  /// In es, this message translates to:
  /// **'Generar wallet'**
  String get generateWallet;

  /// No description provided for @walletCreated.
  ///
  /// In es, this message translates to:
  /// **'¡Wallet creada!'**
  String get walletCreated;

  /// No description provided for @walletCreatedDescription.
  ///
  /// In es, this message translates to:
  /// **'Tu wallet está lista. Te recomendamos hacer backup de tu frase semilla ahora.'**
  String get walletCreatedDescription;

  /// No description provided for @backupWarning.
  ///
  /// In es, this message translates to:
  /// **'Sin backup, perderás acceso a tus fondos si pierdes el dispositivo.'**
  String get backupWarning;

  /// No description provided for @backupNow.
  ///
  /// In es, this message translates to:
  /// **'Hacer backup ahora'**
  String get backupNow;

  /// No description provided for @backupLater.
  ///
  /// In es, this message translates to:
  /// **'Hacerlo después'**
  String get backupLater;

  /// No description provided for @backupTitle.
  ///
  /// In es, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @seedPhraseTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu frase semilla'**
  String get seedPhraseTitle;

  /// No description provided for @seedPhraseDescription.
  ///
  /// In es, this message translates to:
  /// **'Guarda estas 12 palabras en orden. Son la única forma de recuperar tu wallet.'**
  String get seedPhraseDescription;

  /// No description provided for @revealSeedPhrase.
  ///
  /// In es, this message translates to:
  /// **'Revelar frase semilla'**
  String get revealSeedPhrase;

  /// No description provided for @tapToReveal.
  ///
  /// In es, this message translates to:
  /// **'Toca el botón para revelar\ntu frase semilla'**
  String get tapToReveal;

  /// No description provided for @copyToClipboard.
  ///
  /// In es, this message translates to:
  /// **'Copiar al portapapeles'**
  String get copyToClipboard;

  /// No description provided for @seedCopied.
  ///
  /// In es, this message translates to:
  /// **'Frase copiada al portapapeles'**
  String get seedCopied;

  /// No description provided for @neverShareSeed.
  ///
  /// In es, this message translates to:
  /// **'Nunca compartas tu frase semilla con nadie.'**
  String get neverShareSeed;

  /// No description provided for @confirmBackup.
  ///
  /// In es, this message translates to:
  /// **'He guardado mi frase semilla en un lugar seguro'**
  String get confirmBackup;

  /// No description provided for @continue_.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continue_;

  /// No description provided for @restoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Restaurar wallet'**
  String get restoreTitle;

  /// No description provided for @enterSeedPhrase.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu frase semilla'**
  String get enterSeedPhrase;

  /// No description provided for @enterSeedDescription.
  ///
  /// In es, this message translates to:
  /// **'Escribe las 12 o 24 palabras separadas por espacios.'**
  String get enterSeedDescription;

  /// No description provided for @seedPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'palabra1 palabra2 palabra3 ...'**
  String get seedPlaceholder;

  /// No description provided for @wordCount.
  ///
  /// In es, this message translates to:
  /// **'{count} palabras'**
  String wordCount(int count);

  /// No description provided for @needWords.
  ///
  /// In es, this message translates to:
  /// **'(necesitas 12 o 24)'**
  String get needWords;

  /// No description provided for @restoreScanningMint.
  ///
  /// In es, this message translates to:
  /// **'Escaneando mint en busca de tokens...'**
  String get restoreScanningMint;

  /// No description provided for @restoreError.
  ///
  /// In es, this message translates to:
  /// **'Error al restaurar: {error}'**
  String restoreError(String error);

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTitle;

  /// No description provided for @receive.
  ///
  /// In es, this message translates to:
  /// **'Recibir'**
  String get receive;

  /// No description provided for @send.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get send;

  /// No description provided for @sendAction.
  ///
  /// In es, this message translates to:
  /// **'Enviar ↗'**
  String get sendAction;

  /// No description provided for @receiveAction.
  ///
  /// In es, this message translates to:
  /// **'↘ Recibir'**
  String get receiveAction;

  /// No description provided for @deposit.
  ///
  /// In es, this message translates to:
  /// **'Depositar'**
  String get deposit;

  /// No description provided for @withdraw.
  ///
  /// In es, this message translates to:
  /// **'Retirar'**
  String get withdraw;

  /// No description provided for @lightning.
  ///
  /// In es, this message translates to:
  /// **'Lightning'**
  String get lightning;

  /// No description provided for @cashu.
  ///
  /// In es, this message translates to:
  /// **'Cashu'**
  String get cashu;

  /// No description provided for @ecash.
  ///
  /// In es, this message translates to:
  /// **'Ecash'**
  String get ecash;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @noTransactions.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones aún'**
  String get noTransactions;

  /// No description provided for @depositOrReceive.
  ///
  /// In es, this message translates to:
  /// **'Deposita o recibe sats para empezar'**
  String get depositOrReceive;

  /// No description provided for @noMint.
  ///
  /// In es, this message translates to:
  /// **'Sin mint'**
  String get noMint;

  /// No description provided for @balance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @sats.
  ///
  /// In es, this message translates to:
  /// **'sats'**
  String get sats;

  /// No description provided for @pasteEcashToken.
  ///
  /// In es, this message translates to:
  /// **'Pegar token ecash'**
  String get pasteEcashToken;

  /// No description provided for @generateInvoiceToDeposit.
  ///
  /// In es, this message translates to:
  /// **'Generar invoice para depositar'**
  String get generateInvoiceToDeposit;

  /// No description provided for @createEcashToken.
  ///
  /// In es, this message translates to:
  /// **'Crear token ecash'**
  String get createEcashToken;

  /// No description provided for @payLightningInvoice.
  ///
  /// In es, this message translates to:
  /// **'Pagar invoice Lightning'**
  String get payLightningInvoice;

  /// No description provided for @receiveCashu.
  ///
  /// In es, this message translates to:
  /// **'Recibir Cashu'**
  String get receiveCashu;

  /// No description provided for @pasteTheCashuToken.
  ///
  /// In es, this message translates to:
  /// **'Pega el token Cashu:'**
  String get pasteTheCashuToken;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In es, this message translates to:
  /// **'Pegar del portapapeles'**
  String get pasteFromClipboard;

  /// No description provided for @validToken.
  ///
  /// In es, this message translates to:
  /// **'Token válido'**
  String get validToken;

  /// No description provided for @invalidToken.
  ///
  /// In es, this message translates to:
  /// **'Token inválido o malformado'**
  String get invalidToken;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Monto:'**
  String get amount;

  /// No description provided for @mint.
  ///
  /// In es, this message translates to:
  /// **'Mint:'**
  String get mint;

  /// No description provided for @claiming.
  ///
  /// In es, this message translates to:
  /// **'Reclamando...'**
  String get claiming;

  /// No description provided for @claimTokens.
  ///
  /// In es, this message translates to:
  /// **'Reclamar tokens'**
  String get claimTokens;

  /// No description provided for @tokensReceived.
  ///
  /// In es, this message translates to:
  /// **'Tokens recibidos'**
  String get tokensReceived;

  /// No description provided for @backToHome.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get backToHome;

  /// No description provided for @tokenAlreadyClaimed.
  ///
  /// In es, this message translates to:
  /// **'Este token ya fue reclamado'**
  String get tokenAlreadyClaimed;

  /// No description provided for @unknownMint.
  ///
  /// In es, this message translates to:
  /// **'Token de un mint desconocido'**
  String get unknownMint;

  /// No description provided for @claimError.
  ///
  /// In es, this message translates to:
  /// **'Error al reclamar: {error}'**
  String claimError(String error);

  /// No description provided for @sendCashu.
  ///
  /// In es, this message translates to:
  /// **'Enviar Cashu'**
  String get sendCashu;

  /// No description provided for @selectNotesManually.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar notas manualmente'**
  String get selectNotesManually;

  /// No description provided for @amountToSend.
  ///
  /// In es, this message translates to:
  /// **'Monto a enviar:'**
  String get amountToSend;

  /// No description provided for @available.
  ///
  /// In es, this message translates to:
  /// **'Disponible:'**
  String get available;

  /// No description provided for @max.
  ///
  /// In es, this message translates to:
  /// **'(Max)'**
  String get max;

  /// No description provided for @memoOptional.
  ///
  /// In es, this message translates to:
  /// **'Memo (opcional):'**
  String get memoOptional;

  /// No description provided for @memoPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué es este pago?'**
  String get memoPlaceholder;

  /// No description provided for @creatingToken.
  ///
  /// In es, this message translates to:
  /// **'Creando token...'**
  String get creatingToken;

  /// No description provided for @createToken.
  ///
  /// In es, this message translates to:
  /// **'Crear token'**
  String get createToken;

  /// No description provided for @noActiveMint.
  ///
  /// In es, this message translates to:
  /// **'No hay mint activo'**
  String get noActiveMint;

  /// No description provided for @offlineModeMessage.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Usando modo offline...'**
  String get offlineModeMessage;

  /// No description provided for @confirmSend.
  ///
  /// In es, this message translates to:
  /// **'Confirmar envío'**
  String get confirmSend;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @insufficientBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance insuficiente'**
  String get insufficientBalance;

  /// No description provided for @tokenCreationError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear token: {error}'**
  String tokenCreationError(String error);

  /// No description provided for @tokenCreated.
  ///
  /// In es, this message translates to:
  /// **'Token creado'**
  String get tokenCreated;

  /// No description provided for @copy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @tokenCashu.
  ///
  /// In es, this message translates to:
  /// **'Token Cashu'**
  String get tokenCashu;

  /// No description provided for @tokenCashuAnimatedQr.
  ///
  /// In es, this message translates to:
  /// **'Token Cashu (QR animado - {fragments} fragmentos UR)'**
  String tokenCashuAnimatedQr(int fragments);

  /// No description provided for @keepTokenWarning.
  ///
  /// In es, this message translates to:
  /// **'Guarda este token hasta que el receptor lo reclame. Si lo pierdes, perderás los fondos.'**
  String get keepTokenWarning;

  /// No description provided for @tokenCopiedToClipboard.
  ///
  /// In es, this message translates to:
  /// **'Token copiado al portapapeles'**
  String get tokenCopiedToClipboard;

  /// No description provided for @copyAsEmoji.
  ///
  /// In es, this message translates to:
  /// **'Copiar como emoji'**
  String get copyAsEmoji;

  /// No description provided for @emojiCopiedToClipboard.
  ///
  /// In es, this message translates to:
  /// **'Token copiado como emoji 🥜'**
  String get emojiCopiedToClipboard;

  /// No description provided for @peanutDecodeError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo decodificar el token emoji. Puede estar corrupto.'**
  String get peanutDecodeError;

  /// No description provided for @nfcWrite.
  ///
  /// In es, this message translates to:
  /// **'Escribir en tag NFC'**
  String get nfcWrite;

  /// No description provided for @nfcRead.
  ///
  /// In es, this message translates to:
  /// **'Leer tag NFC'**
  String get nfcRead;

  /// No description provided for @nfcHoldNear.
  ///
  /// In es, this message translates to:
  /// **'Acerca el dispositivo al tag NFC...'**
  String get nfcHoldNear;

  /// No description provided for @nfcWriteSuccess.
  ///
  /// In es, this message translates to:
  /// **'Token escrito en tag NFC'**
  String get nfcWriteSuccess;

  /// No description provided for @nfcWriteError.
  ///
  /// In es, this message translates to:
  /// **'Error NFC al escribir: {error}'**
  String nfcWriteError(String error);

  /// No description provided for @nfcReadError.
  ///
  /// In es, this message translates to:
  /// **'Error NFC al leer: {error}'**
  String nfcReadError(String error);

  /// No description provided for @nfcDisabled.
  ///
  /// In es, this message translates to:
  /// **'NFC está desactivado. Actívalo en Ajustes.'**
  String get nfcDisabled;

  /// No description provided for @nfcUnsupported.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no soporta NFC'**
  String get nfcUnsupported;

  /// No description provided for @amountToDeposit.
  ///
  /// In es, this message translates to:
  /// **'Monto a depositar:'**
  String get amountToDeposit;

  /// No description provided for @descriptionOptional.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional):'**
  String get descriptionOptional;

  /// No description provided for @depositPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'¿Para qué es esta recarga?'**
  String get depositPlaceholder;

  /// No description provided for @generating.
  ///
  /// In es, this message translates to:
  /// **'Generando...'**
  String get generating;

  /// No description provided for @generateInvoice.
  ///
  /// In es, this message translates to:
  /// **'Generar invoice'**
  String get generateInvoice;

  /// No description provided for @depositLightning.
  ///
  /// In es, this message translates to:
  /// **'Depositar Lightning'**
  String get depositLightning;

  /// No description provided for @payInvoiceTitle.
  ///
  /// In es, this message translates to:
  /// **'Pagar invoice'**
  String get payInvoiceTitle;

  /// No description provided for @generatingInvoice.
  ///
  /// In es, this message translates to:
  /// **'Generando invoice...'**
  String get generatingInvoice;

  /// No description provided for @waitingForPayment.
  ///
  /// In es, this message translates to:
  /// **'Esperando pago...'**
  String get waitingForPayment;

  /// No description provided for @paymentReceived.
  ///
  /// In es, this message translates to:
  /// **'Pago recibido'**
  String get paymentReceived;

  /// No description provided for @tokensIssued.
  ///
  /// In es, this message translates to:
  /// **'Tokens emitidos!'**
  String get tokensIssued;

  /// No description provided for @error.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @unknownError.
  ///
  /// In es, this message translates to:
  /// **'Error desconocido'**
  String get unknownError;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @copyInvoice.
  ///
  /// In es, this message translates to:
  /// **'Copiar invoice'**
  String get copyInvoice;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción:'**
  String get description;

  /// No description provided for @invoiceCopiedToClipboard.
  ///
  /// In es, this message translates to:
  /// **'Invoice copiado al portapapeles'**
  String get invoiceCopiedToClipboard;

  /// No description provided for @deposited.
  ///
  /// In es, this message translates to:
  /// **'{amount} {unit} depositados'**
  String deposited(String amount, String unit);

  /// No description provided for @pasteLightningInvoice.
  ///
  /// In es, this message translates to:
  /// **'Pega el invoice Lightning:'**
  String get pasteLightningInvoice;

  /// No description provided for @gettingQuote.
  ///
  /// In es, this message translates to:
  /// **'Obteniendo quote...'**
  String get gettingQuote;

  /// No description provided for @validInvoice.
  ///
  /// In es, this message translates to:
  /// **'Invoice válido'**
  String get validInvoice;

  /// No description provided for @invalidInvoice.
  ///
  /// In es, this message translates to:
  /// **'Invoice inválido'**
  String get invalidInvoice;

  /// No description provided for @invalidInvoiceMalformed.
  ///
  /// In es, this message translates to:
  /// **'Invoice inválido o malformado'**
  String get invalidInvoiceMalformed;

  /// No description provided for @feeReserved.
  ///
  /// In es, this message translates to:
  /// **'Fee reservado:'**
  String get feeReserved;

  /// No description provided for @total.
  ///
  /// In es, this message translates to:
  /// **'Total:'**
  String get total;

  /// No description provided for @paying.
  ///
  /// In es, this message translates to:
  /// **'Pagando...'**
  String get paying;

  /// No description provided for @payInvoice.
  ///
  /// In es, this message translates to:
  /// **'Pagar invoice'**
  String get payInvoice;

  /// No description provided for @confirmPayment.
  ///
  /// In es, this message translates to:
  /// **'Confirmar pago'**
  String get confirmPayment;

  /// No description provided for @pay.
  ///
  /// In es, this message translates to:
  /// **'Pagar'**
  String get pay;

  /// No description provided for @fee.
  ///
  /// In es, this message translates to:
  /// **'fee'**
  String get fee;

  /// No description provided for @invoiceExpired.
  ///
  /// In es, this message translates to:
  /// **'Invoice expirado'**
  String get invoiceExpired;

  /// No description provided for @amountOutOfRange.
  ///
  /// In es, this message translates to:
  /// **'Monto fuera del rango permitido'**
  String get amountOutOfRange;

  /// No description provided for @resolvingType.
  ///
  /// In es, this message translates to:
  /// **'Resolviendo {type}...'**
  String resolvingType(String type);

  /// No description provided for @invoiceAlreadyPaid.
  ///
  /// In es, this message translates to:
  /// **'Invoice ya fue pagado'**
  String get invoiceAlreadyPaid;

  /// No description provided for @paymentError.
  ///
  /// In es, this message translates to:
  /// **'Error al pagar: {error}'**
  String paymentError(String error);

  /// No description provided for @sent.
  ///
  /// In es, this message translates to:
  /// **'{amount} {unit} enviados'**
  String sent(String amount, String unit);

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get filterPending;

  /// No description provided for @filterEcash.
  ///
  /// In es, this message translates to:
  /// **'Ecash'**
  String get filterEcash;

  /// No description provided for @filterLightning.
  ///
  /// In es, this message translates to:
  /// **'Lightning'**
  String get filterLightning;

  /// No description provided for @receiveTokensToStart.
  ///
  /// In es, this message translates to:
  /// **'Recibe tokens Cashu para empezar'**
  String get receiveTokensToStart;

  /// No description provided for @noPendingTransactions.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones pendientes'**
  String get noPendingTransactions;

  /// No description provided for @allTransactionsCompleted.
  ///
  /// In es, this message translates to:
  /// **'Todas tus transacciones están completadas'**
  String get allTransactionsCompleted;

  /// No description provided for @noEcashTransactions.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones Ecash'**
  String get noEcashTransactions;

  /// No description provided for @sendOrReceiveTokens.
  ///
  /// In es, this message translates to:
  /// **'Envía o recibe tokens Cashu'**
  String get sendOrReceiveTokens;

  /// No description provided for @noLightningTransactions.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones Lightning'**
  String get noLightningTransactions;

  /// No description provided for @depositOrWithdrawLightning.
  ///
  /// In es, this message translates to:
  /// **'Deposita o retira via Lightning'**
  String get depositOrWithdrawLightning;

  /// No description provided for @pendingStatus.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pendingStatus;

  /// No description provided for @receivedStatus.
  ///
  /// In es, this message translates to:
  /// **'Recibido'**
  String get receivedStatus;

  /// No description provided for @sentStatus.
  ///
  /// In es, this message translates to:
  /// **'Enviado'**
  String get sentStatus;

  /// No description provided for @now.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get now;

  /// No description provided for @agoMinutes.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutes} min'**
  String agoMinutes(int minutes);

  /// No description provided for @agoHours.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours} h'**
  String agoHours(int hours);

  /// No description provided for @agoDays.
  ///
  /// In es, this message translates to:
  /// **'Hace {days} días'**
  String agoDays(int days);

  /// No description provided for @lightningInvoice.
  ///
  /// In es, this message translates to:
  /// **'Invoice Lightning'**
  String get lightningInvoice;

  /// No description provided for @receivedEcash.
  ///
  /// In es, this message translates to:
  /// **'Ecash Recibido'**
  String get receivedEcash;

  /// No description provided for @sentEcash.
  ///
  /// In es, this message translates to:
  /// **'Ecash Enviado'**
  String get sentEcash;

  /// No description provided for @outgoingLightningPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago Lightning Saliente'**
  String get outgoingLightningPayment;

  /// No description provided for @invoiceNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Invoice no disponible'**
  String get invoiceNotAvailable;

  /// No description provided for @tokenNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Token no disponible'**
  String get tokenNotAvailable;

  /// No description provided for @unit.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get unit;

  /// No description provided for @status.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get status;

  /// No description provided for @pending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// No description provided for @memo.
  ///
  /// In es, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @copyInvoiceButton.
  ///
  /// In es, this message translates to:
  /// **'COPIAR INVOICE'**
  String get copyInvoiceButton;

  /// No description provided for @copyButton.
  ///
  /// In es, this message translates to:
  /// **'COPIAR'**
  String get copyButton;

  /// No description provided for @invoiceCopied.
  ///
  /// In es, this message translates to:
  /// **'Invoice copiado'**
  String get invoiceCopied;

  /// No description provided for @tokenCopied.
  ///
  /// In es, this message translates to:
  /// **'Token copiado'**
  String get tokenCopied;

  /// No description provided for @speed.
  ///
  /// In es, this message translates to:
  /// **'VELOCIDAD:'**
  String get speed;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// No description provided for @walletSection.
  ///
  /// In es, this message translates to:
  /// **'WALLET'**
  String get walletSection;

  /// No description provided for @backupSeedPhrase.
  ///
  /// In es, this message translates to:
  /// **'Backup seed phrase'**
  String get backupSeedPhrase;

  /// No description provided for @viewRecoveryWords.
  ///
  /// In es, this message translates to:
  /// **'Ver tus palabras de recuperación'**
  String get viewRecoveryWords;

  /// No description provided for @connectedMints.
  ///
  /// In es, this message translates to:
  /// **'Mints conectados'**
  String get connectedMints;

  /// No description provided for @manageCashuMints.
  ///
  /// In es, this message translates to:
  /// **'Gestionar tus mints Cashu'**
  String get manageCashuMints;

  /// No description provided for @pinAccess.
  ///
  /// In es, this message translates to:
  /// **'PIN de acceso'**
  String get pinAccess;

  /// No description provided for @pinEnabled.
  ///
  /// In es, this message translates to:
  /// **'Activado'**
  String get pinEnabled;

  /// No description provided for @protectWithPin.
  ///
  /// In es, this message translates to:
  /// **'Proteger la app con PIN'**
  String get protectWithPin;

  /// No description provided for @recoverTokens.
  ///
  /// In es, this message translates to:
  /// **'Recuperar tokens'**
  String get recoverTokens;

  /// No description provided for @scanMintsWithSeed.
  ///
  /// In es, this message translates to:
  /// **'Escanear mints con seed phrase'**
  String get scanMintsWithSeed;

  /// No description provided for @appearanceSection.
  ///
  /// In es, this message translates to:
  /// **'IDIOMA'**
  String get appearanceSection;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @informationSection.
  ///
  /// In es, this message translates to:
  /// **'INFORMACIÓN'**
  String get informationSection;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get version;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @deleteWallet.
  ///
  /// In es, this message translates to:
  /// **'Borrar wallet'**
  String get deleteWallet;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @portuguese.
  ///
  /// In es, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @french.
  ///
  /// In es, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @russian.
  ///
  /// In es, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @german.
  ///
  /// In es, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @italian.
  ///
  /// In es, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// No description provided for @korean.
  ///
  /// In es, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @chinese.
  ///
  /// In es, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @japanese.
  ///
  /// In es, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @swahili.
  ///
  /// In es, this message translates to:
  /// **'Kiswahili'**
  String get swahili;

  /// No description provided for @mnemonicNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el mnemonic'**
  String get mnemonicNotFound;

  /// No description provided for @createPin.
  ///
  /// In es, this message translates to:
  /// **'Crear PIN'**
  String get createPin;

  /// No description provided for @enterPinDigits.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un PIN de 4 dígitos'**
  String get enterPinDigits;

  /// No description provided for @confirmPin.
  ///
  /// In es, this message translates to:
  /// **'Confirmar PIN'**
  String get confirmPin;

  /// No description provided for @enterPinAgain.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el PIN nuevamente'**
  String get enterPinAgain;

  /// No description provided for @pinMismatch.
  ///
  /// In es, this message translates to:
  /// **'Los PIN no coinciden'**
  String get pinMismatch;

  /// No description provided for @pinActivated.
  ///
  /// In es, this message translates to:
  /// **'PIN activado'**
  String get pinActivated;

  /// No description provided for @pinDeactivated.
  ///
  /// In es, this message translates to:
  /// **'PIN desactivado'**
  String get pinDeactivated;

  /// No description provided for @verifyPin.
  ///
  /// In es, this message translates to:
  /// **'Verificar PIN'**
  String get verifyPin;

  /// No description provided for @enterCurrentPin.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu PIN actual'**
  String get enterCurrentPin;

  /// No description provided for @incorrectPin.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto'**
  String get incorrectPin;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar idioma'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In es, this message translates to:
  /// **'Idioma cambiado a {language}'**
  String languageChanged(String language);

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @aboutDescription.
  ///
  /// In es, this message translates to:
  /// **'Un wallet de Cashu con ADN cubano para el mundo entero. Hermano de LaChispa.'**
  String get aboutDescription;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el enlace'**
  String get couldNotOpenLink;

  /// No description provided for @deleteWalletQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Borrar wallet?'**
  String get deleteWalletQuestion;

  /// No description provided for @actionIrreversible.
  ///
  /// In es, this message translates to:
  /// **'Esta acción es irreversible'**
  String get actionIrreversible;

  /// No description provided for @deleteWalletWarning.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán todos los datos incluyendo tu seed phrase y tokens. Asegúrate de tener un backup.'**
  String get deleteWalletWarning;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In es, this message translates to:
  /// **'Escribe \"BORRAR\" para confirmar:'**
  String get typeDeleteToConfirm;

  /// No description provided for @deleteConfirmWord.
  ///
  /// In es, this message translates to:
  /// **'BORRAR'**
  String get deleteConfirmWord;

  /// No description provided for @deleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al borrar: {error}'**
  String deleteError(String error);

  /// No description provided for @recoverTokensTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar tokens'**
  String get recoverTokensTitle;

  /// No description provided for @recoverTokensDescription.
  ///
  /// In es, this message translates to:
  /// **'Escanea los mints para recuperar tokens asociados a tu seed phrase (NUT-13)'**
  String get recoverTokensDescription;

  /// No description provided for @useCurrentSeedPhrase.
  ///
  /// In es, this message translates to:
  /// **'Usar mi seed phrase actual'**
  String get useCurrentSeedPhrase;

  /// No description provided for @scanWithSavedWords.
  ///
  /// In es, this message translates to:
  /// **'Escanear mints con las 12 palabras guardadas'**
  String get scanWithSavedWords;

  /// No description provided for @useOtherSeedPhrase.
  ///
  /// In es, this message translates to:
  /// **'Usar otra seed phrase'**
  String get useOtherSeedPhrase;

  /// No description provided for @recoverFromOtherWords.
  ///
  /// In es, this message translates to:
  /// **'Recuperar tokens de otras 12 palabras'**
  String get recoverFromOtherWords;

  /// No description provided for @mintsToScan.
  ///
  /// In es, this message translates to:
  /// **'Mints a escanear:'**
  String get mintsToScan;

  /// No description provided for @allMints.
  ///
  /// In es, this message translates to:
  /// **'Todos los mints ({count})'**
  String allMints(int count);

  /// No description provided for @specificMint.
  ///
  /// In es, this message translates to:
  /// **'Un mint específico'**
  String get specificMint;

  /// No description provided for @enterMnemonicWords.
  ///
  /// In es, this message translates to:
  /// **'Ingresa las 12 palabras separadas por espacios...'**
  String get enterMnemonicWords;

  /// No description provided for @scanMints.
  ///
  /// In es, this message translates to:
  /// **'Escanear mints'**
  String get scanMints;

  /// No description provided for @selectMintToScan.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un mint para escanear'**
  String get selectMintToScan;

  /// No description provided for @mnemonicMustHaveWords.
  ///
  /// In es, this message translates to:
  /// **'El mnemonic debe tener 12 o 24 palabras'**
  String get mnemonicMustHaveWords;

  /// No description provided for @noConnectedMintsToScan.
  ///
  /// In es, this message translates to:
  /// **'No hay mints conectados para escanear'**
  String get noConnectedMintsToScan;

  /// No description provided for @recoveredTokens.
  ///
  /// In es, this message translates to:
  /// **'¡Recuperados {tokens} de {mints} mint(s)!'**
  String recoveredTokens(String tokens, int mints);

  /// No description provided for @scanCompleteNoTokens.
  ///
  /// In es, this message translates to:
  /// **'Escaneo completado. No se encontraron tokens nuevos.'**
  String get scanCompleteNoTokens;

  /// No description provided for @mintsWithError.
  ///
  /// In es, this message translates to:
  /// **'({count} mint(s) con error)'**
  String mintsWithError(int count);

  /// No description provided for @recoveredFromMint.
  ///
  /// In es, this message translates to:
  /// **'¡Recuperados {tokens} de {mint}!'**
  String recoveredFromMint(String tokens, String mint);

  /// No description provided for @noTokensFoundInMint.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron tokens en {mint}.'**
  String noTokensFoundInMint(String mint);

  /// No description provided for @recoveredAndTransferred.
  ///
  /// In es, this message translates to:
  /// **'¡Recuperados y transferidos {amount} {unit} a tu wallet!'**
  String recoveredAndTransferred(String amount, String unit);

  /// No description provided for @noTokensForMnemonic.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron tokens asociados a ese mnemonic.'**
  String get noTokensForMnemonic;

  /// No description provided for @noConnectedMints.
  ///
  /// In es, this message translates to:
  /// **'No hay mints conectados'**
  String get noConnectedMints;

  /// No description provided for @addMintToStart.
  ///
  /// In es, this message translates to:
  /// **'Agrega un mint para comenzar'**
  String get addMintToStart;

  /// No description provided for @addMint.
  ///
  /// In es, this message translates to:
  /// **'Agregar mint'**
  String get addMint;

  /// No description provided for @mintDeleted.
  ///
  /// In es, this message translates to:
  /// **'Mint eliminado'**
  String get mintDeleted;

  /// No description provided for @activeMintUpdated.
  ///
  /// In es, this message translates to:
  /// **'Mint activo actualizado'**
  String get activeMintUpdated;

  /// No description provided for @mintUrl.
  ///
  /// In es, this message translates to:
  /// **'URL del mint:'**
  String get mintUrl;

  /// No description provided for @mintUrlPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'https://mint.example.com'**
  String get mintUrlPlaceholder;

  /// No description provided for @urlMustStartWithHttps.
  ///
  /// In es, this message translates to:
  /// **'La URL debe comenzar con https://'**
  String get urlMustStartWithHttps;

  /// No description provided for @connectingToMint.
  ///
  /// In es, this message translates to:
  /// **'Conectando al mint...'**
  String get connectingToMint;

  /// No description provided for @mintAddedSuccessfully.
  ///
  /// In es, this message translates to:
  /// **'Mint agregado correctamente'**
  String get mintAddedSuccessfully;

  /// No description provided for @couldNotConnectToMint.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar al mint'**
  String get couldNotConnectToMint;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get add;

  /// No description provided for @success.
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @activeMint.
  ///
  /// In es, this message translates to:
  /// **'Mint activo'**
  String get activeMint;

  /// No description provided for @mintMessage.
  ///
  /// In es, this message translates to:
  /// **'Mensaje del Mint'**
  String get mintMessage;

  /// No description provided for @url.
  ///
  /// In es, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @currency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currency;

  /// No description provided for @unknown.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get unknown;

  /// No description provided for @useThisMint.
  ///
  /// In es, this message translates to:
  /// **'Usar este mint'**
  String get useThisMint;

  /// No description provided for @copyMintUrl.
  ///
  /// In es, this message translates to:
  /// **'Copiar URL del mint'**
  String get copyMintUrl;

  /// No description provided for @deleteMint.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mint'**
  String get deleteMint;

  /// No description provided for @copied.
  ///
  /// In es, this message translates to:
  /// **'{label} copiado'**
  String copied(String label);

  /// No description provided for @deleteMintConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mint'**
  String get deleteMintConfirmTitle;

  /// No description provided for @deleteMintConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Si tienes balance en este mint, se perderá. ¿Estás seguro?'**
  String get deleteMintConfirmMessage;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @offlineSend.
  ///
  /// In es, this message translates to:
  /// **'Envío Offline'**
  String get offlineSend;

  /// No description provided for @selectAll.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In es, this message translates to:
  /// **'Ninguno'**
  String get deselectAll;

  /// No description provided for @selectNotesToSend.
  ///
  /// In es, this message translates to:
  /// **'Selecciona las notas que deseas enviar:'**
  String get selectNotesToSend;

  /// No description provided for @totalToSend.
  ///
  /// In es, this message translates to:
  /// **'Total a enviar'**
  String get totalToSend;

  /// No description provided for @notesSelected.
  ///
  /// In es, this message translates to:
  /// **'{count} notas seleccionadas'**
  String notesSelected(int count);

  /// No description provided for @loadingProofsError.
  ///
  /// In es, this message translates to:
  /// **'Error cargando proofs: {error}'**
  String loadingProofsError(String error);

  /// No description provided for @creatingTokenError.
  ///
  /// In es, this message translates to:
  /// **'Error creando token: {error}'**
  String creatingTokenError(String error);

  /// No description provided for @unknownState.
  ///
  /// In es, this message translates to:
  /// **'Estado desconocido'**
  String get unknownState;

  /// No description provided for @depositAmountTitle.
  ///
  /// In es, this message translates to:
  /// **'Depositar {amount} {unit}'**
  String depositAmountTitle(String amount, String unit);

  /// No description provided for @receiveNow.
  ///
  /// In es, this message translates to:
  /// **'Recibir ahora'**
  String get receiveNow;

  /// No description provided for @receiveLater.
  ///
  /// In es, this message translates to:
  /// **'Recibir después'**
  String get receiveLater;

  /// No description provided for @tokenSavedForLater.
  ///
  /// In es, this message translates to:
  /// **'Token guardado para reclamar después'**
  String get tokenSavedForLater;

  /// No description provided for @noConnectionTokenSaved.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Token guardado para reclamar después.'**
  String get noConnectionTokenSaved;

  /// No description provided for @unknownMintOffline.
  ///
  /// In es, this message translates to:
  /// **'Este token es de un mint desconocido. Conéctate a internet para agregarlo y reclamar el token.'**
  String get unknownMintOffline;

  /// No description provided for @noConnectionTryLater.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión al mint. Intenta más tarde.'**
  String get noConnectionTryLater;

  /// No description provided for @saveTokenError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar el token. Intenta de nuevo.'**
  String get saveTokenError;

  /// No description provided for @pendingTokenLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Límite de tokens pendientes alcanzado (max 50)'**
  String get pendingTokenLimitReached;

  /// No description provided for @filterToReceive.
  ///
  /// In es, this message translates to:
  /// **'Para recibir'**
  String get filterToReceive;

  /// No description provided for @noPendingTokens.
  ///
  /// In es, this message translates to:
  /// **'Sin tokens pendientes'**
  String get noPendingTokens;

  /// No description provided for @noPendingTokensHint.
  ///
  /// In es, this message translates to:
  /// **'Guarda tokens para reclamar después'**
  String get noPendingTokensHint;

  /// No description provided for @pendingBadge.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTE'**
  String get pendingBadge;

  /// No description provided for @expiresInDays.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, =1{Expira en 1 día} other{Expira en {days} días}}'**
  String expiresInDays(int days);

  /// No description provided for @retryCount.
  ///
  /// In es, this message translates to:
  /// **'{count} reintentos'**
  String retryCount(int count);

  /// No description provided for @claimNow.
  ///
  /// In es, this message translates to:
  /// **'Reclamar ahora'**
  String get claimNow;

  /// No description provided for @pendingTokenClaimedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Reclamados {amount} {unit}'**
  String pendingTokenClaimedSuccess(String amount, String unit);

  /// No description provided for @pendingTokensClaimed.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Reclamado 1 token ({amount} {unit})} other{Reclamados {count} tokens ({amount} {unit})}}'**
  String pendingTokensClaimed(int count, String amount, String unit);

  /// No description provided for @scan.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get scan;

  /// No description provided for @scanQrCode.
  ///
  /// In es, this message translates to:
  /// **'Escanear QR'**
  String get scanQrCode;

  /// No description provided for @scanCashuToken.
  ///
  /// In es, this message translates to:
  /// **'Escanear token Cashu'**
  String get scanCashuToken;

  /// No description provided for @scanLightningInvoice.
  ///
  /// In es, this message translates to:
  /// **'Escanear invoice'**
  String get scanLightningInvoice;

  /// No description provided for @scanningAnimatedQr.
  ///
  /// In es, this message translates to:
  /// **'Escaneando QR animado...'**
  String get scanningAnimatedQr;

  /// No description provided for @pointCameraAtQr.
  ///
  /// In es, this message translates to:
  /// **'Apunta la cámara al código QR'**
  String get pointCameraAtQr;

  /// No description provided for @pointCameraAtCashuQr.
  ///
  /// In es, this message translates to:
  /// **'Apunta la cámara al QR del token Cashu'**
  String get pointCameraAtCashuQr;

  /// No description provided for @pointCameraAtInvoiceQr.
  ///
  /// In es, this message translates to:
  /// **'Apunta la cámara al QR del invoice'**
  String get pointCameraAtInvoiceQr;

  /// No description provided for @unrecognizedQrCode.
  ///
  /// In es, this message translates to:
  /// **'Código QR no reconocido'**
  String get unrecognizedQrCode;

  /// No description provided for @scanCashuTokenHint.
  ///
  /// In es, this message translates to:
  /// **'Escanea un token Cashu (cashuA... o cashuB...)'**
  String get scanCashuTokenHint;

  /// No description provided for @scanLightningInvoiceHint.
  ///
  /// In es, this message translates to:
  /// **'Escanea un invoice Lightning (lnbc...)'**
  String get scanLightningInvoiceHint;

  /// No description provided for @addMintQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Agregar este mint?'**
  String get addMintQuestion;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Permiso de cámara denegado'**
  String get cameraPermissionDenied;

  /// No description provided for @paymentRequestTitle.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de pago'**
  String get paymentRequestTitle;

  /// No description provided for @paymentRequestFrom.
  ///
  /// In es, this message translates to:
  /// **'Solicitud de'**
  String get paymentRequestFrom;

  /// No description provided for @paymentRequestAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto solicitado'**
  String get paymentRequestAmount;

  /// No description provided for @paymentRequestDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get paymentRequestDescription;

  /// No description provided for @paymentRequestMints.
  ///
  /// In es, this message translates to:
  /// **'Mints aceptados'**
  String get paymentRequestMints;

  /// No description provided for @paymentRequestAnyMint.
  ///
  /// In es, this message translates to:
  /// **'Cualquier mint'**
  String get paymentRequestAnyMint;

  /// No description provided for @paymentRequestPay.
  ///
  /// In es, this message translates to:
  /// **'Pagar'**
  String get paymentRequestPay;

  /// No description provided for @paymentRequestPaying.
  ///
  /// In es, this message translates to:
  /// **'Pagando...'**
  String get paymentRequestPaying;

  /// No description provided for @paymentRequestSuccess.
  ///
  /// In es, this message translates to:
  /// **'Pago enviado correctamente'**
  String get paymentRequestSuccess;

  /// No description provided for @paymentRequestNoTransport.
  ///
  /// In es, this message translates to:
  /// **'Esta solicitud no tiene método de entrega configurado'**
  String get paymentRequestNoTransport;

  /// No description provided for @paymentRequestTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get paymentRequestTransport;

  /// No description provided for @paymentRequestMintNotAccepted.
  ///
  /// In es, this message translates to:
  /// **'Tu mint activo no está en la lista de mints aceptados'**
  String get paymentRequestMintNotAccepted;

  /// No description provided for @paymentRequestUnitMismatch.
  ///
  /// In es, this message translates to:
  /// **'Unidad incompatible: la solicitud requiere {unit}'**
  String paymentRequestUnitMismatch(String unit);

  /// No description provided for @paymentRequestInsufficientBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance insuficiente'**
  String get paymentRequestInsufficientBalance;

  /// No description provided for @paymentRequestErrorParsing.
  ///
  /// In es, this message translates to:
  /// **'Error al leer la solicitud de pago'**
  String get paymentRequestErrorParsing;

  /// No description provided for @p2pkTitle.
  ///
  /// In es, this message translates to:
  /// **'Claves P2PK'**
  String get p2pkTitle;

  /// No description provided for @p2pkSettingsDescription.
  ///
  /// In es, this message translates to:
  /// **'Recibir ecash bloqueado'**
  String get p2pkSettingsDescription;

  /// No description provided for @p2pkExperimental.
  ///
  /// In es, this message translates to:
  /// **'P2PK es experimental. Úsala con precaución.'**
  String get p2pkExperimental;

  /// No description provided for @p2pkPendingSendWarning.
  ///
  /// In es, this message translates to:
  /// **'Tienes un envío P2PK pendiente. Ve al historial y presiona actualizar después de que el destinatario reclame el token.'**
  String get p2pkPendingSendWarning;

  /// No description provided for @p2pkExperimentalShort.
  ///
  /// In es, this message translates to:
  /// **'Experimental'**
  String get p2pkExperimentalShort;

  /// No description provided for @p2pkPrimaryKey.
  ///
  /// In es, this message translates to:
  /// **'Clave Principal'**
  String get p2pkPrimaryKey;

  /// No description provided for @p2pkDerived.
  ///
  /// In es, this message translates to:
  /// **'Derivada'**
  String get p2pkDerived;

  /// No description provided for @p2pkImported.
  ///
  /// In es, this message translates to:
  /// **'Importada'**
  String get p2pkImported;

  /// No description provided for @p2pkImportedKeys.
  ///
  /// In es, this message translates to:
  /// **'Claves Importadas'**
  String get p2pkImportedKeys;

  /// No description provided for @p2pkNoImportedKeys.
  ///
  /// In es, this message translates to:
  /// **'No hay claves importadas'**
  String get p2pkNoImportedKeys;

  /// No description provided for @p2pkShowQR.
  ///
  /// In es, this message translates to:
  /// **'Mostrar QR'**
  String get p2pkShowQR;

  /// No description provided for @p2pkCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get p2pkCopy;

  /// No description provided for @p2pkImportNsec.
  ///
  /// In es, this message translates to:
  /// **'Importar nsec'**
  String get p2pkImportNsec;

  /// No description provided for @p2pkImport.
  ///
  /// In es, this message translates to:
  /// **'Importar'**
  String get p2pkImport;

  /// No description provided for @p2pkEnterLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre para esta clave'**
  String get p2pkEnterLabel;

  /// No description provided for @p2pkLockToKey.
  ///
  /// In es, this message translates to:
  /// **'Envío con firma P2PK'**
  String get p2pkLockToKey;

  /// No description provided for @p2pkLockDescription.
  ///
  /// In es, this message translates to:
  /// **'Solo el destinatario podrá reclamar'**
  String get p2pkLockDescription;

  /// No description provided for @p2pkReceiverPubkey.
  ///
  /// In es, this message translates to:
  /// **'npub1... o hex (64/66 caracteres)'**
  String get p2pkReceiverPubkey;

  /// No description provided for @p2pkInvalidPubkey.
  ///
  /// In es, this message translates to:
  /// **'Clave pública inválida'**
  String get p2pkInvalidPubkey;

  /// No description provided for @p2pkInvalidPrivateKey.
  ///
  /// In es, this message translates to:
  /// **'Clave privada inválida'**
  String get p2pkInvalidPrivateKey;

  /// No description provided for @p2pkLockedToYou.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado para ti'**
  String get p2pkLockedToYou;

  /// No description provided for @p2pkLockedToOther.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado para otra clave'**
  String get p2pkLockedToOther;

  /// No description provided for @p2pkCannotUnlock.
  ///
  /// In es, this message translates to:
  /// **'No tienes la clave para desbloquear este token'**
  String get p2pkCannotUnlock;

  /// No description provided for @p2pkEnterPrivateKey.
  ///
  /// In es, this message translates to:
  /// **'Ingresa la clave privada (nsec)'**
  String get p2pkEnterPrivateKey;

  /// No description provided for @p2pkDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar clave'**
  String get p2pkDeleteTitle;

  /// No description provided for @p2pkDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar esta clave? No podrás recibir tokens bloqueados a ella.'**
  String get p2pkDeleteConfirm;

  /// No description provided for @p2pkRequiresConnection.
  ///
  /// In es, this message translates to:
  /// **'P2PK requiere conexión al mint'**
  String get p2pkRequiresConnection;

  /// No description provided for @p2pkErrorMaxKeysReached.
  ///
  /// In es, this message translates to:
  /// **'Máximo de claves importadas alcanzado (10)'**
  String get p2pkErrorMaxKeysReached;

  /// No description provided for @p2pkErrorInvalidNsec.
  ///
  /// In es, this message translates to:
  /// **'nsec inválido'**
  String get p2pkErrorInvalidNsec;

  /// No description provided for @p2pkErrorKeyAlreadyExists.
  ///
  /// In es, this message translates to:
  /// **'Esta clave ya existe'**
  String get p2pkErrorKeyAlreadyExists;

  /// No description provided for @p2pkErrorKeyNotFound.
  ///
  /// In es, this message translates to:
  /// **'Clave no encontrada'**
  String get p2pkErrorKeyNotFound;

  /// No description provided for @p2pkErrorCannotDeletePrimary.
  ///
  /// In es, this message translates to:
  /// **'No se puede eliminar la clave principal'**
  String get p2pkErrorCannotDeletePrimary;

  /// No description provided for @request.
  ///
  /// In es, this message translates to:
  /// **'Solicitar'**
  String get request;

  /// No description provided for @requestPayment.
  ///
  /// In es, this message translates to:
  /// **'Solicitar pago'**
  String get requestPayment;

  /// No description provided for @requestPaymentDescription.
  ///
  /// In es, this message translates to:
  /// **'Generar solicitud de pago unificada'**
  String get requestPaymentDescription;

  /// No description provided for @generateRequest.
  ///
  /// In es, this message translates to:
  /// **'Generar solicitud'**
  String get generateRequest;

  /// No description provided for @generatingRequest.
  ///
  /// In es, this message translates to:
  /// **'Generando solicitud...'**
  String get generatingRequest;

  /// No description provided for @requestPaymentReceived.
  ///
  /// In es, this message translates to:
  /// **'Pago recibido'**
  String get requestPaymentReceived;

  /// No description provided for @requestDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get requestDescriptionHint;

  /// No description provided for @universal.
  ///
  /// In es, this message translates to:
  /// **'Universal'**
  String get universal;

  /// No description provided for @copiedToClipboard.
  ///
  /// In es, this message translates to:
  /// **'Copiado al portapapeles'**
  String get copiedToClipboard;

  /// No description provided for @swap.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get swap;

  /// No description provided for @swapDescription.
  ///
  /// In es, this message translates to:
  /// **'Convertir entre sats y USD'**
  String get swapDescription;

  /// No description provided for @swapFrom.
  ///
  /// In es, this message translates to:
  /// **'De'**
  String get swapFrom;

  /// No description provided for @swapTo.
  ///
  /// In es, this message translates to:
  /// **'A'**
  String get swapTo;

  /// No description provided for @swapAction.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get swapAction;

  /// No description provided for @swapEstimatedFee.
  ///
  /// In es, this message translates to:
  /// **'Fee estimado'**
  String get swapEstimatedFee;

  /// No description provided for @swapUseAll.
  ///
  /// In es, this message translates to:
  /// **'Usar todo'**
  String get swapUseAll;

  /// No description provided for @swapMinimum.
  ///
  /// In es, this message translates to:
  /// **'Mínimo: {amount}'**
  String swapMinimum(String amount);

  /// No description provided for @swapProcessing.
  ///
  /// In es, this message translates to:
  /// **'Procesando swap...'**
  String get swapProcessing;

  /// No description provided for @swapSuccess.
  ///
  /// In es, this message translates to:
  /// **'Swap completado'**
  String get swapSuccess;

  /// No description provided for @swapErrorInsufficient.
  ///
  /// In es, this message translates to:
  /// **'Saldo insuficiente'**
  String get swapErrorInsufficient;

  /// No description provided for @swapErrorExpired.
  ///
  /// In es, this message translates to:
  /// **'La cotización ha expirado'**
  String get swapErrorExpired;

  /// No description provided for @swapErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error en el swap: {error}'**
  String swapErrorGeneric(String error);

  /// No description provided for @swapChartUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Precio no disponible · Toca para reintentar'**
  String get swapChartUnavailable;

  /// No description provided for @swapChartMinMax.
  ///
  /// In es, this message translates to:
  /// **'24h  Mín: {minPrice} — Máx: {maxPrice}'**
  String swapChartMinMax(String minPrice, String maxPrice);

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @privacyTitle.
  ///
  /// In es, this message translates to:
  /// **'NO RECOPILAMOS NADA'**
  String get privacyTitle;

  /// No description provided for @privacyGoodbye.
  ///
  /// In es, this message translates to:
  /// **'ADIÓS'**
  String get privacyGoodbye;

  /// No description provided for @privacyKeepReading.
  ///
  /// In es, this message translates to:
  /// **'(sigue leyendo si quieres…)'**
  String get privacyKeepReading;

  /// No description provided for @privacyBody.
  ///
  /// In es, this message translates to:
  /// **'No sabemos quién eres\nNo sabemos cuánto tienes\nNo sabemos qué haces'**
  String get privacyBody;

  /// No description provided for @privacyConclusion.
  ///
  /// In es, this message translates to:
  /// **'La mejor forma de proteger tus datos\nes no tenerlos'**
  String get privacyConclusion;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'sw',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return L10nDe();
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
    case 'fr':
      return L10nFr();
    case 'it':
      return L10nIt();
    case 'ja':
      return L10nJa();
    case 'ko':
      return L10nKo();
    case 'pt':
      return L10nPt();
    case 'ru':
      return L10nRu();
    case 'sw':
      return L10nSw();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
