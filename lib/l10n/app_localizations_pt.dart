import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'Sua wallet de ecash privada';

  @override
  String get loadingMessage1 => 'Criptografando suas moedas...';

  @override
  String get loadingMessage2 => 'Preparando seus e-tokens...';

  @override
  String get loadingMessage3 => 'Conectando ao Mint...';

  @override
  String get loadingMessage4 => 'Privacidade por padrão.';

  @override
  String get loadingMessage5 => 'Assinando tokens cegamente...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = Privacidade + Liberdade';

  @override
  String get aboutTagline => 'Privacidade sem fronteiras.';

  @override
  String get welcomeTitle => 'Bem-vindo ao ElCaju';

  @override
  String get welcomeSubtitle => 'Cashu para o mundo. Feito em Cuba.';

  @override
  String get createWallet => 'Criar nova wallet';

  @override
  String get restoreWallet => 'Restaurar wallet';

  @override
  String get createWalletTitle => 'Criar wallet';

  @override
  String get creatingWallet => 'Criando sua wallet...';

  @override
  String get generatingSeed => 'Gerando sua frase semente de forma segura';

  @override
  String get createWalletDescription => 'Uma frase semente de 12 palavras será gerada.\nGuarde-a em um lugar seguro.';

  @override
  String get generateWallet => 'Gerar wallet';

  @override
  String get walletCreated => 'Wallet criada!';

  @override
  String get walletCreatedDescription => 'Sua wallet está pronta. Recomendamos fazer backup da sua frase semente agora.';

  @override
  String get backupWarning => 'Sem backup, você perderá acesso aos seus fundos se perder o dispositivo.';

  @override
  String get backupNow => 'Fazer backup agora';

  @override
  String get backupLater => 'Fazer depois';

  @override
  String get backupTitle => 'Backup';

  @override
  String get seedPhraseTitle => 'Sua frase semente';

  @override
  String get seedPhraseDescription => 'Guarde estas 12 palavras em ordem. Elas são a única forma de recuperar sua wallet.';

  @override
  String get revealSeedPhrase => 'Revelar frase semente';

  @override
  String get tapToReveal => 'Toque no botão para revelar\nsua frase semente';

  @override
  String get copyToClipboard => 'Copiar para área de transferência';

  @override
  String get seedCopied => 'Frase copiada para área de transferência';

  @override
  String get neverShareSeed => 'Nunca compartilhe sua frase semente com ninguém.';

  @override
  String get confirmBackup => 'Guardei minha frase semente em um lugar seguro';

  @override
  String get continue_ => 'Continuar';

  @override
  String get restoreTitle => 'Restaurar wallet';

  @override
  String get enterSeedPhrase => 'Digite sua frase semente';

  @override
  String get enterSeedDescription => 'Digite as 12 ou 24 palavras separadas por espaços.';

  @override
  String get seedPlaceholder => 'palavra1 palavra2 palavra3 ...';

  @override
  String wordCount(int count) {
    return '$count palavras';
  }

  @override
  String get needWords => '(você precisa de 12 ou 24)';

  @override
  String get restoreScanningMint => 'Escaneando mint em busca de tokens...';

  @override
  String restoreError(String error) {
    return 'Erro ao restaurar: $error';
  }

  @override
  String get homeTitle => 'Início';

  @override
  String get receive => 'Receber';

  @override
  String get send => 'Enviar';

  @override
  String get sendAction => 'Enviar ↗';

  @override
  String get receiveAction => '↘ Receber';

  @override
  String get deposit => 'Depositar';

  @override
  String get withdraw => 'Sacar';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => 'Histórico';

  @override
  String get noTransactions => 'Sem transações ainda';

  @override
  String get depositOrReceive => 'Deposite ou receba sats para começar';

  @override
  String get noMint => 'Sem mint';

  @override
  String get balance => 'Saldo';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'Colar token ecash';

  @override
  String get generateInvoiceToDeposit => 'Gerar invoice para depositar';

  @override
  String get createEcashToken => 'Criar token ecash';

  @override
  String get payLightningInvoice => 'Pagar invoice Lightning';

  @override
  String get receiveCashu => 'Receber Cashu';

  @override
  String get pasteTheCashuToken => 'Cole o token Cashu:';

  @override
  String get pasteFromClipboard => 'Colar da área de transferência';

  @override
  String get validToken => 'Token válido';

  @override
  String get invalidToken => 'Token inválido ou malformado';

  @override
  String get amount => 'Valor:';

  @override
  String get mint => 'Mint:';

  @override
  String get claiming => 'Resgatando...';

  @override
  String get claimTokens => 'Resgatar tokens';

  @override
  String get tokensReceived => 'Tokens recebidos';

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get tokenAlreadyClaimed => 'Este token já foi resgatado';

  @override
  String get unknownMint => 'Token de um mint desconhecido';

  @override
  String claimError(String error) {
    return 'Erro ao resgatar: $error';
  }

  @override
  String get sendCashu => 'Enviar Cashu';

  @override
  String get selectNotesManually => 'Selecionar notas manualmente';

  @override
  String get amountToSend => 'Valor a enviar:';

  @override
  String get available => 'Disponível:';

  @override
  String get max => '(Máx)';

  @override
  String get memoOptional => 'Memo (opcional):';

  @override
  String get memoPlaceholder => 'Para que é este pagamento?';

  @override
  String get creatingToken => 'Criando token...';

  @override
  String get createToken => 'Criar token';

  @override
  String get noActiveMint => 'Nenhum mint ativo';

  @override
  String get offlineModeMessage => 'Sem conexão. Usando modo offline...';

  @override
  String get confirmSend => 'Confirmar envio';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get insufficientBalance => 'Saldo insuficiente';

  @override
  String tokenCreationError(String error) {
    return 'Erro ao criar token: $error';
  }

  @override
  String get tokenCreated => 'Token criado';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartilhar';

  @override
  String get tokenCashu => 'Token Cashu';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Token Cashu (QR animado - $fragments fragmentos UR)';
  }

  @override
  String get keepTokenWarning => 'Guarde este token até que o destinatário o resgate. Se você perdê-lo, perderá os fundos.';

  @override
  String get tokenCopiedToClipboard => 'Token copiado para área de transferência';

  @override
  String get copyAsEmoji => 'Copiar como emoji';

  @override
  String get emojiCopiedToClipboard => 'Token copiado como emoji 🥜';

  @override
  String get peanutDecodeError => 'Não foi possível decodificar o token emoji. Pode estar corrompido.';

  @override
  String get amountToDeposit => 'Valor a depositar:';

  @override
  String get descriptionOptional => 'Descrição (opcional):';

  @override
  String get depositPlaceholder => 'Para que é este depósito?';

  @override
  String get generating => 'Gerando...';

  @override
  String get generateInvoice => 'Gerar invoice';

  @override
  String get depositLightning => 'Depositar Lightning';

  @override
  String get payInvoiceTitle => 'Pagar invoice';

  @override
  String get generatingInvoice => 'Gerando invoice...';

  @override
  String get waitingForPayment => 'Aguardando pagamento...';

  @override
  String get paymentReceived => 'Pagamento recebido';

  @override
  String get tokensIssued => 'Tokens emitidos!';

  @override
  String get error => 'Erro';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String get back => 'Voltar';

  @override
  String get copyInvoice => 'Copiar invoice';

  @override
  String get description => 'Descrição:';

  @override
  String get invoiceCopiedToClipboard => 'Invoice copiado para área de transferência';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit depositados';
  }

  @override
  String get pasteLightningInvoice => 'Cole o invoice Lightning:';

  @override
  String get gettingQuote => 'Obtendo cotação...';

  @override
  String get validInvoice => 'Invoice válido';

  @override
  String get invalidInvoice => 'Invoice inválido';

  @override
  String get invalidInvoiceMalformed => 'Invoice inválido ou malformado';

  @override
  String get feeReserved => 'Taxa reservada:';

  @override
  String get total => 'Total:';

  @override
  String get paying => 'Pagando...';

  @override
  String get payInvoice => 'Pagar invoice';

  @override
  String get confirmPayment => 'Confirmar pagamento';

  @override
  String get pay => 'Pagar';

  @override
  String get fee => 'taxa';

  @override
  String get invoiceExpired => 'Invoice expirado';

  @override
  String get amountOutOfRange => 'Valor fora do intervalo permitido';

  @override
  String resolvingType(String type) {
    return 'Resolvendo $type...';
  }

  @override
  String get invoiceAlreadyPaid => 'Invoice já foi pago';

  @override
  String paymentError(String error) {
    return 'Erro ao pagar: $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit enviados';
  }

  @override
  String get filterAll => 'Todos';

  @override
  String get filterPending => 'Pendentes';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Receba tokens Cashu para começar';

  @override
  String get noPendingTransactions => 'Sem transações pendentes';

  @override
  String get allTransactionsCompleted => 'Todas as suas transações estão completas';

  @override
  String get noEcashTransactions => 'Sem transações Ecash';

  @override
  String get sendOrReceiveTokens => 'Envie ou receba tokens Cashu';

  @override
  String get noLightningTransactions => 'Sem transações Lightning';

  @override
  String get depositOrWithdrawLightning => 'Deposite ou saque via Lightning';

  @override
  String get pendingStatus => 'Pendente';

  @override
  String get receivedStatus => 'Recebido';

  @override
  String get sentStatus => 'Enviado';

  @override
  String get now => 'Agora';

  @override
  String agoMinutes(int minutes) {
    return 'Há $minutes min';
  }

  @override
  String agoHours(int hours) {
    return 'Há $hours h';
  }

  @override
  String agoDays(int days) {
    return 'Há $days dias';
  }

  @override
  String get lightningInvoice => 'Invoice Lightning';

  @override
  String get receivedEcash => 'Ecash Recebido';

  @override
  String get sentEcash => 'Ecash Enviado';

  @override
  String get outgoingLightningPayment => 'Pagamento Lightning Enviado';

  @override
  String get invoiceNotAvailable => 'Invoice não disponível';

  @override
  String get tokenNotAvailable => 'Token não disponível';

  @override
  String get unit => 'Unidade';

  @override
  String get status => 'Status';

  @override
  String get pending => 'Pendente';

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
  String get speed => 'VELOCIDADE:';

  @override
  String get settings => 'Configurações';

  @override
  String get walletSection => 'WALLET';

  @override
  String get backupSeedPhrase => 'Backup da frase semente';

  @override
  String get viewRecoveryWords => 'Ver suas palavras de recuperação';

  @override
  String get connectedMints => 'Mints conectados';

  @override
  String get manageCashuMints => 'Gerenciar seus mints Cashu';

  @override
  String get pinAccess => 'PIN de acesso';

  @override
  String get pinEnabled => 'Ativado';

  @override
  String get protectWithPin => 'Proteger o app com PIN';

  @override
  String get recoverTokens => 'Recuperar tokens';

  @override
  String get scanMintsWithSeed => 'Escanear mints com frase semente';

  @override
  String get appearanceSection => 'IDIOMA';

  @override
  String get language => 'Idioma';

  @override
  String get informationSection => 'INFORMAÇÃO';

  @override
  String get version => 'Versão';

  @override
  String get about => 'Sobre';

  @override
  String get deleteWallet => 'Apagar wallet';

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
  String get mnemonicNotFound => 'Mnemônico não encontrado';

  @override
  String get createPin => 'Criar PIN';

  @override
  String get enterPinDigits => 'Digite um PIN de 4 dígitos';

  @override
  String get confirmPin => 'Confirmar PIN';

  @override
  String get enterPinAgain => 'Digite o PIN novamente';

  @override
  String get pinMismatch => 'Os PINs não coincidem';

  @override
  String get pinActivated => 'PIN ativado';

  @override
  String get pinDeactivated => 'PIN desativado';

  @override
  String get verifyPin => 'Verificar PIN';

  @override
  String get enterCurrentPin => 'Digite seu PIN atual';

  @override
  String get incorrectPin => 'PIN incorreto';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String languageChanged(String language) {
    return 'Idioma alterado para $language';
  }

  @override
  String get close => 'Fechar';

  @override
  String get aboutDescription => 'Uma wallet Cashu com DNA cubano para o mundo inteiro. Irmã de LaChispa.';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get deleteWalletQuestion => 'Apagar wallet?';

  @override
  String get actionIrreversible => 'Esta ação é irreversível';

  @override
  String get deleteWalletWarning => 'Todos os dados serão excluídos, incluindo sua frase semente e tokens. Certifique-se de ter um backup.';

  @override
  String get typeDeleteToConfirm => 'Digite \"APAGAR\" para confirmar:';

  @override
  String get deleteConfirmWord => 'APAGAR';

  @override
  String deleteError(String error) {
    return 'Erro ao apagar: $error';
  }

  @override
  String get recoverTokensTitle => 'Recuperar tokens';

  @override
  String get recoverTokensDescription => 'Escanear mints para recuperar tokens associados à sua frase semente (NUT-13)';

  @override
  String get useCurrentSeedPhrase => 'Usar minha frase semente atual';

  @override
  String get scanWithSavedWords => 'Escanear mints com as 12 palavras salvas';

  @override
  String get useOtherSeedPhrase => 'Usar outra frase semente';

  @override
  String get recoverFromOtherWords => 'Recuperar tokens de outras 12 palavras';

  @override
  String get mintsToScan => 'Mints para escanear:';

  @override
  String allMints(int count) {
    return 'Todos os mints ($count)';
  }

  @override
  String get specificMint => 'Um mint específico';

  @override
  String get enterMnemonicWords => 'Digite as 12 palavras separadas por espaços...';

  @override
  String get scanMints => 'Escanear mints';

  @override
  String get selectMintToScan => 'Selecione um mint para escanear';

  @override
  String get mnemonicMustHaveWords => 'O mnemônico deve ter 12 ou 24 palavras';

  @override
  String get noConnectedMintsToScan => 'Nenhum mint conectado para escanear';

  @override
  String recoveredTokens(String tokens, int mints) {
    return 'Recuperados $tokens de $mints mint(s)!';
  }

  @override
  String get scanCompleteNoTokens => 'Escaneamento completo. Nenhum token novo encontrado.';

  @override
  String mintsWithError(int count) {
    return '($count mint(s) com erro)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return 'Recuperados $tokens de $mint!';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return 'Nenhum token encontrado em $mint.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return 'Recuperados e transferidos $amount $unit para sua wallet!';
  }

  @override
  String get noTokensForMnemonic => 'Nenhum token encontrado associado a esse mnemônico.';

  @override
  String get noConnectedMints => 'Nenhum mint conectado';

  @override
  String get addMintToStart => 'Adicione um mint para começar';

  @override
  String get addMint => 'Adicionar mint';

  @override
  String get mintDeleted => 'Mint excluído';

  @override
  String get activeMintUpdated => 'Mint ativo atualizado';

  @override
  String get mintUrl => 'URL do mint:';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'A URL deve começar com https://';

  @override
  String get connectingToMint => 'Conectando ao mint...';

  @override
  String get mintAddedSuccessfully => 'Mint adicionado com sucesso';

  @override
  String get couldNotConnectToMint => 'Não foi possível conectar ao mint';

  @override
  String get add => 'Adicionar';

  @override
  String get success => 'Sucesso';

  @override
  String get loading => 'Carregando...';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get activeMint => 'Mint ativo';

  @override
  String get mintMessage => 'Mensagem do Mint';

  @override
  String get url => 'URL';

  @override
  String get currency => 'Moeda';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get useThisMint => 'Usar este mint';

  @override
  String get copyMintUrl => 'Copiar URL do mint';

  @override
  String get deleteMint => 'Excluir mint';

  @override
  String copied(String label) {
    return '$label copiado';
  }

  @override
  String get deleteMintConfirmTitle => 'Excluir mint';

  @override
  String get deleteMintConfirmMessage => 'Se você tiver saldo neste mint, ele será perdido. Tem certeza?';

  @override
  String get delete => 'Excluir';

  @override
  String get offlineSend => 'Envio Offline';

  @override
  String get selectAll => 'Tudo';

  @override
  String get deselectAll => 'Nenhum';

  @override
  String get selectNotesToSend => 'Selecione as notas que deseja enviar:';

  @override
  String get totalToSend => 'Total a enviar';

  @override
  String notesSelected(int count) {
    return '$count notas selecionadas';
  }

  @override
  String loadingProofsError(String error) {
    return 'Erro ao carregar provas: $error';
  }

  @override
  String creatingTokenError(String error) {
    return 'Erro ao criar token: $error';
  }

  @override
  String get unknownState => 'Estado desconhecido';

  @override
  String depositAmountTitle(String amount, String unit) {
    return 'Depositar $amount $unit';
  }

  @override
  String get receiveNow => 'Receber agora';

  @override
  String get receiveLater => 'Receber depois';

  @override
  String get tokenSavedForLater => 'Token salvo para resgatar depois';

  @override
  String get noConnectionTokenSaved => 'Sem conexão. Token salvo para resgatar depois.';

  @override
  String get unknownMintOffline => 'Este token é de um mint desconhecido. Conecte-se à internet para adicioná-lo e resgatar o token.';

  @override
  String get noConnectionTryLater => 'Sem conexão ao mint. Tente mais tarde.';

  @override
  String get saveTokenError => 'Erro ao salvar o token. Tente novamente.';

  @override
  String get pendingTokenLimitReached => 'Limite de tokens pendentes atingido (máx 50)';

  @override
  String get filterToReceive => 'Para receber';

  @override
  String get noPendingTokens => 'Sem tokens pendentes';

  @override
  String get noPendingTokensHint => 'Salve tokens para resgatar depois';

  @override
  String get pendingBadge => 'PENDENTE';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expira em $days dias',
      one: 'Expira em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count tentativas';
  }

  @override
  String get claimNow => 'Resgatar agora';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return 'Resgatados $amount $unit';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Resgatados $count tokens ($amount $unit)',
      one: 'Resgatado 1 token ($amount $unit)',
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
  String get pointCameraAtQr => 'Aponte a câmera para o código QR';

  @override
  String get pointCameraAtCashuQr => 'Aponte a câmera para o QR do token Cashu';

  @override
  String get pointCameraAtInvoiceQr => 'Aponte a câmera para o QR do invoice';

  @override
  String get unrecognizedQrCode => 'Código QR não reconhecido';

  @override
  String get scanCashuTokenHint => 'Escaneie um token Cashu (cashuA... ou cashuB...)';

  @override
  String get scanLightningInvoiceHint => 'Escaneie um invoice Lightning (lnbc...)';

  @override
  String get addMintQuestion => 'Adicionar este mint?';

  @override
  String get cameraPermissionDenied => 'Permissão de câmera negada';

  @override
  String get paymentRequestNotSupported => 'Solicitações de pagamento ainda não são suportadas';

  @override
  String get p2pkTitle => 'Chaves P2PK';

  @override
  String get p2pkSettingsDescription => 'Receber ecash bloqueado';

  @override
  String get p2pkExperimental => 'P2PK é experimental. Use com cautela.';

  @override
  String get p2pkPendingSendWarning => 'Você tem um envio P2PK pendente. Vá ao histórico e atualize após o destinatário resgatar o token.';

  @override
  String get p2pkExperimentalShort => 'Experimental';

  @override
  String get p2pkPrimaryKey => 'Chave Principal';

  @override
  String get p2pkDerived => 'Derivada';

  @override
  String get p2pkImported => 'Importada';

  @override
  String get p2pkImportedKeys => 'Chaves Importadas';

  @override
  String get p2pkNoImportedKeys => 'Nenhuma chave importada';

  @override
  String get p2pkShowQR => 'Mostrar QR';

  @override
  String get p2pkCopy => 'Copiar';

  @override
  String get p2pkImportNsec => 'Importar nsec';

  @override
  String get p2pkImport => 'Importar';

  @override
  String get p2pkEnterLabel => 'Nome para esta chave';

  @override
  String get p2pkLockToKey => 'Envio com assinatura P2PK';

  @override
  String get p2pkLockDescription => 'Apenas o destinatário pode resgatar';

  @override
  String get p2pkReceiverPubkey => 'npub1... ou hex (64/66 caracteres)';

  @override
  String get p2pkInvalidPubkey => 'Chave pública inválida';

  @override
  String get p2pkInvalidPrivateKey => 'Chave privada inválida';

  @override
  String get p2pkLockedToYou => 'Bloqueado para você';

  @override
  String get p2pkLockedToOther => 'Bloqueado para outra chave';

  @override
  String get p2pkCannotUnlock => 'Você não tem a chave para desbloquear este token';

  @override
  String get p2pkEnterPrivateKey => 'Digite a chave privada (nsec)';

  @override
  String get p2pkDeleteTitle => 'Excluir chave';

  @override
  String get p2pkDeleteConfirm => 'Excluir esta chave? Você não poderá receber tokens bloqueados para ela.';

  @override
  String get p2pkRequiresConnection => 'P2PK requer conexão com o mint';

  @override
  String get p2pkErrorMaxKeysReached => 'Número máximo de chaves importadas atingido (10)';

  @override
  String get p2pkErrorInvalidNsec => 'nsec inválido';

  @override
  String get p2pkErrorKeyAlreadyExists => 'Esta chave já existe';

  @override
  String get p2pkErrorKeyNotFound => 'Chave não encontrada';

  @override
  String get p2pkErrorCannotDeletePrimary => 'Não é possível excluir a chave principal';
}
