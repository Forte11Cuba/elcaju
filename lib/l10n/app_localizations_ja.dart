import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'プライベートなecashウォレット';

  @override
  String get loadingMessage1 => 'コインを暗号化中...';

  @override
  String get loadingMessage2 => 'e-トークンを準備中...';

  @override
  String get loadingMessage3 => 'Mintに接続中...';

  @override
  String get loadingMessage4 => 'デフォルトでプライバシー保護。';

  @override
  String get loadingMessage5 => 'ブラインド署名中...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = プライバシー + 自由';

  @override
  String get aboutTagline => '国境のないプライバシー。';

  @override
  String get welcomeTitle => 'ElCajuへようこそ';

  @override
  String get welcomeSubtitle => '世界のためのCashu。キューバ製。';

  @override
  String get createWallet => '新しいウォレットを作成';

  @override
  String get restoreWallet => 'ウォレットを復元';

  @override
  String get createWalletTitle => 'ウォレット作成';

  @override
  String get creatingWallet => 'ウォレットを作成中...';

  @override
  String get generatingSeed => 'シードフレーズを安全に生成中';

  @override
  String get createWalletDescription => '12語のシードフレーズが生成されます。\n安全な場所に保管してください。';

  @override
  String get generateWallet => 'ウォレットを生成';

  @override
  String get walletCreated => 'ウォレット作成完了！';

  @override
  String get walletCreatedDescription => 'ウォレットの準備ができました。今すぐシードフレーズをバックアップすることをお勧めします。';

  @override
  String get backupWarning => 'バックアップがないと、デバイスを紛失した場合に資金にアクセスできなくなります。';

  @override
  String get backupNow => '今すぐバックアップ';

  @override
  String get backupLater => '後でする';

  @override
  String get backupTitle => 'バックアップ';

  @override
  String get seedPhraseTitle => 'シードフレーズ';

  @override
  String get seedPhraseDescription => 'この12語を順番に保存してください。ウォレットを復元する唯一の方法です。';

  @override
  String get revealSeedPhrase => 'シードフレーズを表示';

  @override
  String get tapToReveal => 'ボタンをタップして\nシードフレーズを表示';

  @override
  String get copyToClipboard => 'クリップボードにコピー';

  @override
  String get seedCopied => 'フレーズをクリップボードにコピーしました';

  @override
  String get neverShareSeed => 'シードフレーズを誰にも共有しないでください。';

  @override
  String get confirmBackup => 'シードフレーズを安全な場所に保存しました';

  @override
  String get continue_ => '続ける';

  @override
  String get restoreTitle => 'ウォレットを復元';

  @override
  String get enterSeedPhrase => 'シードフレーズを入力';

  @override
  String get enterSeedDescription => '12語または24語をスペースで区切って入力してください。';

  @override
  String get seedPlaceholder => '単語1 単語2 単語3 ...';

  @override
  String wordCount(int count) {
    return '$count語';
  }

  @override
  String get needWords => '（12語または24語が必要）';

  @override
  String get restoreScanningMint => 'ミントで既存のトークンをスキャン中...';

  @override
  String restoreError(String error) {
    return '復元エラー：$error';
  }

  @override
  String get homeTitle => 'ホーム';

  @override
  String get receive => '受取';

  @override
  String get send => '送金';

  @override
  String get sendAction => '送金 ↗';

  @override
  String get receiveAction => '↘ 受取';

  @override
  String get deposit => '入金';

  @override
  String get withdraw => '出金';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => '履歴';

  @override
  String get noTransactions => '取引履歴がありません';

  @override
  String get depositOrReceive => 'satsを入金または受け取って開始';

  @override
  String get noMint => 'Mintなし';

  @override
  String get balance => '残高';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'ecashトークンを貼り付け';

  @override
  String get generateInvoiceToDeposit => '入金用インボイスを生成';

  @override
  String get createEcashToken => 'ecashトークンを作成';

  @override
  String get payLightningInvoice => 'Lightningインボイスを支払う';

  @override
  String get receiveCashu => 'Cashuを受け取る';

  @override
  String get pasteTheCashuToken => 'Cashuトークンを貼り付け：';

  @override
  String get pasteFromClipboard => 'クリップボードから貼り付け';

  @override
  String get validToken => '有効なトークン';

  @override
  String get invalidToken => '無効または不正なトークン';

  @override
  String get amount => '金額：';

  @override
  String get mint => 'Mint：';

  @override
  String get claiming => '請求中...';

  @override
  String get claimTokens => 'トークンを請求';

  @override
  String get tokensReceived => 'トークンを受け取りました';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String get tokenAlreadyClaimed => 'このトークンは既に請求済みです';

  @override
  String get unknownMint => '不明なMintからのトークン';

  @override
  String claimError(String error) {
    return '請求エラー：$error';
  }

  @override
  String get sendCashu => 'Cashuを送る';

  @override
  String get selectNotesManually => 'ノートを手動で選択';

  @override
  String get amountToSend => '送金額：';

  @override
  String get available => '利用可能：';

  @override
  String get max => '（最大）';

  @override
  String get memoOptional => 'メモ（任意）：';

  @override
  String get memoPlaceholder => 'この支払いは何のためですか？';

  @override
  String get creatingToken => 'トークン作成中...';

  @override
  String get createToken => 'トークンを作成';

  @override
  String get noActiveMint => 'アクティブなMintがありません';

  @override
  String get offlineModeMessage => '接続なし。オフラインモード使用中...';

  @override
  String get confirmSend => '送金を確認';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get insufficientBalance => '残高不足';

  @override
  String tokenCreationError(String error) {
    return 'トークン作成エラー：$error';
  }

  @override
  String get tokenCreated => 'トークン作成完了';

  @override
  String get copy => 'コピー';

  @override
  String get share => '共有';

  @override
  String get tokenCashu => 'Cashuトークン';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Cashuトークン（アニメーションQR - $fragments個のURフラグメント）';
  }

  @override
  String get keepTokenWarning => '受取人が請求するまでこのトークンを保管してください。紛失すると資金を失います。';

  @override
  String get tokenCopiedToClipboard => 'トークンをクリップボードにコピーしました';

  @override
  String get amountToDeposit => '入金額：';

  @override
  String get descriptionOptional => '説明（任意）：';

  @override
  String get depositPlaceholder => 'この入金は何のためですか？';

  @override
  String get generating => '生成中...';

  @override
  String get generateInvoice => 'インボイスを生成';

  @override
  String get depositLightning => 'Lightning入金';

  @override
  String get payInvoiceTitle => 'インボイスを支払う';

  @override
  String get generatingInvoice => 'インボイス生成中...';

  @override
  String get waitingForPayment => '支払い待ち...';

  @override
  String get paymentReceived => '支払いを受け取りました';

  @override
  String get tokensIssued => 'トークンが発行されました！';

  @override
  String get error => 'エラー';

  @override
  String get unknownError => '不明なエラー';

  @override
  String get back => '戻る';

  @override
  String get copyInvoice => 'インボイスをコピー';

  @override
  String get description => '説明：';

  @override
  String get invoiceCopiedToClipboard => 'インボイスをクリップボードにコピーしました';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unitを入金しました';
  }

  @override
  String get pasteLightningInvoice => 'Lightningインボイスを貼り付け：';

  @override
  String get gettingQuote => '見積もり取得中...';

  @override
  String get validInvoice => '有効なインボイス';

  @override
  String get invalidInvoice => '無効なインボイス';

  @override
  String get invalidInvoiceMalformed => '無効または不正なインボイス';

  @override
  String get feeReserved => '予約手数料：';

  @override
  String get total => '合計：';

  @override
  String get paying => '支払い中...';

  @override
  String get payInvoice => 'インボイスを支払う';

  @override
  String get confirmPayment => '支払いを確認';

  @override
  String get pay => '支払う';

  @override
  String get fee => '手数料';

  @override
  String get invoiceExpired => 'インボイス期限切れ';

  @override
  String get amountOutOfRange => '金額が許容範囲外です';

  @override
  String resolvingType(String type) {
    return '$typeを解決中...';
  }

  @override
  String get invoiceAlreadyPaid => 'インボイスは支払い済みです';

  @override
  String paymentError(String error) {
    return '支払いエラー：$error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unitを送金しました';
  }

  @override
  String get filterAll => 'すべて';

  @override
  String get filterPending => '保留中';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Cashuトークンを受け取って開始';

  @override
  String get noPendingTransactions => '保留中の取引はありません';

  @override
  String get allTransactionsCompleted => 'すべての取引が完了しました';

  @override
  String get noEcashTransactions => 'Ecash取引はありません';

  @override
  String get sendOrReceiveTokens => 'Cashuトークンを送受信';

  @override
  String get noLightningTransactions => 'Lightning取引はありません';

  @override
  String get depositOrWithdrawLightning => 'Lightningで入出金';

  @override
  String get pendingStatus => '保留中';

  @override
  String get receivedStatus => '受取済み';

  @override
  String get sentStatus => '送金済み';

  @override
  String get now => 'たった今';

  @override
  String agoMinutes(int minutes) {
    return '$minutes分前';
  }

  @override
  String agoHours(int hours) {
    return '$hours時間前';
  }

  @override
  String agoDays(int days) {
    return '$days日前';
  }

  @override
  String get lightningInvoice => 'Lightningインボイス';

  @override
  String get receivedEcash => 'Ecash受取';

  @override
  String get sentEcash => 'Ecash送金';

  @override
  String get outgoingLightningPayment => 'Lightning出金';

  @override
  String get invoiceNotAvailable => 'インボイスは利用できません';

  @override
  String get tokenNotAvailable => 'トークンは利用できません';

  @override
  String get unit => '単位';

  @override
  String get status => 'ステータス';

  @override
  String get pending => '保留中';

  @override
  String get memo => 'メモ';

  @override
  String get copyInvoiceButton => 'インボイスをコピー';

  @override
  String get copyButton => 'コピー';

  @override
  String get invoiceCopied => 'インボイスをコピーしました';

  @override
  String get tokenCopied => 'トークンをコピーしました';

  @override
  String get speed => '速度：';

  @override
  String get settings => '設定';

  @override
  String get walletSection => 'ウォレット';

  @override
  String get backupSeedPhrase => 'シードフレーズのバックアップ';

  @override
  String get viewRecoveryWords => '復元用単語を表示';

  @override
  String get connectedMints => '接続中のMint';

  @override
  String get manageCashuMints => 'Cashu Mintを管理';

  @override
  String get pinAccess => 'PINアクセス';

  @override
  String get pinEnabled => '有効';

  @override
  String get protectWithPin => 'PINでアプリを保護';

  @override
  String get recoverTokens => 'トークンを復元';

  @override
  String get scanMintsWithSeed => 'シードフレーズでMintをスキャン';

  @override
  String get appearanceSection => '言語';

  @override
  String get language => '言語';

  @override
  String get informationSection => '情報';

  @override
  String get version => 'バージョン';

  @override
  String get about => 'このアプリについて';

  @override
  String get deleteWallet => 'ウォレットを削除';

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
  String get mnemonicNotFound => 'ニーモニックが見つかりません';

  @override
  String get createPin => 'PINを作成';

  @override
  String get enterPinDigits => '4桁のPINを入力';

  @override
  String get confirmPin => 'PINを確認';

  @override
  String get enterPinAgain => 'PINを再入力';

  @override
  String get pinMismatch => 'PINが一致しません';

  @override
  String get pinActivated => 'PINが有効になりました';

  @override
  String get pinDeactivated => 'PINが無効になりました';

  @override
  String get verifyPin => 'PINを確認';

  @override
  String get enterCurrentPin => '現在のPINを入力';

  @override
  String get incorrectPin => 'PINが正しくありません';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String languageChanged(String language) {
    return '言語を$languageに変更しました';
  }

  @override
  String get close => '閉じる';

  @override
  String get aboutDescription => 'キューバのDNAを持つ世界のためのCashuウォレット。La Chispaの兄弟。';

  @override
  String get couldNotOpenLink => 'リンクを開けませんでした';

  @override
  String get deleteWalletQuestion => 'ウォレットを削除しますか？';

  @override
  String get actionIrreversible => 'この操作は取り消せません';

  @override
  String get deleteWalletWarning => 'シードフレーズとトークンを含むすべてのデータが削除されます。バックアップがあることを確認してください。';

  @override
  String get typeDeleteToConfirm => '確認のため「DELETE」と入力：';

  @override
  String get deleteConfirmWord => 'DELETE';

  @override
  String deleteError(String error) {
    return '削除エラー：$error';
  }

  @override
  String get recoverTokensTitle => 'トークンを復元';

  @override
  String get recoverTokensDescription => 'シードフレーズに関連付けられたトークンを復元するためにMintをスキャン（NUT-13）';

  @override
  String get useCurrentSeedPhrase => '現在のシードフレーズを使用';

  @override
  String get scanWithSavedWords => '保存された12語でMintをスキャン';

  @override
  String get useOtherSeedPhrase => '別のシードフレーズを使用';

  @override
  String get recoverFromOtherWords => '別の12語からトークンを復元';

  @override
  String get mintsToScan => 'スキャンするMint：';

  @override
  String allMints(int count) {
    return 'すべてのMint（$count件）';
  }

  @override
  String get specificMint => '特定のMint';

  @override
  String get enterMnemonicWords => '12語をスペースで区切って入力...';

  @override
  String get scanMints => 'Mintをスキャン';

  @override
  String get selectMintToScan => 'スキャンするMintを選択';

  @override
  String get mnemonicMustHaveWords => 'ニーモニックは12語または24語である必要があります';

  @override
  String get noConnectedMintsToScan => 'スキャンできる接続済みMintがありません';

  @override
  String recoveredTokens(String tokens, int mints) {
    return '$mints件のMintから$tokensを復元しました！';
  }

  @override
  String get scanCompleteNoTokens => 'スキャン完了。新しいトークンは見つかりませんでした。';

  @override
  String mintsWithError(int count) {
    return '（$count件のMintでエラー）';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return '$mintから$tokensを復元しました！';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return '$mintでトークンが見つかりませんでした。';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return '$amount $unitを復元してウォレットに転送しました！';
  }

  @override
  String get noTokensForMnemonic => 'そのニーモニックに関連付けられたトークンは見つかりませんでした。';

  @override
  String get noConnectedMints => '接続済みMintがありません';

  @override
  String get addMintToStart => 'Mintを追加して開始';

  @override
  String get addMint => 'Mintを追加';

  @override
  String get mintDeleted => 'Mintを削除しました';

  @override
  String get activeMintUpdated => 'アクティブMintを更新しました';

  @override
  String get mintUrl => 'Mint URL：';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'URLはhttps://で始まる必要があります';

  @override
  String get connectingToMint => 'Mintに接続中...';

  @override
  String get mintAddedSuccessfully => 'Mintを追加しました';

  @override
  String get couldNotConnectToMint => 'Mintに接続できませんでした';

  @override
  String get add => '追加';

  @override
  String get success => '成功';

  @override
  String get loading => '読み込み中...';

  @override
  String get retry => '再試行';

  @override
  String get activeMint => 'アクティブMint';

  @override
  String get mintMessage => 'Mintメッセージ';

  @override
  String get url => 'URL';

  @override
  String get currency => '通貨';

  @override
  String get unknown => '不明';

  @override
  String get useThisMint => 'このMintを使用';

  @override
  String get copyMintUrl => 'Mint URLをコピー';

  @override
  String get deleteMint => 'Mintを削除';

  @override
  String copied(String label) {
    return '$labelをコピーしました';
  }

  @override
  String get deleteMintConfirmTitle => 'Mintを削除';

  @override
  String get deleteMintConfirmMessage => 'このMintに残高がある場合、失われます。よろしいですか？';

  @override
  String get delete => '削除';

  @override
  String get offlineSend => 'オフライン送金';

  @override
  String get selectNotesToSend => '送信するノートを選択：';

  @override
  String get totalToSend => '送金合計';

  @override
  String notesSelected(int count) {
    return '$count件のノートを選択';
  }

  @override
  String loadingProofsError(String error) {
    return 'プルーフ読み込みエラー：$error';
  }

  @override
  String creatingTokenError(String error) {
    return 'トークン作成エラー：$error';
  }

  @override
  String get unknownState => '不明な状態';

  @override
  String depositAmountTitle(String amount, String unit) {
    return '$amount $unitを入金';
  }

  @override
  String get receiveNow => '今すぐ受け取る';

  @override
  String get receiveLater => '後で受け取る';

  @override
  String get tokenSavedForLater => 'トークンを保存しました。後で請求できます';

  @override
  String get noConnectionTokenSaved => '接続なし。トークンを保存しました。後で請求できます。';

  @override
  String get unknownMintOffline => 'このトークンは不明なMintからのものです。インターネットに接続してMintを追加し、トークンを請求してください。';

  @override
  String get noConnectionTryLater => 'Mintに接続できません。後でもう一度お試しください。';

  @override
  String get saveTokenError => 'トークンの保存エラー。もう一度お試しください。';

  @override
  String get pendingTokenLimitReached => '保留中トークンの上限に達しました（最大50件）';

  @override
  String get filterToReceive => '受取予定';

  @override
  String get noPendingTokens => '保留中のトークンはありません';

  @override
  String get noPendingTokensHint => 'トークンを保存して後で請求';

  @override
  String get pendingBadge => '保留中';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days日後に期限切れ',
      one: '1日後に期限切れ',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count回リトライ';
  }

  @override
  String get claimNow => '今すぐ請求';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return '$amount $unitを請求しました';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のトークン（$amount $unit）を請求しました',
      one: '1件のトークン（$amount $unit）を請求しました',
    );
    return '$_temp0';
  }

  @override
  String get scan => 'スキャン';

  @override
  String get scanQrCode => 'QRコードをスキャン';

  @override
  String get scanCashuToken => 'Cashuトークンをスキャン';

  @override
  String get scanLightningInvoice => 'インボイスをスキャン';

  @override
  String get scanningAnimatedQr => 'アニメーションQRをスキャン中...';

  @override
  String get pointCameraAtQr => 'カメラをQRコードに向けてください';

  @override
  String get pointCameraAtCashuQr => 'カメラをCashuトークンのQRに向けてください';

  @override
  String get pointCameraAtInvoiceQr => 'カメラをインボイスのQRに向けてください';

  @override
  String get unrecognizedQrCode => '認識できないQRコード';

  @override
  String get scanCashuTokenHint => 'Cashuトークンをスキャン（cashuA...またはcashuB...）';

  @override
  String get scanLightningInvoiceHint => 'Lightningインボイスをスキャン（lnbc...）';

  @override
  String get addMintQuestion => 'このMintを追加しますか？';

  @override
  String get cameraPermissionDenied => 'カメラの許可が拒否されました';

  @override
  String get paymentRequestNotSupported => '支払いリクエストはまだサポートされていません';

  @override
  String get p2pkTitle => 'P2PK鍵';

  @override
  String get p2pkSettingsDescription => 'ロックされたecashを受け取る';

  @override
  String get p2pkExperimental => 'P2PKは実験的機能です。注意してご使用ください。';

  @override
  String get p2pkPendingSendWarning => '保留中のP2PK送信があります。受取人がトークンを受け取った後、履歴で更新してください。';

  @override
  String get p2pkExperimentalShort => '実験的';

  @override
  String get p2pkPrimaryKey => 'プライマリ鍵';

  @override
  String get p2pkDerived => '派生';

  @override
  String get p2pkImported => 'インポート済み';

  @override
  String get p2pkImportedKeys => 'インポートした鍵';

  @override
  String get p2pkNoImportedKeys => 'インポートした鍵はありません';

  @override
  String get p2pkShowQR => 'QRを表示';

  @override
  String get p2pkCopy => 'コピー';

  @override
  String get p2pkImportNsec => 'nsecをインポート';

  @override
  String get p2pkImport => 'インポート';

  @override
  String get p2pkEnterLabel => 'この鍵の名前';

  @override
  String get p2pkLockToKey => 'P2PK署名で送信';

  @override
  String get p2pkLockDescription => '受取人のみが請求可能';

  @override
  String get p2pkReceiverPubkey => 'npub1... または hex（64/66文字）';

  @override
  String get p2pkInvalidPubkey => '無効な公開鍵';

  @override
  String get p2pkInvalidPrivateKey => '無効な秘密鍵';

  @override
  String get p2pkLockedToYou => 'あなた宛にロック';

  @override
  String get p2pkLockedToOther => '別の鍵にロック';

  @override
  String get p2pkCannotUnlock => 'このトークンをアンロックする鍵がありません';

  @override
  String get p2pkEnterPrivateKey => '秘密鍵を入力（nsec）';

  @override
  String get p2pkDeleteTitle => '鍵を削除';

  @override
  String get p2pkDeleteConfirm => 'この鍵を削除しますか？この鍵にロックされたトークンを受け取れなくなります。';

  @override
  String get p2pkRequiresConnection => 'P2PKにはMintへの接続が必要です';

  @override
  String get p2pkErrorMaxKeysReached => 'インポート可能な鍵の上限に達しました（10）';

  @override
  String get p2pkErrorInvalidNsec => '無効なnsec';

  @override
  String get p2pkErrorKeyAlreadyExists => 'この鍵は既に存在します';

  @override
  String get p2pkErrorKeyNotFound => '鍵が見つかりません';

  @override
  String get p2pkErrorCannotDeletePrimary => 'プライマリ鍵は削除できません';

  @override
  String get p2pkSendComingSoon => '近日公開';
}
