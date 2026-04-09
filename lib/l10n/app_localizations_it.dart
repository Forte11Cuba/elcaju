// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class L10nIt extends L10n {
  L10nIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'Il tuo portafoglio ecash privato';

  @override
  String get loadingMessage1 => 'Crittografia delle tue monete...';

  @override
  String get loadingMessage2 => 'Preparazione dei tuoi e-token...';

  @override
  String get loadingMessage3 => 'Connessione al Mint...';

  @override
  String get loadingMessage4 => 'Privacy di default.';

  @override
  String get loadingMessage5 => 'Firma cieca dei token...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = Privacy + Libertà';

  @override
  String get aboutTagline => 'Privacy senza confini.';

  @override
  String get welcomeTitle => 'Benvenuto su ElCaju';

  @override
  String get welcomeSubtitle => 'Cashu per il mondo. Fatto a Cuba.';

  @override
  String get createWallet => 'Crea nuovo portafoglio';

  @override
  String get restoreWallet => 'Ripristina portafoglio';

  @override
  String get createWalletTitle => 'Crea portafoglio';

  @override
  String get creatingWallet => 'Creazione del tuo portafoglio...';

  @override
  String get generatingSeed => 'Generazione sicura della tua frase seed';

  @override
  String get createWalletDescription =>
      'Verrà generata una frase seed di 12 parole.\nConservala in un luogo sicuro.';

  @override
  String get generateWallet => 'Genera portafoglio';

  @override
  String get walletCreated => 'Portafoglio creato!';

  @override
  String get walletCreatedDescription =>
      'Il tuo portafoglio è pronto. Ti consigliamo di fare il backup della frase seed ora.';

  @override
  String get backupWarning =>
      'Senza backup, perderai l\'accesso ai tuoi fondi se perdi il dispositivo.';

  @override
  String get backupNow => 'Backup adesso';

  @override
  String get backupLater => 'Fallo dopo';

  @override
  String get backupTitle => 'Backup';

  @override
  String get seedPhraseTitle => 'La tua frase seed';

  @override
  String get seedPhraseDescription =>
      'Conserva queste 12 parole in ordine. Sono l\'unico modo per recuperare il tuo portafoglio.';

  @override
  String get revealSeedPhrase => 'Mostra frase seed';

  @override
  String get tapToReveal => 'Tocca il pulsante per mostrare\nla tua frase seed';

  @override
  String get copyToClipboard => 'Copia negli appunti';

  @override
  String get seedCopied => 'Frase copiata negli appunti';

  @override
  String get neverShareSeed =>
      'Non condividere mai la tua frase seed con nessuno.';

  @override
  String get confirmBackup => 'Ho salvato la mia frase seed in un luogo sicuro';

  @override
  String get continue_ => 'Continua';

  @override
  String get restoreTitle => 'Ripristina portafoglio';

  @override
  String get enterSeedPhrase => 'Inserisci la tua frase seed';

  @override
  String get enterSeedDescription =>
      'Scrivi le 12 o 24 parole separate da spazi.';

  @override
  String get seedPlaceholder => 'parola1 parola2 parola3 ...';

  @override
  String wordCount(int count) {
    return '$count parole';
  }

  @override
  String get needWords => '(servono 12 o 24)';

  @override
  String get restoreScanningMint => 'Scansione del mint per token esistenti...';

  @override
  String restoreError(String error) {
    return 'Errore di ripristino: $error';
  }

  @override
  String get homeTitle => 'Home';

  @override
  String get receive => 'Ricevi';

  @override
  String get send => 'Invia';

  @override
  String get sendAction => 'Invia ↗';

  @override
  String get receiveAction => '↘ Ricevi';

  @override
  String get deposit => 'Deposita';

  @override
  String get withdraw => 'Preleva';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => 'Cronologia';

  @override
  String get noTransactions => 'Nessuna transazione';

  @override
  String get depositOrReceive => 'Deposita o ricevi sats per iniziare';

  @override
  String get noMint => 'Nessun mint';

  @override
  String get balance => 'Saldo';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'Incolla token ecash';

  @override
  String get generateInvoiceToDeposit => 'Genera fattura per depositare';

  @override
  String get createEcashToken => 'Crea token ecash';

  @override
  String get payLightningInvoice => 'Paga fattura Lightning';

  @override
  String get receiveCashu => 'Ricevi Cashu';

  @override
  String get pasteTheCashuToken => 'Incolla il token Cashu:';

  @override
  String get pasteFromClipboard => 'Incolla dagli appunti';

  @override
  String get validToken => 'Token valido';

  @override
  String get invalidToken => 'Token non valido o malformato';

  @override
  String get amount => 'Importo:';

  @override
  String get mint => 'Mint:';

  @override
  String get claiming => 'Riscatto...';

  @override
  String get claimTokens => 'Riscatta token';

  @override
  String get tokensReceived => 'Token ricevuti';

  @override
  String get backToHome => 'Torna alla home';

  @override
  String get tokenAlreadyClaimed => 'Questo token è già stato riscattato';

  @override
  String get unknownMint => 'Token da mint sconosciuto';

  @override
  String claimError(String error) {
    return 'Errore di riscatto: $error';
  }

  @override
  String get sendCashu => 'Invia Cashu';

  @override
  String get selectNotesManually => 'Seleziona note manualmente';

  @override
  String get amountToSend => 'Importo da inviare:';

  @override
  String get available => 'Disponibile:';

  @override
  String get max => '(Max)';

  @override
  String get memoOptional => 'Memo (opzionale):';

  @override
  String get memoPlaceholder => 'A cosa serve questo pagamento?';

  @override
  String get creatingToken => 'Creazione token...';

  @override
  String get createToken => 'Crea token';

  @override
  String get noActiveMint => 'Nessun mint attivo';

  @override
  String get offlineModeMessage => 'Nessuna connessione. Modalità offline...';

  @override
  String get confirmSend => 'Conferma invio';

  @override
  String get confirm => 'Conferma';

  @override
  String get cancel => 'Annulla';

  @override
  String get insufficientBalance => 'Saldo insufficiente';

  @override
  String tokenCreationError(String error) {
    return 'Errore creazione token: $error';
  }

  @override
  String get tokenCreated => 'Token creato';

  @override
  String get copy => 'Copia';

  @override
  String get share => 'Condividi';

  @override
  String get tokenCashu => 'Token Cashu';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Token Cashu (QR animato - $fragments frammenti UR)';
  }

  @override
  String get keepTokenWarning =>
      'Conserva questo token finché il destinatario non lo riscatta. Se lo perdi, perderai i fondi.';

  @override
  String get tokenCopiedToClipboard => 'Token copiato negli appunti';

  @override
  String get copyAsEmoji => 'Copia come emoji';

  @override
  String get emojiCopiedToClipboard => 'Token copiato come emoji 🥜';

  @override
  String get peanutDecodeError =>
      'Impossibile decodificare il token emoji. Potrebbe essere corrotto.';

  @override
  String get nfcWrite => 'Scrivi su tag NFC';

  @override
  String get nfcRead => 'Leggi tag NFC';

  @override
  String get nfcHoldNear => 'Avvicina il dispositivo al tag NFC...';

  @override
  String get nfcWriteSuccess => 'Token scritto sul tag NFC';

  @override
  String nfcWriteError(String error) {
    return 'Errore NFC scrittura: $error';
  }

  @override
  String nfcReadError(String error) {
    return 'Errore NFC lettura: $error';
  }

  @override
  String get nfcDisabled => 'NFC è disattivato. Attivalo nelle Impostazioni.';

  @override
  String get nfcUnsupported => 'Questo dispositivo non supporta NFC';

  @override
  String get amountToDeposit => 'Importo da depositare:';

  @override
  String get descriptionOptional => 'Descrizione (opzionale):';

  @override
  String get depositPlaceholder => 'A cosa serve questo deposito?';

  @override
  String get generating => 'Generazione...';

  @override
  String get generateInvoice => 'Genera fattura';

  @override
  String get depositLightning => 'Deposita Lightning';

  @override
  String get payInvoiceTitle => 'Paga fattura';

  @override
  String get generatingInvoice => 'Generazione fattura...';

  @override
  String get waitingForPayment => 'In attesa del pagamento...';

  @override
  String get paymentReceived => 'Pagamento ricevuto';

  @override
  String get tokensIssued => 'Token emessi!';

  @override
  String get error => 'Errore';

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get back => 'Indietro';

  @override
  String get copyInvoice => 'Copia fattura';

  @override
  String get description => 'Descrizione:';

  @override
  String get invoiceCopiedToClipboard => 'Fattura copiata negli appunti';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit depositati';
  }

  @override
  String get pasteLightningInvoice => 'Incolla la fattura Lightning:';

  @override
  String get gettingQuote => 'Ottenimento preventivo...';

  @override
  String get validInvoice => 'Fattura valida';

  @override
  String get invalidInvoice => 'Fattura non valida';

  @override
  String get invalidInvoiceMalformed => 'Fattura non valida o malformata';

  @override
  String get feeReserved => 'Commissione riservata:';

  @override
  String get total => 'Totale:';

  @override
  String get paying => 'Pagamento...';

  @override
  String get payInvoice => 'Paga fattura';

  @override
  String get confirmPayment => 'Conferma pagamento';

  @override
  String get pay => 'Paga';

  @override
  String get fee => 'commissione';

  @override
  String get invoiceExpired => 'Fattura scaduta';

  @override
  String get amountOutOfRange => 'Importo fuori dall\'intervallo consentito';

  @override
  String resolvingType(String type) {
    return 'Risoluzione $type...';
  }

  @override
  String get invoiceAlreadyPaid => 'Fattura già pagata';

  @override
  String paymentError(String error) {
    return 'Errore di pagamento: $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit inviati';
  }

  @override
  String get filterAll => 'Tutti';

  @override
  String get filterPending => 'In attesa';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Ricevi token Cashu per iniziare';

  @override
  String get noPendingTransactions => 'Nessuna transazione in attesa';

  @override
  String get allTransactionsCompleted =>
      'Tutte le tue transazioni sono completate';

  @override
  String get noEcashTransactions => 'Nessuna transazione Ecash';

  @override
  String get sendOrReceiveTokens => 'Invia o ricevi token Cashu';

  @override
  String get noLightningTransactions => 'Nessuna transazione Lightning';

  @override
  String get depositOrWithdrawLightning => 'Deposita o preleva via Lightning';

  @override
  String get pendingStatus => 'In attesa';

  @override
  String get receivedStatus => 'Ricevuto';

  @override
  String get sentStatus => 'Inviato';

  @override
  String get now => 'Adesso';

  @override
  String agoMinutes(int minutes) {
    return '$minutes min fa';
  }

  @override
  String agoHours(int hours) {
    return '$hours ore fa';
  }

  @override
  String agoDays(int days) {
    return '$days giorni fa';
  }

  @override
  String get lightningInvoice => 'Fattura Lightning';

  @override
  String get receivedEcash => 'Ecash ricevuto';

  @override
  String get sentEcash => 'Ecash inviato';

  @override
  String get outgoingLightningPayment => 'Pagamento Lightning in uscita';

  @override
  String get invoiceNotAvailable => 'Fattura non disponibile';

  @override
  String get tokenNotAvailable => 'Token non disponibile';

  @override
  String get unit => 'Unità';

  @override
  String get status => 'Stato';

  @override
  String get pending => 'In attesa';

  @override
  String get memo => 'Memo';

  @override
  String get copyInvoiceButton => 'COPIA FATTURA';

  @override
  String get copyButton => 'COPIA';

  @override
  String get invoiceCopied => 'Fattura copiata';

  @override
  String get tokenCopied => 'Token copiato';

  @override
  String get speed => 'VELOCITÀ:';

  @override
  String get settings => 'Impostazioni';

  @override
  String get walletSection => 'PORTAFOGLIO';

  @override
  String get backupSeedPhrase => 'Backup frase seed';

  @override
  String get viewRecoveryWords => 'Visualizza le parole di recupero';

  @override
  String get connectedMints => 'Mint connessi';

  @override
  String get manageCashuMints => 'Gestisci i tuoi mint Cashu';

  @override
  String get pinAccess => 'PIN di accesso';

  @override
  String get pinEnabled => 'Attivato';

  @override
  String get protectWithPin => 'Proteggi l\'app con PIN';

  @override
  String get recoverTokens => 'Recupera token';

  @override
  String get scanMintsWithSeed => 'Scansiona mint con frase seed';

  @override
  String get appearanceSection => 'LINGUA';

  @override
  String get language => 'Lingua';

  @override
  String get informationSection => 'INFORMAZIONI';

  @override
  String get version => 'Versione';

  @override
  String get about => 'Info';

  @override
  String get deleteWallet => 'Elimina portafoglio';

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
  String get mnemonicNotFound => 'Mnemonic non trovato';

  @override
  String get createPin => 'Crea PIN';

  @override
  String get enterPinDigits => 'Inserisci un PIN a 4 cifre';

  @override
  String get confirmPin => 'Conferma PIN';

  @override
  String get enterPinAgain => 'Inserisci di nuovo il PIN';

  @override
  String get pinMismatch => 'I PIN non corrispondono';

  @override
  String get pinActivated => 'PIN attivato';

  @override
  String get pinDeactivated => 'PIN disattivato';

  @override
  String get verifyPin => 'Verifica PIN';

  @override
  String get enterCurrentPin => 'Inserisci il tuo PIN attuale';

  @override
  String get incorrectPin => 'PIN errato';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String languageChanged(String language) {
    return 'Lingua cambiata in $language';
  }

  @override
  String get close => 'Chiudi';

  @override
  String get aboutDescription =>
      'Un portafoglio Cashu con DNA cubano per il mondo intero. Fratello di LaChispa.';

  @override
  String get couldNotOpenLink => 'Impossibile aprire il link';

  @override
  String get deleteWalletQuestion => 'Eliminare portafoglio?';

  @override
  String get actionIrreversible => 'Questa azione è irreversibile';

  @override
  String get deleteWalletWarning =>
      'Tutti i dati verranno eliminati, inclusa la frase seed e i token. Assicurati di avere un backup.';

  @override
  String get typeDeleteToConfirm => 'Scrivi \"ELIMINA\" per confermare:';

  @override
  String get deleteConfirmWord => 'ELIMINA';

  @override
  String deleteError(String error) {
    return 'Errore di eliminazione: $error';
  }

  @override
  String get recoverTokensTitle => 'Recupera token';

  @override
  String get recoverTokensDescription =>
      'Scansiona i mint per recuperare i token associati alla tua frase seed (NUT-13)';

  @override
  String get useCurrentSeedPhrase => 'Usa la mia frase seed attuale';

  @override
  String get scanWithSavedWords => 'Scansiona i mint con le 12 parole salvate';

  @override
  String get useOtherSeedPhrase => 'Usa un\'altra frase seed';

  @override
  String get recoverFromOtherWords => 'Recupera token da altre 12 parole';

  @override
  String get mintsToScan => 'Mint da scansionare:';

  @override
  String allMints(int count) {
    return 'Tutti i mint ($count)';
  }

  @override
  String get specificMint => 'Un mint specifico';

  @override
  String get enterMnemonicWords =>
      'Inserisci le 12 parole separate da spazi...';

  @override
  String get scanMints => 'Scansiona mint';

  @override
  String get selectMintToScan => 'Seleziona un mint da scansionare';

  @override
  String get mnemonicMustHaveWords => 'Il mnemonic deve avere 12 o 24 parole';

  @override
  String get noConnectedMintsToScan => 'Nessun mint connesso da scansionare';

  @override
  String recoveredTokens(String tokens, int mints) {
    return 'Recuperati $tokens da $mints mint!';
  }

  @override
  String get scanCompleteNoTokens =>
      'Scansione completata. Nessun nuovo token trovato.';

  @override
  String mintsWithError(int count) {
    return '($count mint con errore)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return 'Recuperati $tokens da $mint!';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return 'Nessun token trovato in $mint.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return 'Recuperati e trasferiti $amount $unit nel tuo portafoglio!';
  }

  @override
  String get noTokensForMnemonic =>
      'Nessun token trovato associato a questo mnemonic.';

  @override
  String get noConnectedMints => 'Nessun mint connesso';

  @override
  String get addMintToStart => 'Aggiungi un mint per iniziare';

  @override
  String get addMint => 'Aggiungi mint';

  @override
  String get mintDeleted => 'Mint eliminato';

  @override
  String get activeMintUpdated => 'Mint attivo aggiornato';

  @override
  String get mintUrl => 'URL del mint:';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'L\'URL deve iniziare con https://';

  @override
  String get connectingToMint => 'Connessione al mint...';

  @override
  String get mintAddedSuccessfully => 'Mint aggiunto con successo';

  @override
  String get couldNotConnectToMint => 'Impossibile connettersi al mint';

  @override
  String get add => 'Aggiungi';

  @override
  String get success => 'Successo';

  @override
  String get loading => 'Caricamento...';

  @override
  String get retry => 'Riprova';

  @override
  String get activeMint => 'Mint attivo';

  @override
  String get mintMessage => 'Messaggio del Mint';

  @override
  String get url => 'URL';

  @override
  String get currency => 'Valuta';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get useThisMint => 'Usa questo mint';

  @override
  String get copyMintUrl => 'Copia URL del mint';

  @override
  String get deleteMint => 'Elimina mint';

  @override
  String copied(String label) {
    return '$label copiato';
  }

  @override
  String get deleteMintConfirmTitle => 'Elimina mint';

  @override
  String get deleteMintConfirmMessage =>
      'Se hai saldo su questo mint, verrà perso. Sei sicuro?';

  @override
  String get delete => 'Elimina';

  @override
  String get offlineSend => 'Invio offline';

  @override
  String get selectAll => 'Tutto';

  @override
  String get deselectAll => 'Nessuno';

  @override
  String get selectNotesToSend => 'Seleziona le note da inviare:';

  @override
  String get totalToSend => 'Totale da inviare';

  @override
  String notesSelected(int count) {
    return '$count note selezionate';
  }

  @override
  String loadingProofsError(String error) {
    return 'Errore caricamento prove: $error';
  }

  @override
  String creatingTokenError(String error) {
    return 'Errore creazione token: $error';
  }

  @override
  String get unknownState => 'Stato sconosciuto';

  @override
  String depositAmountTitle(String amount, String unit) {
    return 'Deposita $amount $unit';
  }

  @override
  String get receiveNow => 'Ricevi adesso';

  @override
  String get receiveLater => 'Ricevi dopo';

  @override
  String get tokenSavedForLater => 'Token salvato per riscattarlo dopo';

  @override
  String get noConnectionTokenSaved =>
      'Nessuna connessione. Token salvato per riscattarlo dopo.';

  @override
  String get unknownMintOffline =>
      'Questo token proviene da un mint sconosciuto. Connettiti a internet per aggiungerlo e riscattare il token.';

  @override
  String get noConnectionTryLater =>
      'Nessuna connessione al mint. Riprova più tardi.';

  @override
  String get saveTokenError => 'Errore nel salvare il token. Riprova.';

  @override
  String get pendingTokenLimitReached =>
      'Limite token in attesa raggiunto (max 50)';

  @override
  String get filterToReceive => 'Da ricevere';

  @override
  String get noPendingTokens => 'Nessun token in attesa';

  @override
  String get noPendingTokensHint => 'Salva token per riscattarli dopo';

  @override
  String get pendingBadge => 'IN ATTESA';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Scade tra $days giorni',
      one: 'Scade tra 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count tentativi';
  }

  @override
  String get claimNow => 'Riscatta adesso';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return 'Riscattati $amount $unit';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Riscattati $count token ($amount $unit)',
      one: 'Riscattato 1 token ($amount $unit)',
    );
    return '$_temp0';
  }

  @override
  String get scan => 'Scansiona';

  @override
  String get scanQrCode => 'Scansiona QR';

  @override
  String get scanCashuToken => 'Scansiona token Cashu';

  @override
  String get scanLightningInvoice => 'Scansiona fattura';

  @override
  String get scanningAnimatedQr => 'Scansione QR animato...';

  @override
  String get pointCameraAtQr => 'Punta la fotocamera sul codice QR';

  @override
  String get pointCameraAtCashuQr =>
      'Punta la fotocamera sul QR del token Cashu';

  @override
  String get pointCameraAtInvoiceQr =>
      'Punta la fotocamera sul QR della fattura';

  @override
  String get unrecognizedQrCode => 'Codice QR non riconosciuto';

  @override
  String get scanCashuTokenHint =>
      'Scansiona un token Cashu (cashuA... o cashuB...)';

  @override
  String get scanLightningInvoiceHint =>
      'Scansiona una fattura Lightning (lnbc...)';

  @override
  String get addMintQuestion => 'Aggiungere questo mint?';

  @override
  String get cameraPermissionDenied => 'Permesso fotocamera negato';

  @override
  String get paymentRequestTitle => 'Richiesta di pagamento';

  @override
  String get paymentRequestFrom => 'Richiesta da';

  @override
  String get paymentRequestAmount => 'Importo richiesto';

  @override
  String get paymentRequestDescription => 'Descrizione';

  @override
  String get paymentRequestMints => 'Mint accettati';

  @override
  String get paymentRequestAnyMint => 'Qualsiasi mint';

  @override
  String get paymentRequestPay => 'Paga';

  @override
  String get paymentRequestPaying => 'Pagamento in corso...';

  @override
  String get paymentRequestSuccess => 'Pagamento inviato con successo';

  @override
  String get paymentRequestNoTransport =>
      'Questa richiesta non ha un metodo di consegna configurato';

  @override
  String get paymentRequestTransport => 'Trasporto';

  @override
  String get paymentRequestMintNotAccepted =>
      'Il tuo mint attivo non è nella lista dei mint accettati';

  @override
  String paymentRequestUnitMismatch(String unit) {
    return 'Unità incompatibile: la richiesta richiede $unit';
  }

  @override
  String get paymentRequestInsufficientBalance => 'Saldo insufficiente';

  @override
  String get paymentRequestErrorParsing =>
      'Errore nella lettura della richiesta di pagamento';

  @override
  String get p2pkTitle => 'Chiavi P2PK';

  @override
  String get p2pkSettingsDescription => 'Ricevi ecash bloccato';

  @override
  String get p2pkExperimental => 'P2PK è sperimentale. Usare con cautela.';

  @override
  String get p2pkPendingSendWarning =>
      'Hai un invio P2PK in sospeso. Vai alla cronologia e aggiorna dopo che il destinatario ha riscattato il token.';

  @override
  String get p2pkExperimentalShort => 'Sperimentale';

  @override
  String get p2pkPrimaryKey => 'Chiave Principale';

  @override
  String get p2pkDerived => 'Derivata';

  @override
  String get p2pkImported => 'Importata';

  @override
  String get p2pkImportedKeys => 'Chiavi Importate';

  @override
  String get p2pkNoImportedKeys => 'Nessuna chiave importata';

  @override
  String get p2pkShowQR => 'Mostra QR';

  @override
  String get p2pkCopy => 'Copia';

  @override
  String get p2pkImportNsec => 'Importa nsec';

  @override
  String get p2pkImport => 'Importa';

  @override
  String get p2pkEnterLabel => 'Nome per questa chiave';

  @override
  String get p2pkLockToKey => 'Invio con firma P2PK';

  @override
  String get p2pkLockDescription => 'Solo il destinatario può riscattare';

  @override
  String get p2pkReceiverPubkey => 'npub1... o hex (64/66 caratteri)';

  @override
  String get p2pkInvalidPubkey => 'Chiave pubblica non valida';

  @override
  String get p2pkInvalidPrivateKey => 'Chiave privata non valida';

  @override
  String get p2pkLockedToYou => 'Bloccato per te';

  @override
  String get p2pkLockedToOther => 'Bloccato per un\'altra chiave';

  @override
  String get p2pkCannotUnlock => 'Non hai la chiave per sbloccare questo token';

  @override
  String get p2pkEnterPrivateKey => 'Inserisci chiave privata (nsec)';

  @override
  String get p2pkDeleteTitle => 'Elimina chiave';

  @override
  String get p2pkDeleteConfirm =>
      'Eliminare questa chiave? Non potrai ricevere token bloccati ad essa.';

  @override
  String get p2pkRequiresConnection => 'P2PK richiede connessione al mint';

  @override
  String get p2pkErrorMaxKeysReached =>
      'Numero massimo di chiavi importate raggiunto (10)';

  @override
  String get p2pkErrorInvalidNsec => 'nsec non valido';

  @override
  String get p2pkErrorKeyAlreadyExists => 'Questa chiave esiste già';

  @override
  String get p2pkErrorKeyNotFound => 'Chiave non trovata';

  @override
  String get p2pkErrorCannotDeletePrimary =>
      'Impossibile eliminare la chiave principale';

  @override
  String get request => 'Richiedi';

  @override
  String get requestPayment => 'Richiedi pagamento';

  @override
  String get requestPaymentDescription =>
      'Genera richiesta di pagamento unificata';

  @override
  String get generateRequest => 'Genera richiesta';

  @override
  String get generatingRequest => 'Generazione in corso...';

  @override
  String get requestPaymentReceived => 'Pagamento ricevuto';

  @override
  String get requestDescriptionHint => 'Descrizione (opzionale)';

  @override
  String get universal => 'Universale';

  @override
  String get copiedToClipboard => 'Copiato negli appunti';

  @override
  String get swap => 'Scambia';

  @override
  String get swapDescription => 'Converti tra sats e USD';

  @override
  String get swapFrom => 'Da';

  @override
  String get swapTo => 'A';

  @override
  String get swapAction => 'Scambia';

  @override
  String get swapEstimatedFee => 'Commissione stimata';

  @override
  String get swapUseAll => 'Usa tutto';
}
