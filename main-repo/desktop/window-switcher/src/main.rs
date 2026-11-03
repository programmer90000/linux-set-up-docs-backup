mod config;

use iced::widget::{button, pick_list, text_input, Column, scrollable, text, Row};
use iced::{Element, Length, Task};
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use std::sync::{Arc, Mutex, LazyLock};

use config::Config;

use iced::{Color, Theme};

use wayland_client::protocol::{wl_registry, wl_seat};
use wayland_client::{backend::{ObjectData, ObjectId}, Connection, Dispatch, Proxy, QueueHandle};
use wayland_protocols_wlr::foreign_toplevel::v1::client::{
    zwlr_foreign_toplevel_handle_v1::{self, ZwlrForeignToplevelHandleV1},
    zwlr_foreign_toplevel_manager_v1::{self, ZwlrForeignToplevelManagerV1},
};

fn get_cache_path() -> PathBuf {
    let mut path = std::env::temp_dir();
    path.push("window-switcher-renames.json");
    path
}

// Load custom titles from disk cache
type TitleMap = HashMap<String, String>;

fn load_disk_titles() -> TitleMap {
    let path = get_cache_path();
    if path.exists() {
        if let Ok(content) = fs::read_to_string(path) {
            if let Ok(map) = serde_json::from_str(&content) {
                return map;
            }
        }
    }
    HashMap::new()
}

fn save_disk_titles(map: &TitleMap) {
    let path = get_cache_path();
    if let Ok(content) = serde_json::to_string(map) {
        let _ = fs::write(path, content);
    }
}

static CUSTOM_TITLES: LazyLock<Mutex<TitleMap>> = LazyLock::new(|| {
    Mutex::new(load_disk_titles())
});

#[derive(Clone, Debug)]
pub struct RawWindowInfo {
    pub app_id: String,
    pub title: String,
    pub handle: ZwlrForeignToplevelHandleV1,
}

#[derive(Default)]
pub struct WaylandState {
    pub seat: Option<wl_seat::WlSeat>,
    pub manager: Option<ZwlrForeignToplevelManagerV1>,
    pub windows: Vec<RawWindowInfo>,
}

#[derive(Default, Debug, Clone)]
pub struct PendingWindow {
    pub app_id: String,
    pub title: String,
}

impl Dispatch<wl_registry::WlRegistry, ()> for WaylandState {
    fn event(
        state: &mut Self,
        registry: &wl_registry::WlRegistry,
        event: wl_registry::Event,
        _: &(),
        _: &Connection,
        qh: &QueueHandle<Self>,
    ) {
        if let wl_registry::Event::Global {
            name,
            interface,
            version,
        } = event
        {
            if interface == "wl_seat" {
                state.seat = Some(registry.bind::<wl_seat::WlSeat, _, _>(name, version.min(1), qh, ()));
            } else if interface == "zwlr_foreign_toplevel_manager_v1" {
                state.manager = Some(registry.bind::<ZwlrForeignToplevelManagerV1, _, _>(
                    name,
                    version.min(1),
                    qh,
                    (),
                ));
            }
        }
    }
}

impl Dispatch<wl_seat::WlSeat, ()> for WaylandState {
    fn event(
        _: &mut Self,
        _: &wl_seat::WlSeat,
        _: wl_seat::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
    }
}

impl Dispatch<ZwlrForeignToplevelManagerV1, ()> for WaylandState {
    fn event(
        _: &mut Self,
        _: &ZwlrForeignToplevelManagerV1,
        _: zwlr_foreign_toplevel_manager_v1::Event,
        _: &(),
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
    }

    fn event_created_child(
        _opcode: u16,
        qh: &QueueHandle<Self>,
    ) -> Arc<dyn ObjectData> {
        qh.make_data::<ZwlrForeignToplevelHandleV1, Arc<Mutex<PendingWindow>>>(
            Arc::new(Mutex::new(PendingWindow::default())),
        )
    }
}

