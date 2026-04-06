use std::str::FromStr;

use cdk::{
    amount::Amount,
    mint_url::MintUrl,
    nuts::{
        CurrencyUnit, PaymentRequest as CdkPaymentRequest, Transport, TransportType,
    },
    wallet::ReceiveOptions as CdkReceiveOptions,
};
use flutter_rust_bridge::frb;
use nostr_sdk::{
    nips::nip19::{Nip19Profile, ToBech32},
    Keys as NostrKeys, PublicKey, RelayUrl,
};

use crate::frb_generated::StreamSink;

use super::{error::Error, wallet::Wallet};

// ========================================================================
// Payment Request parsing (NUT-18 creqA + NUT-26 creqB)
// ========================================================================

/// Parsed payment request info exposed to Flutter.
/// CDK's FromStr auto-detects creqA (CBOR) vs creqB (Bech32m).
pub struct PaymentRequestInfo {
    /// Raw encoded string (creqA... or CREQB1...)
    pub raw: String,
    /// Payment id
    pub payment_id: Option<String>,
    /// Requested amount (in base unit)
    pub amount: Option<u64>,
    /// Currency unit ("sat", "usd", etc.)
    pub unit: Option<String>,
    /// Whether this is a single-use request
    pub single_use: Option<bool>,
    /// Accepted mints (empty = any mint)
    pub mints: Vec<String>,
    /// Human-readable description
    pub description: Option<String>,
    /// Available transports
    pub transports: Vec<TransportInfo>,
    /// Whether NUT-10 spending conditions are required
    pub has_nut10: bool,
}

/// Transport info exposed to Flutter
pub struct TransportInfo {
    /// "nostr" or "post"
    pub transport_type: String,
    /// Target (nprofile or URL)
    pub target: String,
}

impl PaymentRequestInfo {
    /// Parse a payment request string (creqA, CREQB1, or bitcoin:?creq=).
    /// Supports NUT-18 (CBOR+base64) and NUT-26 (Bech32m) automatically.
    #[frb(sync)]
    pub fn parse(encoded: String) -> Result<PaymentRequestInfo, Error> {
        parse_payment_request_inner(encoded)
    }
}

/// Inner parsing logic, outside of frb macro scope to avoid iterator issues.
fn parse_payment_request_inner(encoded: String) -> Result<PaymentRequestInfo, Error> {
    let creq_str = extract_creq_from_uri(&encoded).unwrap_or(encoded);

    let pr = CdkPaymentRequest::from_str(&creq_str)
        .map_err(|e| Error::Cdk(format!("Invalid payment request: {e}")))?;

    let mints: Vec<String> = {
        let mut v = Vec::new();
        for m in &pr.mints {
            v.push(format!("{}", m));
        }
        v
    };
    let mut transports = Vec::new();
    for t in &pr.transports {
        transports.push(TransportInfo {
            transport_type: match t._type {
                TransportType::Nostr => "nostr".into(),
                TransportType::HttpPost => "post".into(),
            },
            target: t.target.clone(),
        });
    }
    let has_nut10 = pr.nut10.is_some();

    Ok(PaymentRequestInfo {
        raw: creq_str,
        payment_id: pr.payment_id,
        amount: pr.amount.map(|a| a.into()),
        unit: pr.unit.map(|u| format!("{}", u)),
        single_use: pr.single_use,
        mints,
        description: pr.description,
        transports,
        has_nut10,
    })
}

/// Extract creq parameter from a BIP-321 bitcoin: URI.
/// e.g. "bitcoin:?creq=CREQB1...&lightning=lnbc..." → "CREQB1..."
/// Handles percent-encoding and case-insensitive key matching.
fn extract_creq_from_uri(input: &str) -> Option<String> {
    if !input
        .get(..8)
        .is_some_and(|scheme| scheme.eq_ignore_ascii_case("bitcoin:"))
    {
        return None;
    }
    let query = input.split_once('?')?.1;
    for param in query.split('&') {
        let (key, value) = param.split_once('=')?;
        if key.eq_ignore_ascii_case("creq") {
            return Some(percent_decode(value));
        }
    }
    None
}

/// Simple percent-decoding for URI query values.
fn percent_decode(value: &str) -> String {
    let bytes = value.as_bytes();
    let mut out = Vec::with_capacity(bytes.len());
    let mut i = 0;
    while i < bytes.len() {
        if bytes[i] == b'%' && i + 2 < bytes.len() {
            if let Ok(byte) = u8::from_str_radix(
                std::str::from_utf8(&bytes[i + 1..i + 3]).unwrap_or(""),
                16,
            ) {
                out.push(byte);
                i += 3;
                continue;
            }
        }
        out.push(bytes[i]);
        i += 1;
    }
    String::from_utf8(out).unwrap_or_else(|_| value.to_string())
}

