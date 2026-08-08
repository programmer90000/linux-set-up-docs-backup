use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Deserialize, Serialize)]
pub struct Config {
    pub window: WindowConfig,
    pub theme: ThemeConfig,
    pub text: TextConfig,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct WindowConfig {
    pub width: f32,
    pub height: f32,
    pub resizable: bool,
    pub decorations: bool,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct ThemeConfig {
    pub background_color: String,
    pub background_opacity: f32,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct TextConfig {
    pub color: String,
    pub size: u16,
}

impl Default for Config {
    fn default() -> Self {
        Self {
            window: WindowConfig {
                width: 2000.0,
                height: 200.0,
                resizable: true,
                decorations: true,
            },
            theme: ThemeConfig {
                background_color: "#FFFFFF".to_string(),
                background_opacity: 1.0,
            },
            text: TextConfig {
                color: "#000000".to_string(),
                size: 14,
            },
        }
    }
}

impl Config {
    pub fn load() -> Self {
        let config_paths = Self::get_config_paths();

        for path in config_paths {
            if path.exists() {
                println!("Loading config from: {:?}", path);
                match fs::read_to_string(&path) {
                    Ok(content) => {
                        match toml::from_str::<Config>(&content) {
                            Ok(config) => {
                                println!("Config loaded successfully");
                                println!("Window size: {}x{}", config.window.width, config.window.height);
                                println!("Resizable: {}", config.window.resizable);
                                println!("Decorations: {}", config.window.decorations);
                                println!("Background color: {}", config.theme.background_color);
                                println!("Background opacity: {}", config.theme.background_opacity);
                                println!("Text color: {}", config.text.color);
                                println!("Text size: {}", config.text.size);
                                return config;
                            }
                            Err(e) => {
                                eprintln!("Error parsing config at {:?}: {}", path, e);
                                eprintln!("Using default config instead");
                            }
                        }
                    }
                    Err(e) => {
                        eprintln!("Error reading config at {:?}: {}", path, e);
                    }
                }
            }
        }

        println!("No valid config found, using defaults");
        Config::default()
    }

    fn get_config_paths() -> Vec<PathBuf> {
        let mut paths = Vec::new();

        // 1. User config directory (Linux: ~/.config/window-switcher/config.toml)
        if let Some(config_dir) = dirs::config_dir() {
            paths.push(config_dir.join("window-switcher").join("config.toml"));
        }

        // 2. Current directory
        paths.push(PathBuf::from("config.toml"));

        // 3. Home directory hidden file
        if let Some(home) = dirs::home_dir() {
            paths.push(home.join(".config").join("window-switcher").join("config.toml"));
        }
        
        paths
    }
}
