use std::{collections::HashMap, str::FromStr, sync::Arc, time::Duration};

use bip39::Mnemonic;
use cdk::{
    amount::{Amount, SplitTarget},
    cdk_database::WalletDatabase as _,
    mint_url::MintUrl,
    nuts::{
        nut00::ProofsMethods, CurrencyUnit, MintQuoteState as CdkMintQuoteState, PaymentMethod,
        PublicKey, SecretKey, SpendingConditions, State as ProofState, Token as CdkToken,
    },
    wallet::{
        MeltQuote as CdkMeltQuote, MintQuote as CdkMintQuote, PreparedSend as CdkPreparedSend,
        ReceiveOptions as CdkReceiveOptions, SendMemo, SendOptions as CdkSendOptions,
        Wallet as CdkWallet, WalletSubscription,
    },
};
use cdk_common::{
    util::unix_time,
    wallet::{
        Transaction as CdkTransaction, TransactionDirection as CdkTransactionDirection,
        TransactionId,
    },
    NotificationPayload,
};
use cdk_sqlite::WalletSqliteDatabase;
use flutter_rust_bridge::frb;
use log::info;
use tokio::sync::broadcast;
use uuid::Uuid;

use crate::frb_generated::StreamSink;

use super::{
    error::Error,
    mint_info::MintInfo,
    token::Token,
};

// ========================================================================
// Wallet
// ========================================================================

#[derive(Clone)]
pub struct Wallet {
    pub mint_url: String,
    pub unit: String,

    balance_broadcast: broadcast::Sender<u64>,
    pub(crate) inner: CdkWallet,
    seed: [u8; 64],
}

impl Wallet {
    #[frb(sync)]
    pub fn new(
        mint_url: String,
        unit: String,
        mnemonic: String,
        target_proof_count: Option<usize>,
        db: &WalletDatabase,
    ) -> Result<Self, Error> {
        let mnemonic = Mnemonic::parse(&mnemonic).map_err(|_| Error::InvalidInput)?;
        let seed: [u8; 64] = mnemonic.to_seed("").into();
        let unit = CurrencyUnit::from_str(&unit).unwrap_or(CurrencyUnit::Custom(unit.to_string()));
        Ok(Self {
            mint_url: mint_url.clone(),
            unit: unit.to_string(),
            balance_broadcast: broadcast::channel(1).0,
            inner: CdkWallet::new(
                &mint_url,
                unit,
                db.inner.clone(),
                seed,
                target_proof_count,
            )?,
            seed,
        })
    }

    // === Balance ===

    pub async fn balance(&self) -> Result<u64, Error> {
        Ok(self.inner.total_balance().await?.into())
    }

    pub async fn stream_balance(&self, sink: StreamSink<u64>) -> Result<(), Error> {
        let mut receiver = self.balance_broadcast.subscribe();
        let _ = sink.add(self.balance().await?);
        flutter_rust_bridge::spawn(async move {
            loop {
                match receiver.recv().await {
                    Ok(balance) => {
                        if sink.add(balance).is_err() {
                            break;
                        }
                    }
                    Err(_) => break,
                }
            }
        });
        Ok(())
    }

    // === Receive ===

    pub async fn receive(&self, token: Token, opts: Option<ReceiveOptions>) -> Result<u64, Error> {
        let amount = self
            .inner
            .receive(&token.encoded, opts.unwrap_or_default().try_into()?)
            .await?
            .into();
        self.update_balance_streams().await;
        Ok(amount)
    }

    // === Send ===

    pub async fn prepare_send(
        &self,
        amount: u64,
        opts: Option<SendOptions>,
    ) -> Result<PreparedSend, Error> {
        let prepared_send = self
            .inner
            .prepare_send(amount.into(), opts.unwrap_or_default().try_into()?)
            .await?;
        Ok(prepared_send.into())
    }

