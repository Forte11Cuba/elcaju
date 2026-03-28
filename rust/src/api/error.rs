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
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::Cdk(msg) => write!(f, "Cashu error: {msg}"),
            Error::Database(msg) => write!(f, "Database error: {msg}"),
            Error::InvalidInput => write!(f, "Invalid input"),
            Error::Network(msg) => write!(f, "Network error: {msg}"),
        }
    }
}

impl std::error::Error for Error {}

impl From<cdk::error::Error> for Error {
    fn from(e: cdk::error::Error) -> Self {
        Error::Cdk(e.to_string())
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
