use std::str::FromStr;

use cdk::{
    amount::Amount,
    nuts::{
        PaymentRequest as CdkPaymentRequest, TransportType as CdkTransportType,
    },
};
use flutter_rust_bridge::frb;

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

    let mints: Vec<String> = match &pr.mints {
        Some(list) => {
            let mut v = Vec::new();
            for m in list {
                v.push(format!("{}", m));
            }
            v
        }
        None => Vec::new(),
    };
    let mut transports = Vec::new();
    for t in &pr.transports {
        transports.push(TransportInfo {
            transport_type: match t._type {
                CdkTransportType::Nostr => "nostr".into(),
                CdkTransportType::HttpPost => "post".into(),
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
fn extract_creq_from_uri(input: &str) -> Option<String> {
    let lower = input.to_lowercase();
    if !lower.starts_with("bitcoin:") {
        return None;
    }
    let query = input.splitn(2, '?').nth(1)?;
    for param in query.split('&') {
        if param.len() > 5 && param[..5].eq_ignore_ascii_case("creq=") {
            return Some(param[5..].to_string());
        }
    }
    None
}

// ========================================================================
// Payment execution
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
