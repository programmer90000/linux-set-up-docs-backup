use serde::Deserialize;
use std::{collections::HashMap, path::{Path, PathBuf}};

/// Entry of an app list or power menu.
#[derive(Deserialize, Default, Debug, Clone)]
pub struct Item {
    pub label: Option<String>,
    pub icon: Option<String>,    // icon theme name
    pub command: Option<String>, // shell command
    pub desktop: Option<String>, // e.g. "firefox-esr.desktop" (icon + launching for free)
}

/// A `[widget.<name>]` table. Every field is optional.
#[derive(Deserialize, Default, Debug, Clone)]
pub struct WidgetCfg {
    #[serde(rename = "type")]
    pub kind: Option<String>,
    pub icon: Option<String>,
    pub format: Option<String>, // "{icon} {text}"
    /// Long-running command; every stdout line becomes the new state.
    pub stream: Option<String>,
    /// Long-running event source; every stdout line triggers `command`.
    pub watch: Option<String>,
    /// One-shot query; its first stdout line is the new state.
    pub command: Option<String>,
    pub on_click: Option<String>,
    pub on_right_click: Option<String>,
    /// For widgets in `more`: never | always | nonempty | class:<name> | min_length:<px>
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
    /// Connector names ("eDP-1", "HDMI-A-1"). Empty or ["*"] = all monitors.
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
    /// A name in a widget list is either a `[widget.<name>]` table or a bare widget type.
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
            widgets: ["app_list", "clock", "date", "volume", "power"].map(String::from).to_vec(),
            more: vec![],
        });
    }
    c
}
