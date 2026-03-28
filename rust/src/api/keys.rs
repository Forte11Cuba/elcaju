use std::str::FromStr;

use bip39::Mnemonic;
use cdk_common::SecretKey;
use flutter_rust_bridge::frb;

use super::error::Error;

/// Generate a new 12-word BIP39 mnemonic
#[frb(sync)]
pub fn generate_mnemonic() -> Result<String, Error> {
    let mut entropy = [0u8; 16]; // 128 bits → 12 words
    getrandom::fill(&mut entropy).map_err(|_| Error::InvalidInput)?;
    let mnemonic = Mnemonic::from_entropy(&entropy).map_err(|_| Error::InvalidInput)?;
    Ok(mnemonic.to_string())
}

/// Convert a mnemonic to a 64-byte seed
#[frb(sync)]
pub fn mnemonic_to_seed(mnemonic: String) -> Result<Vec<u8>, Error> {
    let mnemonic = Mnemonic::parse(&mnemonic).map_err(|_| Error::InvalidInput)?;
    Ok(mnemonic.to_seed("").to_vec())
}

/// Derive the public key (hex) from a secret key (hex)
#[frb(sync)]
pub fn get_pub_key(secret: String) -> Result<String, Error> {
    let secret = SecretKey::from_str(&secret)?;
    let pub_key = secret.public_key();
    Ok(pub_key.to_string())
}