// ========================================================================
// Payment execution (payer side)
// ========================================================================

impl Wallet {
    /// Pay a NUT-18 payment request.
    /// Uses CDK's pay_request() which handles:
    /// - NUT-10 spending conditions
    /// - Transport selection (Nostr preferred, HTTP POST fallback)
    /// - Token preparation and delivery
    pub async fn pay_payment_request(
        &self,
        encoded: String,
        custom_amount: Option<u64>,
    ) -> Result<(), Error> {
        let creq_str = extract_creq_from_uri(&encoded).unwrap_or(encoded);

        let pr = CdkPaymentRequest::from_str(&creq_str)
            .map_err(|e| Error::Cdk(format!("Invalid payment request: {e}")))?;

        self.inner
            .pay_request(pr, custom_amount.map(Amount::from))
            .await?;

        self.update_balance_streams().await;
        Ok(())
    }
}

// ========================================================================
// Payment Request creation (payee/receiver side) — NUT-18/26
// ========================================================================

/// Parameters for creating a payment request.
pub struct CreateRequestParams {
    /// Amount to request (in smallest unit, e.g. sats)
    pub amount: Option<u64>,
    /// Currency unit ("sat", "usd", etc.)
    pub unit: String,
    /// Human-readable description
    pub description: Option<String>,
    /// Nostr relay URLs for the transport
    pub nostr_relays: Vec<String>,
}

/// Result of creating a payment request.
pub struct CreatedPaymentRequest {
    /// NUT-18 encoding: creqA... (CBOR+base64url)
    pub creq_a: String,
    /// NUT-26 encoding: CREQB1... (Bech32m, uppercase for QR)
    pub creq_b: String,
    /// Opaque handle holding the ephemeral Nostr keys — pass to wait_for_nostr_payment().
    /// The secret key never leaves Rust.
    pub listener_handle: NostrListenerHandle,
}

/// Opaque handle that keeps Nostr ephemeral keys in Rust memory.
/// Dart receives this as an opaque reference and passes it back
/// to wait_for_nostr_payment() without ever seeing the secret key.
/// Also carries the expected payment parameters for validation.
#[derive(Clone)]
pub struct NostrListenerHandle {
    keys: NostrKeys,
    pubkey: PublicKey,
    relays: Vec<String>,
    /// Expected amount (None = any amount accepted)
    expected_amount: Option<Amount>,
    /// Expected currency unit
    expected_unit: CurrencyUnit,
    /// This wallet's mint URL
    mint_url: MintUrl,
}

/// Serializable data for persisting a NostrListenerHandle across app restarts.
pub struct PersistedRequestData {
    pub secret_hex: String,
    pub pubkey_hex: String,
    pub relays: Vec<String>,
    pub amount: Option<u64>,
    pub unit: String,
    pub mint_url: String,
}

impl NostrListenerHandle {
    /// Export handle data for persistence (e.g. SharedPreferences).
    /// The secret key is exposed as hex — the caller is responsible
    /// for storing it securely.
    #[frb(sync)]
    pub fn to_persisted(&self) -> PersistedRequestData {
        PersistedRequestData {
            secret_hex: self.keys.secret_key().to_secret_hex(),
            pubkey_hex: self.pubkey.to_hex(),
            relays: self.relays.clone(),
            amount: self.expected_amount.map(|a| a.into()),
            unit: self.expected_unit.to_string(),
            mint_url: self.mint_url.to_string(),
        }
    }

    /// Reconstruct a handle from persisted data (e.g. after app restart).
    #[frb(sync)]
    pub fn from_persisted(data: PersistedRequestData) -> Result<NostrListenerHandle, Error> {
        let secret_key = nostr_sdk::SecretKey::from_hex(&data.secret_hex)
            .map_err(|e| Error::Cdk(format!("Invalid persisted secret key: {e}")))?;
        let keys = NostrKeys::new(secret_key);
        // Derive pubkey from secret — don't trust the persisted copy
        let pubkey = keys.public_key;
        let unit = CurrencyUnit::from_str(&data.unit)
            .unwrap_or(CurrencyUnit::Custom(data.unit));
        let mint_url = MintUrl::from_str(&data.mint_url)
            .map_err(|e| Error::Cdk(format!("Invalid persisted mint URL: {e}")))?;

        Ok(NostrListenerHandle {
            keys,
            pubkey,
            relays: data.relays,
            expected_amount: data.amount.map(Amount::from),
            expected_unit: unit,
            mint_url,
        })
    }
}

/// State of a Nostr payment listener.
pub enum NostrPaymentState {
    /// Connected to relays, waiting for payment
    Waiting,
    /// Payment received and tokens claimed
    Received,
    /// Error occurred
    Error,
}