impl Dispatch<ZwlrForeignToplevelHandleV1, Arc<Mutex<PendingWindow>>> for WaylandState {
    fn event(
        state: &mut Self,
        handle: &ZwlrForeignToplevelHandleV1,
        event: zwlr_foreign_toplevel_handle_v1::Event,
        data: &Arc<Mutex<PendingWindow>>,
        _: &Connection,
        _: &QueueHandle<Self>,
    ) {
        match event {
            zwlr_foreign_toplevel_handle_v1::Event::AppId { app_id } => {
                if let Ok(mut pending) = data.lock() {
                    pending.app_id = app_id;
                }
            }
            zwlr_foreign_toplevel_handle_v1::Event::Title { title } => {
                if let Ok(mut pending) = data.lock() {
                    pending.title = title;
                }
            }
            zwlr_foreign_toplevel_handle_v1::Event::Closed => {
                let handle_id = format!("{:?}", handle.id());
                state.windows.retain(|w| format!("{:?}", w.handle.id()) != handle_id);
                if let Ok(mut titles) = CUSTOM_TITLES.lock() {
                    titles.remove(&handle_id);
                    save_disk_titles(&titles);
                }
            }
            zwlr_foreign_toplevel_handle_v1::Event::Done => {
                if let Ok(pending) = data.lock() {
                    state.windows.push(RawWindowInfo {
                        app_id: pending.app_id.clone(),
                        title: pending.title.clone(),
                        handle: handle.clone(),
                    });
                }
            }
            _ => {}
        }
    }
}

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
    let search_enabled = config.search.enabled;
    
    let bg_color_for_theme = bg_color.clone();
    let bg_color_for_state = bg_color.clone();
    let text_color_for_state = text_color.clone();
    
    iced::application("Window Switcher", WindowSwitcher::update, WindowSwitcher::view).subscription(WindowSwitcher::subscription).window(iced::window::Settings { size: iced::Size::new(width, height), decorations: decorations, position: iced::window::Position::Centered, transparent: true, ..Default::default()}).theme(move |_state| theme(&bg_color_for_theme, bg_opacity)).run_with(move || {(WindowSwitcher::new(bg_color_for_state, bg_opacity, text_color_for_state, text_size, search_enabled), Task::none())})
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

impl std::fmt::Display for SortOrder {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SortOrder::Alphabetical => write!(f, "Alphabetical"),
            SortOrder::NewestFirst => write!(f, "Most Recently Opened First"),
            SortOrder::OldestFirst => write!(f, "Oldest Opened First"),
        }
    }
}

#[derive(Debug, Clone)]
struct WindowInfo {
    app_id: String,
    title: String,
    handle: ZwlrForeignToplevelHandleV1,
    index: usize,
}

#[derive(Debug, Clone)]
struct AppGroup {
    app_id: String,
    windows: Vec<WindowInfo>,
}

#[derive(Debug, Clone)]
enum Message {
    Refresh,
    SelectAppGroup(usize),
    SelectWindowInGroup(usize, usize),
    BackToMainView,
    ChangeSortOrder(SortOrder),
    SearchChanged(String),
    StartRename(ObjectId, String),
    EditInputChanged(String),
    SaveRename(ObjectId),
    CancelRename,
    Event(iced::Event),
    KeyPressed(iced::keyboard::Key, iced::keyboard::Modifiers),
}

struct WindowSwitcher {
    app_groups: Vec<AppGroup>,
    sort_order: SortOrder,
    error_message: Option<String>,
    loading: bool,
    active_group_idx: Option<usize>,
    background_color: String,
    background_opacity: f32,
    text_color: String,
    text_size: u16,
    seat: Option<wl_seat::WlSeat>,
    connection: Option<Connection>,
    search_enabled: bool,
    search_query: String,
    editing_window_id: Option<ObjectId>,
    edit_input_value: String,
    focused_index: usize,
}

