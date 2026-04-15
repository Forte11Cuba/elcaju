// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class L10nKo extends L10n {
  L10nKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => '당신의 프라이빗 ecash 지갑';

  @override
  String get loadingMessage1 => '코인 암호화 중...';

  @override
  String get loadingMessage2 => 'e-토큰 준비 중...';

  @override
  String get loadingMessage3 => 'Mint에 연결 중...';

  @override
  String get loadingMessage4 => '기본 프라이버시.';

  @override
  String get loadingMessage5 => '블라인드 서명 토큰...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = 프라이버시 + 자유';

  @override
  String get aboutTagline => '국경 없는 프라이버시.';

  @override
  String get welcomeTitle => 'ElCaju에 오신 것을 환영합니다';

  @override
  String get welcomeSubtitle => '세계를 위한 Cashu. 쿠바에서 제작.';

  @override
  String get createWallet => '새 지갑 만들기';

  @override
  String get restoreWallet => '지갑 복구';

  @override
  String get createWalletTitle => '지갑 만들기';

  @override
  String get creatingWallet => '지갑 생성 중...';

  @override
  String get generatingSeed => '시드 문구를 안전하게 생성 중';

  @override
  String get createWalletDescription =>
      '12개의 단어로 된 시드 문구가 생성됩니다.\n안전한 곳에 보관하세요.';

  @override
  String get generateWallet => '지갑 생성';

  @override
  String get walletCreated => '지갑이 생성되었습니다!';

  @override
  String get walletCreatedDescription =>
      '지갑이 준비되었습니다. 지금 시드 문구를 백업하는 것을 권장합니다.';

  @override
  String get backupWarning => '백업 없이는 기기를 분실하면 자금에 접근할 수 없습니다.';

  @override
  String get backupNow => '지금 백업';

  @override
  String get backupLater => '나중에 하기';

  @override
  String get backupTitle => '백업';

  @override
  String get seedPhraseTitle => '시드 문구';

  @override
  String get seedPhraseDescription =>
      '이 12개의 단어를 순서대로 저장하세요. 지갑을 복구하는 유일한 방법입니다.';

  @override
  String get revealSeedPhrase => '시드 문구 보기';

  @override
  String get tapToReveal => '버튼을 탭하여\n시드 문구를 확인하세요';

  @override
  String get copyToClipboard => '클립보드에 복사';

  @override
  String get seedCopied => '문구가 클립보드에 복사되었습니다';

  @override
  String get neverShareSeed => '시드 문구를 절대 다른 사람과 공유하지 마세요.';

  @override
  String get confirmBackup => '시드 문구를 안전한 곳에 저장했습니다';

  @override
  String get continue_ => '계속';

  @override
  String get restoreTitle => '지갑 복구';

  @override
  String get enterSeedPhrase => '시드 문구를 입력하세요';

  @override
  String get enterSeedDescription => '12개 또는 24개의 단어를 공백으로 구분하여 입력하세요.';

  @override
  String get seedPlaceholder => '단어1 단어2 단어3 ...';

  @override
  String wordCount(int count) {
    return '$count개 단어';
  }

  @override
  String get needWords => '(12개 또는 24개 필요)';

  @override
  String get restoreScanningMint => '민트에서 기존 토큰 검색 중...';

  @override
  String restoreError(String error) {
    return '복구 오류: $error';
  }

  @override
  String get homeTitle => '홈';

  @override
  String get receive => '받기';

  @override
  String get send => '보내기';

  @override
  String get sendAction => '보내기 ↗';

  @override
  String get receiveAction => '↘ 받기';

  @override
  String get deposit => '입금';

  @override
  String get withdraw => '출금';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => '거래 내역';

  @override
  String get noTransactions => '거래 내역이 없습니다';

  @override
  String get depositOrReceive => '시작하려면 sats를 입금하거나 받으세요';

  @override
  String get noMint => 'Mint 없음';

  @override
  String get balance => '잔액';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'ecash 토큰 붙여넣기';

  @override
  String get generateInvoiceToDeposit => '입금용 인보이스 생성';

  @override
  String get createEcashToken => 'ecash 토큰 만들기';

  @override
  String get payLightningInvoice => 'Lightning 인보이스 결제';

  @override
  String get receiveCashu => 'Cashu 받기';

  @override
  String get pasteTheCashuToken => 'Cashu 토큰을 붙여넣으세요:';

  @override
  String get pasteFromClipboard => '클립보드에서 붙여넣기';

  @override
  String get validToken => '유효한 토큰';

  @override
  String get invalidToken => '유효하지 않거나 손상된 토큰';

  @override
  String get amount => '금액:';

  @override
  String get mint => 'Mint:';

  @override
  String get claiming => '청구 중...';

  @override
  String get claimTokens => '토큰 청구';

  @override
  String get tokensReceived => '토큰을 받았습니다';

  @override
  String get backToHome => '홈으로 돌아가기';

  @override
  String get tokenAlreadyClaimed => '이 토큰은 이미 청구되었습니다';

  @override
  String get unknownMint => '알 수 없는 mint의 토큰';

  @override
  String claimError(String error) {
    return '청구 오류: $error';
  }

  @override
  String get sendCashu => 'Cashu 보내기';

  @override
  String get selectNotesManually => '수동으로 노트 선택';

  @override
  String get amountToSend => '보낼 금액:';

  @override
  String get available => '사용 가능:';

  @override
  String get max => '(최대)';

  @override
  String get memoOptional => '메모 (선택사항):';

  @override
  String get memoPlaceholder => '이 결제는 무엇을 위한 것인가요?';

  @override
  String get creatingToken => '토큰 생성 중...';

  @override
  String get createToken => '토큰 만들기';

  @override
  String get noActiveMint => '활성 mint 없음';

  @override
  String get offlineModeMessage => '연결 없음. 오프라인 모드...';

  @override
  String get confirmSend => '보내기 확인';

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get insufficientBalance => '잔액 부족';

  @override
  String get feeExceedsAmount => '수수료가 송금액을 초과합니다';

  @override
  String tokenCreationError(String error) {
    return '토큰 생성 오류: $error';
  }

  @override
  String get tokenCreated => '토큰이 생성되었습니다';

  @override
  String get copy => '복사';

  @override
  String get share => '공유';

  @override
  String get tokenCashu => 'Cashu 토큰';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Cashu 토큰 (애니메이션 QR - $fragments개 UR 조각)';
  }

  @override
  String get keepTokenWarning => '수신자가 청구할 때까지 이 토큰을 보관하세요. 분실하면 자금을 잃게 됩니다.';

  @override
  String get tokenCopiedToClipboard => '토큰이 클립보드에 복사되었습니다';

  @override
  String get copyAsEmoji => '이모지로 복사';

  @override
  String get emojiCopiedToClipboard => '토큰이 이모지로 복사되었습니다 🥜';

  @override
  String get peanutDecodeError => '이모지 토큰을 디코딩할 수 없습니다. 손상되었을 수 있습니다.';

  @override
  String get nfcWrite => 'NFC 태그에 쓰기';

  @override
  String get nfcRead => 'NFC 태그 읽기';

  @override
  String get nfcHoldNear => '기기를 NFC 태그에 가까이 대세요...';

  @override
  String get nfcWriteSuccess => '토큰이 NFC 태그에 기록되었습니다';

  @override
  String nfcWriteError(String error) {
    return 'NFC 쓰기 오류: $error';
  }

  @override
  String nfcReadError(String error) {
    return 'NFC 읽기 오류: $error';
  }

  @override
  String get nfcDisabled => 'NFC가 비활성화되어 있습니다. 설정에서 활성화하세요.';

  @override
  String get nfcUnsupported => '이 기기는 NFC를 지원하지 않습니다';

  @override
  String get amountToDeposit => '입금할 금액:';

  @override
  String get descriptionOptional => '설명 (선택사항):';

  @override
  String get depositPlaceholder => '이 입금은 무엇을 위한 것인가요?';

  @override
  String get generating => '생성 중...';

  @override
  String get generateInvoice => '인보이스 생성';

  @override
  String get depositLightning => 'Lightning 입금';

  @override
  String get payInvoiceTitle => '인보이스 결제';

  @override
  String get generatingInvoice => '인보이스 생성 중...';

  @override
  String get waitingForPayment => '결제 대기 중...';

  @override
  String get paymentReceived => '결제 완료';

  @override
  String get tokensIssued => '토큰이 발행되었습니다!';

  @override
  String get error => '오류';

  @override
  String get unknownError => '알 수 없는 오류';

  @override
  String get back => '뒤로';

  @override
  String get copyInvoice => '인보이스 복사';

  @override
  String get description => '설명:';

  @override
  String get invoiceCopiedToClipboard => '인보이스가 클립보드에 복사되었습니다';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit 입금됨';
  }

  @override
  String get pasteLightningInvoice => 'Lightning 인보이스를 붙여넣으세요:';

  @override
  String get gettingQuote => '견적 조회 중...';

  @override
  String get validInvoice => '유효한 인보이스';

  @override
  String get invalidInvoice => '유효하지 않은 인보이스';

  @override
  String get invalidInvoiceMalformed => '유효하지 않거나 손상된 인보이스';

  @override
  String get feeReserved => '예약 수수료:';

  @override
  String get total => '총액:';

  @override
  String get paying => '결제 중...';

  @override
  String get payInvoice => '인보이스 결제';

  @override
  String get confirmPayment => '결제 확인';

  @override
  String get pay => '결제';

  @override
  String get fee => '수수료';

  @override
  String get invoiceExpired => '인보이스 만료됨';

  @override
  String get amountOutOfRange => '허용 범위를 벗어난 금액';

  @override
  String resolvingType(String type) {
    return '$type 확인 중...';
  }

  @override
  String get invoiceAlreadyPaid => '이미 결제된 인보이스';

  @override
  String paymentError(String error) {
    return '결제 오류: $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit 전송됨';
  }

  @override
  String get filterAll => '전체';

  @override
  String get filterPending => '대기 중';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => '시작하려면 Cashu 토큰을 받으세요';

  @override
  String get noPendingTransactions => '대기 중인 거래 없음';

  @override
  String get allTransactionsCompleted => '모든 거래가 완료되었습니다';

  @override
  String get noEcashTransactions => 'Ecash 거래 없음';

  @override
  String get sendOrReceiveTokens => 'Cashu 토큰을 보내거나 받으세요';

  @override
  String get noLightningTransactions => 'Lightning 거래 없음';

  @override
  String get depositOrWithdrawLightning => 'Lightning으로 입금 또는 출금';

  @override
  String get pendingStatus => '대기 중';

  @override
  String get receivedStatus => '받음';

  @override
  String get sentStatus => '보냄';

  @override
  String get now => '방금';

  @override
  String agoMinutes(int minutes) {
    return '$minutes분 전';
  }

  @override
  String agoHours(int hours) {
    return '$hours시간 전';
  }

  @override
  String agoDays(int days) {
    return '$days일 전';
  }

  @override
  String get lightningInvoice => 'Lightning 인보이스';

  @override
  String get receivedEcash => 'Ecash 받음';

  @override
  String get sentEcash => 'Ecash 보냄';

  @override
  String get outgoingLightningPayment => 'Lightning 송금';

  @override
  String get invoiceNotAvailable => '인보이스를 사용할 수 없음';

  @override
  String get tokenNotAvailable => '토큰을 사용할 수 없음';

  @override
  String get unit => '단위';

  @override
  String get status => '상태';

  @override
  String get pending => '대기 중';

  @override
  String get memo => '메모';

  @override
  String get copyInvoiceButton => '인보이스 복사';

  @override
  String get copyButton => '복사';

  @override
  String get invoiceCopied => '인보이스 복사됨';

  @override
  String get tokenCopied => '토큰 복사됨';

  @override
  String get speed => '속도:';

  @override
  String get settings => '설정';

  @override
  String get walletSection => '지갑';

  @override
  String get backupSeedPhrase => '시드 문구 백업';

  @override
  String get viewRecoveryWords => '복구 단어 보기';

  @override
  String get connectedMints => '연결된 Mint';

  @override
  String get manageCashuMints => 'Cashu mint 관리';

  @override
  String get pinAccess => 'PIN 잠금';

  @override
  String get pinEnabled => '활성화됨';

  @override
  String get protectWithPin => 'PIN으로 앱 보호';

  @override
  String get recoverTokens => '토큰 복구';

  @override
  String get scanMintsWithSeed => '시드 문구로 mint 스캔';

  @override
  String get appearanceSection => '언어';

  @override
  String get language => '언어';

  @override
  String get informationSection => '정보';

  @override
  String get version => '버전';

  @override
  String get about => '정보';

  @override
  String get deleteWallet => '지갑 삭제';

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
  String get mnemonicNotFound => '니모닉을 찾을 수 없음';

  @override
  String get createPin => 'PIN 만들기';

  @override
  String get enterPinDigits => '4자리 PIN을 입력하세요';

  @override
  String get confirmPin => 'PIN 확인';

  @override
  String get enterPinAgain => 'PIN을 다시 입력하세요';

  @override
  String get pinMismatch => 'PIN이 일치하지 않습니다';

  @override
  String get pinActivated => 'PIN 활성화됨';

  @override
  String get pinDeactivated => 'PIN 비활성화됨';

  @override
  String get verifyPin => 'PIN 확인';

  @override
  String get enterCurrentPin => '현재 PIN을 입력하세요';

  @override
  String get incorrectPin => '잘못된 PIN';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String languageChanged(String language) {
    return '언어가 $language(으)로 변경되었습니다';
  }

  @override
  String get close => '닫기';

  @override
  String get aboutDescription => '전 세계를 위한 쿠바 DNA를 가진 Cashu 지갑. LaChispa의 형제.';

  @override
  String get couldNotOpenLink => '링크를 열 수 없음';

  @override
  String get deleteWalletQuestion => '지갑을 삭제하시겠습니까?';

  @override
  String get actionIrreversible => '이 작업은 되돌릴 수 없습니다';

  @override
  String get deleteWalletWarning =>
      '시드 문구와 토큰을 포함한 모든 데이터가 삭제됩니다. 백업이 있는지 확인하세요.';

  @override
  String get typeDeleteToConfirm => '확인하려면 \"삭제\"를 입력하세요:';

  @override
  String get deleteConfirmWord => '삭제';

  @override
  String deleteError(String error) {
    return '삭제 오류: $error';
  }

  @override
  String get recoverTokensTitle => '토큰 복구';

  @override
  String get recoverTokensDescription =>
      '시드 문구와 연결된 토큰을 복구하기 위해 mint 스캔 (NUT-13)';

  @override
  String get useCurrentSeedPhrase => '현재 시드 문구 사용';

  @override
  String get scanWithSavedWords => '저장된 12개 단어로 mint 스캔';

  @override
  String get useOtherSeedPhrase => '다른 시드 문구 사용';

  @override
  String get recoverFromOtherWords => '다른 12개 단어에서 토큰 복구';

  @override
  String get mintsToScan => '스캔할 Mint:';

  @override
  String allMints(int count) {
    return '모든 mint ($count개)';
  }

  @override
  String get specificMint => '특정 mint';

  @override
  String get enterMnemonicWords => '공백으로 구분된 12개 단어를 입력하세요...';

  @override
  String get scanMints => 'Mint 스캔';

  @override
  String get selectMintToScan => '스캔할 mint 선택';

  @override
  String get mnemonicMustHaveWords => '니모닉은 12개 또는 24개 단어여야 합니다';

  @override
  String get noConnectedMintsToScan => '스캔할 연결된 mint 없음';

  @override
  String recoveredTokens(String tokens, int mints) {
    return '$mints개 mint에서 $tokens 복구됨!';
  }

  @override
  String get scanCompleteNoTokens => '스캔 완료. 새 토큰을 찾지 못했습니다.';

  @override
  String mintsWithError(int count) {
    return '($count개 mint 오류)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return '$mint에서 $tokens 복구됨!';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return '$mint에서 토큰을 찾을 수 없음.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return '$amount $unit이(가) 지갑으로 복구 및 전송되었습니다!';
  }

  @override
  String get noTokensForMnemonic => '해당 니모닉과 연결된 토큰을 찾을 수 없음.';

  @override
  String get noConnectedMints => '연결된 mint 없음';

  @override
  String get addMintToStart => '시작하려면 mint를 추가하세요';

  @override
  String get addMint => 'Mint 추가';

  @override
  String get mintDeleted => 'Mint 삭제됨';

  @override
  String get activeMintUpdated => '활성 mint 업데이트됨';

  @override
  String get mintUrl => 'Mint URL:';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'URL은 https://로 시작해야 합니다';

  @override
  String get connectingToMint => 'Mint에 연결 중...';

  @override
  String get mintAddedSuccessfully => 'Mint가 성공적으로 추가되었습니다';

  @override
  String get couldNotConnectToMint => 'Mint에 연결할 수 없음';

  @override
  String get add => '추가';

  @override
  String get success => '성공';

  @override
  String get loading => '로딩 중...';

  @override
  String get retry => '다시 시도';

  @override
  String get activeMint => '활성 Mint';

  @override
  String get mintMessage => 'Mint 메시지';

  @override
  String get url => 'URL';

  @override
  String get currency => '통화';

  @override
  String get unknown => '알 수 없음';

  @override
  String get useThisMint => '이 mint 사용';

  @override
  String get copyMintUrl => 'Mint URL 복사';

  @override
  String get deleteMint => 'Mint 삭제';

  @override
  String copied(String label) {
    return '$label 복사됨';
  }

  @override
  String get deleteMintConfirmTitle => 'Mint 삭제';

  @override
  String get deleteMintConfirmMessage => '이 mint에 잔액이 있으면 잃게 됩니다. 확실합니까?';

  @override
  String get delete => '삭제';

  @override
  String get offlineSend => '오프라인 전송';

  @override
  String get selectAll => '전체';

  @override
  String get deselectAll => '없음';

  @override
  String get selectNotesToSend => '보낼 노트를 선택하세요:';

  @override
  String get totalToSend => '보낼 총액';

  @override
  String notesSelected(int count) {
    return '$count개 노트 선택됨';
  }

  @override
  String loadingProofsError(String error) {
    return '증명 로드 오류: $error';
  }

  @override
  String creatingTokenError(String error) {
    return '토큰 생성 오류: $error';
  }

  @override
  String get unknownState => '알 수 없는 상태';

  @override
  String depositAmountTitle(String amount, String unit) {
    return '$amount $unit 입금';
  }

  @override
  String get receiveNow => '지금 받기';

  @override
  String get receiveLater => '나중에 받기';

  @override
  String get tokenSavedForLater => '나중에 청구하기 위해 토큰이 저장되었습니다';

  @override
  String get noConnectionTokenSaved => '연결 없음. 나중에 청구하기 위해 토큰이 저장되었습니다.';

  @override
  String get unknownMintOffline =>
      '이 토큰은 알 수 없는 mint의 것입니다. 인터넷에 연결하여 추가하고 토큰을 청구하세요.';

  @override
  String get noConnectionTryLater => 'Mint에 연결할 수 없음. 나중에 다시 시도하세요.';

  @override
  String get saveTokenError => '토큰 저장 오류. 다시 시도해 주세요.';

  @override
  String get pendingTokenLimitReached => '대기 중 토큰 한도 도달 (최대 50개)';

  @override
  String get filterToReceive => '받을 항목';

  @override
  String get noPendingTokens => '대기 중인 토큰 없음';

  @override
  String get noPendingTokensHint => '나중에 청구할 토큰을 저장하세요';

  @override
  String get pendingBadge => '대기 중';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days일 후 만료',
      one: '1일 후 만료',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count회 재시도';
  }

  @override
  String get claimNow => '지금 청구';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return '$amount $unit 청구됨';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 토큰 청구됨 ($amount $unit)',
      one: '1개 토큰 청구됨 ($amount $unit)',
    );
    return '$_temp0';
  }

  @override
  String get scan => '스캔';

  @override
  String get scanQrCode => 'QR 스캔';

  @override
  String get scanCashuToken => 'Cashu 토큰 스캔';

  @override
  String get scanLightningInvoice => '인보이스 스캔';

  @override
  String get scanningAnimatedQr => '애니메이션 QR 스캔 중...';

  @override
  String get pointCameraAtQr => '카메라를 QR 코드에 맞추세요';

  @override
  String get pointCameraAtCashuQr => '카메라를 Cashu 토큰 QR에 맞추세요';

  @override
  String get pointCameraAtInvoiceQr => '카메라를 인보이스 QR에 맞추세요';

  @override
  String get unrecognizedQrCode => '인식할 수 없는 QR 코드';

  @override
  String get scanCashuTokenHint => 'Cashu 토큰 스캔 (cashuA... 또는 cashuB...)';

  @override
  String get scanLightningInvoiceHint => 'Lightning 인보이스 스캔 (lnbc...)';

  @override
  String get addMintQuestion => '이 mint를 추가하시겠습니까?';

  @override
  String get cameraPermissionDenied => '카메라 권한이 거부되었습니다';

  @override
  String get paymentRequestTitle => '결제 요청';

  @override
  String get paymentRequestFrom => '요청자';

  @override
  String get paymentRequestAmount => '요청 금액';

  @override
  String get paymentRequestDescription => '설명';

  @override
  String get paymentRequestMints => '허용된 민트';

  @override
  String get paymentRequestAnyMint => '모든 민트';

  @override
  String get paymentRequestPay => '결제';

  @override
  String get paymentRequestPaying => '결제 중...';

  @override
  String get paymentRequestSuccess => '결제가 성공적으로 전송되었습니다';

  @override
  String get paymentRequestNoTransport => '이 요청에는 전달 방법이 설정되지 않았습니다';

  @override
  String get paymentRequestTransport => '전송 방식';

  @override
  String get paymentRequestMintNotAccepted => '활성 민트가 허용된 민트 목록에 없습니다';

  @override
  String paymentRequestUnitMismatch(String unit) {
    return '호환되지 않는 단위: 요청에 $unit이(가) 필요합니다';
  }

  @override
  String get paymentRequestInsufficientBalance => '잔액 부족';

  @override
  String get paymentRequestErrorParsing => '결제 요청을 읽는 중 오류 발생';

  @override
  String get p2pkTitle => 'P2PK 키';

  @override
  String get p2pkSettingsDescription => '잠긴 ecash 받기';

  @override
  String get p2pkExperimental => 'P2PK는 실험적 기능입니다. 주의하여 사용하세요.';

  @override
  String get p2pkPendingSendWarning =>
      '대기 중인 P2PK 전송이 있습니다. 수신자가 토큰을 수령한 후 기록에서 새로고침하세요.';

  @override
  String get p2pkExperimentalShort => '실험적';

  @override
  String get p2pkPrimaryKey => '기본 키';

  @override
  String get p2pkDerived => '파생됨';

  @override
  String get p2pkImported => '가져옴';

  @override
  String get p2pkImportedKeys => '가져온 키';

  @override
  String get p2pkNoImportedKeys => '가져온 키가 없습니다';

  @override
  String get p2pkShowQR => 'QR 표시';

  @override
  String get p2pkCopy => '복사';

  @override
  String get p2pkImportNsec => 'nsec 가져오기';

  @override
  String get p2pkImport => '가져오기';

  @override
  String get p2pkEnterLabel => '이 키의 이름';

  @override
  String get p2pkLockToKey => 'P2PK 서명으로 전송';

  @override
  String get p2pkLockDescription => '수신자만 청구 가능';

  @override
  String get p2pkReceiverPubkey => 'npub1... 또는 hex (64/66자)';

  @override
  String get p2pkInvalidPubkey => '유효하지 않은 공개 키';

  @override
  String get p2pkInvalidPrivateKey => '유효하지 않은 개인 키';

  @override
  String get p2pkLockedToYou => '당신에게 잠김';

  @override
  String get p2pkLockedToOther => '다른 키로 잠김';

  @override
  String get p2pkCannotUnlock => '이 토큰을 잠금 해제할 키가 없습니다';

  @override
  String get p2pkEnterPrivateKey => '개인 키 입력 (nsec)';

  @override
  String get p2pkDeleteTitle => '키 삭제';

  @override
  String get p2pkDeleteConfirm => '이 키를 삭제하시겠습니까? 이 키로 잠긴 토큰을 받을 수 없게 됩니다.';

  @override
  String get p2pkRequiresConnection => 'P2PK는 mint 연결이 필요합니다';

  @override
  String get p2pkErrorMaxKeysReached => '가져온 키의 최대 개수에 도달했습니다 (10)';

  @override
  String get p2pkErrorInvalidNsec => '유효하지 않은 nsec';

  @override
  String get p2pkErrorKeyAlreadyExists => '이 키는 이미 존재합니다';

  @override
  String get p2pkErrorKeyNotFound => '키를 찾을 수 없습니다';

  @override
  String get p2pkErrorCannotDeletePrimary => '기본 키는 삭제할 수 없습니다';

  @override
  String get request => '요청';

  @override
  String get requestPayment => '결제 요청';

  @override
  String get requestPaymentDescription => '통합 결제 요청 생성';

  @override
  String get generateRequest => '요청 생성';

  @override
  String get generatingRequest => '생성 중...';

  @override
  String get requestPaymentReceived => '결제가 수신되었습니다';

  @override
  String get requestDescriptionHint => '설명 (선택사항)';

  @override
  String get universal => '유니버설';

  @override
  String get copiedToClipboard => '클립보드에 복사되었습니다';

  @override
  String get swap => '교환';

  @override
  String get swapDescription => 'Sats와 USD 간 변환';

  @override
  String get swapFrom => '에서';

  @override
  String get swapTo => '으로';

  @override
  String get swapAction => '교환';

  @override
  String get swapEstimatedFee => '예상 수수료';

  @override
  String get swapUseAll => '전액 사용';

  @override
  String swapMinimum(String amount) {
    return '최소: $amount';
  }

  @override
  String get swapProcessing => '교환 처리 중...';

  @override
  String get swapSuccess => '교환 완료';

  @override
  String get swapErrorInsufficient => '잔액 부족';

  @override
  String get swapErrorExpired => '견적이 만료되었습니다';

  @override
  String swapErrorGeneric(String error) {
    return '교환 오류: $error';
  }

  @override
  String get swapChartUnavailable => '가격 불러오기 실패 · 탭하여 재시도';

  @override
  String swapChartMinMax(String minPrice, String maxPrice) {
    return '24h  최저: $minPrice — 최고: $maxPrice';
  }

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get privacyTitle => '우리는 아무것도 수집하지 않습니다';

  @override
  String get privacyGoodbye => '안녕';

  @override
  String get privacyKeepReading => '(계속 읽고 싶으면…)';

  @override
  String get privacyBody => '당신이 누구인지 모릅니다\n얼마를 가지고 있는지 모릅니다\n무엇을 하는지 모릅니다';

  @override
  String get privacyConclusion => '데이터를 보호하는 가장 좋은 방법은\n데이터를 갖지 않는 것입니다';
}
