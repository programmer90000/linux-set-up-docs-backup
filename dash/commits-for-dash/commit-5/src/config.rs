use serde::Deserialize;
use std::{collections::HashMap, path::{Path, PathBuf}};

#[derive(Deserialize, Default, Debug, Clone)]
pub struct Item {
    pub label: Option<String>,
    pub icon: Option<String>,
    pub command: Option<String>,
    pub desktop: Option<String>,
}

#[derive(Deserialize, Default, Debug, Clone)]
pub struct WidgetCfg {
    #[serde(rename = "type")]
    pub kind: Option<String>,
    pub icon: Option<String>,
    pub format: Option<String>,
    pub stream: Option<String>,
    pub watch: Option<String>,
    pub command: Option<String>,
    pub on_click: Option<String>,
    pub on_right_click: Option<String>,
    pub show_on_dash: Option<String>,
    #[serde(default)]
    pub items: Vec<Item>,
}

#[derive(Deserialize, Debug, Clone)]
pub struct PanelCfg {
    #[serde(default = "d_pos")]
    pub position: String,
    #[serde(default = "d_size")]
    pub size: i32,
    #[serde(default = "d_spacing")]
    pub spacing: i32,
    #[serde(default)]
    pub monitors: Vec<String>,
    #[serde(default)]
    pub widgets: Vec<String>,
    #[serde(default)]
    pub more: Vec<String>,
}
fn d_pos() -> String { "top".into() }
fn d_size() -> i32 { 36 }
fn d_spacing() -> i32 { 4 }

#[derive(Deserialize, Default, Debug, Clone)]
pub struct Config {
    #[serde(default)]
    pub widget: HashMap<String, WidgetCfg>,
    #[serde(default)]
    pub panel: Vec<PanelCfg>,
}

impl Config {
    pub fn resolve(&self, name: &str) -> (String, WidgetCfg) {
        match self.widget.get(name) {
            Some(w) => (w.kind.clone().unwrap_or_else(|| name.to_string()), w.clone()),
            None => (name.to_string(), WidgetCfg::default()),
        }
    }
}

pub fn default_path() -> PathBuf {
    let base = std::env::var_os("XDG_CONFIG_HOME")
        .map(PathBuf::from)
        .or_else(|| std::env::var_os("HOME").map(|h| PathBuf::from(h).join(".config")))
        .unwrap_or_default();
    base.join("dash/config.toml")
}

pub fn load(path: &Path) -> Config {
    let mut c: Config = match std::fs::read_to_string(path) {
        Ok(s) => toml::from_str(&s).unwrap_or_else(|e| {
            eprintln!("dash: config error in {}: {e}", path.display());
            std::process::exit(1)
        }),
        Err(_) => {
            eprintln!("dash: no config at {}, using defaults", path.display());
            Config::default()
        }
    };
    if c.panel.is_empty() {
        c.panel.push(PanelCfg {
            position: d_pos(), size: d_size(), spacing: d_spacing(), monitors: vec![],
            widgets: vec!["date".into(), "clock".into()],
            more: vec![],
        });
    }
    c
}