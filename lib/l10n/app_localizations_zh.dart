import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => '您的私密电子现金钱包';

  @override
  String get loadingMessage1 => '正在加密您的代币...';

  @override
  String get loadingMessage2 => '正在准备您的电子代币...';

  @override
  String get loadingMessage3 => '正在连接铸造厂...';

  @override
  String get loadingMessage4 => '默认隐私保护。';

  @override
  String get loadingMessage5 => '正在盲签代币...';

  @override
  String get loadingMessage6 => '全力以赴...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = 隐私 + 自由';

  @override
  String get aboutTagline => '无国界隐私。';

  @override
  String get welcomeTitle => '欢迎使用 ElCaju';

  @override
  String get welcomeSubtitle => '面向世界的 Cashu。古巴制造。';

  @override
  String get createWallet => '创建新钱包';

  @override
  String get restoreWallet => '恢复钱包';

  @override
  String get createWalletTitle => '创建钱包';

  @override
  String get creatingWallet => '正在创建您的钱包...';

  @override
  String get generatingSeed => '正在安全生成您的助记词';

  @override
  String get createWalletDescription => '将生成一个12词助记词。\n请将其保存在安全的地方。';

  @override
  String get generateWallet => '生成钱包';

  @override
  String get walletCreated => '钱包已创建！';

  @override
  String get walletCreatedDescription => '您的钱包已准备就绪。我们建议您现在备份助记词。';

  @override
  String get backupWarning => '如果没有备份，一旦丢失设备，您将无法访问您的资金。';

  @override
  String get backupNow => '立即备份';

  @override
  String get backupLater => '稍后备份';

  @override
  String get backupTitle => '备份';

  @override
  String get seedPhraseTitle => '您的助记词';

  @override
  String get seedPhraseDescription => '按顺序保存这12个单词。这是恢复钱包的唯一方式。';

  @override
  String get revealSeedPhrase => '显示助记词';

  @override
  String get tapToReveal => '点击按钮显示\n您的助记词';

  @override
  String get copyToClipboard => '复制到剪贴板';

  @override
  String get seedCopied => '助记词已复制到剪贴板';

  @override
  String get neverShareSeed => '切勿与任何人分享您的助记词。';

  @override
  String get confirmBackup => '我已将助记词保存在安全的地方';

  @override
  String get continue_ => '继续';

  @override
  String get restoreTitle => '恢复钱包';

  @override
  String get enterSeedPhrase => '输入您的助记词';

  @override
  String get enterSeedDescription => '输入12或24个单词，用空格分隔。';

  @override
  String get seedPlaceholder => '单词1 单词2 单词3 ...';

  @override
  String wordCount(int count) {
    return '$count 个单词';
  }

  @override
  String get needWords => '（需要12或24个）';

  @override
  String get restoreScanningMint => '正在扫描铸币厂中的现有代币...';

  @override
  String restoreError(String error) {
    return '恢复错误：$error';
  }

  @override
  String get homeTitle => '首页';

  @override
  String get receive => '收款';

  @override
  String get send => '付款';

  @override
  String get sendAction => '付款 ↗';

  @override
  String get receiveAction => '↘ 收款';

  @override
  String get deposit => '存入';

  @override
  String get withdraw => '提取';

  @override
  String get lightning => '闪电网络';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => '电子现金';

  @override
  String get history => '历史记录';

  @override
  String get noTransactions => '暂无交易';

  @override
  String get depositOrReceive => '存入或接收聪开始使用';

  @override
  String get noMint => '无铸造厂';

  @override
  String get balance => '余额';

  @override
  String get sats => '聪';

  @override
  String get pasteEcashToken => '粘贴电子现金代币';

  @override
  String get generateInvoiceToDeposit => '生成存款发票';

  @override
  String get createEcashToken => '创建电子现金代币';

  @override
  String get payLightningInvoice => '支付闪电发票';

  @override
  String get receiveCashu => '接收 Cashu';

  @override
  String get pasteTheCashuToken => '粘贴 Cashu 代币：';

  @override
  String get pasteFromClipboard => '从剪贴板粘贴';

  @override
  String get validToken => '有效代币';

  @override
  String get invalidToken => '无效或格式错误的代币';

  @override
  String get amount => '金额：';

  @override
  String get mint => '铸造厂：';

  @override
  String get claiming => '正在领取...';

  @override
  String get claimTokens => '领取代币';

  @override
  String get tokensReceived => '已收到代币';

  @override
  String get backToHome => '返回首页';

  @override
  String get tokenAlreadyClaimed => '此代币已被领取';

  @override
  String get unknownMint => '来自未知铸造厂的代币';

  @override
  String claimError(String error) {
    return '领取错误：$error';
  }

  @override
  String get sendCashu => '发送 Cashu';

  @override
  String get selectNotesManually => '手动选择票据';

  @override
  String get amountToSend => '发送金额：';

  @override
  String get available => '可用：';

  @override
  String get max => '（最大）';

  @override
  String get memoOptional => '备注（可选）：';

  @override
  String get memoPlaceholder => '这笔付款是用于什么？';

  @override
  String get creatingToken => '正在创建代币...';

  @override
  String get createToken => '创建代币';

  @override
  String get noActiveMint => '没有活跃的铸造厂';

  @override
  String get offlineModeMessage => '无连接。使用离线模式...';

  @override
  String get confirmSend => '确认发送';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get insufficientBalance => '余额不足';

  @override
  String tokenCreationError(String error) {
    return '创建代币错误：$error';
  }

  @override
  String get tokenCreated => '代币已创建';

  @override
  String get copy => '复制';

  @override
  String get share => '分享';

  @override
  String get tokenCashu => 'Cashu 代币';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Cashu 代币（动态二维码 - $fragments 个 UR 片段）';
  }

  @override
  String get keepTokenWarning => '请保留此代币直到收款方领取。如果丢失，资金将无法找回。';

  @override
  String get tokenCopiedToClipboard => '代币已复制到剪贴板';

  @override
  String get amountToDeposit => '存入金额：';

  @override
  String get descriptionOptional => '描述（可选）：';

  @override
  String get depositPlaceholder => '这笔存款是用于什么？';

  @override
  String get generating => '正在生成...';

  @override
  String get generateInvoice => '生成发票';

  @override
  String get depositLightning => '闪电存款';

  @override
  String get payInvoiceTitle => '支付发票';

  @override
  String get generatingInvoice => '正在生成发票...';

  @override
  String get waitingForPayment => '等待付款...';

  @override
  String get paymentReceived => '已收到付款';

  @override
  String get tokensIssued => '代币已发行！';

  @override
  String get error => '错误';

  @override
  String get unknownError => '未知错误';

  @override
  String get back => '返回';

  @override
  String get copyInvoice => '复制发票';

  @override
  String get description => '描述：';

  @override
  String get invoiceCopiedToClipboard => '发票已复制到剪贴板';

  @override
  String deposited(String amount, String unit) {
    return '已存入 $amount $unit';
  }

  @override
  String get pasteLightningInvoice => '粘贴闪电发票：';

  @override
  String get gettingQuote => '正在获取报价...';

  @override
  String get validInvoice => '有效发票';

  @override
  String get invalidInvoice => '无效发票';

  @override
  String get invalidInvoiceMalformed => '无效或格式错误的发票';

  @override
  String get feeReserved => '预留手续费：';

  @override
  String get total => '总计：';

  @override
  String get paying => '正在支付...';

  @override
  String get payInvoice => '支付发票';

  @override
  String get confirmPayment => '确认支付';

  @override
  String get pay => '支付';

  @override
  String get fee => '手续费';

  @override
  String get invoiceExpired => '发票已过期';

  @override
  String get amountOutOfRange => '金额超出允许范围';

  @override
  String resolvingType(String type) {
    return '正在解析 $type...';
  }

  @override
  String get invoiceAlreadyPaid => '发票已支付';

  @override
  String paymentError(String error) {
    return '支付错误：$error';
  }

  @override
  String sent(String amount, String unit) {
    return '已发送 $amount $unit';
  }

  @override
  String get filterAll => '全部';

  @override
  String get filterPending => '待处理';

  @override
  String get filterEcash => '电子现金';

  @override
  String get filterLightning => '闪电';

  @override
  String get receiveTokensToStart => '接收 Cashu 代币开始使用';

  @override
  String get noPendingTransactions => '没有待处理的交易';

  @override
  String get allTransactionsCompleted => '所有交易已完成';

  @override
  String get noEcashTransactions => '没有电子现金交易';

  @override
  String get sendOrReceiveTokens => '发送或接收 Cashu 代币';

  @override
  String get noLightningTransactions => '没有闪电交易';

  @override
  String get depositOrWithdrawLightning => '通过闪电网络存入或提取';

  @override
  String get pendingStatus => '待处理';

  @override
  String get receivedStatus => '已收到';

  @override
  String get sentStatus => '已发送';

  @override
  String get now => '刚刚';

  @override
  String agoMinutes(int minutes) {
    return '$minutes 分钟前';
  }

  @override
  String agoHours(int hours) {
    return '$hours 小时前';
  }

  @override
  String agoDays(int days) {
    return '$days 天前';
  }

  @override
  String get lightningInvoice => '闪电发票';

  @override
  String get receivedEcash => '收到电子现金';

  @override
  String get sentEcash => '发送电子现金';

  @override
  String get outgoingLightningPayment => '闪电支出';

  @override
  String get invoiceNotAvailable => '发票不可用';

  @override
  String get tokenNotAvailable => '代币不可用';

  @override
  String get unit => '单位';

  @override
  String get status => '状态';

  @override
  String get pending => '待处理';

  @override
  String get memo => '备注';

  @override
  String get copyInvoiceButton => '复制发票';

  @override
  String get copyButton => '复制';

  @override
  String get invoiceCopied => '发票已复制';

  @override
  String get tokenCopied => '代币已复制';

  @override
  String get speed => '速度：';

  @override
  String get settings => '设置';

  @override
  String get walletSection => '钱包';

  @override
  String get backupSeedPhrase => '备份助记词';

  @override
  String get viewRecoveryWords => '查看恢复词';

  @override
  String get connectedMints => '已连接铸造厂';

  @override
  String get manageCashuMints => '管理您的 Cashu 铸造厂';

  @override
  String get pinAccess => 'PIN 访问';

  @override
  String get pinEnabled => '已启用';

  @override
  String get protectWithPin => '用 PIN 保护应用';

  @override
  String get recoverTokens => '恢复代币';

  @override
  String get scanMintsWithSeed => '使用助记词扫描铸造厂';

  @override
  String get appearanceSection => '语言';

  @override
  String get language => '语言';

  @override
  String get informationSection => '信息';

  @override
  String get version => '版本';

  @override
  String get about => '关于';

  @override
  String get deleteWallet => '删除钱包';

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
  String get mnemonicNotFound => '未找到助记词';

  @override
  String get createPin => '创建 PIN';

  @override
  String get enterPinDigits => '输入4位数 PIN';

  @override
  String get confirmPin => '确认 PIN';

  @override
  String get enterPinAgain => '再次输入 PIN';

  @override
  String get pinMismatch => 'PIN 不匹配';

  @override
  String get pinActivated => 'PIN 已激活';

  @override
  String get pinDeactivated => 'PIN 已停用';

  @override
  String get verifyPin => '验证 PIN';

  @override
  String get enterCurrentPin => '输入当前 PIN';

  @override
  String get incorrectPin => 'PIN 错误';

  @override
  String get selectLanguage => '选择语言';

  @override
  String languageChanged(String language) {
    return '语言已更改为 $language';
  }

  @override
  String get close => '关闭';

  @override
  String get aboutDescription => '具有古巴基因的 Cashu 钱包，面向全世界。La Chispa 的兄弟项目。';

  @override
  String get couldNotOpenLink => '无法打开链接';

  @override
  String get deleteWalletQuestion => '删除钱包？';

  @override
  String get actionIrreversible => '此操作不可撤销';

  @override
  String get deleteWalletWarning => '所有数据将被删除，包括您的助记词和代币。请确保您有备份。';

  @override
  String get typeDeleteToConfirm => '输入 \"DELETE\" 确认：';

  @override
  String get deleteConfirmWord => 'DELETE';

  @override
  String deleteError(String error) {
    return '删除错误：$error';
  }

  @override
  String get recoverTokensTitle => '恢复代币';

  @override
  String get recoverTokensDescription => '扫描铸造厂以恢复与您的助记词关联的代币（NUT-13）';

  @override
  String get useCurrentSeedPhrase => '使用当前助记词';

  @override
  String get scanWithSavedWords => '使用保存的12个单词扫描铸造厂';

  @override
  String get useOtherSeedPhrase => '使用其他助记词';

  @override
  String get recoverFromOtherWords => '从其他12个单词恢复代币';

  @override
  String get mintsToScan => '要扫描的铸造厂：';

  @override
  String allMints(int count) {
    return '所有铸造厂（$count个）';
  }

  @override
  String get specificMint => '特定铸造厂';

  @override
  String get enterMnemonicWords => '输入12个单词，用空格分隔...';

  @override
  String get scanMints => '扫描铸造厂';

  @override
  String get selectMintToScan => '选择要扫描的铸造厂';

  @override
  String get mnemonicMustHaveWords => '助记词必须有12或24个单词';

  @override
  String get noConnectedMintsToScan => '没有已连接的铸造厂可扫描';

  @override
  String recoveredTokens(String tokens, int mints) {
    return '已从 $mints 个铸造厂恢复 $tokens！';
  }

  @override
  String get scanCompleteNoTokens => '扫描完成。未发现新代币。';

  @override
  String mintsWithError(int count) {
    return '（$count个铸造厂出错）';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return '已从 $mint 恢复 $tokens！';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return '在 $mint 中未发现代币。';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return '已恢复并转入 $amount $unit 到您的钱包！';
  }

  @override
  String get noTokensForMnemonic => '未发现与该助记词关联的代币。';

  @override
  String get noConnectedMints => '没有已连接的铸造厂';

  @override
  String get addMintToStart => '添加铸造厂开始使用';

  @override
  String get addMint => '添加铸造厂';

  @override
  String get mintDeleted => '铸造厂已删除';

  @override
  String get activeMintUpdated => '活跃铸造厂已更新';

  @override
  String get mintUrl => '铸造厂 URL：';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'URL 必须以 https:// 开头';

  @override
  String get connectingToMint => '正在连接铸造厂...';

  @override
  String get mintAddedSuccessfully => '铸造厂添加成功';

  @override
  String get couldNotConnectToMint => '无法连接到铸造厂';

  @override
  String get add => '添加';

  @override
  String get success => '成功';

  @override
  String get loading => '加载中...';

  @override
  String get retry => '重试';

  @override
  String get activeMint => '活跃铸造厂';

  @override
  String get mintMessage => '铸造厂消息';

  @override
  String get url => '网址';

  @override
  String get currency => '货币';

  @override
  String get unknown => '未知';

  @override
  String get useThisMint => '使用此铸造厂';

  @override
  String get copyMintUrl => '复制铸造厂 URL';

  @override
  String get deleteMint => '删除铸造厂';

  @override
  String copied(String label) {
    return '$label 已复制';
  }

  @override
  String get deleteMintConfirmTitle => '删除铸造厂';

  @override
  String get deleteMintConfirmMessage => '如果您在此铸造厂有余额，将会丢失。确定要删除吗？';

  @override
  String get delete => '删除';

  @override
  String get offlineSend => '离线发送';

  @override
  String get selectNotesToSend => '选择要发送的票据：';

  @override
  String get totalToSend => '发送总额';

  @override
  String notesSelected(int count) {
    return '已选择 $count 张票据';
  }

  @override
  String loadingProofsError(String error) {
    return '加载证明错误：$error';
  }

  @override
  String creatingTokenError(String error) {
    return '创建代币错误：$error';
  }

  @override
  String get unknownState => '未知状态';

  @override
  String depositAmountTitle(String amount, String unit) {
    return '存入 $amount $unit';
  }

  @override
  String get receiveNow => '立即接收';

  @override
  String get receiveLater => '稍后接收';

  @override
  String get tokenSavedForLater => '代币已保存，稍后领取';

  @override
  String get noConnectionTokenSaved => '无连接。代币已保存，稍后领取。';

  @override
  String get unknownMintOffline => '此代币来自未知铸造厂。请连接互联网以添加并领取代币。';

  @override
  String get noConnectionTryLater => '无法连接铸造厂。请稍后重试。';

  @override
  String get saveTokenError => '保存代币错误。请重试。';

  @override
  String get pendingTokenLimitReached => '待处理代币达到上限（最多50个）';

  @override
  String get filterToReceive => '待接收';

  @override
  String get noPendingTokens => '没有待处理代币';

  @override
  String get noPendingTokensHint => '保存代币稍后领取';

  @override
  String get pendingBadge => '待处理';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days天后过期',
      one: '1天后过期',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count 次重试';
  }

  @override
  String get claimNow => '立即领取';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return '已领取 $amount $unit';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已领取$count个代币（$amount $unit）',
      one: '已领取1个代币（$amount $unit）',
    );
    return '$_temp0';
  }

  @override
  String get scan => '扫描';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get scanCashuToken => '扫描 Cashu 代币';

  @override
  String get scanLightningInvoice => '扫描发票';

  @override
  String get scanningAnimatedQr => '正在扫描动态二维码...';

  @override
  String get pointCameraAtQr => '将相机对准二维码';

  @override
  String get pointCameraAtCashuQr => '将相机对准 Cashu 代币二维码';

  @override
  String get pointCameraAtInvoiceQr => '将相机对准发票二维码';

  @override
  String get unrecognizedQrCode => '无法识别的二维码';

  @override
  String get scanCashuTokenHint => '扫描 Cashu 代币（cashuA... 或 cashuB...）';

  @override
  String get scanLightningInvoiceHint => '扫描闪电发票（lnbc...）';

  @override
  String get addMintQuestion => '添加此铸造厂？';

  @override
  String get cameraPermissionDenied => '相机权限被拒绝';

  @override
  String get paymentRequestNotSupported => '付款请求尚不支持';

  @override
  String get p2pkTitle => 'P2PK密钥';

  @override
  String get p2pkSettingsDescription => '接收锁定的ecash';

  @override
  String get p2pkExperimental => 'P2PK是实验性功能。请谨慎使用。';

  @override
  String get p2pkPendingSendWarning => '您有一笔待处理的P2PK发送。在收款人领取代币后，请前往历史记录刷新。';

  @override
  String get p2pkExperimentalShort => '实验性';

  @override
  String get p2pkPrimaryKey => '主密钥';

  @override
  String get p2pkDerived => '派生的';

  @override
  String get p2pkImported => '已导入';

  @override
  String get p2pkImportedKeys => '已导入的密钥';

  @override
  String get p2pkNoImportedKeys => '没有已导入的密钥';

  @override
  String get p2pkShowQR => '显示二维码';

  @override
  String get p2pkCopy => '复制';

  @override
  String get p2pkImportNsec => '导入nsec';

  @override
  String get p2pkImport => '导入';

  @override
  String get p2pkEnterLabel => '此密钥的名称';

  @override
  String get p2pkLockToKey => 'P2PK签名发送';

  @override
  String get p2pkLockDescription => '只有接收者可以领取';

  @override
  String get p2pkReceiverPubkey => 'npub1... 或 hex（64/66字符）';

  @override
  String get p2pkInvalidPubkey => '无效的公钥';

  @override
  String get p2pkInvalidPrivateKey => '无效的私钥';

  @override
  String get p2pkLockedToYou => '已锁定给您';

  @override
  String get p2pkLockedToOther => '已锁定给其他密钥';

  @override
  String get p2pkCannotUnlock => '您没有解锁此代币的密钥';

  @override
  String get p2pkEnterPrivateKey => '输入私钥（nsec）';

  @override
  String get p2pkDeleteTitle => '删除密钥';

  @override
  String get p2pkDeleteConfirm => '删除此密钥？您将无法接收锁定给它的代币。';

  @override
  String get p2pkRequiresConnection => 'P2PK需要连接到铸造厂';

  @override
  String get p2pkErrorMaxKeysReached => '已达到导入密钥的最大数量（10）';

  @override
  String get p2pkErrorInvalidNsec => '无效的nsec';

  @override
  String get p2pkErrorKeyAlreadyExists => '此密钥已存在';

  @override
  String get p2pkErrorKeyNotFound => '未找到密钥';

  @override
  String get p2pkErrorCannotDeletePrimary => '无法删除主密钥';

  @override
  String get p2pkSendComingSoon => '即将推出';
}