    pub async fn send(
        &self,
        send: PreparedSend,
        memo: Option<String>,
        include_memo: Option<bool>,
    ) -> Result<SendResult, Error> {
        let send_memo = memo.map(|m| SendMemo {
            memo: m,
            include_memo: include_memo.unwrap_or_default(),
        });
        let cdk_token = self
            .inner
            .confirm_send(
                send.operation_id,
                send.cdk_amount,
                send.cdk_options,
                send.proofs_to_swap,
                send.proofs_to_send,
                send.cdk_swap_fee,
                send.cdk_send_fee,
                send_memo,
            )
            .await?;

        // Compute the deterministic transaction ID from the token's proofs
        // (SHA-256 of sorted Y values — same as CDK uses internally)
        // Best-effort: send is already committed, don't fail on ID computation
        let tx_id = match self.inner.get_mint_keysets().await {
            Ok(keysets) => match cdk_token.proofs(&keysets) {
                Ok(proofs) => TransactionId::try_from(proofs)
                    .map(|id| id.to_string())
                    .map_err(|e| info!("Failed to compute tx ID from proofs: {e}"))
                    .ok(),
                Err(e) => {
                    info!("Failed to extract proofs from token: {e}");
                    None
                }
            },
            Err(e) => {
                info!("Failed to fetch keysets for tx ID: {e}");
                None
            }
        };

        let token_str = cdk_token.to_string();
        self.update_balance_streams().await;

        Ok(SendResult {
            token: Token::from_str(&token_str)?,
            transaction_id: tx_id,
        })
    }

    pub async fn cancel_send(&self, send: PreparedSend) -> Result<(), Error> {
        self.inner
            .cancel_send(
                send.operation_id,
                send.proofs_to_swap,
                send.proofs_to_send,
            )
            .await?;
        Ok(())
    }

    // === Lightning Deposit (NUT-04) ===