impl WindowSwitcher {
    fn new(background_color: String, background_opacity: f32, text_color: String, text_size: u16, search_enabled: bool) -> Self {
        let mut switcher = Self {
            app_groups: Vec::new(),
            sort_order: SortOrder::default(),
            error_message: None,
            loading: true,
            active_group_idx: None,
            background_color,
            background_opacity,
            text_color,
            text_size,
            seat: None,
            connection: None,
            search_enabled,
            search_query: String::new(),
            editing_window_id: None,
            edit_input_value: String::new(),
            focused_index: 0,
        };
        switcher.load_windows();
        switcher
    }

    fn subscription(&self) -> iced::Subscription<Message> {
        iced::Subscription::batch(vec![
            iced::event::listen().map(Message::Event),
            iced::keyboard::on_key_press(|key, modifiers| Some(Message::KeyPressed(key, modifiers))),
        ])
    }
    
    fn load_windows(&mut self) {
        self.loading = true;
        self.error_message = None;
        self.active_group_idx = None;
        self.search_query.clear();
        self.editing_window_id = None;
        self.edit_input_value.clear();
        self.focused_index = 0;
        
        let connection = match Connection::connect_to_env() {
            Ok(conn) => conn,
            Err(e) => {
                self.error_message = Some(format!("Failed to connect to Wayland: {}", e));
                self.loading = false;
                return;
            }
        };
        
        let mut event_queue = connection.new_event_queue();
        let qh = event_queue.handle();
        let display = connection.display();
        
        let mut state = WaylandState::default();
        
        display.get_registry(&qh, ());
        
        if let Err(e) = event_queue.roundtrip(&mut state) {
            self.error_message = Some(format!("Wayland roundtrip failed: {}", e));
            self.loading = false;
            return;
        }
        
        if let Err(e) = event_queue.roundtrip(&mut state) {
            self.error_message = Some(format!("Wayland window list roundtrip failed: {}", e));
            self.loading = false;
            return;
        }
        
        self.seat = state.seat;
        
        let windows: Vec<WindowInfo> = state
            .windows
            .into_iter().enumerate().map(|(idx, w)| WindowInfo {app_id: w.app_id, title: w.title, handle: w.handle, index: idx,})
            .collect();
            
        self.app_groups = self.group_windows(windows);
        self.sort_app_groups();
        self.connection = Some(connection);
        self.loading = false;
    }
    
    fn group_windows(&self, windows: Vec<WindowInfo>) -> Vec<AppGroup> {
        let mut groups: HashMap<String, Vec<WindowInfo>> = HashMap::new();
        
        for window in windows {
            groups.entry(window.app_id.clone())
                .or_insert_with(Vec::new)
                .push(window);
        }
        
        groups.into_iter()
            .map(|(app_id, windows)| AppGroup { app_id, windows })
            .collect()
    }
    
    fn sort_app_groups(&mut self) {
        match self.sort_order {
            SortOrder::Alphabetical => {
                self.app_groups.sort_by(|a, b| a.app_id.cmp(&b.app_id));
                for group in &mut self.app_groups {
                    group.windows.sort_by(|a, b| a.title.cmp(&b.title));
                }
            }
            SortOrder::NewestFirst => {
                self.app_groups.sort_by(|a, b| {
                    let max_a = a.windows.iter().map(|w| w.index).max().unwrap_or(0);
                    let max_b = b.windows.iter().map(|w| w.index).max().unwrap_or(0);
                    max_a.cmp(&max_b)
                });
                for group in &mut self.app_groups {
                    group.windows.sort_by(|a, b| a.index.cmp(&b.index));
                }
            }
            SortOrder::OldestFirst => {
                self.app_groups.sort_by(|a, b| {
                    let min_a = a.windows.iter().map(|w| w.index).min().unwrap_or(0);
                    let min_b = b.windows.iter().map(|w| w.index).min().unwrap_or(0);
                    min_b.cmp(&min_a)
                });
                for group in &mut self.app_groups {
                    group.windows.sort_by(|a, b| b.index.cmp(&a.index));
                }
            }
        }
    }
    
