use std::str::FromStr;

use cdk::{
    nuts::{nut04, nut05, nut06},
    wallet::{HttpClient, MintConnector},
};
use cdk_common::{
    mint_url::MintUrl, ContactInfo as CdkContactInfo, MintInfo as CdkMintInfo,
    MintVersion as CdkMintVersion, Nuts as CdkNuts,
};

use super::error::Error;

// === MintInfo structs ===

pub struct MintInfo {
    pub name: Option<String>,
    pub pubkey: Option<String>,
    pub version: Option<MintVersion>,
    pub description: Option<String>,
    pub description_long: Option<String>,
    pub contact: Option<Vec<ContactInfo>>,
    pub nuts: Nuts,
    pub icon_url: Option<String>,
    pub urls: Option<Vec<String>>,
    pub motd: Option<String>,
    pub time: Option<u64>,
    pub tos_url: Option<String>,
}

impl From<CdkMintInfo> for MintInfo {
    fn from(value: CdkMintInfo) -> Self {
        Self {
            name: value.name,
            pubkey: value.pubkey.map(|p| p.to_string()),
            version: value.version.map(|v| v.into()),
            description: value.description,
            description_long: value.description_long,
            contact: value
                .contact
                .map(|c| c.into_iter().map(|c| c.into()).collect()),
            nuts: value.nuts.into(),
            icon_url: value.icon_url,
            urls: value.urls,
            motd: value.motd,
            time: value.time,
            tos_url: value.tos_url,
        }
    }
}

pub struct MintVersion {
    pub name: String,
    pub version: String,
}

impl From<CdkMintVersion> for MintVersion {
    fn from(value: CdkMintVersion) -> Self {
        Self {
            name: value.name,
            version: value.version,
        }
    }
}

pub struct ContactInfo {
    pub method: String,
    pub info: String,
}

impl From<CdkContactInfo> for ContactInfo {
    fn from(c: CdkContactInfo) -> Self {
        Self {
            method: c.method,
            info: c.info,
        }
    }
}

// === NUT settings ===

pub struct Nuts {
    pub nut04: Nut04Settings,
    pub nut05: Nut05Settings,
    pub nut07: SupportedSettings,
    pub nut08: SupportedSettings,
    pub nut09: SupportedSettings,
    pub nut10: SupportedSettings,
    pub nut11: SupportedSettings,
    pub nut12: SupportedSettings,
    pub nut14: SupportedSettings,
    pub nut20: SupportedSettings,
}

impl From<CdkNuts> for Nuts {
    fn from(value: CdkNuts) -> Self {
        Self {
            nut04: value.nut04.into(),
            nut05: value.nut05.into(),
            nut07: value.nut07.into(),
            nut08: value.nut08.into(),
            nut09: value.nut09.into(),
            nut10: value.nut10.into(),
            nut11: value.nut11.into(),
            nut12: value.nut12.into(),
            nut14: value.nut14.into(),
            nut20: value.nut20.into(),
        }
    }
}

pub struct SupportedSettings {
    pub supported: bool,
}

impl From<nut06::SupportedSettings> for SupportedSettings {
    fn from(value: nut06::SupportedSettings) -> Self {
        Self {
            supported: value.supported,
        }
    }
}

pub struct Nut04Settings {
    pub methods: Vec<MintMethodSettings>,
    pub disabled: bool,
}

impl From<nut04::Settings> for Nut04Settings {
    fn from(value: nut04::Settings) -> Self {
        Self {
            methods: value.methods.into_iter().map(|m| m.into()).collect(),
            disabled: value.disabled,
        }
    }
}

pub struct MintMethodSettings {
    pub method: String,
    pub unit: String,
    pub min_amount: Option<u64>,
    pub max_amount: Option<u64>,
}

impl From<nut04::MintMethodSettings> for MintMethodSettings {
    fn from(value: nut04::MintMethodSettings) -> Self {
        Self {
            method: value.method.to_string(),
            unit: value.unit.to_string(),
            min_amount: value.min_amount.map(|v| v.into()),
            max_amount: value.max_amount.map(|v| v.into()),
        }
    }
}

pub struct Nut05Settings {
    pub methods: Vec<MeltMethodSettings>,
    pub disabled: bool,
}

impl From<nut05::Settings> for Nut05Settings {
    fn from(value: nut05::Settings) -> Self {
        Self {
            methods: value.methods.into_iter().map(|m| m.into()).collect(),
            disabled: value.disabled,
        }
    }
}

pub struct MeltMethodSettings {
    pub method: String,
    pub unit: String,
    pub min_amount: Option<u64>,
    pub max_amount: Option<u64>,
}

impl From<nut05::MeltMethodSettings> for MeltMethodSettings {
    fn from(value: nut05::MeltMethodSettings) -> Self {
        Self {
            method: value.method.to_string(),
            unit: value.unit.to_string(),
            min_amount: value.min_amount.map(|v| v.into()),
            max_amount: value.max_amount.map(|v| v.into()),
        }
    }
}

// === API functions ===

/// Fetch full mint info from a mint URL
pub async fn get_mint_info(mint_url: &str) -> Result<MintInfo, Error> {
    let mint_url = MintUrl::from_str(mint_url)?;
    let client = HttpClient::new(mint_url, None);
    Ok(client.get_mint_info().await?.into())
}

/// Ping a mint to check if it's reachable (replaces Dart HTTP call)
pub async fn ping_mint(mint_url: &str) -> Result<bool, Error> {
    let url = format!("{}/v1/info", mint_url.trim_end_matches('/'));
    let resp = reqwest::Client::new()
        .get(&url)
        .timeout(std::time::Duration::from_secs(3))
        .send()
        .await;
    match resp {
        Ok(r) => Ok(r.status().is_success()),
        Err(_) => Ok(false),
    }
}

/// Keyset info returned by fetch_keysets
pub struct KeysetInfo {
    pub id: String,
    pub unit: String,
    pub active: bool,
}

/// Fetch keysets from a mint (replaces Dart HTTP call)
pub async fn fetch_keysets(mint_url: &str) -> Result<Vec<KeysetInfo>, Error> {
    let url = format!("{}/v1/keysets", mint_url.trim_end_matches('/'));
    let resp = reqwest::Client::new()
        .get(&url)
        .timeout(std::time::Duration::from_secs(5))
        .send()
        .await?
        .text()
        .await?;

    let data: serde_json::Value = serde_json::from_str(&resp)?;
    let keysets = data["keysets"]
        .as_array()
        .ok_or(Error::InvalidInput)?
        .iter()
        .filter_map(|ks| {
            Some(KeysetInfo {
                id: ks["id"].as_str()?.to_string(),
                unit: ks["unit"].as_str()?.to_string(),
                active: ks["active"].as_bool().unwrap_or(false),
            })
        })
        .collect();
    Ok(keysets)
}