    pub async fn mint(
        &self,
        amount: u64,
        description: Option<String>,
        sink: StreamSink<MintQuote>,
    ) -> Result<(), Error> {
        let mint_url = self.mint_url()?;
        let unit = self.unit();
        let quote = self
            .inner
            .mint_quote(PaymentMethod::BOLT11, Some(amount.into()), description, None)
            .await?;

        if sink.add(MintQuote::from(quote.clone())).is_err() {
            return Ok(());
        }

        // Try WebSocket (NUT-17) subscription — if unavailable, HTTP polling still works
        let subscription = match self
            .inner
            .subscribe(WalletSubscription::Bolt11MintQuoteState(vec![quote.id.clone()]))
            .await
        {
            Ok(sub) => Some(sub),
            Err(e) => {
                info!(
                    "Mint quote {}: WebSocket unavailable, using HTTP polling only: {e}",
                    quote.id
                );
                None
            }
        };

        let _self = self.clone();
        flutter_rust_bridge::spawn(async move {
            // Timeout: time until quote expires + 30s buffer, or 1 hour if no expiry
            let remaining = quote.expiry.saturating_sub(unix_time());
            let timeout_dur = if quote.expiry == 0 {
                Duration::from_secs(3600)
            } else {
                Duration::from_secs(remaining + 30)
            };

            // Clone for the timeout error path (originals are moved into the async block)
            let expired_id = quote.id.clone();
            let expired_request = quote.request.clone();
            let expired_amount = quote.amount;
            let expired_expiry = quote.expiry;

            // Detect payment via two parallel paths:
            // - Path A: WebSocket (NUT-17) — fast when it works (sats on most mints)
            // - Path B: HTTP polling every 5s — fallback for mints that don't send
            //   WebSocket notifications for all units (e.g. Nutshell 0.20.0 + USD)
            // First one to detect payment wins.
            let quote_id_for_poll = quote.id.clone();
            let poll_wallet = _self.clone();

            // Timeout only covers detection, not minting.
            // If payment is detected near expiry, mint() must still complete.
            enum Detected {
                Paid,
                Issued,
            }

            let mut subscription = subscription;
            let detected = tokio::time::timeout(timeout_dur, async {
                tokio::select! {
                    // Path A: WebSocket subscription (skipped if unavailable)
                    result = async {
                        let Some(ref mut sub) = subscription else {
                            return std::future::pending::<Detected>().await;
                        };
                        while let Some(event) = sub.recv().await {
                            match event.into_inner() {
                                NotificationPayload::MintQuoteBolt11Response(info)
                                    if info.state == CdkMintQuoteState::Paid =>
                                {
                                    info!("Mint quote {} paid via WebSocket", quote.id);
                                    return Detected::Paid;
                                }
                                NotificationPayload::MintQuoteBolt11Response(info)
                                    if info.state == CdkMintQuoteState::Issued =>
                                {
                                    return Detected::Issued;
                                }
                                _ => continue,
                            }
                        }
                        std::future::pending::<Detected>().await
                    } => result,

                    // Path B: HTTP polling fallback
                    result = async {
                        loop {
                            tokio::time::sleep(Duration::from_secs(5)).await;
                            match poll_wallet.inner.check_mint_quote_status(&quote_id_for_poll).await {
                                Ok(q) if q.state == CdkMintQuoteState::Paid => {
                                    info!("Mint quote {} paid via HTTP polling", quote_id_for_poll);
                                    return Detected::Paid;
                                }
                                Ok(q) if q.state == CdkMintQuoteState::Issued => {
                                    return Detected::Issued;
                                }
                                _ => continue,
                            }
                        }
                    } => result,
                }
            })
            .await;

            // Handle detection result — mint logic runs outside the timeout
            match detected {
                Err(_) => {
                    // Timeout: quote expired
                    let _ = sink.add(MintQuote {
                        id: expired_id,
                        request: expired_request,
                        amount: expired_amount.map(|a| a.into()),
                        expiry: Some(expired_expiry),
                        state: MintQuoteState::Error,
                        token: None,
                        error: Some("Quote expired".to_string()),
                        transaction_id: None,
                    });
                }
                Ok(Detected::Paid) => {
                    // Notify Dart: payment detected
                    let _ = sink.add(MintQuote {
                        id: quote.id.clone(),
                        request: quote.request.clone(),
                        amount: quote.amount.map(|a| a.into()),
                        expiry: Some(quote.expiry),
                        state: CdkMintQuoteState::Paid.into(),
                        token: None,
                        error: None,
                        transaction_id: None,
                    });

                    // Mint the ecash tokens (outside timeout)
                    match _self
                        .inner
                        .mint(&quote.id, SplitTarget::None, None)
                        .await
                    {
                        Ok(mint_proofs) => {
                            let tx_id = match TransactionId::try_from(
                                mint_proofs.clone(),
                            ) {
                                Ok(id) => Some(id.to_string()),
                                Err(e) => {
                                    info!("Failed to compute mint tx ID: {e}");
                                    None
                                }
                            };

                            let mint_amount =
                                mint_proofs.total_amount().unwrap_or_default();
                            let _ = sink.add(MintQuote {
                                id: quote.id,
                                request: quote.request,
                                amount: Some(mint_amount.into()),
                                expiry: Some(quote.expiry),
                                state: CdkMintQuoteState::Issued.into(),
                                token: Token::try_from(CdkToken::new(
                                    mint_url,
                                    mint_proofs,
                                    None,
                                    unit,
                                ))
                                .ok(),
                                error: None,
                                transaction_id: tx_id,
                            });
                            _self.update_balance_streams().await;
                        }
                        Err(e) => {
                            let _ = sink.add(MintQuote {
                                id: quote.id,
                                request: quote.request,
                                amount: quote.amount.map(|a| a.into()),
                                expiry: Some(quote.expiry),
                                state: MintQuoteState::Error,
                                token: None,
                                error: Some(e.to_string()),
                                transaction_id: None,
                            });
                        }
                    }
                }
                Ok(Detected::Issued) => {
                    // Already issued (recovered from previous session)
                    let _ = sink.add(MintQuote {
                        id: quote.id.clone(),
                        request: quote.request.clone(),
                        amount: quote.amount.map(|a| a.into()),
                        expiry: Some(quote.expiry),
                        state: CdkMintQuoteState::Issued.into(),
                        token: None,
                        error: None,
                        transaction_id: None,
                    });
                    _self.update_balance_streams().await;
                }
            }
        });
        Ok(())
    }

