// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class L10nDe extends L10n {
  L10nDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'Deine private ecash Wallet';

  @override
  String get loadingMessage1 => 'Verschlüsselung deiner Münzen...';

  @override
  String get loadingMessage2 => 'Vorbereitung deiner E-Tokens...';

  @override
  String get loadingMessage3 => 'Verbindung zum Mint...';

  @override
  String get loadingMessage4 => 'Privatsphäre standardmäßig.';

  @override
  String get loadingMessage5 => 'Blind signierte Tokens...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = Privatsphäre + Freiheit';

  @override
  String get aboutTagline => 'Privatsphäre ohne Grenzen.';

  @override
  String get welcomeTitle => 'Willkommen bei ElCaju';

  @override
  String get welcomeSubtitle => 'Cashu für die Welt. Made in Cuba.';

  @override
  String get createWallet => 'Neue Wallet erstellen';

  @override
  String get restoreWallet => 'Wallet wiederherstellen';

  @override
  String get createWalletTitle => 'Wallet erstellen';

  @override
  String get creatingWallet => 'Erstelle deine Wallet...';

  @override
  String get generatingSeed => 'Sichere Generierung deiner Seed-Phrase';

  @override
  String get createWalletDescription =>
      'Eine 12-Wort Seed-Phrase wird generiert.\nBewahre sie an einem sicheren Ort auf.';

  @override
  String get generateWallet => 'Wallet generieren';

  @override
  String get walletCreated => 'Wallet erstellt!';

  @override
  String get walletCreatedDescription =>
      'Deine Wallet ist bereit. Wir empfehlen, jetzt ein Backup deiner Seed-Phrase zu erstellen.';

  @override
  String get backupWarning =>
      'Ohne Backup verlierst du den Zugang zu deinen Mitteln, wenn du das Gerät verlierst.';

  @override
  String get backupNow => 'Jetzt sichern';

  @override
  String get backupLater => 'Später machen';

  @override
  String get backupTitle => 'Backup';

  @override
  String get seedPhraseTitle => 'Deine Seed-Phrase';

  @override
  String get seedPhraseDescription =>
      'Speichere diese 12 Wörter in der richtigen Reihenfolge. Sie sind der einzige Weg, deine Wallet wiederherzustellen.';

  @override
  String get revealSeedPhrase => 'Seed-Phrase anzeigen';

  @override
  String get tapToReveal =>
      'Tippe auf den Button, um\ndeine Seed-Phrase anzuzeigen';

  @override
  String get copyToClipboard => 'In Zwischenablage kopieren';

  @override
  String get seedCopied => 'Phrase in Zwischenablage kopiert';

  @override
  String get neverShareSeed => 'Teile deine Seed-Phrase niemals mit anderen.';

  @override
  String get confirmBackup =>
      'Ich habe meine Seed-Phrase an einem sicheren Ort gespeichert';

  @override
  String get continue_ => 'Weiter';

  @override
  String get restoreTitle => 'Wallet wiederherstellen';

  @override
  String get enterSeedPhrase => 'Gib deine Seed-Phrase ein';

  @override
  String get enterSeedDescription =>
      'Gib die 12 oder 24 Wörter durch Leerzeichen getrennt ein.';

  @override
  String get seedPlaceholder => 'wort1 wort2 wort3 ...';

  @override
  String wordCount(int count) {
    return '$count Wörter';
  }

  @override
  String get needWords => '(du brauchst 12 oder 24)';

  @override
  String get restoreScanningMint =>
      'Mint wird nach vorhandenen Token durchsucht...';

  @override
  String restoreError(String error) {
    return 'Wiederherstellungsfehler: $error';
  }

  @override
  String get homeTitle => 'Start';

  @override
  String get receive => 'Empfangen';

  @override
  String get send => 'Senden';

  @override
  String get sendAction => 'Senden ↗';

  @override
  String get receiveAction => '↘ Empfangen';

  @override
  String get deposit => 'Einzahlen';

  @override
  String get withdraw => 'Abheben';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => 'Verlauf';

  @override
  String get noTransactions => 'Noch keine Transaktionen';

  @override
  String get depositOrReceive => 'Zahle ein oder empfange Sats zum Starten';

  @override
  String get noMint => 'Kein Mint';

  @override
  String get balance => 'Guthaben';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'Ecash Token einfügen';

  @override
  String get generateInvoiceToDeposit => 'Rechnung zum Einzahlen erstellen';

  @override
  String get createEcashToken => 'Ecash Token erstellen';

  @override
  String get payLightningInvoice => 'Lightning Rechnung bezahlen';

  @override
  String get receiveCashu => 'Cashu empfangen';

  @override
  String get pasteTheCashuToken => 'Füge den Cashu Token ein:';

  @override
  String get pasteFromClipboard => 'Aus Zwischenablage einfügen';

  @override
  String get validToken => 'Token gültig';

  @override
  String get invalidToken => 'Ungültiger oder fehlerhafter Token';

  @override
  String get amount => 'Betrag:';

  @override
  String get mint => 'Mint:';

  @override
  String get claiming => 'Einlösen...';

  @override
  String get claimTokens => 'Tokens einlösen';

  @override
  String get tokensReceived => 'Tokens empfangen';

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get tokenAlreadyClaimed => 'Dieser Token wurde bereits eingelöst';

  @override
  String get unknownMint => 'Token von unbekanntem Mint';

  @override
  String claimError(String error) {
    return 'Einlösungsfehler: $error';
  }

  @override
  String get sendCashu => 'Cashu senden';

  @override
  String get selectNotesManually => 'Notizen manuell auswählen';

  @override
  String get amountToSend => 'Zu sendender Betrag:';

  @override
  String get available => 'Verfügbar:';

  @override
  String get max => '(Max)';

  @override
  String get memoOptional => 'Memo (optional):';

  @override
  String get memoPlaceholder => 'Wofür ist diese Zahlung?';

  @override
  String get creatingToken => 'Token wird erstellt...';

  @override
  String get createToken => 'Token erstellen';

  @override
  String get noActiveMint => 'Kein aktiver Mint';

  @override
  String get offlineModeMessage => 'Keine Verbindung. Offline-Modus...';

  @override
  String get confirmSend => 'Senden bestätigen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get insufficientBalance => 'Unzureichendes Guthaben';

  @override
  String tokenCreationError(String error) {
    return 'Fehler beim Erstellen des Tokens: $error';
  }

  @override
  String get tokenCreated => 'Token erstellt';

  @override
  String get copy => 'Kopieren';

  @override
  String get share => 'Teilen';

  @override
  String get tokenCashu => 'Cashu Token';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Cashu Token (animierter QR - $fragments UR-Fragmente)';
  }

  @override
  String get keepTokenWarning =>
      'Bewahre diesen Token auf, bis der Empfänger ihn einlöst. Wenn du ihn verlierst, verlierst du die Mittel.';

  @override
  String get tokenCopiedToClipboard => 'Token in Zwischenablage kopiert';

  @override
  String get copyAsEmoji => 'Als Emoji kopieren';

  @override
  String get emojiCopiedToClipboard => 'Token als Emoji kopiert 🥜';

  @override
  String get peanutDecodeError =>
      'Emoji-Token konnte nicht dekodiert werden. Möglicherweise beschädigt.';

  @override
  String get nfcWrite => 'Auf NFC-Tag schreiben';

  @override
  String get nfcRead => 'NFC-Tag lesen';

  @override
  String get nfcHoldNear => 'Gerät an NFC-Tag halten...';

  @override
  String get nfcWriteSuccess => 'Token auf NFC-Tag geschrieben';

  @override
  String nfcWriteError(String error) {
    return 'NFC-Schreibfehler: $error';
  }

  @override
  String nfcReadError(String error) {
    return 'NFC-Lesefehler: $error';
  }

  @override
  String get nfcDisabled =>
      'NFC ist deaktiviert. Aktiviere es in den Einstellungen.';

  @override
  String get nfcUnsupported => 'Dieses Gerät unterstützt kein NFC';

  @override
  String get amountToDeposit => 'Einzuzahlender Betrag:';

  @override
  String get descriptionOptional => 'Beschreibung (optional):';

  @override
  String get depositPlaceholder => 'Wofür ist diese Einzahlung?';

  @override
  String get generating => 'Generiere...';

  @override
  String get generateInvoice => 'Rechnung erstellen';

  @override
  String get depositLightning => 'Lightning einzahlen';

  @override
  String get payInvoiceTitle => 'Rechnung bezahlen';

  @override
  String get generatingInvoice => 'Rechnung wird erstellt...';

  @override
  String get waitingForPayment => 'Warte auf Zahlung...';

  @override
  String get paymentReceived => 'Zahlung empfangen';

  @override
  String get tokensIssued => 'Tokens ausgegeben!';

  @override
  String get error => 'Fehler';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get back => 'Zurück';

  @override
  String get copyInvoice => 'Rechnung kopieren';

  @override
  String get description => 'Beschreibung:';

  @override
  String get invoiceCopiedToClipboard => 'Rechnung in Zwischenablage kopiert';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit eingezahlt';
  }

  @override
  String get pasteLightningInvoice => 'Füge die Lightning Rechnung ein:';

  @override
  String get gettingQuote => 'Angebot wird geholt...';

  @override
  String get validInvoice => 'Rechnung gültig';

  @override
  String get invalidInvoice => 'Ungültige Rechnung';

  @override
  String get invalidInvoiceMalformed => 'Ungültige oder fehlerhafte Rechnung';

  @override
  String get feeReserved => 'Reservierte Gebühr:';

  @override
  String get total => 'Gesamt:';

  @override
  String get paying => 'Bezahle...';

  @override
  String get payInvoice => 'Rechnung bezahlen';

  @override
  String get confirmPayment => 'Zahlung bestätigen';

  @override
  String get pay => 'Bezahlen';

  @override
  String get fee => 'Gebühr';

  @override
  String get invoiceExpired => 'Rechnung abgelaufen';

  @override
  String get amountOutOfRange => 'Betrag außerhalb des erlaubten Bereichs';

  @override
  String resolvingType(String type) {
    return 'Löse $type auf...';
  }

  @override
  String get invoiceAlreadyPaid => 'Rechnung bereits bezahlt';

  @override
  String paymentError(String error) {
    return 'Zahlungsfehler: $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit gesendet';
  }

  @override
  String get filterAll => 'Alle';

  @override
  String get filterPending => 'Ausstehend';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Empfange Cashu Tokens zum Starten';

  @override
  String get noPendingTransactions => 'Keine ausstehenden Transaktionen';

  @override
  String get allTransactionsCompleted =>
      'Alle deine Transaktionen sind abgeschlossen';

  @override
  String get noEcashTransactions => 'Keine Ecash Transaktionen';

  @override
  String get sendOrReceiveTokens => 'Sende oder empfange Cashu Tokens';

  @override
  String get noLightningTransactions => 'Keine Lightning Transaktionen';

  @override
  String get depositOrWithdrawLightning =>
      'Zahle ein oder hebe ab via Lightning';

  @override
  String get pendingStatus => 'Ausstehend';

  @override
  String get receivedStatus => 'Empfangen';

  @override
  String get sentStatus => 'Gesendet';

  @override
  String get now => 'Jetzt';

  @override
  String agoMinutes(int minutes) {
    return 'Vor $minutes Min';
  }

  @override
  String agoHours(int hours) {
    return 'Vor $hours Std';
  }

  @override
  String agoDays(int days) {
    return 'Vor $days Tagen';
  }

  @override
  String get lightningInvoice => 'Lightning Rechnung';

  @override
  String get receivedEcash => 'Ecash empfangen';

  @override
  String get sentEcash => 'Ecash gesendet';

  @override
  String get outgoingLightningPayment => 'Ausgehende Lightning Zahlung';

  @override
  String get invoiceNotAvailable => 'Rechnung nicht verfügbar';

  @override
  String get tokenNotAvailable => 'Token nicht verfügbar';

  @override
  String get unit => 'Einheit';

  @override
  String get status => 'Status';

  @override
  String get pending => 'Ausstehend';

  @override
  String get memo => 'Memo';

  @override
  String get copyInvoiceButton => 'RECHNUNG KOPIEREN';

  @override
  String get copyButton => 'KOPIEREN';

  @override
  String get invoiceCopied => 'Rechnung kopiert';

  @override
  String get tokenCopied => 'Token kopiert';

  @override
  String get speed => 'GESCHWINDIGKEIT:';

  @override
  String get settings => 'Einstellungen';

  @override
  String get walletSection => 'WALLET';

  @override
  String get backupSeedPhrase => 'Seed-Phrase sichern';

  @override
  String get viewRecoveryWords => 'Deine Wiederherstellungswörter anzeigen';

  @override
  String get connectedMints => 'Verbundene Mints';

  @override
  String get manageCashuMints => 'Verwalte deine Cashu Mints';

  @override
  String get pinAccess => 'PIN-Zugang';

  @override
  String get pinEnabled => 'Aktiviert';

  @override
  String get protectWithPin => 'App mit PIN schützen';

  @override
  String get recoverTokens => 'Tokens wiederherstellen';

  @override
  String get scanMintsWithSeed => 'Mints mit Seed-Phrase scannen';

  @override
  String get appearanceSection => 'SPRACHE';

  @override
  String get language => 'Sprache';

  @override
  String get informationSection => 'INFORMATION';

  @override
  String get version => 'Version';

  @override
  String get about => 'Über';

  @override
  String get deleteWallet => 'Wallet löschen';

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
  String get mnemonicNotFound => 'Mnemonic nicht gefunden';

  @override
  String get createPin => 'PIN erstellen';

  @override
  String get enterPinDigits => 'Gib eine 4-stellige PIN ein';

  @override
  String get confirmPin => 'PIN bestätigen';

  @override
  String get enterPinAgain => 'PIN erneut eingeben';

  @override
  String get pinMismatch => 'PINs stimmen nicht überein';

  @override
  String get pinActivated => 'PIN aktiviert';

  @override
  String get pinDeactivated => 'PIN deaktiviert';

  @override
  String get verifyPin => 'PIN überprüfen';

  @override
  String get enterCurrentPin => 'Gib deine aktuelle PIN ein';

  @override
  String get incorrectPin => 'Falsche PIN';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String languageChanged(String language) {
    return 'Sprache geändert zu $language';
  }

  @override
  String get close => 'Schließen';

  @override
  String get aboutDescription =>
      'Eine Cashu Wallet mit kubanischer DNA für die ganze Welt. Bruder von LaChispa.';

  @override
  String get couldNotOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String get deleteWalletQuestion => 'Wallet löschen?';

  @override
  String get actionIrreversible => 'Diese Aktion ist unwiderruflich';

  @override
  String get deleteWalletWarning =>
      'Alle Daten werden gelöscht, einschließlich deiner Seed-Phrase und Tokens. Stelle sicher, dass du ein Backup hast.';

  @override
  String get typeDeleteToConfirm => 'Gib \"LÖSCHEN\" zur Bestätigung ein:';

  @override
  String get deleteConfirmWord => 'LÖSCHEN';

  @override
  String deleteError(String error) {
    return 'Löschfehler: $error';
  }

  @override
  String get recoverTokensTitle => 'Tokens wiederherstellen';

  @override
  String get recoverTokensDescription =>
      'Mints scannen, um Tokens wiederherzustellen, die mit deiner Seed-Phrase verknüpft sind (NUT-13)';

  @override
  String get useCurrentSeedPhrase => 'Meine aktuelle Seed-Phrase verwenden';

  @override
  String get scanWithSavedWords =>
      'Mints mit den gespeicherten 12 Wörtern scannen';

  @override
  String get useOtherSeedPhrase => 'Andere Seed-Phrase verwenden';

  @override
  String get recoverFromOtherWords =>
      'Tokens von anderen 12 Wörtern wiederherstellen';

  @override
  String get mintsToScan => 'Zu scannende Mints:';

  @override
  String allMints(int count) {
    return 'Alle Mints ($count)';
  }

  @override
  String get specificMint => 'Ein bestimmter Mint';

  @override
  String get enterMnemonicWords =>
      'Gib die 12 Wörter durch Leerzeichen getrennt ein...';

  @override
  String get scanMints => 'Mints scannen';

  @override
  String get selectMintToScan => 'Wähle einen Mint zum Scannen';

  @override
  String get mnemonicMustHaveWords => 'Mnemonic muss 12 oder 24 Wörter haben';

  @override
  String get noConnectedMintsToScan => 'Keine verbundenen Mints zum Scannen';

  @override
  String recoveredTokens(String tokens, int mints) {
    return '$tokens von $mints Mint(s) wiederhergestellt!';
  }

  @override
  String get scanCompleteNoTokens =>
      'Scan abgeschlossen. Keine neuen Tokens gefunden.';

  @override
  String mintsWithError(int count) {
    return '($count Mint(s) mit Fehler)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return '$tokens von $mint wiederhergestellt!';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return 'Keine Tokens in $mint gefunden.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return '$amount $unit wiederhergestellt und in deine Wallet übertragen!';
  }

  @override
  String get noTokensForMnemonic =>
      'Keine Tokens mit diesem Mnemonic verknüpft gefunden.';

  @override
  String get noConnectedMints => 'Keine verbundenen Mints';

  @override
  String get addMintToStart => 'Füge einen Mint hinzu, um zu starten';

  @override
  String get addMint => 'Mint hinzufügen';

  @override
  String get mintDeleted => 'Mint gelöscht';

  @override
  String get activeMintUpdated => 'Aktiver Mint aktualisiert';

  @override
  String get mintUrl => 'Mint URL:';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'URL muss mit https:// beginnen';

  @override
  String get connectingToMint => 'Verbinde mit Mint...';

  @override
  String get mintAddedSuccessfully => 'Mint erfolgreich hinzugefügt';

  @override
  String get couldNotConnectToMint => 'Verbindung zum Mint fehlgeschlagen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get success => 'Erfolg';

  @override
  String get loading => 'Laden...';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get activeMint => 'Aktiver Mint';

  @override
  String get mintMessage => 'Mint Nachricht';

  @override
  String get url => 'URL';

  @override
  String get currency => 'Währung';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get useThisMint => 'Diesen Mint verwenden';

  @override
  String get copyMintUrl => 'Mint URL kopieren';

  @override
  String get deleteMint => 'Mint löschen';

  @override
  String copied(String label) {
    return '$label kopiert';
  }

  @override
  String get deleteMintConfirmTitle => 'Mint löschen';

  @override
  String get deleteMintConfirmMessage =>
      'Wenn du Guthaben auf diesem Mint hast, geht es verloren. Bist du sicher?';

  @override
  String get delete => 'Löschen';

  @override
  String get offlineSend => 'Offline senden';

  @override
  String get selectAll => 'Alle';

  @override
  String get deselectAll => 'Keine';

  @override
  String get selectNotesToSend => 'Wähle die zu sendenden Notizen:';

  @override
  String get totalToSend => 'Gesamt zu senden';

  @override
  String notesSelected(int count) {
    return '$count Notizen ausgewählt';
  }

  @override
  String loadingProofsError(String error) {
    return 'Fehler beim Laden der Beweise: $error';
  }

  @override
  String creatingTokenError(String error) {
    return 'Fehler beim Erstellen des Tokens: $error';
  }

  @override
  String get unknownState => 'Unbekannter Zustand';

  @override
  String depositAmountTitle(String amount, String unit) {
    return '$amount $unit einzahlen';
  }

  @override
  String get receiveNow => 'Jetzt empfangen';

  @override
  String get receiveLater => 'Später empfangen';

  @override
  String get tokenSavedForLater => 'Token zum späteren Einlösen gespeichert';

  @override
  String get noConnectionTokenSaved =>
      'Keine Verbindung. Token zum späteren Einlösen gespeichert.';

  @override
  String get unknownMintOffline =>
      'Dieser Token stammt von einem unbekannten Mint. Verbinde dich mit dem Internet, um ihn hinzuzufügen und den Token einzulösen.';

  @override
  String get noConnectionTryLater =>
      'Keine Verbindung zum Mint. Versuche es später erneut.';

  @override
  String get saveTokenError =>
      'Fehler beim Speichern des Tokens. Bitte erneut versuchen.';

  @override
  String get pendingTokenLimitReached =>
      'Limit für ausstehende Tokens erreicht (max 50)';

  @override
  String get filterToReceive => 'Zu empfangen';

  @override
  String get noPendingTokens => 'Keine ausstehenden Tokens';

  @override
  String get noPendingTokensHint => 'Speichere Tokens zum späteren Einlösen';

  @override
  String get pendingBadge => 'AUSSTEHEND';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Läuft in $days Tagen ab',
      one: 'Läuft in 1 Tag ab',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count Versuche';
  }

  @override
  String get claimNow => 'Jetzt einlösen';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return '$amount $unit eingelöst';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tokens eingelöst ($amount $unit)',
      one: '1 Token eingelöst ($amount $unit)',
    );
    return '$_temp0';
  }

  @override
  String get scan => 'Scannen';

  @override
  String get scanQrCode => 'QR scannen';

  @override
  String get scanCashuToken => 'Cashu Token scannen';

  @override
  String get scanLightningInvoice => 'Rechnung scannen';

  @override
  String get scanningAnimatedQr => 'Animierten QR scannen...';

  @override
  String get pointCameraAtQr => 'Richte die Kamera auf den QR-Code';

  @override
  String get pointCameraAtCashuQr => 'Richte die Kamera auf den Cashu Token QR';

  @override
  String get pointCameraAtInvoiceQr => 'Richte die Kamera auf den Rechnungs-QR';

  @override
  String get unrecognizedQrCode => 'Nicht erkannter QR-Code';

  @override
  String get scanCashuTokenHint =>
      'Scanne einen Cashu Token (cashuA... oder cashuB...)';

  @override
  String get scanLightningInvoiceHint =>
      'Scanne eine Lightning Rechnung (lnbc...)';

  @override
  String get addMintQuestion => 'Diesen Mint hinzufügen?';

  @override
  String get cameraPermissionDenied => 'Kamera-Berechtigung verweigert';

  @override
  String get paymentRequestTitle => 'Zahlungsanfrage';

  @override
  String get paymentRequestFrom => 'Anfrage von';

  @override
  String get paymentRequestAmount => 'Angeforderter Betrag';

  @override
  String get paymentRequestDescription => 'Beschreibung';

  @override
  String get paymentRequestMints => 'Akzeptierte Mints';

  @override
  String get paymentRequestAnyMint => 'Jeder Mint';

  @override
  String get paymentRequestPay => 'Bezahlen';

  @override
  String get paymentRequestPaying => 'Bezahle...';

  @override
  String get paymentRequestSuccess => 'Zahlung erfolgreich gesendet';

  @override
  String get paymentRequestNoTransport =>
      'Diese Anfrage hat keine konfigurierte Zustellmethode';

  @override
  String get paymentRequestTransport => 'Transport';

  @override
  String get paymentRequestMintNotAccepted =>
      'Dein aktiver Mint ist nicht in der Liste der akzeptierten Mints';

  @override
  String paymentRequestUnitMismatch(String unit) {
    return 'Inkompatible Einheit: Anfrage erfordert $unit';
  }

  @override
  String get paymentRequestInsufficientBalance => 'Unzureichendes Guthaben';

  @override
  String get paymentRequestErrorParsing =>
      'Fehler beim Lesen der Zahlungsanfrage';

  @override
  String get p2pkTitle => 'P2PK-Schlüssel';

  @override
  String get p2pkSettingsDescription => 'Gesperrtes ecash empfangen';

  @override
  String get p2pkExperimental =>
      'P2PK ist experimentell. Mit Vorsicht verwenden.';

  @override
  String get p2pkPendingSendWarning =>
      'Du hast einen ausstehenden P2PK-Versand. Gehe zum Verlauf und aktualisiere, nachdem der Empfänger den Token eingelöst hat.';

  @override
  String get p2pkExperimentalShort => 'Experimentell';

  @override
  String get p2pkPrimaryKey => 'Primärschlüssel';

  @override
  String get p2pkDerived => 'Abgeleitet';

  @override
  String get p2pkImported => 'Importiert';

  @override
  String get p2pkImportedKeys => 'Importierte Schlüssel';

  @override
  String get p2pkNoImportedKeys => 'Keine importierten Schlüssel';

  @override
  String get p2pkShowQR => 'QR zeigen';

  @override
  String get p2pkCopy => 'Kopieren';

  @override
  String get p2pkImportNsec => 'nsec importieren';

  @override
  String get p2pkImport => 'Importieren';

  @override
  String get p2pkEnterLabel => 'Name für diesen Schlüssel';

  @override
  String get p2pkLockToKey => 'Senden mit P2PK-Signatur';

  @override
  String get p2pkLockDescription => 'Nur der Empfänger kann einlösen';

  @override
  String get p2pkReceiverPubkey => 'npub1... oder hex (64/66 Zeichen)';

  @override
  String get p2pkInvalidPubkey => 'Ungültiger öffentlicher Schlüssel';

  @override
  String get p2pkInvalidPrivateKey => 'Ungültiger privater Schlüssel';

  @override
  String get p2pkLockedToYou => 'Für dich gesperrt';

  @override
  String get p2pkLockedToOther => 'Für anderen Schlüssel gesperrt';

  @override
  String get p2pkCannotUnlock =>
      'Du hast nicht den Schlüssel, um diesen Token zu entsperren';

  @override
  String get p2pkEnterPrivateKey => 'Privaten Schlüssel eingeben (nsec)';

  @override
  String get p2pkDeleteTitle => 'Schlüssel löschen';

  @override
  String get p2pkDeleteConfirm =>
      'Diesen Schlüssel löschen? Du kannst keine Token mehr empfangen, die daran gesperrt sind.';

  @override
  String get p2pkRequiresConnection => 'P2PK erfordert Verbindung zum Mint';

  @override
  String get p2pkErrorMaxKeysReached =>
      'Maximale Anzahl importierter Schlüssel erreicht (10)';

  @override
  String get p2pkErrorInvalidNsec => 'Ungültiger nsec';

  @override
  String get p2pkErrorKeyAlreadyExists => 'Dieser Schlüssel existiert bereits';

  @override
  String get p2pkErrorKeyNotFound => 'Schlüssel nicht gefunden';

  @override
  String get p2pkErrorCannotDeletePrimary =>
      'Primärschlüssel kann nicht gelöscht werden';
}
