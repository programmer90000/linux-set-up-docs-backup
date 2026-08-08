mod config;

use iced::widget::{button, Column, scrollable, text, Row};
use iced::{Element, Length, Task, Size};
use iced::window;
use std::collections::HashMap;
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

use config::Config;

use iced::{Color, Theme};
use std::sync::Arc;

pub fn theme(bg_hex: &str, bg_opacity: f32) -> Theme {
    let mut color = Color::parse(bg_hex).unwrap_or_else(|| {
        Color::from_rgb(1.00, 1.00, 1.00)
    });
    
    color.a = bg_opacity.clamp(0.0, 1.0);
    
    let palette = iced::theme::Palette {
        background: color,
        ..Theme::default().palette()
    };
    
    let theme = iced::theme::Custom::new("theme".to_string(), palette);
    Theme::Custom(Arc::new(theme))
}

pub fn main() -> iced::Result {
    let config = Config::load();
    let width = config.window.width;
    let height = config.window.height;
    let decorations = config.window.decorations;
    let bg_color = config.theme.background_color.clone();
    let bg_opacity = config.theme.background_opacity;
    let text_color = config.text.color.clone();
    let text_size = config.text.size;
    
    let bg_color_for_theme = bg_color.clone();
    let bg_color_for_state = bg_color.clone();
    let text_color_for_state = text_color.clone();
    
    iced::application("LabWC Window Switcher", WindowSwitcher::update, WindowSwitcher::view).window(iced::window::Settings { size: iced::Size::new(width, height), decorations: decorations, position: iced::window::Position::Centered, transparent: true, ..Default::default()}).theme(move |_state| theme(&bg_color_for_theme, bg_opacity)).run_with(move || {(WindowSwitcher::new(bg_color_for_state, bg_opacity, text_color_for_state, text_size), Task::none())})
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum SortOrder {
    Alphabetical,
    NewestFirst,
    OldestFirst,
}

impl Default for SortOrder {
    fn default() -> Self {
        Self::Alphabetical
    }
}

#[derive(Debug, Clone)]
struct WindowInfo {
    app_id: String,
    title: String,
    timestamp: u64,
}

#[derive(Debug, Clone)]
struct AppGroup {
    app_id: String,
    windows: Vec<WindowInfo>,
}

#[derive(Debug, Clone)]
enum Message {
    Refresh,
    SelectWindow(usize, usize),
    ChangeSortOrder(SortOrder),
}

struct WindowSwitcher {
    app_groups: Vec<AppGroup>,
    sort_order: SortOrder,
    error_message: Option<String>,
    loading: bool,
    background_color: String,
    background_opacity: f32,
    text_color: String,
    text_size: u16,
}

impl WindowSwitcher {
    fn new(background_color: String, background_opacity: f32, text_color: String, text_size: u16) -> Self {
        let mut switcher = Self {
            app_groups: Vec::new(),
            sort_order: SortOrder::default(),
            error_message: None,
            loading: true,
            background_color,
            background_opacity,
            text_color,
            text_size,
        };
        switcher.load_windows();
        switcher
    }
    
    fn load_windows(&mut self) {
        self.loading = true;
        self.error_message = None;
        
        let output = Command::new("wlrctl")
            .arg("window")
            .arg("list")
            .output();
        
        match output {
            Ok(output) if output.status.success() => {
                let stdout = String::from_utf8_lossy(&output.stdout);
                let windows = self.parse_window_list(&stdout);
                self.app_groups = self.group_windows(windows);
                self.sort_app_groups();
                self.loading = false;
            }
            Ok(output) => {
                self.error_message = Some(format!("wlrctl error: {}", String::from_utf8_lossy(&output.stderr)));
                self.loading = false;
            }
            Err(e) => {
                self.error_message = Some(format!("Failed to run wlrctl: {}", e));
                self.loading = false;
            }
        }
    }
    
    fn parse_window_list(&self, output: &str) -> Vec<WindowInfo> {
        let mut windows = Vec::new();
        
        for line in output.lines() {
            if line.is_empty() {
                continue;
            }
            
            let parts: Vec<&str> = line.splitn(2, ':').collect();
            if parts.len() == 2 {
                let app_id = parts[0].trim().to_string();
                let title = parts[1].trim().to_string();
                
                if !title.is_empty() && title != "title" {
                    let timestamp = self.get_window_timestamp(&app_id, &title);
                    windows.push(WindowInfo {app_id, title, timestamp});
                }
            }
        }
        
        windows
    }
    
    fn get_window_pid(&self, app_id: &str, title: &str) -> Option<u32> {
        let output = Command::new("wlrctl")
            .arg("window")
            .arg("get-pid")
            .arg(format!("app-id:{}", app_id))
            .arg(format!("title:{}", title))
            .output()
            .ok()?;
        
        if output.status.success() {
            let pid_str = String::from_utf8_lossy(&output.stdout);
            let pid_str = pid_str.trim();
            pid_str.parse::<u32>().ok()
        } else {
            None
        }
    }
    
    fn get_window_timestamp(&self, app_id: &str, title: &str) -> u64 {
        if let Some(pid) = self.get_window_pid(app_id, title) {
            if let Some(ts) = self.get_timestamp_from_proc(pid) {
                return ts;
            }
            
            if let Some(ts) = self.get_timestamp_from_proc_stat(pid) {
                return ts;
            }
        }
        
        let hash_input = format!("{}{}", app_id, title);
        let mut hash = 0u64;
        for (i, byte) in hash_input.bytes().enumerate() {
            hash = hash.wrapping_add((byte as u64) << (i % 8));
        }
        1577836800 + (hash % 315360000)
    }
    
    fn get_timestamp_from_proc(&self, pid: u32) -> Option<u64> {
        let stat_path = format!("/proc/{}/stat", pid);
        let content = std::fs::read_to_string(&stat_path).ok()?;
        let fields: Vec<&str> = content.split_whitespace().collect();
        
        if fields.len() >= 22 {
            if let Ok(start_time_ticks) = fields[21].parse::<u64>() {
                let uptime_content = std::fs::read_to_string("/proc/uptime").ok()?;
                let uptime_seconds = uptime_content
                    .split_whitespace()
                    .next()?
                    .parse::<f64>()
                    .ok()?;
                
                let boot_time = SystemTime::now()
                    .duration_since(UNIX_EPOCH)
                    .unwrap_or_default()
                    .as_secs() - uptime_seconds as u64;
                
                let start_time_seconds = start_time_ticks / 100;
                return Some(boot_time + start_time_seconds);
            }
        }
        None
    }
    
    fn get_timestamp_from_proc_stat(&self, pid: u32) -> Option<u64> {
        let proc_path = format!("/proc/{}", pid);
        std::fs::metadata(&proc_path)
            .ok()
            .and_then(|meta| meta.modified().ok())
            .and_then(|time| time.duration_since(UNIX_EPOCH).ok())
            .map(|d| d.as_secs())
    }
    
    fn group_windows(&self, windows: Vec<WindowInfo>) -> Vec<AppGroup> {
        let mut groups: HashMap<String, Vec<WindowInfo>> = HashMap::new();
        
        for window in windows {
            groups.entry(window.app_id.clone())
                .or_insert_with(Vec::new)
                .push(window);
        }
        
        groups.into_iter()
            .map(|(app_id, mut windows)| {
                windows.sort_by(|a, b| b.timestamp.cmp(&a.timestamp));
                AppGroup { app_id, windows }
            })
            .collect()
    }
    
    fn sort_app_groups(&mut self) {
        match self.sort_order {
            SortOrder::Alphabetical => {
                self.app_groups.sort_by(|a, b| a.app_id.cmp(&b.app_id));
            }
            SortOrder::NewestFirst => {
                self.app_groups.sort_by(|a, b| {
                    let a_max = a.windows.iter().map(|w| w.timestamp).max().unwrap_or(0);
                    let b_max = b.windows.iter().map(|w| w.timestamp).max().unwrap_or(0);
                    b_max.cmp(&a_max)
                });
            }
            SortOrder::OldestFirst => {
                self.app_groups.sort_by(|a, b| {
                    let a_min = a.windows.iter().map(|w| w.timestamp).min().unwrap_or(0);
                    let b_min = b.windows.iter().map(|w| w.timestamp).min().unwrap_or(0);
                    a_min.cmp(&b_min)
                });
            }
        }
    }
    
    fn focus_window(&self, app_id: &str, title: &str) {
        let mut cmd = Command::new("wlrctl");
        cmd.arg("window");
        cmd.arg("focus");
        cmd.arg(format!("app-id:{}", app_id));
        cmd.arg(format!("title:{}", title));
        
        let _ = cmd.output();
    }
    
    fn update(&mut self, message: Message) -> Task<Message> {
        match message {
            Message::Refresh => {
                self.load_windows();
                Task::none()
            }
            Message::SelectWindow(app_idx, window_idx) => {
                if let Some(app_group) = self.app_groups.get(app_idx) {
                    if let Some(window) = app_group.windows.get(window_idx) {
                        self.focus_window(&window.app_id, &window.title);
                    }
                }
                Task::none()
            }
            Message::ChangeSortOrder(order) => {
                self.sort_order = order;
                self.sort_app_groups();
                Task::none()
            }
        }
    }
    
    fn view(&self) -> Element<Message> {
        let mut content = Column::new().spacing(10).padding(20);
        let text_color = Color::parse(&self.text_color).unwrap_or(Color::from_rgb(0.0, 0.0, 0.0));
        
        let sort_row = Row::new()
            .spacing(10)
            .padding(5)
            .push(button(text("Refresh").color(text_color)).on_press(Message::Refresh))
            .push(button(text("Alphabetical").color(text_color)).on_press(Message::ChangeSortOrder(SortOrder::Alphabetical)))
            .push(button(text("Newest First").color(text_color)).on_press(Message::ChangeSortOrder(SortOrder::NewestFirst)))
            .push(button(text("Oldest First").color(text_color)).on_press(Message::ChangeSortOrder(SortOrder::OldestFirst)));
        
        content = content.push(sort_row);
        
        let sort_text = match self.sort_order {
            SortOrder::Alphabetical => "Alphabetical",
            SortOrder::NewestFirst => "Newest First",
            SortOrder::OldestFirst => "Oldest First",
        };
        content = content.push(
            text(format!("Sort: {} | Groups: {} | Windows: {} | Opacity: {:.1}", 
                sort_text, 
                self.app_groups.len(),
                self.app_groups.iter().map(|g| g.windows.len()).sum::<usize>(),
                self.background_opacity
            )).color(text_color).size(self.text_size)
        );
        
        if let Some(error) = &self.error_message {
            content = content.push(text(format!("Error: {}", error)).color(text_color).size(self.text_size));
        }
        
        if self.loading {
            content = content.push(text("Loading windows...").color(text_color).size(self.text_size));
        } else if self.app_groups.is_empty() {
            content = content.push(text("No windows found").color(text_color).size(self.text_size));
        } else {
            let mut grid = Column::new().spacing(10);
            let cols: usize = 4;
            let mut rows = Vec::new();
            let mut current_row = Vec::new();
            
            for (app_idx, app_group) in self.app_groups.iter().enumerate() {
                let display_text = if app_group.windows.len() == 1 {
                    format!("{}: {}", app_group.app_id, app_group.windows[0].title)
                } else {
                    format!("{} ({} windows)", app_group.app_id, app_group.windows.len())
                };
                
                let button_widget = button(text(display_text).color(text_color).size(self.text_size))
                    .width(Length::Fill)
                    .on_press(Message::SelectWindow(app_idx, 0));
                
                current_row.push(button_widget);
                
                if current_row.len() >= cols {
                    rows.push(current_row);
                    current_row = Vec::new();
                }
            }
            
            if !current_row.is_empty() {
                rows.push(current_row);
            }
            
            for row_buttons in rows {
                let mut row_widget = Row::new().spacing(10);
                for btn in row_buttons {
                    row_widget = row_widget.push(btn);
                }
                grid = grid.push(row_widget);
            }
            
            content = content.push(scrollable(grid));
        }
        
        content.into()
    }
}