    pub async fn check_all_mint_quotes(&self) -> Result<(), Error> {
        let minted = self.inner.mint_unissued_quotes().await?;
        if minted > Amount::ZERO {
            self.update_balance_streams().await;
        }
        Ok(())
    }

    // === Lightning Withdrawal (NUT-05) ===

    pub async fn melt_quote(&self, request: String) -> Result<MeltQuote, Error> {
        Ok(self
            .inner
            .melt_quote(PaymentMethod::BOLT11, request, None, None)
            .await?
            .into())
    }

    pub async fn melt(&self, quote: MeltQuote) -> Result<u64, Error> {
        let melted = self
            .inner
            .prepare_melt(&quote.id, HashMap::new())
            .await?
            .confirm()
            .await?;
        self.update_balance_streams().await;
        Ok(melted.total_amount().into())
    }

    // === Transactions ===

    pub async fn list_transactions(
        &self,
        direction: Option<TransactionDirection>,
    ) -> Result<Vec<Transaction>, Error> {
        let pending_ys = self
            .inner
            .get_pending_spent_proofs()
            .await?
            .into_iter()
            .map(|p| p.y())
            .collect::<Result<Vec<_>, _>>()?;

        let cdk_txs = self
            .inner
            .list_transactions(direction.map(|d| d.into()))
            .await?;

        let mut txs = Vec::new();
        for tx in cdk_txs {
            let status = if pending_ys.iter().any(|y| tx.ys.contains(y)) {
                TransactionStatus::Pending
            } else {
                TransactionStatus::Settled
            };
            let mut transaction: Transaction = tx.into();
            transaction.status = status;
            txs.push(transaction);
        }
        Ok(txs)
    }

    pub async fn check_pending_transactions(&self) -> Result<(), Error> {
        self.inner.check_all_pending_proofs().await?;
        self.update_balance_streams().await;
        Ok(())
    }

    // === Recovery ===

    pub async fn restore(&self) -> Result<(), Error> {
        self.inner.restore().await?;
        self.update_balance_streams().await;
        Ok(())
    }

    pub async fn recover_incomplete_sagas(&self) -> Result<(), Error> {
        self.inner.recover_incomplete_sagas().await?;
        self.update_balance_streams().await;
        Ok(())
    }

    pub async fn finalize_pending_melts(&self) -> Result<(), Error> {
        self.inner.finalize_pending_melts().await?;
        self.update_balance_streams().await;
        Ok(())
    }

    // === Reclaim orphaned proofs ===

    /// Check pending-spent proofs with the mint and revert unspent ones.
    /// Returns the number of proofs recovered.
    pub async fn reclaim_pending_proofs(&self) -> Result<u64, Error> {
        let pending = self.inner.get_pending_spent_proofs().await?;
        if pending.is_empty() {
            return Ok(0);
        }

        // check_proofs_spent: queries mint AND removes spent proofs from local DB
        let states = self.inner.check_proofs_spent(pending).await?;

        // Collect Y values of proofs the mint says are NOT spent
        // Only reclaim proofs the mint explicitly reports as Unspent.
        // Pending proofs (still being processed) must not be unreserved.
        let unspent_ys: Vec<PublicKey> = states
            .into_iter()
            .filter(|s| s.state == ProofState::Unspent)
            .map(|s| s.y)
            .collect();

        let count = unspent_ys.len() as u64;
        if count > 0 {
            // Revert from PendingSpent to Unspent
            self.inner.unreserve_proofs(unspent_ys).await?;
        }

        // Always refresh: check_proofs_spent may have removed spent proofs
        self.update_balance_streams().await;
        Ok(count)
    }

    // === Utility ===

    pub async fn is_token_spent(&self, token: Token) -> Result<bool, Error> {
        let token: CdkToken = token.try_into()?;
        let mint_keysets = self.inner.get_mint_keysets().await?;
        let proof_states = self
            .inner
            .check_proofs_spent(token.proofs(&mint_keysets)?)
            .await?;
        Ok(proof_states
            .iter()
            .any(|state| state.state == ProofState::Spent))
    }

