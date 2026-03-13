// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class L10nSw extends L10n {
  L10nSw([String locale = 'sw']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'Pochi yako ya faragha ya ecash';

  @override
  String get loadingMessage1 => 'Kusimba sarafu zako...';

  @override
  String get loadingMessage2 => 'Kuandaa e-tokeni zako...';

  @override
  String get loadingMessage3 => 'Kuunganisha na Mint...';

  @override
  String get loadingMessage4 => 'Faragha kwa chaguo-msingi.';

  @override
  String get loadingMessage5 => 'Kusaini tokeni kwa upofu...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = Faragha + Uhuru';

  @override
  String get aboutTagline => 'Faragha bila mipaka.';

  @override
  String get welcomeTitle => 'Karibu ElCaju';

  @override
  String get welcomeSubtitle => 'Cashu kwa ulimwengu. Imetengenezwa Cuba.';

  @override
  String get createWallet => 'Unda pochi mpya';

  @override
  String get restoreWallet => 'Rejesha pochi';

  @override
  String get createWalletTitle => 'Unda pochi';

  @override
  String get creatingWallet => 'Kuunda pochi yako...';

  @override
  String get generatingSeed => 'Kutengeneza maneno yako ya mbegu kwa usalama';

  @override
  String get createWalletDescription =>
      'Maneno 12 ya mbegu yatatengenezwa.\nYahifadhi mahali salama.';

  @override
  String get generateWallet => 'Tengeneza pochi';

  @override
  String get walletCreated => 'Pochi imeundwa!';

  @override
  String get walletCreatedDescription =>
      'Pochi yako iko tayari. Tunakushauri uhifadhi nakala ya maneno yako ya mbegu sasa.';

  @override
  String get backupWarning =>
      'Bila nakala, utapoteza uwezo wa kufikia fedha zako ukipoteza kifaa.';

  @override
  String get backupNow => 'Hifadhi nakala sasa';

  @override
  String get backupLater => 'Fanya baadaye';

  @override
  String get backupTitle => 'Nakala rudufu';

  @override
  String get seedPhraseTitle => 'Maneno yako ya mbegu';

  @override
  String get seedPhraseDescription =>
      'Hifadhi maneno haya 12 kwa mpangilio. Ndiyo njia pekee ya kurejesha pochi yako.';

  @override
  String get revealSeedPhrase => 'Onyesha maneno ya mbegu';

  @override
  String get tapToReveal => 'Bofya kitufe kuonyesha\nmaneno yako ya mbegu';

  @override
  String get copyToClipboard => 'Nakili kwenye ubao wa kunakili';

  @override
  String get seedCopied => 'Maneno yamenakiliwa kwenye ubao';

  @override
  String get neverShareSeed => 'Usishiriki maneno yako ya mbegu na mtu yeyote.';

  @override
  String get confirmBackup => 'Nimehifadhi maneno yangu ya mbegu mahali salama';

  @override
  String get continue_ => 'Endelea';

  @override
  String get restoreTitle => 'Rejesha pochi';

  @override
  String get enterSeedPhrase => 'Ingiza maneno yako ya mbegu';

  @override
  String get enterSeedDescription =>
      'Andika maneno 12 au 24 yakitengwa na nafasi.';

  @override
  String get seedPlaceholder => 'neno1 neno2 neno3 ...';

  @override
  String wordCount(int count) {
    return 'maneno $count';
  }

  @override
  String get needWords => '(unahitaji 12 au 24)';

  @override
  String get restoreScanningMint => 'Inatafuta tokeni zilizopo kwenye mint...';

  @override
  String restoreError(String error) {
    return 'Hitilafu ya kurejesha: $error';
  }

  @override
  String get homeTitle => 'Nyumbani';

  @override
  String get receive => 'Pokea';

  @override
  String get send => 'Tuma';

  @override
  String get sendAction => 'Tuma ↗';

  @override
  String get receiveAction => '↘ Pokea';

  @override
  String get deposit => 'Weka';

  @override
  String get withdraw => 'Toa';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => 'Historia';

  @override
  String get noTransactions => 'Hakuna miamala bado';

  @override
  String get depositOrReceive => 'Weka au pokea sats kuanza';

  @override
  String get noMint => 'Hakuna mint';

  @override
  String get balance => 'Salio';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'Bandika tokeni ya ecash';

  @override
  String get generateInvoiceToDeposit => 'Tengeneza ankara ya kuweka';

  @override
  String get createEcashToken => 'Unda tokeni ya ecash';

  @override
  String get payLightningInvoice => 'Lipa ankara ya Lightning';

  @override
  String get receiveCashu => 'Pokea Cashu';

  @override
  String get pasteTheCashuToken => 'Bandika tokeni ya Cashu:';

  @override
  String get pasteFromClipboard => 'Bandika kutoka ubao';

  @override
  String get validToken => 'Tokeni halali';

  @override
  String get invalidToken => 'Tokeni batili au imeharibika';

  @override
  String get amount => 'Kiasi:';

  @override
  String get mint => 'Mint:';

  @override
  String get claiming => 'Kudai...';

  @override
  String get claimTokens => 'Dai tokeni';

  @override
  String get tokensReceived => 'Tokeni zimepokelewa';

  @override
  String get backToHome => 'Rudi nyumbani';

  @override
  String get tokenAlreadyClaimed => 'Tokeni hii tayari imedaiwa';

  @override
  String get unknownMint => 'Tokeni kutoka mint isiyojulikana';

  @override
  String claimError(String error) {
    return 'Hitilafu ya kudai: $error';
  }

  @override
  String get sendCashu => 'Tuma Cashu';

  @override
  String get selectNotesManually => 'Chagua noti kwa mkono';

  @override
  String get amountToSend => 'Kiasi cha kutuma:';

  @override
  String get available => 'Inapatikana:';

  @override
  String get max => '(Upeo)';

  @override
  String get memoOptional => 'Memo (si lazima):';

  @override
  String get memoPlaceholder => 'Malipo haya ni ya nini?';

  @override
  String get creatingToken => 'Kuunda tokeni...';

  @override
  String get createToken => 'Unda tokeni';

  @override
  String get noActiveMint => 'Hakuna mint inayofanya kazi';

  @override
  String get offlineModeMessage =>
      'Hakuna muunganisho. Kutumia hali ya nje ya mtandao...';

  @override
  String get confirmSend => 'Thibitisha kutuma';

  @override
  String get confirm => 'Thibitisha';

  @override
  String get cancel => 'Ghairi';

  @override
  String get insufficientBalance => 'Salio halitoshi';

  @override
  String tokenCreationError(String error) {
    return 'Hitilafu ya kuunda tokeni: $error';
  }

  @override
  String get tokenCreated => 'Tokeni imeundwa';

  @override
  String get copy => 'Nakili';

  @override
  String get share => 'Shiriki';

  @override
  String get tokenCashu => 'Tokeni ya Cashu';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Tokeni ya Cashu (QR inayosogea - vipande $fragments vya UR)';
  }

  @override
  String get keepTokenWarning =>
      'Hifadhi tokeni hii hadi mpokeaji aidai. Ukiipoteza, utapoteza fedha.';

  @override
  String get tokenCopiedToClipboard => 'Tokeni imenakiliwa kwenye ubao';

  @override
  String get copyAsEmoji => 'Nakili kama emoji';

  @override
  String get emojiCopiedToClipboard => 'Tokeni imenakiliwa kama emoji 🥜';

  @override
  String get peanutDecodeError =>
      'Imeshindwa kusimbua tokeni ya emoji. Inaweza kuwa imeharibika.';

  @override
  String get nfcWrite => 'Andika kwenye NFC tag';

  @override
  String get nfcRead => 'Soma NFC tag';

  @override
  String get nfcHoldNear => 'Karibia kifaa kwenye NFC tag...';

  @override
  String get nfcWriteSuccess => 'Tokeni imeandikwa kwenye NFC tag';

  @override
  String nfcWriteError(String error) {
    return 'Hitilafu ya NFC kuandika: $error';
  }

  @override
  String nfcReadError(String error) {
    return 'Hitilafu ya NFC kusoma: $error';
  }

  @override
  String get nfcDisabled => 'NFC imezimwa. Iwashe katika Mipangilio.';

  @override
  String get nfcUnsupported => 'Kifaa hiki hakitumii NFC';

  @override
  String get amountToDeposit => 'Kiasi cha kuweka:';

  @override
  String get descriptionOptional => 'Maelezo (si lazima):';

  @override
  String get depositPlaceholder => 'Amana hii ni ya nini?';

  @override
  String get generating => 'Kutengeneza...';

  @override
  String get generateInvoice => 'Tengeneza ankara';

  @override
  String get depositLightning => 'Weka Lightning';

  @override
  String get payInvoiceTitle => 'Lipa ankara';

  @override
  String get generatingInvoice => 'Kutengeneza ankara...';

  @override
  String get waitingForPayment => 'Kusubiri malipo...';

  @override
  String get paymentReceived => 'Malipo yamepokelewa';

  @override
  String get tokensIssued => 'Tokeni zimetolewa!';

  @override
  String get error => 'Hitilafu';

  @override
  String get unknownError => 'Hitilafu isiyojulikana';

  @override
  String get back => 'Rudi';

  @override
  String get copyInvoice => 'Nakili ankara';

  @override
  String get description => 'Maelezo:';

  @override
  String get invoiceCopiedToClipboard => 'Ankara imenakiliwa kwenye ubao';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit zimewekwa';
  }

  @override
  String get pasteLightningInvoice => 'Bandika ankara ya Lightning:';

  @override
  String get gettingQuote => 'Kupata bei...';

  @override
  String get validInvoice => 'Ankara halali';

  @override
  String get invalidInvoice => 'Ankara batili';

  @override
  String get invalidInvoiceMalformed => 'Ankara batili au imeharibika';

  @override
  String get feeReserved => 'Ada iliyohifadhiwa:';

  @override
  String get total => 'Jumla:';

  @override
  String get paying => 'Kulipa...';

  @override
  String get payInvoice => 'Lipa ankara';

  @override
  String get confirmPayment => 'Thibitisha malipo';

  @override
  String get pay => 'Lipa';

  @override
  String get fee => 'ada';

  @override
  String get invoiceExpired => 'Ankara imeisha muda';

  @override
  String get amountOutOfRange => 'Kiasi nje ya masafa yanayoruhusiwa';

  @override
  String resolvingType(String type) {
    return 'Kutatua $type...';
  }

  @override
  String get invoiceAlreadyPaid => 'Ankara tayari imelipwa';

  @override
  String paymentError(String error) {
    return 'Hitilafu ya malipo: $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit zimetumwa';
  }

  @override
  String get filterAll => 'Zote';

  @override
  String get filterPending => 'Zinazosubiri';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Pokea tokeni za Cashu kuanza';

  @override
  String get noPendingTransactions => 'Hakuna miamala inayosubiri';

  @override
  String get allTransactionsCompleted => 'Miamala yako yote imekamilika';

  @override
  String get noEcashTransactions => 'Hakuna miamala ya Ecash';

  @override
  String get sendOrReceiveTokens => 'Tuma au pokea tokeni za Cashu';

  @override
  String get noLightningTransactions => 'Hakuna miamala ya Lightning';

  @override
  String get depositOrWithdrawLightning => 'Weka au toa kupitia Lightning';

  @override
  String get pendingStatus => 'Inasubiri';

  @override
  String get receivedStatus => 'Imepokelewa';

  @override
  String get sentStatus => 'Imetumwa';

  @override
  String get now => 'Sasa';

  @override
  String agoMinutes(int minutes) {
    return 'Dakika $minutes zilizopita';
  }

  @override
  String agoHours(int hours) {
    return 'Saa $hours zilizopita';
  }

  @override
  String agoDays(int days) {
    return 'Siku $days zilizopita';
  }

  @override
  String get lightningInvoice => 'Ankara ya Lightning';

  @override
  String get receivedEcash => 'Ecash Iliyopokelewa';

  @override
  String get sentEcash => 'Ecash Iliyotumwa';

  @override
  String get outgoingLightningPayment => 'Malipo ya Lightning Yanayotoka';

  @override
  String get invoiceNotAvailable => 'Ankara haipatikani';

  @override
  String get tokenNotAvailable => 'Tokeni haipatikani';

  @override
  String get unit => 'Kitengo';

  @override
  String get status => 'Hali';

  @override
  String get pending => 'Inasubiri';

  @override
  String get memo => 'Memo';

  @override
  String get copyInvoiceButton => 'NAKILI ANKARA';

  @override
  String get copyButton => 'NAKILI';

  @override
  String get invoiceCopied => 'Ankara imenakiliwa';

  @override
  String get tokenCopied => 'Tokeni imenakiliwa';

  @override
  String get speed => 'KASI:';

  @override
  String get settings => 'Mipangilio';

  @override
  String get walletSection => 'POCHI';

  @override
  String get backupSeedPhrase => 'Nakala ya maneno ya mbegu';

  @override
  String get viewRecoveryWords => 'Tazama maneno yako ya kurejesha';

  @override
  String get connectedMints => 'Mint zilizounganishwa';

  @override
  String get manageCashuMints => 'Simamia mint zako za Cashu';

  @override
  String get pinAccess => 'Ufikiaji wa PIN';

  @override
  String get pinEnabled => 'Imewashwa';

  @override
  String get protectWithPin => 'Linda programu kwa PIN';

  @override
  String get recoverTokens => 'Rejesha tokeni';

  @override
  String get scanMintsWithSeed => 'Changanua mint na maneno ya mbegu';

  @override
  String get appearanceSection => 'LUGHA';

  @override
  String get language => 'Lugha';

  @override
  String get informationSection => 'MAELEZO';

  @override
  String get version => 'Toleo';

  @override
  String get about => 'Kuhusu';

  @override
  String get deleteWallet => 'Futa pochi';

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
  String get mnemonicNotFound => 'Mnemonic haijapatikana';

  @override
  String get createPin => 'Unda PIN';

  @override
  String get enterPinDigits => 'Ingiza PIN ya tarakimu 4';

  @override
  String get confirmPin => 'Thibitisha PIN';

  @override
  String get enterPinAgain => 'Ingiza PIN tena';

  @override
  String get pinMismatch => 'PIN hazilingani';

  @override
  String get pinActivated => 'PIN imewashwa';

  @override
  String get pinDeactivated => 'PIN imezimwa';

  @override
  String get verifyPin => 'Thibitisha PIN';

  @override
  String get enterCurrentPin => 'Ingiza PIN yako ya sasa';

  @override
  String get incorrectPin => 'PIN si sahihi';

  @override
  String get selectLanguage => 'Chagua lugha';

  @override
  String languageChanged(String language) {
    return 'Lugha imebadilishwa kuwa $language';
  }

  @override
  String get close => 'Funga';

  @override
  String get aboutDescription =>
      'Pochi ya Cashu yenye DNA ya Cuba kwa ulimwengu wote. Ndugu wa LaChispa.';

  @override
  String get couldNotOpenLink => 'Haikuweza kufungua kiungo';

  @override
  String get deleteWalletQuestion => 'Futa pochi?';

  @override
  String get actionIrreversible => 'Kitendo hiki hakiwezi kutenduliwa';

  @override
  String get deleteWalletWarning =>
      'Data zote zitafutwa ikiwa ni pamoja na maneno yako ya mbegu na tokeni. Hakikisha una nakala.';

  @override
  String get typeDeleteToConfirm => 'Andika \"FUTA\" kuthibitisha:';

  @override
  String get deleteConfirmWord => 'FUTA';

  @override
  String deleteError(String error) {
    return 'Hitilafu ya kufuta: $error';
  }

  @override
  String get recoverTokensTitle => 'Rejesha tokeni';

  @override
  String get recoverTokensDescription =>
      'Changanua mint kurejesha tokeni zinazohusiana na maneno yako ya mbegu (NUT-13)';

  @override
  String get useCurrentSeedPhrase => 'Tumia maneno yangu ya mbegu ya sasa';

  @override
  String get scanWithSavedWords =>
      'Changanua mint na maneno 12 yaliyohifadhiwa';

  @override
  String get useOtherSeedPhrase => 'Tumia maneno mengine ya mbegu';

  @override
  String get recoverFromOtherWords => 'Rejesha tokeni kutoka maneno mengine 12';

  @override
  String get mintsToScan => 'Mint za kuchanganua:';

  @override
  String allMints(int count) {
    return 'Mint zote ($count)';
  }

  @override
  String get specificMint => 'Mint maalum';

  @override
  String get enterMnemonicWords => 'Ingiza maneno 12 yakitengwa na nafasi...';

  @override
  String get scanMints => 'Changanua mint';

  @override
  String get selectMintToScan => 'Chagua mint ya kuchanganua';

  @override
  String get mnemonicMustHaveWords => 'Mnemonic lazima iwe na maneno 12 au 24';

  @override
  String get noConnectedMintsToScan =>
      'Hakuna mint zilizounganishwa za kuchanganua';

  @override
  String recoveredTokens(String tokens, int mints) {
    return 'Zimerejeshwa $tokens kutoka mint $mints!';
  }

  @override
  String get scanCompleteNoTokens =>
      'Uchanganuzi umekamilika. Hakuna tokeni mpya zilizopatikana.';

  @override
  String mintsWithError(int count) {
    return '(mint $count zenye hitilafu)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return 'Zimerejeshwa $tokens kutoka $mint!';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return 'Hakuna tokeni zilizopatikana katika $mint.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return 'Zimerejeshwa na kuhamishwa $amount $unit kwenye pochi yako!';
  }

  @override
  String get noTokensForMnemonic =>
      'Hakuna tokeni zilizopatikana zinazohusiana na mnemonic hiyo.';

  @override
  String get noConnectedMints => 'Hakuna mint zilizounganishwa';

  @override
  String get addMintToStart => 'Ongeza mint kuanza';

  @override
  String get addMint => 'Ongeza mint';

  @override
  String get mintDeleted => 'Mint imefutwa';

  @override
  String get activeMintUpdated => 'Mint inayofanya kazi imesasishwa';

  @override
  String get mintUrl => 'URL ya mint:';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'URL lazima ianze na https://';

  @override
  String get connectingToMint => 'Kuunganisha na mint...';

  @override
  String get mintAddedSuccessfully => 'Mint imeongezwa kwa mafanikio';

  @override
  String get couldNotConnectToMint => 'Haikuweza kuunganisha na mint';

  @override
  String get add => 'Ongeza';

  @override
  String get success => 'Mafanikio';

  @override
  String get loading => 'Inapakia...';

  @override
  String get retry => 'Jaribu tena';

  @override
  String get activeMint => 'Mint inayofanya kazi';

  @override
  String get mintMessage => 'Ujumbe wa Mint';

  @override
  String get url => 'URL';

  @override
  String get currency => 'Sarafu';

  @override
  String get unknown => 'Haijulikani';

  @override
  String get useThisMint => 'Tumia mint hii';

  @override
  String get copyMintUrl => 'Nakili URL ya mint';

  @override
  String get deleteMint => 'Futa mint';

  @override
  String copied(String label) {
    return '$label imenakiliwa';
  }

  @override
  String get deleteMintConfirmTitle => 'Futa mint';

  @override
  String get deleteMintConfirmMessage =>
      'Ukiwa na salio katika mint hii, itapotea. Una uhakika?';

  @override
  String get delete => 'Futa';

  @override
  String get offlineSend => 'Tuma Nje ya Mtandao';

  @override
  String get selectAll => 'Zote';

  @override
  String get deselectAll => 'Hakuna';

  @override
  String get selectNotesToSend => 'Chagua noti unazotaka kutuma:';

  @override
  String get totalToSend => 'Jumla ya kutuma';

  @override
  String notesSelected(int count) {
    return 'noti $count zimechaguliwa';
  }

  @override
  String loadingProofsError(String error) {
    return 'Hitilafu ya kupakia uthibitisho: $error';
  }

  @override
  String creatingTokenError(String error) {
    return 'Hitilafu ya kuunda tokeni: $error';
  }

  @override
  String get unknownState => 'Hali isiyojulikana';

  @override
  String depositAmountTitle(String amount, String unit) {
    return 'Weka $amount $unit';
  }

  @override
  String get receiveNow => 'Pokea sasa';

  @override
  String get receiveLater => 'Pokea baadaye';

  @override
  String get tokenSavedForLater => 'Tokeni imehifadhiwa kudai baadaye';

  @override
  String get noConnectionTokenSaved =>
      'Hakuna muunganisho. Tokeni imehifadhiwa kudai baadaye.';

  @override
  String get unknownMintOffline =>
      'Tokeni hii ni kutoka mint isiyojulikana. Unganisha na mtandao kuongeza na kudai tokeni.';

  @override
  String get noConnectionTryLater =>
      'Hakuna muunganisho na mint. Jaribu baadaye.';

  @override
  String get saveTokenError => 'Hitilafu ya kuhifadhi tokeni. Jaribu tena.';

  @override
  String get pendingTokenLimitReached =>
      'Kikomo cha tokeni zinazosubiri kimefikiwa (upeo 50)';

  @override
  String get filterToReceive => 'Za kupokea';

  @override
  String get noPendingTokens => 'Hakuna tokeni zinazosubiri';

  @override
  String get noPendingTokensHint => 'Hifadhi tokeni kudai baadaye';

  @override
  String get pendingBadge => 'INASUBIRI';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Inaisha siku $days',
      one: 'Inaisha siku 1',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return 'majaribio $count';
  }

  @override
  String get claimNow => 'Dai sasa';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return 'Zimedaiwa $amount $unit';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zimedaiwa tokeni $count ($amount $unit)',
      one: 'Imedaiwa tokeni 1 ($amount $unit)',
    );
    return '$_temp0';
  }

  @override
  String get scan => 'Changanua';

  @override
  String get scanQrCode => 'Changanua QR';

  @override
  String get scanCashuToken => 'Changanua tokeni ya Cashu';

  @override
  String get scanLightningInvoice => 'Changanua ankara';

  @override
  String get scanningAnimatedQr => 'Kuchanganua QR inayosogea...';

  @override
  String get pointCameraAtQr => 'Elekeza kamera kwenye msimbo wa QR';

  @override
  String get pointCameraAtCashuQr =>
      'Elekeza kamera kwenye QR ya tokeni ya Cashu';

  @override
  String get pointCameraAtInvoiceQr => 'Elekeza kamera kwenye QR ya ankara';

  @override
  String get unrecognizedQrCode => 'Msimbo wa QR haujatambuliwa';

  @override
  String get scanCashuTokenHint =>
      'Changanua tokeni ya Cashu (cashuA... au cashuB...)';

  @override
  String get scanLightningInvoiceHint =>
      'Changanua ankara ya Lightning (lnbc...)';

  @override
  String get addMintQuestion => 'Ongeza mint hii?';

  @override
  String get cameraPermissionDenied => 'Ruhusa ya kamera imekataliwa';

  @override
  String get paymentRequestNotSupported => 'Maombi ya malipo bado hayatumiki';

  @override
  String get p2pkTitle => 'Funguo za P2PK';

  @override
  String get p2pkSettingsDescription => 'Pokea ecash iliyofungwa';

  @override
  String get p2pkExperimental => 'P2PK ni ya majaribio. Tumia kwa uangalifu.';

  @override
  String get p2pkPendingSendWarning =>
      'Una usafirishaji wa P2PK unaosubiri. Nenda kwenye historia na usasishe baada ya mpokeaji kudai tokeni.';

  @override
  String get p2pkExperimentalShort => 'Majaribio';

  @override
  String get p2pkPrimaryKey => 'Ufunguo Mkuu';

  @override
  String get p2pkDerived => 'Iliyotokana';

  @override
  String get p2pkImported => 'Iliyoingizwa';

  @override
  String get p2pkImportedKeys => 'Funguo Zilizoingizwa';

  @override
  String get p2pkNoImportedKeys => 'Hakuna funguo zilizoingizwa';

  @override
  String get p2pkShowQR => 'Onyesha QR';

  @override
  String get p2pkCopy => 'Nakili';

  @override
  String get p2pkImportNsec => 'Ingiza nsec';

  @override
  String get p2pkImport => 'Ingiza';

  @override
  String get p2pkEnterLabel => 'Jina la ufunguo huu';

  @override
  String get p2pkLockToKey => 'Tuma kwa saini ya P2PK';

  @override
  String get p2pkLockDescription => 'Mpokeaji pekee anaweza kudai';

  @override
  String get p2pkReceiverPubkey => 'npub1... au hex (herufi 64/66)';

  @override
  String get p2pkInvalidPubkey => 'Ufunguo wa umma batili';

  @override
  String get p2pkInvalidPrivateKey => 'Ufunguo wa siri batili';

  @override
  String get p2pkLockedToYou => 'Imefungwa kwako';

  @override
  String get p2pkLockedToOther => 'Imefungwa kwa ufunguo mwingine';

  @override
  String get p2pkCannotUnlock => 'Huna ufunguo wa kufungua tokeni hii';

  @override
  String get p2pkEnterPrivateKey => 'Ingiza ufunguo wa siri (nsec)';

  @override
  String get p2pkDeleteTitle => 'Futa ufunguo';

  @override
  String get p2pkDeleteConfirm =>
      'Futa ufunguo huu? Hutaweza kupokea tokeni zilizofungwa kwake.';

  @override
  String get p2pkRequiresConnection => 'P2PK inahitaji muunganisho kwa mint';

  @override
  String get p2pkErrorMaxKeysReached =>
      'Idadi ya juu ya funguo zilizoingizwa imefikiwa (10)';

  @override
  String get p2pkErrorInvalidNsec => 'nsec batili';

  @override
  String get p2pkErrorKeyAlreadyExists => 'Ufunguo huu tayari upo';

  @override
  String get p2pkErrorKeyNotFound => 'Ufunguo haujapatikana';

  @override
  String get p2pkErrorCannotDeletePrimary => 'Haiwezekani kufuta ufunguo mkuu';
}