    fn focus_window(&self, window: &WindowInfo) {
        if let Some(seat) = &self.seat {
            window.handle.unset_minimized();
            window.handle.activate(seat);
            if let Some(conn) = &self.connection {
                let _ = conn.flush();
            }
        } else {
            eprintln!("Cannot focus window: Wayland seat unavailable.");
        }
    }
    
    fn close_window_task() -> Task<Message> {
        iced::window::get_latest().and_then(|id| iced::window::close(id))
    }

    fn get_current_item_count(&self) -> usize {
        let query = self.search_query.to_lowercase();
        let custom_titles = CUSTOM_TITLES.lock().unwrap();
        
        match self.active_group_idx {
            None => {
                self.app_groups.iter().filter(|group| {
                    if group.windows.len() == 1 {
                        let win = &group.windows[0];
                        let key = format!("{:?}", win.handle.id());
                        let title = custom_titles.get(&key).cloned().unwrap_or_else(|| win.title.clone());
                        query.is_empty() || group.app_id.to_lowercase().contains(&query) || title.to_lowercase().contains(&query)
                    } else {
                        query.is_empty() || group.app_id.to_lowercase().contains(&query) || group.windows.iter().any(|w| {
                            let key = format!("{:?}", w.handle.id());
                            let title = custom_titles.get(&key).cloned().unwrap_or_else(|| w.title.clone());
                            title.to_lowercase().contains(&query)
                        })
                    }
                }).count()
            }
            Some(app_idx) => {
                if let Some(group) = self.app_groups.get(app_idx) {
                    group.windows.iter().filter(|w| {
                        let key = format!("{:?}", w.handle.id());
                        let title = custom_titles.get(&key).cloned().unwrap_or_else(|| w.title.clone());
                        query.is_empty() || title.to_lowercase().contains(&query) || w.app_id.to_lowercase().contains(&query)
                    }).count()
                } else {
                    0
                }
            }
        }
    }
    
    fn handle_enter_press(&mut self) -> Task<Message> {
        let query = self.search_query.to_lowercase();
        let custom_titles = CUSTOM_TITLES.lock().unwrap();
        
        match self.active_group_idx {
            None => {
                let mut current_idx = 0;
                for (app_idx, group) in self.app_groups.iter().enumerate() {
                    let matches = if group.windows.len() == 1 {
                        let win = &group.windows[0];
                        let key = format!("{:?}", win.handle.id());
                        let title = custom_titles.get(&key).cloned().unwrap_or_else(|| win.title.clone());
                        query.is_empty() || group.app_id.to_lowercase().contains(&query) || title.to_lowercase().contains(&query)
                    } else {
                        query.is_empty() || group.app_id.to_lowercase().contains(&query) || group.windows.iter().any(|w| {
                            let key = format!("{:?}", w.handle.id());
                            let title = custom_titles.get(&key).cloned().unwrap_or_else(|| w.title.clone());
                            title.to_lowercase().contains(&query)
                        })
                    };

                    if matches {
                        if current_idx == self.focused_index {
                            return self.update(Message::SelectAppGroup(app_idx));
                        }
                        current_idx += 1;
                    }
                }
            }
            Some(app_idx) => {
                if let Some(group) = self.app_groups.get(app_idx) {
                    let mut current_idx = 0;
                    for (win_idx, window) in group.windows.iter().enumerate() {
                        let key = format!("{:?}", window.handle.id());
                        let title = custom_titles.get(&key).cloned().unwrap_or_else(|| window.title.clone());
                        let matches = query.is_empty() || title.to_lowercase().contains(&query) || window.app_id.to_lowercase().contains(&query);

                        if matches {
                            if current_idx == self.focused_index {
                                return self.update(Message::SelectWindowInGroup(app_idx, win_idx));
                            }
                            current_idx += 1;
                        }
                    }
                }
            }
        }
        Task::none()
    }