    pub async fn get_mint(&self) -> Result<Option<MintInfo>, Error> {
        Ok(self.inner.fetch_mint_info().await?.map(|info| info.into()))
    }

    // === Internal helpers ===

    pub(crate) fn mint_url(&self) -> Result<MintUrl, Error> {
        Ok(MintUrl::from_str(&self.mint_url)?)
    }

    fn unit(&self) -> CurrencyUnit {
        CurrencyUnit::from_str(&self.unit).unwrap_or(CurrencyUnit::Custom(self.unit.clone()))
    }

    pub(crate) async fn update_balance_streams(&self) {
        let balance = self
            .inner
            .total_balance()
            .await
            .unwrap_or(Amount::ZERO)
            .into();
        let _ = self.balance_broadcast.send(balance);
    }
}

// ========================================================================
// Types
// ========================================================================

/// Result of a confirmed send, carrying both the ecash token and the
/// deterministic transaction ID so Dart can save metadata without a racy
/// listTransactions lookup.
pub struct SendResult {
    pub token: Token,
    /// Deterministic transaction ID (None if computation failed)
    pub transaction_id: Option<String>,
}

pub struct MintQuote {
    pub id: String,
    pub request: String,
    pub amount: Option<u64>,
    pub expiry: Option<u64>,
    pub state: MintQuoteState,
    pub token: Option<Token>,
    pub error: Option<String>,
    /// Deterministic transaction ID (set when proofs are available, typically on Issued)
    pub transaction_id: Option<String>,
}

impl From<CdkMintQuote> for MintQuote {
    fn from(quote: CdkMintQuote) -> Self {
        Self {
            id: quote.id,
            request: quote.request,
            amount: quote.amount.map(|a| a.into()),
            expiry: Some(quote.expiry),
            state: quote.state.into(),
            token: None,
            error: None,
            transaction_id: None,
        }
    }
}

pub enum MintQuoteState {
    Unpaid,
    Paid,
    Issued,
    Error,
}

impl From<CdkMintQuoteState> for MintQuoteState {
    fn from(state: CdkMintQuoteState) -> Self {
        match state {
            CdkMintQuoteState::Unpaid => Self::Unpaid,
            CdkMintQuoteState::Paid => Self::Paid,
            CdkMintQuoteState::Issued => Self::Issued,
        }
    }
}

pub struct MeltQuote {
    pub id: String,
    pub request: String,
    pub amount: u64,
    pub fee_reserve: u64,
    pub expiry: u64,
}

impl From<CdkMeltQuote> for MeltQuote {
    fn from(quote: CdkMeltQuote) -> Self {
        Self {
            id: quote.id,
            request: quote.request,
            amount: quote.amount.into(),
            fee_reserve: quote.fee_reserve.into(),
            expiry: quote.expiry,
        }
    }
}

pub struct PreparedSend {
    pub amount: u64,
    pub swap_fee: u64,
    pub send_fee: u64,
    pub fee: u64,

    operation_id: Uuid,
    cdk_amount: Amount,
    cdk_options: CdkSendOptions,
    proofs_to_swap: cdk::nuts::Proofs,
    proofs_to_send: cdk::nuts::Proofs,
    cdk_swap_fee: Amount,
    cdk_send_fee: Amount,
}

impl<'a> From<CdkPreparedSend<'a>> for PreparedSend {
    fn from(ps: CdkPreparedSend<'a>) -> Self {
        let amount = ps.amount();
        let swap_fee = ps.swap_fee();
        let send_fee = ps.send_fee();
        let fee = ps.fee();
        Self {
            amount: amount.into(),
            swap_fee: swap_fee.into(),
            send_fee: send_fee.into(),
            fee: fee.into(),
            operation_id: ps.operation_id(),
            cdk_amount: amount,
            cdk_options: ps.options().clone(),
            proofs_to_swap: ps.proofs_to_swap().to_vec(),
            proofs_to_send: ps.proofs_to_send().to_vec(),
            cdk_swap_fee: swap_fee,
            cdk_send_fee: send_fee,
        }
    }
}

