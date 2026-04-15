// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'ElCaju';

  @override
  String get appTagline => 'Votre portefeuille ecash privé';

  @override
  String get loadingMessage1 => 'Chiffrement de vos pièces...';

  @override
  String get loadingMessage2 => 'Préparation de vos e-tokens...';

  @override
  String get loadingMessage3 => 'Connexion au Mint...';

  @override
  String get loadingMessage4 => 'Confidentialité par défaut.';

  @override
  String get loadingMessage5 => 'Signature aveugle des tokens...';

  @override
  String get loadingMessage6 => 'Go full Calle...';

  @override
  String get loadingMessage7 => 'Cashu + Bitchat = Confidentialité + Liberté';

  @override
  String get aboutTagline => 'Confidentialité sans frontières.';

  @override
  String get welcomeTitle => 'Bienvenue sur ElCaju';

  @override
  String get welcomeSubtitle => 'Cashu pour le monde. Fait à Cuba.';

  @override
  String get createWallet => 'Créer un nouveau portefeuille';

  @override
  String get restoreWallet => 'Restaurer le portefeuille';

  @override
  String get createWalletTitle => 'Créer un portefeuille';

  @override
  String get creatingWallet => 'Création de votre portefeuille...';

  @override
  String get generatingSeed =>
      'Génération sécurisée de votre phrase de récupération';

  @override
  String get createWalletDescription =>
      'Une phrase de récupération de 12 mots sera générée.\nConservez-la dans un endroit sûr.';

  @override
  String get generateWallet => 'Générer le portefeuille';

  @override
  String get walletCreated => 'Portefeuille créé !';

  @override
  String get walletCreatedDescription =>
      'Votre portefeuille est prêt. Nous vous recommandons de sauvegarder votre phrase de récupération maintenant.';

  @override
  String get backupWarning =>
      'Sans sauvegarde, vous perdrez l\'accès à vos fonds si vous perdez l\'appareil.';

  @override
  String get backupNow => 'Sauvegarder maintenant';

  @override
  String get backupLater => 'Plus tard';

  @override
  String get backupTitle => 'Sauvegarde';

  @override
  String get seedPhraseTitle => 'Votre phrase de récupération';

  @override
  String get seedPhraseDescription =>
      'Conservez ces 12 mots dans l\'ordre. C\'est le seul moyen de récupérer votre portefeuille.';

  @override
  String get revealSeedPhrase => 'Révéler la phrase de récupération';

  @override
  String get tapToReveal =>
      'Appuyez sur le bouton pour révéler\nvotre phrase de récupération';

  @override
  String get copyToClipboard => 'Copier dans le presse-papiers';

  @override
  String get seedCopied => 'Phrase copiée dans le presse-papiers';

  @override
  String get neverShareSeed =>
      'Ne partagez jamais votre phrase de récupération avec personne.';

  @override
  String get confirmBackup =>
      'J\'ai sauvegardé ma phrase de récupération dans un endroit sûr';

  @override
  String get continue_ => 'Continuer';

  @override
  String get restoreTitle => 'Restaurer le portefeuille';

  @override
  String get enterSeedPhrase => 'Entrez votre phrase de récupération';

  @override
  String get enterSeedDescription =>
      'Tapez les 12 ou 24 mots séparés par des espaces.';

  @override
  String get seedPlaceholder => 'mot1 mot2 mot3 ...';

  @override
  String wordCount(int count) {
    return '$count mots';
  }

  @override
  String get needWords => '(vous avez besoin de 12 ou 24)';

  @override
  String get restoreScanningMint => 'Recherche de tokens sur le mint...';

  @override
  String restoreError(String error) {
    return 'Erreur de restauration : $error';
  }

  @override
  String get homeTitle => 'Accueil';

  @override
  String get receive => 'Recevoir';

  @override
  String get send => 'Envoyer';

  @override
  String get sendAction => 'Envoyer ↗';

  @override
  String get receiveAction => '↘ Recevoir';

  @override
  String get deposit => 'Déposer';

  @override
  String get withdraw => 'Retirer';

  @override
  String get lightning => 'Lightning';

  @override
  String get cashu => 'Cashu';

  @override
  String get ecash => 'Ecash';

  @override
  String get history => 'Historique';

  @override
  String get noTransactions => 'Aucune transaction';

  @override
  String get depositOrReceive => 'Déposez ou recevez des sats pour commencer';

  @override
  String get noMint => 'Aucun mint';

  @override
  String get balance => 'Solde';

  @override
  String get sats => 'sats';

  @override
  String get pasteEcashToken => 'Coller le token ecash';

  @override
  String get generateInvoiceToDeposit => 'Générer une facture pour déposer';

  @override
  String get createEcashToken => 'Créer un token ecash';

  @override
  String get payLightningInvoice => 'Payer une facture Lightning';

  @override
  String get receiveCashu => 'Recevoir Cashu';

  @override
  String get pasteTheCashuToken => 'Collez le token Cashu :';

  @override
  String get pasteFromClipboard => 'Coller depuis le presse-papiers';

  @override
  String get validToken => 'Token valide';

  @override
  String get invalidToken => 'Token invalide ou malformé';

  @override
  String get amount => 'Montant :';

  @override
  String get mint => 'Mint :';

  @override
  String get claiming => 'Réclamation...';

  @override
  String get claimTokens => 'Réclamer les tokens';

  @override
  String get tokensReceived => 'Tokens reçus';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get tokenAlreadyClaimed => 'Ce token a déjà été réclamé';

  @override
  String get unknownMint => 'Token d\'un mint inconnu';

  @override
  String claimError(String error) {
    return 'Erreur de réclamation : $error';
  }

  @override
  String get sendCashu => 'Envoyer Cashu';

  @override
  String get selectNotesManually => 'Sélectionner les notes manuellement';

  @override
  String get amountToSend => 'Montant à envoyer :';

  @override
  String get available => 'Disponible :';

  @override
  String get max => '(Max)';

  @override
  String get memoOptional => 'Mémo (optionnel) :';

  @override
  String get memoPlaceholder => 'À quoi sert ce paiement ?';

  @override
  String get creatingToken => 'Création du token...';

  @override
  String get createToken => 'Créer le token';

  @override
  String get noActiveMint => 'Aucun mint actif';

  @override
  String get offlineModeMessage => 'Pas de connexion. Mode hors ligne...';

  @override
  String get confirmSend => 'Confirmer l\'envoi';

  @override
  String get confirm => 'Confirmer';

  @override
  String get cancel => 'Annuler';

  @override
  String get insufficientBalance => 'Solde insuffisant';

  @override
  String get feeExceedsAmount => 'Les frais dépassent le montant à envoyer';

  @override
  String tokenCreationError(String error) {
    return 'Erreur de création du token : $error';
  }

  @override
  String get tokenCreated => 'Token créé';

  @override
  String get copy => 'Copier';

  @override
  String get share => 'Partager';

  @override
  String get tokenCashu => 'Token Cashu';

  @override
  String tokenCashuAnimatedQr(int fragments) {
    return 'Token Cashu (QR animé - $fragments fragments UR)';
  }

  @override
  String get keepTokenWarning =>
      'Conservez ce token jusqu\'à ce que le destinataire le réclame. Si vous le perdez, vous perdrez les fonds.';

  @override
  String get tokenCopiedToClipboard => 'Token copié dans le presse-papiers';

  @override
  String get copyAsEmoji => 'Copier en emoji';

  @override
  String get emojiCopiedToClipboard => 'Token copié en emoji 🥜';

  @override
  String get peanutDecodeError =>
      'Impossible de décoder le token emoji. Il est peut-être corrompu.';

  @override
  String get nfcWrite => 'Écrire sur tag NFC';

  @override
  String get nfcRead => 'Lire tag NFC';

  @override
  String get nfcHoldNear => 'Approchez l\'appareil du tag NFC...';

  @override
  String get nfcWriteSuccess => 'Token écrit sur le tag NFC';

  @override
  String nfcWriteError(String error) {
    return 'Erreur NFC écriture : $error';
  }

  @override
  String nfcReadError(String error) {
    return 'Erreur NFC lecture : $error';
  }

  @override
  String get nfcDisabled =>
      'NFC est désactivé. Activez-le dans les Paramètres.';

  @override
  String get nfcUnsupported => 'Cet appareil ne prend pas en charge le NFC';

  @override
  String get amountToDeposit => 'Montant à déposer :';

  @override
  String get descriptionOptional => 'Description (optionnelle) :';

  @override
  String get depositPlaceholder => 'À quoi sert ce dépôt ?';

  @override
  String get generating => 'Génération...';

  @override
  String get generateInvoice => 'Générer la facture';

  @override
  String get depositLightning => 'Déposer Lightning';

  @override
  String get payInvoiceTitle => 'Payer la facture';

  @override
  String get generatingInvoice => 'Génération de la facture...';

  @override
  String get waitingForPayment => 'En attente du paiement...';

  @override
  String get paymentReceived => 'Paiement reçu';

  @override
  String get tokensIssued => 'Tokens émis !';

  @override
  String get error => 'Erreur';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get back => 'Retour';

  @override
  String get copyInvoice => 'Copier la facture';

  @override
  String get description => 'Description :';

  @override
  String get invoiceCopiedToClipboard =>
      'Facture copiée dans le presse-papiers';

  @override
  String deposited(String amount, String unit) {
    return '$amount $unit déposés';
  }

  @override
  String get pasteLightningInvoice => 'Collez la facture Lightning :';

  @override
  String get gettingQuote => 'Obtention du devis...';

  @override
  String get validInvoice => 'Facture valide';

  @override
  String get invalidInvoice => 'Facture invalide';

  @override
  String get invalidInvoiceMalformed => 'Facture invalide ou malformée';

  @override
  String get feeReserved => 'Frais réservés :';

  @override
  String get total => 'Total :';

  @override
  String get paying => 'Paiement...';

  @override
  String get payInvoice => 'Payer la facture';

  @override
  String get confirmPayment => 'Confirmer le paiement';

  @override
  String get pay => 'Payer';

  @override
  String get fee => 'frais';

  @override
  String get invoiceExpired => 'Facture expirée';

  @override
  String get amountOutOfRange => 'Montant hors de la plage autorisée';

  @override
  String resolvingType(String type) {
    return 'Résolution de $type...';
  }

  @override
  String get invoiceAlreadyPaid => 'Facture déjà payée';

  @override
  String paymentError(String error) {
    return 'Erreur de paiement : $error';
  }

  @override
  String sent(String amount, String unit) {
    return '$amount $unit envoyés';
  }

  @override
  String get filterAll => 'Tous';

  @override
  String get filterPending => 'En attente';

  @override
  String get filterEcash => 'Ecash';

  @override
  String get filterLightning => 'Lightning';

  @override
  String get receiveTokensToStart => 'Recevez des tokens Cashu pour commencer';

  @override
  String get noPendingTransactions => 'Aucune transaction en attente';

  @override
  String get allTransactionsCompleted =>
      'Toutes vos transactions sont terminées';

  @override
  String get noEcashTransactions => 'Aucune transaction Ecash';

  @override
  String get sendOrReceiveTokens => 'Envoyez ou recevez des tokens Cashu';

  @override
  String get noLightningTransactions => 'Aucune transaction Lightning';

  @override
  String get depositOrWithdrawLightning => 'Déposez ou retirez via Lightning';

  @override
  String get pendingStatus => 'En attente';

  @override
  String get receivedStatus => 'Reçu';

  @override
  String get sentStatus => 'Envoyé';

  @override
  String get now => 'Maintenant';

  @override
  String agoMinutes(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String agoHours(int hours) {
    return 'Il y a $hours h';
  }

  @override
  String agoDays(int days) {
    return 'Il y a $days jours';
  }

  @override
  String get lightningInvoice => 'Facture Lightning';

  @override
  String get receivedEcash => 'Ecash reçu';

  @override
  String get sentEcash => 'Ecash envoyé';

  @override
  String get outgoingLightningPayment => 'Paiement Lightning sortant';

  @override
  String get invoiceNotAvailable => 'Facture non disponible';

  @override
  String get tokenNotAvailable => 'Token non disponible';

  @override
  String get unit => 'Unité';

  @override
  String get status => 'Statut';

  @override
  String get pending => 'En attente';

  @override
  String get memo => 'Mémo';

  @override
  String get copyInvoiceButton => 'COPIER LA FACTURE';

  @override
  String get copyButton => 'COPIER';

  @override
  String get invoiceCopied => 'Facture copiée';

  @override
  String get tokenCopied => 'Token copié';

  @override
  String get speed => 'VITESSE :';

  @override
  String get settings => 'Paramètres';

  @override
  String get walletSection => 'PORTEFEUILLE';

  @override
  String get backupSeedPhrase => 'Sauvegarder la phrase de récupération';

  @override
  String get viewRecoveryWords => 'Voir vos mots de récupération';

  @override
  String get connectedMints => 'Mints connectés';

  @override
  String get manageCashuMints => 'Gérer vos mints Cashu';

  @override
  String get pinAccess => 'Code PIN';

  @override
  String get pinEnabled => 'Activé';

  @override
  String get protectWithPin => 'Protéger l\'app avec un PIN';

  @override
  String get recoverTokens => 'Récupérer les tokens';

  @override
  String get scanMintsWithSeed =>
      'Scanner les mints avec la phrase de récupération';

  @override
  String get appearanceSection => 'LANGUE';

  @override
  String get language => 'Langue';

  @override
  String get informationSection => 'INFORMATIONS';

  @override
  String get version => 'Version';

  @override
  String get about => 'À propos';

  @override
  String get deleteWallet => 'Supprimer le portefeuille';

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
  String get mnemonicNotFound => 'Mnémonique non trouvé';

  @override
  String get createPin => 'Créer un PIN';

  @override
  String get enterPinDigits => 'Entrez un PIN à 4 chiffres';

  @override
  String get confirmPin => 'Confirmer le PIN';

  @override
  String get enterPinAgain => 'Entrez le PIN à nouveau';

  @override
  String get pinMismatch => 'Les PIN ne correspondent pas';

  @override
  String get pinActivated => 'PIN activé';

  @override
  String get pinDeactivated => 'PIN désactivé';

  @override
  String get verifyPin => 'Vérifier le PIN';

  @override
  String get enterCurrentPin => 'Entrez votre PIN actuel';

  @override
  String get incorrectPin => 'PIN incorrect';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String languageChanged(String language) {
    return 'Langue changée en $language';
  }

  @override
  String get close => 'Fermer';

  @override
  String get aboutDescription =>
      'Un portefeuille Cashu avec ADN cubain pour le monde entier. Frère de LaChispa.';

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get deleteWalletQuestion => 'Supprimer le portefeuille ?';

  @override
  String get actionIrreversible => 'Cette action est irréversible';

  @override
  String get deleteWalletWarning =>
      'Toutes les données seront supprimées, y compris votre phrase de récupération et vos tokens. Assurez-vous d\'avoir une sauvegarde.';

  @override
  String get typeDeleteToConfirm => 'Tapez \"SUPPRIMER\" pour confirmer :';

  @override
  String get deleteConfirmWord => 'SUPPRIMER';

  @override
  String deleteError(String error) {
    return 'Erreur de suppression : $error';
  }

  @override
  String get recoverTokensTitle => 'Récupérer les tokens';

  @override
  String get recoverTokensDescription =>
      'Scanner les mints pour récupérer les tokens associés à votre phrase de récupération (NUT-13)';

  @override
  String get useCurrentSeedPhrase =>
      'Utiliser ma phrase de récupération actuelle';

  @override
  String get scanWithSavedWords =>
      'Scanner les mints avec les 12 mots sauvegardés';

  @override
  String get useOtherSeedPhrase => 'Utiliser une autre phrase de récupération';

  @override
  String get recoverFromOtherWords => 'Récupérer les tokens d\'autres 12 mots';

  @override
  String get mintsToScan => 'Mints à scanner :';

  @override
  String allMints(int count) {
    return 'Tous les mints ($count)';
  }

  @override
  String get specificMint => 'Un mint spécifique';

  @override
  String get enterMnemonicWords =>
      'Entrez les 12 mots séparés par des espaces...';

  @override
  String get scanMints => 'Scanner les mints';

  @override
  String get selectMintToScan => 'Sélectionnez un mint à scanner';

  @override
  String get mnemonicMustHaveWords => 'Le mnémonique doit avoir 12 ou 24 mots';

  @override
  String get noConnectedMintsToScan => 'Aucun mint connecté à scanner';

  @override
  String recoveredTokens(String tokens, int mints) {
    return 'Récupéré $tokens de $mints mint(s) !';
  }

  @override
  String get scanCompleteNoTokens =>
      'Scan terminé. Aucun nouveau token trouvé.';

  @override
  String mintsWithError(int count) {
    return '($count mint(s) avec erreur)';
  }

  @override
  String recoveredFromMint(String tokens, String mint) {
    return 'Récupéré $tokens de $mint !';
  }

  @override
  String noTokensFoundInMint(String mint) {
    return 'Aucun token trouvé dans $mint.';
  }

  @override
  String recoveredAndTransferred(String amount, String unit) {
    return 'Récupéré et transféré $amount $unit vers votre portefeuille !';
  }

  @override
  String get noTokensForMnemonic =>
      'Aucun token trouvé associé à ce mnémonique.';

  @override
  String get noConnectedMints => 'Aucun mint connecté';

  @override
  String get addMintToStart => 'Ajoutez un mint pour commencer';

  @override
  String get addMint => 'Ajouter un mint';

  @override
  String get mintDeleted => 'Mint supprimé';

  @override
  String get activeMintUpdated => 'Mint actif mis à jour';

  @override
  String get mintUrl => 'URL du mint :';

  @override
  String get mintUrlPlaceholder => 'https://mint.example.com';

  @override
  String get urlMustStartWithHttps => 'L\'URL doit commencer par https://';

  @override
  String get connectingToMint => 'Connexion au mint...';

  @override
  String get mintAddedSuccessfully => 'Mint ajouté avec succès';

  @override
  String get couldNotConnectToMint => 'Impossible de se connecter au mint';

  @override
  String get add => 'Ajouter';

  @override
  String get success => 'Succès';

  @override
  String get loading => 'Chargement...';

  @override
  String get retry => 'Réessayer';

  @override
  String get activeMint => 'Mint actif';

  @override
  String get mintMessage => 'Message du Mint';

  @override
  String get url => 'URL';

  @override
  String get currency => 'Devise';

  @override
  String get unknown => 'Inconnu';

  @override
  String get useThisMint => 'Utiliser ce mint';

  @override
  String get copyMintUrl => 'Copier l\'URL du mint';

  @override
  String get deleteMint => 'Supprimer le mint';

  @override
  String copied(String label) {
    return '$label copié';
  }

  @override
  String get deleteMintConfirmTitle => 'Supprimer le mint';

  @override
  String get deleteMintConfirmMessage =>
      'Si vous avez un solde sur ce mint, il sera perdu. Êtes-vous sûr ?';

  @override
  String get delete => 'Supprimer';

  @override
  String get offlineSend => 'Envoi hors ligne';

  @override
  String get selectAll => 'Tout';

  @override
  String get deselectAll => 'Aucun';

  @override
  String get selectNotesToSend => 'Sélectionnez les notes à envoyer :';

  @override
  String get totalToSend => 'Total à envoyer';

  @override
  String notesSelected(int count) {
    return '$count notes sélectionnées';
  }

  @override
  String loadingProofsError(String error) {
    return 'Erreur de chargement des preuves : $error';
  }

  @override
  String creatingTokenError(String error) {
    return 'Erreur de création du token : $error';
  }

  @override
  String get unknownState => 'État inconnu';

  @override
  String depositAmountTitle(String amount, String unit) {
    return 'Déposer $amount $unit';
  }

  @override
  String get receiveNow => 'Recevoir maintenant';

  @override
  String get receiveLater => 'Recevoir plus tard';

  @override
  String get tokenSavedForLater => 'Token sauvegardé pour réclamer plus tard';

  @override
  String get noConnectionTokenSaved =>
      'Pas de connexion. Token sauvegardé pour réclamer plus tard.';

  @override
  String get unknownMintOffline =>
      'Ce token provient d\'un mint inconnu. Connectez-vous à Internet pour l\'ajouter et réclamer le token.';

  @override
  String get noConnectionTryLater =>
      'Pas de connexion au mint. Réessayez plus tard.';

  @override
  String get saveTokenError =>
      'Erreur lors de la sauvegarde du token. Veuillez réessayer.';

  @override
  String get pendingTokenLimitReached =>
      'Limite de tokens en attente atteinte (max 50)';

  @override
  String get filterToReceive => 'À recevoir';

  @override
  String get noPendingTokens => 'Aucun token en attente';

  @override
  String get noPendingTokensHint =>
      'Sauvegardez des tokens pour les réclamer plus tard';

  @override
  String get pendingBadge => 'EN ATTENTE';

  @override
  String expiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expire dans $days jours',
      one: 'Expire dans 1 jour',
    );
    return '$_temp0';
  }

  @override
  String retryCount(int count) {
    return '$count tentatives';
  }

  @override
  String get claimNow => 'Réclamer maintenant';

  @override
  String pendingTokenClaimedSuccess(String amount, String unit) {
    return 'Réclamé $amount $unit';
  }

  @override
  String pendingTokensClaimed(int count, String amount, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Réclamé $count tokens ($amount $unit)',
      one: 'Réclamé 1 token ($amount $unit)',
    );
    return '$_temp0';
  }

  @override
  String get scan => 'Scanner';

  @override
  String get scanQrCode => 'Scanner le QR';

  @override
  String get scanCashuToken => 'Scanner un token Cashu';

  @override
  String get scanLightningInvoice => 'Scanner une facture';

  @override
  String get scanningAnimatedQr => 'Scan du QR animé...';

  @override
  String get pointCameraAtQr => 'Pointez la caméra vers le code QR';

  @override
  String get pointCameraAtCashuQr =>
      'Pointez la caméra vers le QR du token Cashu';

  @override
  String get pointCameraAtInvoiceQr =>
      'Pointez la caméra vers le QR de la facture';

  @override
  String get unrecognizedQrCode => 'Code QR non reconnu';

  @override
  String get scanCashuTokenHint =>
      'Scannez un token Cashu (cashuA... ou cashuB...)';

  @override
  String get scanLightningInvoiceHint =>
      'Scannez une facture Lightning (lnbc...)';

  @override
  String get addMintQuestion => 'Ajouter ce mint ?';

  @override
  String get cameraPermissionDenied => 'Permission de la caméra refusée';

  @override
  String get paymentRequestTitle => 'Demande de paiement';

  @override
  String get paymentRequestFrom => 'Demande de';

  @override
  String get paymentRequestAmount => 'Montant demandé';

  @override
  String get paymentRequestDescription => 'Description';

  @override
  String get paymentRequestMints => 'Mints acceptés';

  @override
  String get paymentRequestAnyMint => 'N\'importe quel mint';

  @override
  String get paymentRequestPay => 'Payer';

  @override
  String get paymentRequestPaying => 'Paiement en cours...';

  @override
  String get paymentRequestSuccess => 'Paiement envoyé avec succès';

  @override
  String get paymentRequestNoTransport =>
      'Cette demande n\'a pas de méthode de livraison configurée';

  @override
  String get paymentRequestTransport => 'Transport';

  @override
  String get paymentRequestMintNotAccepted =>
      'Votre mint actif n\'est pas dans la liste des mints acceptés';

  @override
  String paymentRequestUnitMismatch(String unit) {
    return 'Unité incompatible : la demande nécessite $unit';
  }

  @override
  String get paymentRequestInsufficientBalance => 'Solde insuffisant';

  @override
  String get paymentRequestErrorParsing =>
      'Erreur lors de la lecture de la demande de paiement';

  @override
  String get p2pkTitle => 'Clés P2PK';

  @override
  String get p2pkSettingsDescription => 'Recevoir ecash verrouillé';

  @override
  String get p2pkExperimental =>
      'P2PK est expérimental. Utiliser avec prudence.';

  @override
  String get p2pkPendingSendWarning =>
      'Vous avez un envoi P2PK en attente. Allez dans l\'historique et actualisez après que le destinataire a réclamé le jeton.';

  @override
  String get p2pkExperimentalShort => 'Expérimental';

  @override
  String get p2pkPrimaryKey => 'Clé Principale';

  @override
  String get p2pkDerived => 'Dérivée';

  @override
  String get p2pkImported => 'Importée';

  @override
  String get p2pkImportedKeys => 'Clés Importées';

  @override
  String get p2pkNoImportedKeys => 'Aucune clé importée';

  @override
  String get p2pkShowQR => 'Afficher QR';

  @override
  String get p2pkCopy => 'Copier';

  @override
  String get p2pkImportNsec => 'Importer nsec';

  @override
  String get p2pkImport => 'Importer';

  @override
  String get p2pkEnterLabel => 'Nom pour cette clé';

  @override
  String get p2pkLockToKey => 'Envoi avec signature P2PK';

  @override
  String get p2pkLockDescription => 'Seul le destinataire peut réclamer';

  @override
  String get p2pkReceiverPubkey => 'npub1... ou hex (64/66 caractères)';

  @override
  String get p2pkInvalidPubkey => 'Clé publique invalide';

  @override
  String get p2pkInvalidPrivateKey => 'Clé privée invalide';

  @override
  String get p2pkLockedToYou => 'Verrouillé pour vous';

  @override
  String get p2pkLockedToOther => 'Verrouillé pour une autre clé';

  @override
  String get p2pkCannotUnlock =>
      'Vous n\'avez pas la clé pour déverrouiller ce token';

  @override
  String get p2pkEnterPrivateKey => 'Entrer la clé privée (nsec)';

  @override
  String get p2pkDeleteTitle => 'Supprimer la clé';

  @override
  String get p2pkDeleteConfirm =>
      'Supprimer cette clé ? Vous ne pourrez plus recevoir de tokens verrouillés dessus.';

  @override
  String get p2pkRequiresConnection => 'P2PK nécessite une connexion au mint';

  @override
  String get p2pkErrorMaxKeysReached =>
      'Nombre maximum de clés importées atteint (10)';

  @override
  String get p2pkErrorInvalidNsec => 'nsec invalide';

  @override
  String get p2pkErrorKeyAlreadyExists => 'Cette clé existe déjà';

  @override
  String get p2pkErrorKeyNotFound => 'Clé non trouvée';

  @override
  String get p2pkErrorCannotDeletePrimary =>
      'Impossible de supprimer la clé principale';

  @override
  String get request => 'Demander';

  @override
  String get requestPayment => 'Demander un paiement';

  @override
  String get requestPaymentDescription =>
      'Générer une demande de paiement unifiée';

  @override
  String get generateRequest => 'Générer la demande';

  @override
  String get generatingRequest => 'Génération en cours...';

  @override
  String get requestPaymentReceived => 'Paiement reçu';

  @override
  String get requestDescriptionHint => 'Description (facultatif)';

  @override
  String get universal => 'Universel';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get swap => 'Échanger';

  @override
  String get swapDescription => 'Convertir entre sats et USD';

  @override
  String get swapFrom => 'De';

  @override
  String get swapTo => 'Vers';

  @override
  String get swapAction => 'Échanger';

  @override
  String get swapEstimatedFee => 'Frais estimés';

  @override
  String get swapUseAll => 'Tout utiliser';

  @override
  String swapMinimum(String amount) {
    return 'Minimum : $amount';
  }

  @override
  String get swapProcessing => 'Swap en cours...';

  @override
  String get swapSuccess => 'Swap terminé';

  @override
  String get swapErrorInsufficient => 'Solde insuffisant';

  @override
  String get swapErrorExpired => 'Le devis a expiré';

  @override
  String swapErrorGeneric(String error) {
    return 'Erreur de swap : $error';
  }

  @override
  String get swapChartUnavailable =>
      'Prix indisponible · Appuyez pour réessayer';

  @override
  String swapChartMinMax(String minPrice, String maxPrice) {
    return '24h  Min : $minPrice — Max : $maxPrice';
  }

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyTitle => 'NOUS NE COLLECTONS RIEN';

  @override
  String get privacyGoodbye => 'AU REVOIR';

  @override
  String get privacyKeepReading => '(continue à lire si tu veux…)';

  @override
  String get privacyBody =>
      'Nous ne savons pas qui tu es\nNous ne savons pas combien tu as\nNous ne savons pas ce que tu fais';

  @override
  String get privacyConclusion =>
      'La meilleure façon de protéger tes données,\nc\'est de ne pas les avoir';
}