    fn handle_tab_press(&mut self) -> Task<Message> {
        let query = self.search_query.to_lowercase();
        let custom_titles = CUSTOM_TITLES.lock().unwrap();

        match self.active_group_idx {
            None => {
                let mut current_idx = 0;
                for (app_idx, group) in self.app_groups.iter().enumerate() {
                    if group.windows.len() == 1 {
                        let win = &group.windows[0];
                        let key = format!("{:?}", win.handle.id());
                        let title = custom_titles.get(&key).cloned().unwrap_or_else(|| win.title.clone());
                        let matches = query.is_empty() || group.app_id.to_lowercase().contains(&query) || title.to_lowercase().contains(&query);

                        if matches {
                            if current_idx == self.focused_index {
                                let handle_id = win.handle.id();
                                drop(custom_titles);
                                return self.update(Message::StartRename(handle_id, title));
                            }
                            current_idx += 1;
                        }
                    } else {
                        let matches = query.is_empty() || group.app_id.to_lowercase().contains(&query) || group.windows.iter().any(|w| {
                            let key = format!("{:?}", w.handle.id());
                            let title = custom_titles.get(&key).cloned().unwrap_or_else(|| w.title.clone());
                            title.to_lowercase().contains(&query)
                        });
                        if matches {
                            current_idx += 1;
                        }
                    }
                }
            }
            Some(app_idx) => {
                if let Some(group) = self.app_groups.get(app_idx) {
                    let mut current_idx = 0;
                    for window in &group.windows {
                        let key = format!("{:?}", window.handle.id());
                        let title = custom_titles.get(&key).cloned().unwrap_or_else(|| window.title.clone());
                        let matches = query.is_empty() || title.to_lowercase().contains(&query) || window.app_id.to_lowercase().contains(&query);

                        if matches {
                            if current_idx == self.focused_index {
                                let handle_id = window.handle.id();
                                drop(custom_titles);
                                return self.update(Message::StartRename(handle_id, title));
                            }
                            current_idx += 1;
                        }
                    }
                }
            }
        }
        Task::none()
    }
    
    fn update(&mut self, message: Message) -> Task<Message> {
        match message {
            Message::Event(iced::Event::Window(iced::window::Event::Unfocused)) => {
                Self::close_window_task()
            }
            Message::Event(_) => Task::none(),
            Message::KeyPressed(key, _modifiers) => {
                if self.editing_window_id.is_some() {
                    return Task::none();
                }

                use iced::keyboard::key::Key;

                match key {
                    Key::Named(iced::keyboard::key::Named::ArrowDown) => {
                        let max_items = self.get_current_item_count();
                        if max_items > 0 {
                            self.focused_index = (self.focused_index + 1).min(max_items - 1);
                        }
                        Task::none()
                    }
                    Key::Named(iced::keyboard::key::Named::ArrowUp) => {
                        self.focused_index = self.focused_index.saturating_sub(1);
                        Task::none()
                    }
                    Key::Named(iced::keyboard::key::Named::Enter) => {
                        self.handle_enter_press()
                    }
                    Key::Named(iced::keyboard::key::Named::Tab) => {
                        self.handle_tab_press()
                    }
                    _ => Task::none(),
                }
            }
            Message::Refresh => {
                self.load_windows();
                Task::none()
            }
            Message::SelectAppGroup(app_idx) => {
                if let Some(app_group) = self.app_groups.get(app_idx) {
                    if app_group.windows.len() == 1 {
                        self.focus_window(&app_group.windows[0]);
                        return Self::close_window_task();
                    } else {
                        self.active_group_idx = Some(app_idx);
                        self.search_query.clear(); // Reset search query when navigating into a group
                        self.focused_index = 0;
                    }
                }
                Task::none()
            }
            Message::SelectWindowInGroup(app_idx, window_idx) => {
                if let Some(app_group) = self.app_groups.get(app_idx) {
                    if let Some(window) = app_group.windows.get(window_idx) {
                        self.focus_window(window);
                        return Self::close_window_task();
                    }
                }
                Task::none()
            }
            Message::BackToMainView => {
                self.active_group_idx = None;
                self.search_query.clear(); // Reset search query when going back
                self.focused_index = 0;
                Task::none()
            }
            Message::ChangeSortOrder(order) => {
                self.sort_order = order;
                self.sort_app_groups();
                self.focused_index = 0;
                Task::none()
            }
            Message::SearchChanged(query) => {
                self.search_query = query;
                self.focused_index = 0;
                Task::none()
            }
            Message::StartRename(id, current_title) => {
                self.editing_window_id = Some(id);
                self.edit_input_value = current_title;
                Task::none()
            }
            Message::EditInputChanged(val) => {
                self.edit_input_value = val;
                Task::none()
            }
            Message::SaveRename(id) => {
                if !self.edit_input_value.trim().is_empty() {
                    let key = format!("{:?}", id);
                    if let Ok(mut titles) = CUSTOM_TITLES.lock() {
                        titles.insert(key, self.edit_input_value.clone());
                        save_disk_titles(&titles);
                    }
                }
                self.editing_window_id = None;
                self.edit_input_value.clear();
                Task::none()
            }
            Message::CancelRename => {
                self.editing_window_id = None;
                self.edit_input_value.clear();
                Task::none()
            }
        }
    }
    
