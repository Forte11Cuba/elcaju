import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'Your private ecash wallet';

  @override
  String get loadingMessage1 => 'Encrypting your coins...';

  @override
  String get loadingMessage2 => 'Preparing your e-tokens...';

  @override
  String get loadingMessage3 => 'Connecting to the Mint...';

  @override
  String get loadingMessage4 => 'Privacy by default.';

  @override
  String get loadingMessage5 => 'Blind signing tokens...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = Privacy + Freedom';

  @override
  String get aboutTagline => 'Privacy without borders.';

  @override
  String get welcomeTitle => 'Welcome to ElCaju';

  @override
  String get welcomeSubtitle => 'Cashu for the world. Made in Cuba.';

  @override
  String get createWallet => 'Create new wallet';

  @override
  String get restoreWallet => 'Restore wallet';

  @override
  String get createWalletTitle => 'Create wallet';

  @override
  String get creatingWallet => 'Creating your wallet...';

  @override
  String get generatingSeed => 'Generating your seed phrase securely';

  @override
  String get createWalletDescription => 'A 12-word seed phrase will be generated.\nStore it in a safe place.';

  @override
  String get generateWallet => 'Generate wallet';

  @override
  String get walletCreated => 'Wallet created!';

  @override
  String get walletCreatedDescription => 'Your wallet is ready. We recommend backing up your seed phrase now.';

  @override
  String get backupWarning => 'Without backup, you will lose access to your funds if you lose the device.';

  @override
  String get backupNow => 'Backup now';

  @override
  String get backupLater => 'Do it later';

  @override
  String get backupTitle => 'Backup';

  @override
  String get seedPhraseTitle => 'Your seed phrase';

  @override
  String get seedPhraseDescription => 'Save these 12 words in order. They are the only way to recover your wallet.';

  @override
  String get revealSeedPhrase => 'Reveal seed phrase';

  @override
  String get tapToReveal => 'Tap the button to reveal\nyour seed phrase';

  @override
  String get copyToClipboard => 'Copy to clipboard';

  @override
  String get seedCopied => 'Phrase copied to clipboard';

  @override
  String get neverShareSeed => 'Never share your seed phrase with anyone.';

  @override
  String get confirmBackup => 'I have saved my seed phrase in a safe place';

  @override
  String get continue_ => 'Continue';

  @override
  String get restoreTitle => 'Restore wallet';

  @override
  String get enterSeedPhrase => 'Enter your seed phrase';

  @override
  String get enterSeedDescription => 'Type the 12 or 24 words separated by spaces.';

  @override
  String get seedPlaceholder => 'word1 word2 word3 ...';

  @override
  String wordCount(int count) {
    return '$count words';
  }

  @override
  String get needWords => '(you need 12 or 24)';

  @override
  String restoreError(String error) {
    return 'Restore error: $error';
  }

  @override
  String get homeTitle => 'Home';

  @override
  String get receive => 'Receive';

  @override
  String get send => 'Send';

  @override
  String get sendAction => 'Send ↗';

  @override
  String get receiveAction => '↘ Receive';

  @override
  String get deposit => 'Deposit';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => 'History';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get depositOrReceive => 'Deposit or receive sats to start';

  @override
  String get noMint => 'No mint';

  @override
  String get balance => 'Balance';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'Paste ecash token';

  @override
  String get generateInvoiceToDeposit => 'Generate invoice to deposit';

  @override
  String get createEcashToken => 'Create ecash token';

  @override
  String get payLightningInvoice => 'Pay Lightning invoice';

  @override
  String get receiveCashu => 'Receive Cashu';

  @override
  String get pasteTheCashuToken => 'Paste the Cashu token:';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get validToken => 'Valid token';

  @override
  String get invalidToken => 'Invalid or malformed token';

  @override
  String get amount => 'Amount:';

  @override
  String get mint => 'Mint:';

  @override
  String get claiming => 'Claiming...';

  @override
  String get claimTokens => 'Claim tokens';

  @override
  String get tokensReceived => 'Tokens received';

  @override
  String get backToHome => 'Back to home';

  @override
  String get tokenAlreadyClaimed => 'This token was already claimed';

  @override
  String get unknownMint => 'Token from unknown mint';

  @override
  String claimError(String error) {
    return 'Claim error: $error';
  }

  @override
  String get sendCashu => 'Send Cashu';

  @override
  String get selectNotesManually => 'Select notes manually';

  @override
  String get amountToSend => 'Amount to send:';

  @override
  String get available => 'Available:';

  @override
  String get max => '(Max)';

  @override
  String get memoOptional => 'Memo (optional):';

  @override
  String get memoPlaceholder => 'What is this payment for?';

  @override
  String get creatingToken => 'Creating token...';

  @override
  String get createToken => 'Create token';

  @override
  String get noActiveMint => 'No active mint';

  @override
  String get offlineModeMessage => 'No connection. Using offline mode...';

  @override
  String get confirmSend => 'Confirm send';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String tokenCreationError(String error) {
    return 'Error creating token: $error';
  }

  @override
  String get tokenCreated => 'Token created';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get tokenCashu => 'Cashu Token';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Cashu Token (animated QR - $fragments UR fragments)';
  }

  @override
  String get keepTokenWarning => 'Keep this token until the recipient claims it. If you lose it, you will lose the funds.';

  @override
  String get tokenCopiedToClipboard => 'Token copied to clipboard';

  @override
  String get amountToDeposit => 'Amount to deposit:';

  @override
  String get descriptionOptional => 'Description (optional):';

  @override
  String get depositPlaceholder => 'What is this deposit for?';

  @override
  String get generating => 'Generating...';

  @override
  String get generateInvoice => 'Generate invoice';

  @override
  String get depositLightning => 'Deposit Lightning';

  @override
  String get payInvoiceTitle => 'Pay invoice';

  @override
  String get generatingInvoice => 'Generating invoice...';

  @override
  String get waitingForPayment => 'Waiting for payment...';

  @override
  String get paymentReceived => 'Payment received';

  @override
  String get tokensIssued => 'Tokens issued!';

  @override
  String get error => 'Error';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get back => 'Back';

  @override
  String get copyInvoice => 'Copy invoice';

  @override
  String get description => 'Description:';

  @override
  String get invoiceCopiedToClipboard => 'Invoice copied to clipboard';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit deposited';
  }

  @override
  String get pasteLightningInvoice => 'Paste the Lightning invoice:';

  @override
  String get gettingQuote => 'Getting quote...';

  @override
  String get validInvoice => 'Valid invoice';

  @override
  String get invalidInvoice => 'Invalid invoice';

  @override
  String get invalidInvoiceMalformed => 'Invalid or malformed invoice';

  @override
  String get feeReserved => 'Fee reserved:';

  @override
  String get total => 'Total:';

  @override
  String get paying => 'Paying...';

  @override
  String get payInvoice => 'Pay invoice';

  @override
  String get confirmPayment => 'Confirm payment';

  @override
  String get pay => 'Pay';

  @override
  String get fee => 'fee';

  @override
  String get invoiceExpired => 'Invoice expired';

  @override
  String get amountOutOfRange => 'Amount out of allowed range';

  @override
  String resolvingType(String type) {
    return 'Resolving $type...';
  }

  @override
  String get invoiceAlreadyPaid => 'Invoice already paid';

  @override
  String paymentError(String error) {
    return 'Payment error: $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit sent';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Receive Cashu tokens to start';

  @override
  String get noPendingTransactions => 'No pending transactions';

  @override
  String get allTransactionsCompleted => 'All your transactions are completed';

  @override
  String get noEcashTransactions => 'No Ecash transactions';

  @override
  String get sendOrReceiveTokens => 'Send or receive Cashu tokens';

  @override
  String get noLightningTransactions => 'No Lightning transactions';

  @override
  String get depositOrWithdrawLightning => 'Deposit or withdraw via Lightning';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get receivedStatus => 'Received';

  @override
  String get sentStatus => 'Sent';

  @override
  String get now => 'Now';

  @override
  String agoMinutes(int minutes) {
    return '$minutes min ago';
  }

  @override
  String agoHours(int hours) {
    return '$hours h ago';
  }

  @override
  String agoDays(int days) {
    return '$days days ago';
  }

  @override
  String get lightningInvoice => 'Lightning Invoice';

  @override
  String get receivedEcash => 'Received Ecash';

  @override
  String get sentEcash => 'Sent Ecash';

  @override
  String get outgoingLightningPayment => 'Outgoing Lightning Payment';

  @override
  String get invoiceNotAvailable => 'Invoice not available';

  @override
  String get tokenNotAvailable => 'Token not available';

  @override
  String get unit => 'Unit';

  @override
  String get status => 'Status';

  @override
  String get pending => 'Pending';

  @override
  String get memo => 'Memo';

  @override
  String get copyInvoiceButton => 'COPY INVOICE';

  @override
  String get copyButton => 'COPY';

  @override
  String get invoiceCopied => 'Invoice copied';

  @override
  String get tokenCopied => 'Token copied';

  @override
  String get speed => 'SPEED:';

  @override
  String get settings => 'Settings';

  @override
  String get walletSection => 'WALLET';

  @override
  String get backupSeedPhrase => 'Backup seed phrase';

  @override
  String get viewRecoveryWords => 'View your recovery words';

  @override
  String get connectedMints => 'Connected mints';

  @override
  String get manageCashuMints => 'Manage your Cashu mints';

  @override
  String get pinAccess => 'PIN access';

  @override
  String get pinEnabled => 'Enabled';

  @override
  String get protectWithPin => 'Protect the app with PIN';

  @override
  String get recoverTokens => 'Recover tokens';

  @override
  String get scanMintsWithSeed => 'Scan mints with seed phrase';

  @override
  String get appearanceSection => 'LANGUAGE';

  @override
  String get language => 'Language';

  @override
  String get informationSection => 'INFORMATION';

  @override
  String get version => 'Version';

  @override
  String get about => 'About';

  @override
  String get deleteWallet => 'Delete wallet';

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
  String get mnemonicNotFound => 'Mnemonic not found';

  @override
  String get createPin => 'Create PIN';

  @override
  String get enterPinDigits => 'Enter a 4-digit PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get enterPinAgain => 'Enter the PIN again';

  @override
  String get pinMismatch => 'PINs do not match';

  @override
  String get pinActivated => 'PIN activated';

  @override
  String get pinDeactivated => 'PIN deactivated';

  @override
  String get verifyPin => 'Verify PIN';

  @override
  String get enterCurrentPin => 'Enter your current PIN';

  @override
  String get incorrectPin => 'Incorrect PIN';

  @override
  String get selectLanguage => 'Select language';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get close => 'Close';

  @override
  String get aboutDescription => 'A Cashu wallet with Cuban DNA for the entire world. Brother of La Chispa.';

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get deleteWalletQuestion => 'Delete wallet?';

  @override
  String get actionIrreversible => 'This action is irreversible';

  @override
  String get deleteWalletWarning => 'All data will be deleted including your seed phrase and tokens. Make sure you have a backup.';

  @override
  String get typeDeleteToConfirm => 'Type \"DELETE\" to confirm:';

  @override
  String get deleteConfirmWord => 'DELETE';

  @override
  String deleteError(String error) {
    return 'Delete error: $error';
  }

  @override
  String get recoverTokensTitle => 'Recover tokens';

  @override
  String get recoverTokensDescription => 'Scan mints to recover tokens associated with your seed phrase (NUT-13)';

  @override
  String get useCurrentSeedPhrase => 'Use my current seed phrase';

  @override
  String get scanWithSavedWords => 'Scan mints with the 12 saved words';

  @override
  String get useOtherSeedPhrase => 'Use another seed phrase';

  @override
  String get recoverFromOtherWords => 'Recover tokens from other 12 words';

  @override
  String get mintsToScan => 'Mints to scan:';

  @override
  String allMints(int count) {
    return 'All mints ($count)';
  }

  @override
  String get specificMint => 'A specific mint';

  @override
  String get enterMnemonicWords => 'Enter the 12 words separated by spaces...';

  @override
  String get scanMints => 'Scan mints';

  @override
  String get selectMintToScan => 'Select a mint to scan';

  @override
  String get mnemonicMustHaveWords => 'Mnemonic must have 12 or 24 words';

  @override
  String get noConnectedMintsToScan => 'No connected mints to scan';

  @override
  String recoveredTokens(String tokens, int mints) {
    return 'Recovered $tokens from $mints mint(s)!';
  }

  @override
  String get scanCompleteNoTokens => 'Scan complete. No new tokens found.';

  @override
  String mintsWithError(int count) {
    return '($count mint(s) with error)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return 'Recovered $tokens from $mint!';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return 'No tokens found in $mint.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return 'Recovered and transferred $amount $unit to your wallet!';
  }

  @override
  String get noTokensForMnemonic => 'No tokens found associated with that mnemonic.';

  @override
  String get noConnectedMints => 'No connected mints';

  @override
  String get addMintToStart => 'Add a mint to start';

  @override
  String get addMint => 'Add mint';

  @override
  String get mintDeleted => 'Mint deleted';

  @override
  String get activeMintUpdated => 'Active mint updated';

  @override
  String get mintUrl => 'Mint URL:';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'URL must start with https://';

  @override
  String get connectingToMint => 'Connecting to mint...';

  @override
  String get mintAddedSuccessfully => 'Mint added successfully';

  @override
  String get couldNotConnectToMint => 'Could not connect to mint';

  @override
  String get add => 'Add';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get activeMint => 'Active mint';

  @override
  String get mintMessage => 'Mint Message';

  @override
  String get url => 'URL';

  @override
  String get currency => 'Currency';

  @override
  String get unknown => 'Unknown';

  @override
  String get useThisMint => 'Use this mint';

  @override
  String get copyMintUrl => 'Copy mint URL';

  @override
  String get deleteMint => 'Delete mint';

  @override
  String copied(String label) {
    return '$label copied';
  }

  @override
  String get deleteMintConfirmTitle => 'Delete mint';

  @override
  String get deleteMintConfirmMessage => 'If you have balance in this mint, it will be lost. Are you sure?';

  @override
  String get delete => 'Delete';

  @override
  String get offlineSend => 'Offline Send';

  @override
  String get selectNotesToSend => 'Select the notes you want to send:';

  @override
  String get totalToSend => 'Total to send';

  @override
  String notesSelected(int count) {
    return '$count notes selected';
  }

  @override
  String loadingProofsError(String error) {
    return 'Error loading proofs: $error';
  }

  @override
  String creatingTokenError(String error) {
    return 'Error creating token: $error';
  }

  @override
  String get unknownState => 'Unknown state';

  @override
  String depositAmountTitle(String amount, String unit) {
    return 'Deposit $amount $unit';
  }

  @override
  String get receiveNow => 'Receive now';

  @override
  String get receiveLater => 'Receive later';

  @override
  String get tokenSavedForLater => 'Token saved to claim later';

  @override
  String get noConnectionTokenSaved => 'No connection. Token saved to claim later.';

  @override
  String get unknownMintOffline => 'This token is from an unknown mint. Connect to the internet to add it and claim the token.';

  @override
  String get noConnectionTryLater => 'No connection to mint. Try again later.';

  @override
  String get saveTokenError => 'Error saving token. Please try again.';

  @override
  String get pendingTokenLimitReached => 'Pending tokens limit reached (max 50)';

  @override
  String get filterToReceive => 'To receive';

  @override
  String get noPendingTokens => 'No pending tokens';

  @override
  String get noPendingTokensHint => 'Save tokens to claim later';

  @override
  String get pendingBadge => 'PENDING';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days',
      one: 'Expires in 1 day',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count retries';
  }

  @override
  String get claimNow => 'Claim now';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return 'Claimed $amount $unit';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Claimed $count tokens ($amount $unit)',
      one: 'Claimed 1 token ($amount $unit)',
    );
    return '$_temp0';
  }

  @override
  String get scan => 'Scan';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get scanCashuToken => 'Scan Cashu Token';

  @override
  String get scanLightningInvoice => 'Scan Invoice';

  @override
  String get scanningAnimatedQr => 'Scanning animated QR...';

  @override
  String get pointCameraAtQr => 'Point the camera at the QR code';

  @override
  String get pointCameraAtCashuQr => 'Point the camera at the Cashu token QR';

  @override
  String get pointCameraAtInvoiceQr => 'Point the camera at the invoice QR';

  @override
  String get unrecognizedQrCode => 'Unrecognized QR code';

  @override
  String get scanCashuTokenHint => 'Scan a Cashu token (cashuA... or cashuB...)';

  @override
  String get scanLightningInvoiceHint => 'Scan a Lightning invoice (lnbc...)';

  @override
  String get addMintQuestion => 'Add this mint?';

  @override
  String get cameraPermissionDenied => 'Camera permission denied';

  @override
  String get paymentRequestNotSupported => 'Payment requests are not yet supported';

  @override
  String get p2pkTitle => 'P2PK Keys';

  @override
  String get p2pkSettingsDescription => 'Receive locked ecash';

  @override
  String get p2pkExperimental => 'P2PK is experimental. Use with caution.';

  @override
  String get p2pkPendingSendWarning => 'You have a pending P2PK send. Go to history and refresh after the recipient claims the token.';

  @override
  String get p2pkExperimentalShort => 'Experimental';

  @override
  String get p2pkPrimaryKey => 'Primary Key';

  @override
  String get p2pkDerived => 'Derived';

  @override
  String get p2pkImported => 'Imported';

  @override
  String get p2pkImportedKeys => 'Imported Keys';

  @override
  String get p2pkNoImportedKeys => 'No imported keys';

  @override
  String get p2pkShowQR => 'Show QR';

  @override
  String get p2pkCopy => 'Copy';

  @override
  String get p2pkImportNsec => 'Import nsec';

  @override
  String get p2pkImport => 'Import';

  @override
  String get p2pkEnterLabel => 'Name for this key';

  @override
  String get p2pkLockToKey => 'Send with P2PK signature';

  @override
  String get p2pkLockDescription => 'Only the recipient can claim';

  @override
  String get p2pkReceiverPubkey => 'npub1... or hex (64/66 chars)';

  @override
  String get p2pkInvalidPubkey => 'Invalid public key';

  @override
  String get p2pkInvalidPrivateKey => 'Invalid private key';

  @override
  String get p2pkLockedToYou => 'Locked to you';

  @override
  String get p2pkLockedToOther => 'Locked to another key';

  @override
  String get p2pkCannotUnlock => 'You don\'t have the key to unlock this token';

  @override
  String get p2pkEnterPrivateKey => 'Enter private key (nsec)';

  @override
  String get p2pkDeleteTitle => 'Delete key';

  @override
  String get p2pkDeleteConfirm => 'Delete this key? You won\'t be able to receive tokens locked to it.';

  @override
  String get p2pkRequiresConnection => 'P2PK requires connection to the mint';

  @override
  String get p2pkErrorMaxKeysReached => 'Maximum imported keys reached (10)';

  @override
  String get p2pkErrorInvalidNsec => 'Invalid nsec';

  @override
  String get p2pkErrorKeyAlreadyExists => 'This key already exists';

  @override
  String get p2pkErrorKeyNotFound => 'Key not found';

  @override
  String get p2pkErrorCannotDeletePrimary => 'Cannot delete primary key';

  @override
  String get p2pkSendComingSoon => 'Coming soon';
}
