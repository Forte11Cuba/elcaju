use std::{
    str::FromStr,
    sync::{Arc, RwLock},
};

use bc_ur::{prelude::CBOR, MultipartDecoder, MultipartEncoder, UR};
use cdk::nuts::Token as CdkToken;
use cdk_common::{KeySetInfo, Proofs};
use flutter_rust_bridge::frb;

use super::error::Error;

pub struct Token {
    pub encoded: String,
    pub raw: Option<Vec<u8>>,
    pub amount: u64,
    pub mint_url: String,
}

impl Token {
    #[frb(sync)]
    pub fn parse(encoded: &str) -> Result<Self, Error> {
        let encoded = encoded.strip_prefix("cashu:").unwrap_or(encoded);
        let token = CdkToken::from_str(encoded)?;
        Token::try_from(token)
    }

    #[frb(sync)]
    pub fn from_raw_bytes(raw: Vec<u8>) -> Result<Self, Error> {
        let token = CdkToken::try_from(&raw)?;
        Token::try_from(token)
    }

    pub(crate) fn proofs(&self, mint_keysets: &[KeySetInfo]) -> Result<Proofs, Error> {
        let token: CdkToken = self.try_into()?;
        Ok(token.proofs(mint_keysets)?)
    }
}

impl std::fmt::Display for Token {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.encoded)
    }
}

impl FromStr for Token {
    type Err = Error;

    fn from_str(s: &str) -> Result<Self, Error> {
        Token::parse(s)
    }
}

impl TryFrom<CdkToken> for Token {
    type Error = Error;

    fn try_from(token: CdkToken) -> Result<Self, Error> {
        match token {
            CdkToken::TokenV3(token_v3) => Ok(Token {
                encoded: token_v3.to_string(),
                raw: None,
                amount: token_v3.value()?.into(),
                mint_url: token_v3.mint_urls().first().unwrap().to_string(),
            }),
            CdkToken::TokenV4(token_v4) => Ok(Token {
                encoded: token_v4.to_string(),
                raw: Some(token_v4.to_raw_bytes()?),
                amount: token_v4.value()?.into(),
                mint_url: token_v4.mint_url.to_string(),
            }),
        }
    }
}

impl TryInto<CdkToken> for Token {
    type Error = Error;

    fn try_into(self) -> Result<CdkToken, Error> {
        Ok(CdkToken::from_str(&self.encoded)?)
    }
}

impl TryInto<CdkToken> for &Token {
    type Error = Error;

    fn try_into(self) -> Result<CdkToken, Error> {
        Ok(CdkToken::from_str(&self.encoded)?)
    }
}

// === QR Multiframe (bc-ur) ===

pub struct TokenDecoder {
    decoder: Arc<RwLock<MultipartDecoder>>,
}

impl TokenDecoder {
    #[frb(sync)]
    pub fn new() -> Self {
        Self {
            decoder: Arc::new(RwLock::new(MultipartDecoder::default())),
        }
    }

    #[frb(sync)]
    pub fn is_complete(&self) -> bool {
        let decoder = self.decoder.read().expect("Lock poisoned");
        decoder.is_complete()
    }

    #[frb(sync)]
    pub fn receive(&self, input: String) -> Result<(), Error> {
        let mut decoder = self.decoder.write().expect("Lock poisoned");
        decoder.receive(&input)?;
        Ok(())
    }

    #[frb(sync)]
    pub fn value(&self) -> Result<Option<Token>, Error> {
        let decoder = self.decoder.read().expect("Lock poisoned");
        let ur = decoder.message()?;
        match ur {
            Some(ur) => {
                let bytes = ur
                    .cbor()
                    .try_byte_string()
                    .map_err(|e| Error::Ur(format!("Failed to decode CBOR byte string: {}", e)))?;
                let utf8_encoded = String::from_utf8(bytes)?;
                let token = Token::from_str(&utf8_encoded)?;
                Ok(Some(token))
            }
            None => Ok(None),
        }
    }
}

#[frb(sync)]
pub fn encode_qr_token(
    token: &Token,
    max_fragment_length: Option<usize>,
) -> Result<Vec<String>, Error> {
    let ur = UR::new("", CBOR::to_byte_string(&token.encoded))?;
    let mut encoder = MultipartEncoder::new(&ur, max_fragment_length.unwrap_or(150))?;
    let mut parts = Vec::new();
    for _ in 0..encoder.parts_count() {
        if let Ok(part) = encoder.next_part() {
            parts.push(part);
        }
    }
    Ok(parts)
}