    fn view(&self) -> Element<Message> {
        let mut content = Column::new().spacing(10).padding(20).width(Length::Fill);
        let text_color = Color::parse(&self.text_color).unwrap_or(Color::from_rgb(0.0, 0.0, 0.0));
        
        let custom_titles = CUSTOM_TITLES.lock().unwrap();
        
        // Render search bar if enabled via config
        if self.search_enabled {
            let search_input = text_input("Type to search windows...", &self.search_query).on_input(Message::SearchChanged).padding(10).size(self.text_size).width(Length::Fill);
            
            let sort_dropdown = pick_list(
                &[
                    SortOrder::NewestFirst,
                    SortOrder::OldestFirst,
                    SortOrder::Alphabetical,
                ][..],
                Some(self.sort_order.clone()),
                Message::ChangeSortOrder,
            ).text_size(self.text_size).padding(10);
            
            let search_and_sort_row = Row::new().spacing(10).align_y(iced::Alignment::Center).push(search_input).push(sort_dropdown);

            content = content.push(search_and_sort_row);
        }
        
        let mut action_row = Row::new().spacing(10).padding(5);
        
        if self.active_group_idx.is_some() {
            action_row = action_row.push(
                button(text("← Back").color(text_color)).on_press(Message::BackToMainView),
            );
        }
        
        action_row = action_row.push(
            button(text("Refresh").color(text_color)).on_press(Message::Refresh),
        );
        
        content = content.push(action_row);
        
        let sort_text = match self.sort_order {
            SortOrder::Alphabetical => "Alphabetical",
            SortOrder::NewestFirst => "Most Recently Opened First",
            SortOrder::OldestFirst => "Oldest Opened First",
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
            let query = self.search_query.to_lowercase();
            
            match self.active_group_idx {
                None => {
                    let mut list_column = Column::new().spacing(10);
                    let mut current_item_idx = 0;
                    
                    for (_app_idx, app_group) in self.app_groups.iter().enumerate() {
                        if app_group.windows.len() == 1 {
                            let win = &app_group.windows[0];
                            let handle_id = win.handle.id();
                            let handle_key = format!("{:?}", handle_id);
                            let current_title = custom_titles.get(&handle_key).cloned().unwrap_or_else(|| win.title.clone());
                            let display_text = format!("{}: {}", app_group.app_id, current_title);
                            
                            let matches = query.is_empty() || app_group.app_id.to_lowercase().contains(&query) || current_title.to_lowercase().contains(&query);
                            
                            if matches {
                                let is_focused = current_item_idx == self.focused_index;
                                
                                if self.editing_window_id == Some(handle_id.clone()) {
                                    let input = text_input("New name...", &self.edit_input_value).on_input(Message::EditInputChanged).size(self.text_size);
                                    let save_btn = button(text("Save").size(self.text_size)).on_press(Message::SaveRename(handle_id));
                                    let cancel_btn = button(text("Cancel").size(self.text_size)).on_press(Message::CancelRename);
                                    let edit_row = Row::new().spacing(5).push(input).push(save_btn).push(cancel_btn);
                                    list_column = list_column.push(edit_row);
                                } else {
                                    let prefix = if is_focused { "▶ " } else { "  " };
                                    let window_btn = button(text(format!("{}{}", prefix, display_text)).color(text_color).size(self.text_size)).width(Length::Shrink).on_press(Message::SelectAppGroup(_app_idx));
                                    let rename_btn = button(text("✏️").size(self.text_size)).on_press(Message::StartRename(handle_id, current_title.clone()));
                                    let item_row = Row::new().spacing(10).align_y(iced::Alignment::Center).push(window_btn).push(rename_btn);
                                    list_column = list_column.push(item_row);
                                }
                                current_item_idx += 1;
                            }
                        } else {
                            let display_text = format!("{} ({} windows)", app_group.app_id, app_group.windows.len());
                            let matches = query.is_empty() || app_group.app_id.to_lowercase().contains(&query) || app_group.windows.iter().any(|w| {
                                    let key = format!("{:?}", w.handle.id());
                                    let title = custom_titles.get(&key).cloned().unwrap_or_else(|| w.title.clone());
                                    title.to_lowercase().contains(&query)
                                });
                            
                            if matches {
                                let is_focused = current_item_idx == self.focused_index;
                                let prefix = if is_focused { "▶ " } else { "  " };
                                let button_widget = button(text(format!("{}{}", prefix, display_text)).color(text_color).size(self.text_size)).width(Length::Shrink).on_press(Message::SelectAppGroup(_app_idx));
                                
                                list_column = list_column.push(button_widget);
                                current_item_idx += 1;
                            }
                        }
                    }
                    
                    grid = grid.push(list_column);
                }
                Some(app_idx) => {
                    if let Some(app_group) = self.app_groups.get(app_idx) {
                        let mut list_column = Column::new().spacing(10);
                        let mut current_item_idx = 0;
                        
                        for (win_idx, window) in app_group.windows.iter().enumerate() {
                            let handle_id = window.handle.id();
                            let handle_key = format!("{:?}", handle_id);
                            let current_title = custom_titles.get(&handle_key).cloned().unwrap_or_else(|| window.title.clone());
                            
                            let matches = query.is_empty() || current_title.to_lowercase().contains(&query) || window.app_id.to_lowercase().contains(&query);
                            
                            if matches {
                                let is_focused = current_item_idx == self.focused_index;
                                
                                if self.editing_window_id == Some(handle_id.clone()) {
                                    let input = text_input("New name...", &self.edit_input_value).on_input(Message::EditInputChanged).size(self.text_size);
                                    let save_btn = button(text("Save").size(self.text_size)).on_press(Message::SaveRename(handle_id));
                                    let cancel_btn = button(text("Cancel").size(self.text_size)).on_press(Message::CancelRename);
                                    let edit_row = Row::new().spacing(5).push(input).push(save_btn).push(cancel_btn);
                                    list_column = list_column.push(edit_row);
                                } else {
                                    let prefix = if is_focused { "▶ " } else { "  " };
                                    let window_btn = button(text(format!("{}{}", prefix, current_title)).color(text_color).size(self.text_size)).width(Length::Shrink).on_press(Message::SelectWindowInGroup(app_idx, win_idx));
                                    let rename_btn = button(text("✏️").size(self.text_size)).on_press(Message::StartRename(handle_id, current_title));
                                    let item_row = Row::new().spacing(10).align_y(iced::Alignment::Center).push(window_btn).push(rename_btn);
                                    list_column = list_column.push(item_row);
                                }
                                current_item_idx += 1;
                            }
                        }
                        
                        grid = grid.push(list_column);
                    }
                }
            }
            
            let scrollable_content = scrollable(grid).direction(scrollable::Direction::Both {
                    vertical: scrollable::Scrollbar::default(),
                    horizontal: scrollable::Scrollbar::default(),
                }).width(Length::Fill).height(Length::Fill);
            
            content = content.push(scrollable_content);
        }
        
        content.into()
    }
}