#[derive(Default)]
pub struct ReceiveOptions {
    pub signing_keys: Option<Vec<String>>,
    pub preimages: Option<Vec<String>>,
}

impl TryInto<CdkReceiveOptions> for ReceiveOptions {
    type Error = Error;

    fn try_into(self) -> Result<CdkReceiveOptions, Self::Error> {
        let p2pk_signing_keys = self
            .signing_keys
            .unwrap_or_default()
            .into_iter()
            .map(|s| SecretKey::from_str(&s))
            .collect::<Result<Vec<_>, _>>()?;
        Ok(CdkReceiveOptions {
            p2pk_signing_keys,
            preimages: self.preimages.unwrap_or_default(),
            ..Default::default()
        })
    }
}

#[derive(Default)]
pub struct SendOptions {
    pub pubkey: Option<String>,
    pub include_fee: Option<bool>,
}

impl TryInto<CdkSendOptions> for SendOptions {
    type Error = Error;

    fn try_into(self) -> Result<CdkSendOptions, Self::Error> {
        let pubkey = self.pubkey.map(|s| PublicKey::from_str(&s)).transpose()?;
        Ok(CdkSendOptions {
            conditions: pubkey.map(|pubkey| SpendingConditions::new_p2pk(pubkey, None)),
            include_fee: self.include_fee.unwrap_or_default(),
            ..Default::default()
        })
    }
}

#[derive(PartialEq, Eq)]
pub struct Transaction {
    pub id: String,
    pub mint_url: String,
    pub direction: TransactionDirection,
    pub amount: u64,
    pub fee: u64,
    pub unit: String,
    pub ys: Vec<String>,
    pub timestamp: u64,
    pub memo: Option<String>,
    pub metadata: HashMap<String, String>,
    pub status: TransactionStatus,
}

impl From<CdkTransaction> for Transaction {
    fn from(tx: CdkTransaction) -> Self {
        Self {
            id: tx.id().to_string(),
            mint_url: tx.mint_url.to_string(),
            direction: tx.direction.into(),
            amount: tx.amount.into(),
            fee: tx.fee.into(),
            unit: tx.unit.to_string(),
            ys: tx.ys.iter().map(|y| y.to_string()).collect(),
            timestamp: tx.timestamp,
            memo: tx.memo,
            metadata: tx.metadata,
            status: TransactionStatus::Settled,
        }
    }
}

impl PartialOrd for Transaction {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for Transaction {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.timestamp.cmp(&other.timestamp).reverse()
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum TransactionDirection {
    Incoming,
    Outgoing,
}

impl From<CdkTransactionDirection> for TransactionDirection {
    fn from(direction: CdkTransactionDirection) -> Self {
        match direction {
            CdkTransactionDirection::Incoming => Self::Incoming,
            CdkTransactionDirection::Outgoing => Self::Outgoing,
        }
    }
}

impl Into<CdkTransactionDirection> for TransactionDirection {
    fn into(self) -> CdkTransactionDirection {
        match self {
            Self::Incoming => CdkTransactionDirection::Incoming,
            Self::Outgoing => CdkTransactionDirection::Outgoing,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TransactionStatus {
    Pending,
    Settled,
}

// ========================================================================
// WalletDatabase
// ========================================================================

#[derive(Clone)]
pub struct WalletDatabase {
    pub path: String,
    inner: Arc<WalletSqliteDatabase>,
}

impl WalletDatabase {
    pub async fn new_instance(path: String) -> Result<Self, Error> {
        let inner = WalletSqliteDatabase::new(path.as_str()).await?;
        Ok(Self {
            inner: Arc::new(inner),
            path,
        })
    }

    pub async fn remove_mint(&self, mint_url: &str) -> Result<(), Error> {
        let mint_url = MintUrl::from_str(mint_url)?;
        self.inner.remove_mint(mint_url).await?;
        Ok(())
    }
}