/// Event emitted by the Nostr payment listener.
pub struct NostrPaymentEvent {
    pub state: NostrPaymentState,
    pub amount: Option<u64>,
    pub error: Option<String>,
}

impl Wallet {
    /// Create a NUT-18 payment request with Nostr transport.
    ///
    /// Builds a PaymentRequest with the wallet's mint URL and unit,
    /// generates ephemeral Nostr keys, and returns both creqA and creqB
    /// encodings plus the keys needed for the Nostr listener.
    pub async fn create_payment_request(
        &self,
        params: CreateRequestParams,
    ) -> Result<CreatedPaymentRequest, Error> {
        // Generate ephemeral Nostr keys for this request
        let keys = NostrKeys::generate();

        // Parse relay URLs for nprofile
        if params.nostr_relays.is_empty() {
            return Err(Error::InvalidInput);
        }

        let relay_urls: Vec<RelayUrl> = params
            .nostr_relays
            .iter()
            .map(|r| RelayUrl::parse(r))
            .collect::<Result<Vec<_>, _>>()
            .map_err(|e| Error::Cdk(format!("Invalid relay URL: {e}")))?;

        let nprofile = Nip19Profile::new(keys.public_key, relay_urls);
        let nprofile_bech32 = nprofile
            .to_bech32()
            .map_err(|e| Error::Cdk(format!("nprofile encoding failed: {e}")))?;

        // Build the Nostr transport
        let nostr_transport = Transport {
            _type: TransportType::Nostr,
            target: nprofile_bech32,
            tags: vec![vec!["n".to_string(), "17".to_string()]],
        };

        // Build the PaymentRequest with this wallet's mint and unit
        let mint_url = self.mint_url()?;
        if params.unit != self.unit {
            return Err(Error::InvalidInput);
        }
        let unit = CurrencyUnit::from_str(&self.unit)
            .unwrap_or(CurrencyUnit::Custom(self.unit.clone()));

        let pr = CdkPaymentRequest {
            payment_id: None,
            amount: params.amount.map(Amount::from),
            unit: Some(unit.clone()),
            single_use: Some(true),
            mints: vec![mint_url.clone()],
            description: params.description,
            transports: vec![nostr_transport],
            nut10: None,
        };

        // Encode both formats
        let creq_a = pr.to_string(); // NUT-18: creqA...
        let creq_b = pr
            .to_bech32_string()
            .map_err(|e| Error::Cdk(format!("Bech32m encoding failed: {e}")))?;

        let pubkey = keys.public_key;
        Ok(CreatedPaymentRequest {
            creq_a,
            creq_b,
            listener_handle: NostrListenerHandle {
                keys,
                pubkey,
                relays: params.nostr_relays,
                expected_amount: params.amount.map(Amount::from),
                expected_unit: unit,
                mint_url,
            },
        })
    }

    /// Wait for an incoming Nostr payment (NIP-17 gift-wrap).
    ///
    /// Takes the opaque NostrListenerHandle returned by create_payment_request().
    /// The secret key never leaves Rust memory.
    pub async fn wait_for_nostr_payment(
        &self,
        handle: NostrListenerHandle,
        sink: StreamSink<NostrPaymentEvent>,
    ) -> Result<(), Error> {
        let NostrListenerHandle {
            keys,
            pubkey,
            relays,
            expected_amount,
            expected_unit,
            mint_url,
        } = handle;

        // Fail fast if the handle was created for a different wallet
        let current_mint = self.mint_url()?;
        let current_unit = CurrencyUnit::from_str(&self.unit)
            .unwrap_or(CurrencyUnit::Custom(self.unit.clone()));
        if mint_url != current_mint || expected_unit != current_unit {
            return Err(Error::InvalidInput);
        }

        if sink
            .add(NostrPaymentEvent {
                state: NostrPaymentState::Waiting,
                amount: None,
                error: None,
            })
            .is_err()
        {
            return Ok(());
        }

        let _self = self.clone();
        flutter_rust_bridge::spawn(async move {
            match wait_for_nostr_payment_inner(
                &_self, keys, pubkey, relays, expected_amount, expected_unit, mint_url, &sink,
            )
            .await
            {
                Ok(amount) => {
                    let _ = sink.add(NostrPaymentEvent {
                        state: NostrPaymentState::Received,
                        amount: Some(amount.into()),
                        error: None,
                    });
                    _self.update_balance_streams().await;
                }
                Err(e) => {
                    let _ = sink.add(NostrPaymentEvent {
                        state: NostrPaymentState::Error,
                        amount: None,
                        error: Some(e.to_string()),
                    });
                }
            }
        });

        Ok(())
    }
}

