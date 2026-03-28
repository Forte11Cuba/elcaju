use std::fmt;

/// Errores unificados de elcaju_core
#[derive(Debug)]
pub enum Error {
    /// Error del protocolo Cashu (cdk)
    Cdk(String),
    /// Error de base de datos (SQLite)
    Database(String),
    /// Input inválido del usuario
    InvalidInput,
    /// Error de red (HTTP, conexión)
    Network(String),
    /// Error de UR (QR multiframe)
    Ur(String),
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::Cdk(msg) => write!(f, "Cashu error: {msg}"),
            Error::Database(msg) => write!(f, "Database error: {msg}"),
            Error::InvalidInput => write!(f, "Invalid input"),
            Error::Network(msg) => write!(f, "Network error: {msg}"),
            Error::Ur(msg) => write!(f, "UR error: {msg}"),
        }
    }
}

impl std::error::Error for Error {}

// --- cdk errors ---

impl From<cdk::error::Error> for Error {
    fn from(e: cdk::error::Error) -> Self {
        Error::Cdk(e.to_string())
    }
}

impl From<cdk::amount::Error> for Error {
    fn from(e: cdk::amount::Error) -> Self {
        Error::Cdk(e.to_string())
    }
}

impl From<cdk::cdk_database::Error> for Error {
    fn from(e: cdk::cdk_database::Error) -> Self {
        Error::Database(e.to_string())
    }
}

impl From<cdk::mint_url::Error> for Error {
    fn from(e: cdk::mint_url::Error) -> Self {
        Error::Network(e.to_string())
    }
}

impl From<cdk::nuts::nut00::Error> for Error {
    fn from(e: cdk::nuts::nut00::Error) -> Self {
        Error::Cdk(e.to_string())
    }
}

impl From<cdk::nuts::nut01::Error> for Error {
    fn from(e: cdk::nuts::nut01::Error) -> Self {
        Error::Cdk(e.to_string())
    }
}

impl From<cdk::nuts::nut11::Error> for Error {
    fn from(e: cdk::nuts::nut11::Error) -> Self {
        Error::Cdk(e.to_string())
    }
}

// --- external errors ---

impl From<bc_ur::Error> for Error {
    fn from(e: bc_ur::Error) -> Self {
        Error::Ur(e.to_string())
    }
}

impl From<reqwest::Error> for Error {
    fn from(e: reqwest::Error) -> Self {
        Error::Network(e.to_string())
    }
}

impl From<serde_json::Error> for Error {
    fn from(e: serde_json::Error) -> Self {
        Error::Cdk(e.to_string())
    }
}

impl From<std::string::FromUtf8Error> for Error {
    fn from(e: std::string::FromUtf8Error) -> Self {
        Error::Cdk(e.to_string())
    }
}
