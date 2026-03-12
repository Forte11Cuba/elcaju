import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class L10nRu extends L10n {
  L10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'Ваш приватный ecash кошелёк';

  @override
  String get loadingMessage1 => 'Шифрование ваших монет...';

  @override
  String get loadingMessage2 => 'Подготовка ваших e-токенов...';

  @override
  String get loadingMessage3 => 'Подключение к Mint...';

  @override
  String get loadingMessage4 => 'Конфиденциальность по умолчанию.';

  @override
  String get loadingMessage5 => 'Слепая подпись токенов...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = Конфиденциальность + Свобода';

  @override
  String get aboutTagline => 'Конфиденциальность без границ.';

  @override
  String get welcomeTitle => 'Добро пожаловать в ElCaju';

  @override
  String get welcomeSubtitle => 'Cashu для мира. Сделано на Кубе.';

  @override
  String get createWallet => 'Создать новый кошелёк';

  @override
  String get restoreWallet => 'Восстановить кошелёк';

  @override
  String get createWalletTitle => 'Создать кошелёк';

  @override
  String get creatingWallet => 'Создание вашего кошелька...';

  @override
  String get generatingSeed => 'Безопасная генерация вашей сид-фразы';

  @override
  String get createWalletDescription => 'Будет сгенерирована сид-фраза из 12 слов.\nСохраните её в безопасном месте.';

  @override
  String get generateWallet => 'Создать кошелёк';

  @override
  String get walletCreated => 'Кошелёк создан!';

  @override
  String get walletCreatedDescription => 'Ваш кошелёк готов. Рекомендуем сделать резервную копию сид-фразы сейчас.';

  @override
  String get backupWarning => 'Без резервной копии вы потеряете доступ к средствам при потере устройства.';

  @override
  String get backupNow => 'Сделать резервную копию';

  @override
  String get backupLater => 'Сделать позже';

  @override
  String get backupTitle => 'Резервная копия';

  @override
  String get seedPhraseTitle => 'Ваша сид-фраза';

  @override
  String get seedPhraseDescription => 'Сохраните эти 12 слов по порядку. Это единственный способ восстановить кошелёк.';

  @override
  String get revealSeedPhrase => 'Показать сид-фразу';

  @override
  String get tapToReveal => 'Нажмите кнопку, чтобы показать\nвашу сид-фразу';

  @override
  String get copyToClipboard => 'Копировать в буфер обмена';

  @override
  String get seedCopied => 'Фраза скопирована в буфер обмена';

  @override
  String get neverShareSeed => 'Никогда не делитесь сид-фразой ни с кем.';

  @override
  String get confirmBackup => 'Я сохранил сид-фразу в безопасном месте';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get restoreTitle => 'Восстановить кошелёк';

  @override
  String get enterSeedPhrase => 'Введите вашу сид-фразу';

  @override
  String get enterSeedDescription => 'Введите 12 или 24 слова через пробел.';

  @override
  String get seedPlaceholder => 'слово1 слово2 слово3 ...';

  @override
  String wordCount(int count) {
    return '$count слов';
  }

  @override
  String get needWords => '(нужно 12 или 24)';

  @override
  String get restoreScanningMint => 'Сканирование минта на наличие токенов...';

  @override
  String restoreError(String error) {
    return 'Ошибка восстановления: $error';
  }

  @override
  String get homeTitle => 'Главная';

  @override
  String get receive => 'Получить';

  @override
  String get send => 'Отправить';

  @override
  String get sendAction => 'Отправить ↗';

  @override
  String get receiveAction => '↘ Получить';

  @override
  String get deposit => 'Пополнить';

  @override
  String get withdraw => 'Вывести';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => 'История';

  @override
  String get noTransactions => 'Нет транзакций';

  @override
  String get depositOrReceive => 'Пополните или получите sats для начала';

  @override
  String get noMint => 'Нет mint';

  @override
  String get balance => 'Баланс';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'Вставить ecash токен';

  @override
  String get generateInvoiceToDeposit => 'Создать счёт для пополнения';

  @override
  String get createEcashToken => 'Создать ecash токен';

  @override
  String get payLightningInvoice => 'Оплатить Lightning счёт';

  @override
  String get receiveCashu => 'Получить Cashu';

  @override
  String get pasteTheCashuToken => 'Вставьте Cashu токен:';

  @override
  String get pasteFromClipboard => 'Вставить из буфера обмена';

  @override
  String get validToken => 'Токен действителен';

  @override
  String get invalidToken => 'Недействительный или повреждённый токен';

  @override
  String get amount => 'Сумма:';

  @override
  String get mint => 'Mint:';

  @override
  String get claiming => 'Получение...';

  @override
  String get claimTokens => 'Получить токены';

  @override
  String get tokensReceived => 'Токены получены';

  @override
  String get backToHome => 'Вернуться на главную';

  @override
  String get tokenAlreadyClaimed => 'Этот токен уже был получен';

  @override
  String get unknownMint => 'Токен от неизвестного mint';

  @override
  String claimError(String error) {
    return 'Ошибка получения: $error';
  }

  @override
  String get sendCashu => 'Отправить Cashu';

  @override
  String get selectNotesManually => 'Выбрать заметки вручную';

  @override
  String get amountToSend => 'Сумма для отправки:';

  @override
  String get available => 'Доступно:';

  @override
  String get max => '(Макс)';

  @override
  String get memoOptional => 'Заметка (необязательно):';

  @override
  String get memoPlaceholder => 'Для чего этот платёж?';

  @override
  String get creatingToken => 'Создание токена...';

  @override
  String get createToken => 'Создать токен';

  @override
  String get noActiveMint => 'Нет активного mint';

  @override
  String get offlineModeMessage => 'Нет соединения. Офлайн режим...';

  @override
  String get confirmSend => 'Подтвердить отправку';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get cancel => 'Отмена';

  @override
  String get insufficientBalance => 'Недостаточный баланс';

  @override
  String tokenCreationError(String error) {
    return 'Ошибка создания токена: $error';
  }

  @override
  String get tokenCreated => 'Токен создан';

  @override
  String get copy => 'Копировать';

  @override
  String get share => 'Поделиться';

  @override
  String get tokenCashu => 'Cashu токен';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Cashu токен (анимированный QR - $fragments UR фрагментов)';
  }

  @override
  String get keepTokenWarning => 'Сохраните этот токен, пока получатель не заберёт его. Если потеряете — потеряете средства.';

  @override
  String get tokenCopiedToClipboard => 'Токен скопирован в буфер обмена';

  @override
  String get copyAsEmoji => 'Скопировать как эмодзи';

  @override
  String get emojiCopiedToClipboard => 'Токен скопирован как эмодзи 🥜';

  @override
  String get amountToDeposit => 'Сумма для пополнения:';

  @override
  String get descriptionOptional => 'Описание (необязательно):';

  @override
  String get depositPlaceholder => 'Для чего это пополнение?';

  @override
  String get generating => 'Генерация...';

  @override
  String get generateInvoice => 'Создать счёт';

  @override
  String get depositLightning => 'Пополнить Lightning';

  @override
  String get payInvoiceTitle => 'Оплатить счёт';

  @override
  String get generatingInvoice => 'Создание счёта...';

  @override
  String get waitingForPayment => 'Ожидание оплаты...';

  @override
  String get paymentReceived => 'Платёж получен';

  @override
  String get tokensIssued => 'Токены выпущены!';

  @override
  String get error => 'Ошибка';

  @override
  String get unknownError => 'Неизвестная ошибка';

  @override
  String get back => 'Назад';

  @override
  String get copyInvoice => 'Копировать счёт';

  @override
  String get description => 'Описание:';

  @override
  String get invoiceCopiedToClipboard => 'Счёт скопирован в буфер обмена';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit пополнено';
  }

  @override
  String get pasteLightningInvoice => 'Вставьте Lightning счёт:';

  @override
  String get gettingQuote => 'Получение котировки...';

  @override
  String get validInvoice => 'Счёт действителен';

  @override
  String get invalidInvoice => 'Недействительный счёт';

  @override
  String get invalidInvoiceMalformed => 'Недействительный или повреждённый счёт';

  @override
  String get feeReserved => 'Зарезервированная комиссия:';

  @override
  String get total => 'Итого:';

  @override
  String get paying => 'Оплата...';

  @override
  String get payInvoice => 'Оплатить счёт';

  @override
  String get confirmPayment => 'Подтвердить оплату';

  @override
  String get pay => 'Оплатить';

  @override
  String get fee => 'комиссия';

  @override
  String get invoiceExpired => 'Счёт истёк';

  @override
  String get amountOutOfRange => 'Сумма вне допустимого диапазона';

  @override
  String resolvingType(String type) {
    return 'Разрешение $type...';
  }

  @override
  String get invoiceAlreadyPaid => 'Счёт уже оплачен';

  @override
  String paymentError(String error) {
    return 'Ошибка оплаты: $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit отправлено';
  }

  @override
  String get filterAll => 'Все';

  @override
  String get filterPending => 'Ожидающие';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Получите Cashu токены для начала';

  @override
  String get noPendingTransactions => 'Нет ожидающих транзакций';

  @override
  String get allTransactionsCompleted => 'Все ваши транзакции завершены';

  @override
  String get noEcashTransactions => 'Нет Ecash транзакций';

  @override
  String get sendOrReceiveTokens => 'Отправьте или получите Cashu токены';

  @override
  String get noLightningTransactions => 'Нет Lightning транзакций';

  @override
  String get depositOrWithdrawLightning => 'Пополните или выведите через Lightning';

  @override
  String get pendingStatus => 'Ожидание';

  @override
  String get receivedStatus => 'Получено';

  @override
  String get sentStatus => 'Отправлено';

  @override
  String get now => 'Сейчас';

  @override
  String agoMinutes(int minutes) {
    return '$minutes мин назад';
  }

  @override
  String agoHours(int hours) {
    return '$hours ч назад';
  }

  @override
  String agoDays(int days) {
    return '$days дней назад';
  }

  @override
  String get lightningInvoice => 'Lightning счёт';

  @override
  String get receivedEcash => 'Ecash получен';

  @override
  String get sentEcash => 'Ecash отправлен';

  @override
  String get outgoingLightningPayment => 'Исходящий Lightning платёж';

  @override
  String get invoiceNotAvailable => 'Счёт недоступен';

  @override
  String get tokenNotAvailable => 'Токен недоступен';

  @override
  String get unit => 'Единица';

  @override
  String get status => 'Статус';

  @override
  String get pending => 'Ожидание';

  @override
  String get memo => 'Заметка';

  @override
  String get copyInvoiceButton => 'КОПИРОВАТЬ СЧЁТ';

  @override
  String get copyButton => 'КОПИРОВАТЬ';

  @override
  String get invoiceCopied => 'Счёт скопирован';

  @override
  String get tokenCopied => 'Токен скопирован';

  @override
  String get speed => 'СКОРОСТЬ:';

  @override
  String get settings => 'Настройки';

  @override
  String get walletSection => 'КОШЕЛЁК';

  @override
  String get backupSeedPhrase => 'Резервная копия сид-фразы';

  @override
  String get viewRecoveryWords => 'Посмотреть слова восстановления';

  @override
  String get connectedMints => 'Подключённые mint';

  @override
  String get manageCashuMints => 'Управление вашими Cashu mint';

  @override
  String get pinAccess => 'PIN-код';

  @override
  String get pinEnabled => 'Включён';

  @override
  String get protectWithPin => 'Защитить приложение PIN-кодом';

  @override
  String get recoverTokens => 'Восстановить токены';

  @override
  String get scanMintsWithSeed => 'Сканировать mint с сид-фразой';

  @override
  String get appearanceSection => 'ЯЗЫК';

  @override
  String get language => 'Язык';

  @override
  String get informationSection => 'ИНФОРМАЦИЯ';

  @override
  String get version => 'Версия';

  @override
  String get about => 'О приложении';

  @override
  String get deleteWallet => 'Удалить кошелёк';

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
  String get mnemonicNotFound => 'Мнемоника не найдена';

  @override
  String get createPin => 'Создать PIN';

  @override
  String get enterPinDigits => 'Введите 4-значный PIN';

  @override
  String get confirmPin => 'Подтвердить PIN';

  @override
  String get enterPinAgain => 'Введите PIN ещё раз';

  @override
  String get pinMismatch => 'PIN-коды не совпадают';

  @override
  String get pinActivated => 'PIN активирован';

  @override
  String get pinDeactivated => 'PIN деактивирован';

  @override
  String get verifyPin => 'Проверить PIN';

  @override
  String get enterCurrentPin => 'Введите текущий PIN';

  @override
  String get incorrectPin => 'Неверный PIN';

  @override
  String get selectLanguage => 'Выбрать язык';

  @override
  String languageChanged(String language) {
    return 'Язык изменён на $language';
  }

  @override
  String get close => 'Закрыть';

  @override
  String get aboutDescription => 'Cashu кошелёк с кубинской ДНК для всего мира. Брат LaChispa.';

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get deleteWalletQuestion => 'Удалить кошелёк?';

  @override
  String get actionIrreversible => 'Это действие необратимо';

  @override
  String get deleteWalletWarning => 'Все данные будут удалены, включая сид-фразу и токены. Убедитесь, что у вас есть резервная копия.';

  @override
  String get typeDeleteToConfirm => 'Введите \"УДАЛИТЬ\" для подтверждения:';

  @override
  String get deleteConfirmWord => 'УДАЛИТЬ';

  @override
  String deleteError(String error) {
    return 'Ошибка удаления: $error';
  }

  @override
  String get recoverTokensTitle => 'Восстановить токены';

  @override
  String get recoverTokensDescription => 'Сканировать mint для восстановления токенов, связанных с вашей сид-фразой (NUT-13)';

  @override
  String get useCurrentSeedPhrase => 'Использовать текущую сид-фразу';

  @override
  String get scanWithSavedWords => 'Сканировать mint с сохранёнными 12 словами';

  @override
  String get useOtherSeedPhrase => 'Использовать другую сид-фразу';

  @override
  String get recoverFromOtherWords => 'Восстановить токены из других 12 слов';

  @override
  String get mintsToScan => 'Mint для сканирования:';

  @override
  String allMints(int count) {
    return 'Все mint ($count)';
  }

  @override
  String get specificMint => 'Конкретный mint';

  @override
  String get enterMnemonicWords => 'Введите 12 слов через пробел...';

  @override
  String get scanMints => 'Сканировать mint';

  @override
  String get selectMintToScan => 'Выберите mint для сканирования';

  @override
  String get mnemonicMustHaveWords => 'Мнемоника должна содержать 12 или 24 слова';

  @override
  String get noConnectedMintsToScan => 'Нет подключённых mint для сканирования';

  @override
  String recoveredTokens(String tokens, int mints) {
    return 'Восстановлено $tokens из $mints mint!';
  }

  @override
  String get scanCompleteNoTokens => 'Сканирование завершено. Новых токенов не найдено.';

  @override
  String mintsWithError(int count) {
    return '($count mint с ошибкой)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return 'Восстановлено $tokens из $mint!';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return 'Токены не найдены в $mint.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return 'Восстановлено и переведено $amount $unit в ваш кошелёк!';
  }

  @override
  String get noTokensForMnemonic => 'Токены, связанные с этой мнемоникой, не найдены.';

  @override
  String get noConnectedMints => 'Нет подключённых mint';

  @override
  String get addMintToStart => 'Добавьте mint для начала';

  @override
  String get addMint => 'Добавить mint';

  @override
  String get mintDeleted => 'Mint удалён';

  @override
  String get activeMintUpdated => 'Активный mint обновлён';

  @override
  String get mintUrl => 'URL mint:';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'URL должен начинаться с https://';

  @override
  String get connectingToMint => 'Подключение к mint...';

  @override
  String get mintAddedSuccessfully => 'Mint успешно добавлен';

  @override
  String get couldNotConnectToMint => 'Не удалось подключиться к mint';

  @override
  String get add => 'Добавить';

  @override
  String get success => 'Успех';

  @override
  String get loading => 'Загрузка...';

  @override
  String get retry => 'Повторить';

  @override
  String get activeMint => 'Активный mint';

  @override
  String get mintMessage => 'Сообщение Mint';

  @override
  String get url => 'URL';

  @override
  String get currency => 'Валюта';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get useThisMint => 'Использовать этот mint';

  @override
  String get copyMintUrl => 'Копировать URL mint';

  @override
  String get deleteMint => 'Удалить mint';

  @override
  String copied(String label) {
    return '$label скопировано';
  }

  @override
  String get deleteMintConfirmTitle => 'Удалить mint';

  @override
  String get deleteMintConfirmMessage => 'Если у вас есть баланс на этом mint, он будет потерян. Вы уверены?';

  @override
  String get delete => 'Удалить';

  @override
  String get offlineSend => 'Офлайн отправка';

  @override
  String get selectAll => 'Все';

  @override
  String get deselectAll => 'Ничего';

  @override
  String get selectNotesToSend => 'Выберите заметки для отправки:';

  @override
  String get totalToSend => 'Итого к отправке';

  @override
  String notesSelected(int count) {
    return '$count заметок выбрано';
  }

  @override
  String loadingProofsError(String error) {
    return 'Ошибка загрузки доказательств: $error';
  }

  @override
  String creatingTokenError(String error) {
    return 'Ошибка создания токена: $error';
  }

  @override
  String get unknownState => 'Неизвестное состояние';

  @override
  String depositAmountTitle(String amount, String unit) {
    return 'Пополнить $amount $unit';
  }

  @override
  String get receiveNow => 'Получить сейчас';

  @override
  String get receiveLater => 'Получить позже';

  @override
  String get tokenSavedForLater => 'Токен сохранён для получения позже';

  @override
  String get noConnectionTokenSaved => 'Нет соединения. Токен сохранён для получения позже.';

  @override
  String get unknownMintOffline => 'Этот токен от неизвестного mint. Подключитесь к интернету, чтобы добавить его и получить токен.';

  @override
  String get noConnectionTryLater => 'Нет соединения с mint. Попробуйте позже.';

  @override
  String get saveTokenError => 'Ошибка сохранения токена. Попробуйте снова.';

  @override
  String get pendingTokenLimitReached => 'Достигнут лимит ожидающих токенов (макс 50)';

  @override
  String get filterToReceive => 'К получению';

  @override
  String get noPendingTokens => 'Нет ожидающих токенов';

  @override
  String get noPendingTokensHint => 'Сохраните токены для получения позже';

  @override
  String get pendingBadge => 'ОЖИДАНИЕ';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Истекает через $days дней',
      one: 'Истекает через 1 день',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count попыток';
  }

  @override
  String get claimNow => 'Получить сейчас';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return 'Получено $amount $unit';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Получено $count токенов ($amount $unit)',
      one: 'Получен 1 токен ($amount $unit)',
    );
    return '$_temp0';
  }

  @override
  String get scan => 'Сканировать';

  @override
  String get scanQrCode => 'Сканировать QR';

  @override
  String get scanCashuToken => 'Сканировать Cashu токен';

  @override
  String get scanLightningInvoice => 'Сканировать счёт';

  @override
  String get scanningAnimatedQr => 'Сканирование анимированного QR...';

  @override
  String get pointCameraAtQr => 'Наведите камеру на QR-код';

  @override
  String get pointCameraAtCashuQr => 'Наведите камеру на QR Cashu токена';

  @override
  String get pointCameraAtInvoiceQr => 'Наведите камеру на QR счёта';

  @override
  String get unrecognizedQrCode => 'Нераспознанный QR-код';

  @override
  String get scanCashuTokenHint => 'Сканируйте Cashu токен (cashuA... или cashuB...)';

  @override
  String get scanLightningInvoiceHint => 'Сканируйте Lightning счёт (lnbc...)';

  @override
  String get addMintQuestion => 'Добавить этот mint?';

  @override
  String get cameraPermissionDenied => 'Доступ к камере запрещён';

  @override
  String get paymentRequestNotSupported => 'Запросы на оплату пока не поддерживаются';

  @override
  String get p2pkTitle => 'Ключи P2PK';

  @override
  String get p2pkSettingsDescription => 'Получить заблокированный ecash';

  @override
  String get p2pkExperimental => 'P2PK экспериментальный. Используйте с осторожностью.';

  @override
  String get p2pkPendingSendWarning => 'У вас есть ожидающая отправка P2PK. Перейдите в историю и обновите после того, как получатель заберёт токен.';

  @override
  String get p2pkExperimentalShort => 'Экспериментальный';

  @override
  String get p2pkPrimaryKey => 'Основной ключ';

  @override
  String get p2pkDerived => 'Производный';

  @override
  String get p2pkImported => 'Импортированный';

  @override
  String get p2pkImportedKeys => 'Импортированные ключи';

  @override
  String get p2pkNoImportedKeys => 'Нет импортированных ключей';

  @override
  String get p2pkShowQR => 'Показать QR';

  @override
  String get p2pkCopy => 'Копировать';

  @override
  String get p2pkImportNsec => 'Импортировать nsec';

  @override
  String get p2pkImport => 'Импортировать';

  @override
  String get p2pkEnterLabel => 'Имя для этого ключа';

  @override
  String get p2pkLockToKey => 'Отправка с подписью P2PK';

  @override
  String get p2pkLockDescription => 'Только получатель может получить';

  @override
  String get p2pkReceiverPubkey => 'npub1... или hex (64/66 символов)';

  @override
  String get p2pkInvalidPubkey => 'Недействительный публичный ключ';

  @override
  String get p2pkInvalidPrivateKey => 'Недействительный приватный ключ';

  @override
  String get p2pkLockedToYou => 'Заблокировано для вас';

  @override
  String get p2pkLockedToOther => 'Заблокировано для другого ключа';

  @override
  String get p2pkCannotUnlock => 'У вас нет ключа для разблокировки этого токена';

  @override
  String get p2pkEnterPrivateKey => 'Введите приватный ключ (nsec)';

  @override
  String get p2pkDeleteTitle => 'Удалить ключ';

  @override
  String get p2pkDeleteConfirm => 'Удалить этот ключ? Вы не сможете получать токены заблокированные на него.';

  @override
  String get p2pkRequiresConnection => 'P2PK требует подключения к mint';

  @override
  String get p2pkErrorMaxKeysReached => 'Достигнуто максимальное количество импортированных ключей (10)';

  @override
  String get p2pkErrorInvalidNsec => 'Недействительный nsec';

  @override
  String get p2pkErrorKeyAlreadyExists => 'Этот ключ уже существует';

  @override
  String get p2pkErrorKeyNotFound => 'Ключ не найден';

  @override
  String get p2pkErrorCannotDeletePrimary => 'Невозможно удалить основной ключ';
}