/// Internal: connect to relays, listen for gift-wrapped payment, receive tokens.
/// Validates incoming payments against expected amount/unit/mint before accepting.
/// Periodically checks if the Dart stream is still alive and disconnects if not.
#[allow(clippy::too_many_arguments)]
async fn wait_for_nostr_payment_inner(
    wallet: &Wallet,
    keys: NostrKeys,
    pubkey: PublicKey,
    relays: Vec<String>,
    expected_amount: Option<Amount>,
    expected_unit: CurrencyUnit,
    expected_mint: MintUrl,
    sink: &StreamSink<NostrPaymentEvent>,
) -> Result<Amount, Error> {
    use cdk::nuts::{nut00::ProofsMethods, PaymentRequestPayload, Token as CdkToken};
    use nostr_sdk::{Client, Filter, Kind};
    use std::time::Duration;

    // Create Nostr client with ephemeral keys
    let client = Client::new(keys.clone());
    for relay in &relays {
        client
            .add_read_relay(relay)
            .await
            .map_err(|e| Error::Cdk(format!("Failed to add relay {relay}: {e}")))?;
    }

    // Connect with timeout so we fail fast if relays are unreachable
    tokio::time::timeout(Duration::from_secs(10), client.connect())
        .await
        .map_err(|_| Error::Network("Relay connection timed out".to_string()))?;

    // Create the broadcast receiver BEFORE subscribing so we capture historical
    // events the relay sends back in response to our subscription filter.
    // (broadcast::Receiver only sees messages sent after its creation)
    let mut notifications = client.notifications();

    // Subscribe to NIP-17 gift-wrap events (kind 1059) addressed to our ephemeral pubkey
    let filter = Filter::new().pubkey(pubkey).kind(Kind::GiftWrap);
    client
        .subscribe(filter, None)
        .await
        .map_err(|e| Error::Cdk(format!("Subscription failed: {e}")))?;
    loop {
        match tokio::time::timeout(Duration::from_secs(1), notifications.recv()).await {
            Ok(Ok(notification)) => {
                // Check sink is alive before processing
                if sink
                    .add(NostrPaymentEvent {
                        state: NostrPaymentState::Waiting,
                        amount: None,
                        error: None,
                    })
                    .is_err()
                {
                    client.disconnect().await;
                    return Err(Error::Network("Listener cancelled by client".to_string()));
                }

                if let nostr_sdk::RelayPoolNotification::Event { event, .. } = notification {
                    // Try to unwrap NIP-17 gift-wrap
                    let unwrapped = match client.unwrap_gift_wrap(&event).await {
                        Ok(rumor) => rumor,
                        Err(_) => continue,
                    };

                    // Parse PaymentRequestPayload from the rumor content
                    let payload: PaymentRequestPayload =
                        match serde_json::from_str(&unwrapped.rumor.content) {
                            Ok(p) => p,
                            Err(_) => continue,
                        };

                    // Validate unit matches
                    if payload.unit != expected_unit {
                        log::warn!(
                            "Ignoring payment: unit mismatch (expected {}, got {})",
                            expected_unit,
                            payload.unit
                        );
                        continue;
                    }

                    // Validate mint matches
                    if payload.mint != expected_mint {
                        log::warn!(
                            "Ignoring payment: mint mismatch (expected {}, got {})",
                            expected_mint,
                            payload.mint
                        );
                        continue;
                    }

                    // Validate amount if a specific amount was requested
                    if let Some(expected) = expected_amount {
                        let received_amount = payload.proofs.total_amount().unwrap_or_default();
                        if received_amount < expected {
                            log::warn!(
                                "Ignoring payment: underpayment (expected {}, got {})",
                                expected,
                                received_amount
                            );
                            continue;
                        }
                    }

                    // Build a token from the validated payload and receive it
                    let token = CdkToken::new(
                        payload.mint,
                        payload.proofs,
                        payload.memo,
                        payload.unit,
                    );
                    let token_str = token.to_string();

                    // Continue listening on receive errors (e.g. already-spent proofs)
                    match wallet
                        .inner
                        .receive(&token_str, CdkReceiveOptions::default())
                        .await
                    {
                        Ok(received) => {
                            client.disconnect().await;
                            return Ok(received);
                        }
                        Err(e) => {
                            log::warn!("Failed to receive token, continuing: {e}");
                            continue;
                        }
                    }
                }
            }
            Ok(Err(_)) => {
                // Notification channel closed
                break;
            }
            Err(_) => {
                // Timeout — check if the Dart stream is still alive
                if sink
                    .add(NostrPaymentEvent {
                        state: NostrPaymentState::Waiting,
                        amount: None,
                        error: None,
                    })
                    .is_err()
                {
                    // Dart side cancelled the stream, clean up
                    client.disconnect().await;
                    return Err(Error::Network("Listener cancelled by client".to_string()));
                }
            }
        }
    }

    client.disconnect().await;
    Err(Error::Network(
        "Nostr listener ended before a payment was received".to_string(),
    ))
}
