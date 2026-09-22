use clap::Parser;
use crossterm::{
event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode},
execute,
terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
backend::CrosstermBackend,
layout::{Constraint, Direction, Layout, Rect},
style::{Color, Modifier, Style},
widgets::{Block, Borders, Clear, List, ListItem, Paragraph, Row, Table, TableState, Tabs},
Frame, Terminal,
};
use rusqlite::{params, Connection};
use serde::{Deserialize, Serialize};
use std::{
fs,
io::{self, BufRead},
time::{Duration, Instant},
};

// ==========================================
// CLI ARGUMENTS
// ==========================================
#[derive(Parser, Debug)]
#[command(author, version, about = "Debian 13 System Monitor TUI in Rust")]
struct Args {
/// Update interval in milliseconds
#[arg(short, long, default_value_t = 1000)]
interval: u64,

/// Log the first 100 readings into a circular SQLite database
#[arg(long, default_value = "sysmon_metrics.db")]
sqlite_log: Option<String>,

/// Path to TOML layout config
#[arg(short, long)]
config: Option<String>,

/// Filter displayed metrics by string match
#[arg(short, long)]
filter: Option<String>,

/// Sort process table by column: cpu, mem, pid, name
#[arg(short, long, default_value = "cpu")]
sort_by: String,
}

// ==========================================
// CONFIGURATION SCHEMA (TOML)
// ==========================================
#[derive(Debug, Deserialize, Serialize, Clone)]
struct ThresholdsConfig {
cpu_high: f32,
mem_high: f32,
temp_high: f32,
temp_low: f32,
}

impl Default for ThresholdsConfig {
fn default() -> Self {
Self {
cpu_high: 85.0,
mem_high: 90.0,
temp_high: 80.0,
temp_low: 10.0,
}
}
}

#[derive(Debug, Deserialize, Serialize, Clone)]
struct AppConfig {
thresholds: ThresholdsConfig,
tabs: Vec<TabConfig>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
struct TabConfig {
name: String,
panels: Vec<String>, // Allowed: "cpu", "mem", "disk", "proc", "net"
}

impl Default for AppConfig {
fn default() -> Self {
Self {
thresholds: ThresholdsConfig::default(),
tabs: vec![
TabConfig {
name: "Overview".into(),
panels: vec!["cpu".into(), "mem".into(), "disk".into()],
},
TabConfig {
name: "Processes".into(),
panels: vec!["proc".into()],
},
],
}
}
}

// ==========================================
// DATA METRICS MODEL
// ==========================================
#[derive(Debug, Clone, Default)]
struct ProcessInfo {
pid: u32,
name: String,
cpu_usage: f32,
mem_bytes: u64,
}

#[derive(Debug, Clone, Default)]
struct SystemMetrics {
cpu_usage_pct: f32,
mem_total_kb: u64,
mem_free_kb: u64,
mem_available_kb: u64,
swap_total_kb: u64,
swap_free_kb: u64,
cpu_temp_c: f32,
processes: Vec<ProcessInfo>,
is_root: bool,
}

impl SystemMetrics {
fn fetch(filter: Option<&str>, sort_by: &str) -> Self {
let is_root = unsafe { libc::getuid() == 0 };
let mut metrics = SystemMetrics {
is_root,
..Default::default()
};

metrics.parse_cpu();
metrics.parse_mem();
metrics.parse_temp();
metrics.parse_processes(filter, sort_by);

metrics
}

fn parse_cpu(&mut self) {
if let Ok(content) = fs::read_to_string("/proc/stat") {
if let Some(line) = content.lines().next() {
let parts: Vec<&str> = line.split_whitespace().collect();
if parts.len() >= 5 {
let user: u64 = parts[1].parse().unwrap_or(0);
let nice: u64 = parts[2].parse().unwrap_or(0);
let system: u64 = parts[3].parse().unwrap_or(0);
let idle: u64 = parts[4].parse().unwrap_or(0);
let total = user + nice + system + idle;
if total > 0 {
let active = user + nice + system;
self.cpu_usage_pct = (active as f32 / total as f32) * 100.0;
}
}
}
}
}

fn parse_mem(&mut self) {
if let Ok(file) = fs::File::open("/proc/meminfo") {
let reader = io::BufReader::new(file);
for line in reader.lines().flatten() {
let parts: Vec<&str> = line.split_whitespace().collect();
if parts.len() >= 2 {
let val: u64 = parts[1].parse().unwrap_or(0);
match parts[0] {
"MemTotal:" => self.mem_total_kb = val,
"MemFree:" => self.mem_free_kb = val,
"MemAvailable:" => self.mem_available_kb = val,
"SwapTotal:" => self.swap_total_kb = val,
"SwapFree:" => self.swap_free_kb = val,
_ => {}
}
}
}
}
}

fn parse_temp(&mut self) {
let temp_path = "/sys/class/thermal/thermal_zone0/temp";
if let Ok(content) = fs::read_to_string(temp_path) {
if let Ok(milli) = content.trim().parse::<f32>() {
self.cpu_temp_c = milli / 1000.0;
}
} else {
self.cpu_temp_c = -1.0;
}
}

fn parse_processes(&mut self, filter: Option<&str>, sort_by: &str) {
let mut procs = Vec::new();
if let Ok(entries) = fs::read_dir("/proc") {
for entry in entries.flatten() {
let path = entry.path();
if path.is_dir() {
if let Some(pid_str) = path.file_name().and_then(|s| s.to_str()) {
if let Ok(pid) = pid_str.parse::<u32>() {
let comm_path = path.join("comm");
let stat_path = path.join("statm");

let name = fs::read_to_string(comm_path)
.map(|s| s.trim().to_string())
.unwrap_or_else(|_| "N/A".into());

let mem_bytes = fs::read_to_string(stat_path)
.ok()
.and_then(|s| {
s.split_whitespace()
.nth(1)
.and_then(|p| p.parse::<u64>().ok())
})
.map(|pages| pages * 4096)
.unwrap_or(0);

if let Some(f) = filter {
if !name.to_lowercase().contains(&f.to_lowercase()) {
continue;
}
}

procs.push(ProcessInfo {
pid,
name,
cpu_usage: 0.0,
mem_bytes,
});
}
}
}
}
}

match sort_by {
"pid" => procs.sort_by_key(|p| p.pid),
"name" => procs.sort_by(|a, b| a.name.cmp(&b.name)),
"mem" => procs.sort_by(|a, b| b.mem_bytes.cmp(&a.mem_bytes)),
_ => procs.sort_by(|a, b| b.pid.cmp(&a.pid)),
}

self.processes = procs;
}
}

// ==========================================
// SQLITE CIRCULAR LOGGER
// ==========================================
struct CircularLogger {
conn: Connection,
}

impl CircularLogger {
fn new(db_path: &str) -> rusqlite::Result<Self> {
let conn = Connection::open(db_path)?;
conn.execute(
"CREATE TABLE IF NOT EXISTS metrics (
id INTEGER PRIMARY KEY AUTOINCREMENT,
timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
cpu_usage REAL,
mem_available_kb INTEGER,
cpu_temp REAL
)",
[],
)?;
Ok(Self { conn })
}

fn log(&mut self, m: &SystemMetrics) -> rusqlite::Result<()> {
let count: i64 =
self.conn
.query_row("SELECT COUNT(*) FROM metrics", [], |row| row.get(0))?;

if count >= 100 {
self.conn.execute(
"DELETE FROM metrics WHERE id = (SELECT id FROM metrics ORDER BY id ASC LIMIT 1)",
[],
)?;
}

self.conn.execute(
"INSERT INTO metrics (cpu_usage, mem_available_kb, cpu_temp) VALUES (?1, ?2, ?3)",
params![m.cpu_usage_pct, m.mem_available_kb, m.cpu_temp_c],
)?;

Ok(())
}
}

// ==========================================
// APPLICATION STATE MANAGEMENT
// ==========================================
struct App {
metrics: SystemMetrics,
config: AppConfig,
active_tab: usize,
table_state: TableState,
show_shortcuts_popup: bool,
logger: Option<CircularLogger>,
args: Args,
}

impl App {
fn new(args: Args) -> Self {
let config = if let Some(ref path) = args.config {
fs::read_to_string(path)
.ok()
.and_then(|c| toml::from_str(&c).ok())
.unwrap_or_default()
} else {
AppConfig::default()
};

let logger = args
.sqlite_log
.as_ref()
.and_then(|path| CircularLogger::new(path).ok());

let mut app = Self {
metrics: SystemMetrics::default(),
config,
active_tab: 0,
table_state: TableState::default(),
show_shortcuts_popup: false,
logger,
args,
};
app.refresh();
app
}

fn refresh(&mut self) {
self.metrics =
SystemMetrics::fetch(self.args.filter.as_deref(), &self.args.sort_by);
if let Some(ref mut logger) = self.logger {
let _ = logger.log(&self.metrics);
}
}

fn next_tab(&mut self) {
self.active_tab = (self.active_tab + 1) % self.config.tabs.len();
}

fn prev_tab(&mut self) {
if self.active_tab == 0 {
self.active_tab = self.config.tabs.len() - 1;
} else {
self.active_tab -= 1;
}
}

fn scroll_next(&mut self) {
let i = match self.table_state.selected() {
Some(i) => {
if i >= self.metrics.processes.len().saturating_sub(1) {
0
} else {
i + 1
}
}
None => 0,
};
self.table_state.select(Some(i));
}

fn scroll_prev(&mut self) {
let i = match self.table_state.selected() {
Some(i) => {
if i == 0 {
self.metrics.processes.len().saturating_sub(1)
} else {
i - 1
}
}
None => 0,
};
self.table_state.select(Some(i));
}
}

// ==========================================
// MAIN ENTRY POINT
// ==========================================
fn main() -> Result<(), Box<dyn std::error::Error>> {
let args = Args::parse();

enable_raw_mode()?;
let mut stdout = io::stdout();
execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
let backend = CrosstermBackend::new(stdout);
let mut terminal = Terminal::new(backend)?;

let mut app = App::new(args);
let mut last_update = Instant::now();
let tick_rate = Duration::from_millis(app.args.interval);

loop {
terminal.draw(|f| ui(f, &mut app))?;

let timeout = tick_rate
.checked_sub(last_update.elapsed())
.unwrap_or_else(|| Duration::from_secs(0));

if crossterm::event::poll(timeout)? {
if let Event::Key(key) = event::read()? {
match key.code {
KeyCode::Char('q') => break,
KeyCode::Char('r') => app.refresh(),
KeyCode::Char('s') | KeyCode::F(1) => {
app.show_shortcuts_popup = !app.show_shortcuts_popup
}
KeyCode::Tab => app.next_tab(),
KeyCode::BackTab => app.prev_tab(),
KeyCode::Down | KeyCode::Char('j') => app.scroll_next(),
KeyCode::Up | KeyCode::Char('k') => app.scroll_prev(),
_ => {}
}
}
}

if last_update.elapsed() >= tick_rate {
app.refresh();
last_update = Instant::now();
}
}

disable_raw_mode()?;
execute!(
terminal.backend_mut(),
LeaveAlternateScreen,
DisableMouseCapture
)?;
terminal.show_cursor()?;

Ok(())
}

// ==========================================
// UI RENDERING ENGINE
// ==========================================
fn ui(f: &mut Frame, app: &mut App) {
let constraints = if !app.metrics.is_root {
vec![
Constraint::Length(3), // Warning Banner
Constraint::Length(3), // Tab navigation
Constraint::Min(0), // Active layout
Constraint::Length(1), // Footer Shortcut Button
]
} else {
vec![
Constraint::Length(3), // Tab navigation
Constraint::Min(0), // Active layout
Constraint::Length(1), // Footer Shortcut Button
]
};

let chunks = Layout::default()
.direction(Direction::Vertical)
.constraints(constraints)
.split(f.size());

let mut idx = 0;

// 1. NON-PRIVILEGED WARNING BANNER
if !app.metrics.is_root {
let warning = Paragraph::new("⚠️ RUNNING IN NON-PRIVILEGED MODE: SOME SYSTEM METRICS ARE HIDDEN OR INACCESSIBLE. RE-RUN WITH SUDO FOR FULL ACCESS.")
.style(Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD))
.block(Block::default().borders(Borders::ALL).title(" Privilege Warning "));
f.render_widget(warning, chunks[idx]);
idx += 1;
}

// 2. TAB SELECTION BAR
let titles: Vec<_> = app.config.tabs.iter().map(|t| t.name.as_str()).collect();
let tabs = Tabs::new(titles)
.block(Block::default().borders(Borders::ALL).title(" System Dashboard "))
.select(app.active_tab)
.highlight_style(Style::default().fg(Color::Cyan).add_modifier(Modifier::BOLD));
f.render_widget(tabs, chunks[idx]);
idx += 1;

// 3. GRID CONTENT RENDERER
let content_area = chunks[idx];
idx += 1;

// Clone panels list to prevent double mutable/immutable borrow collision
let panels = app.config.tabs[app.active_tab].panels.clone();
let panels_count = panels.len();

if panels_count > 0 {
let grid_constraints = vec![Constraint::Ratio(1, panels_count as u32); panels_count];
let panel_chunks = Layout::default()
.direction(Direction::Horizontal)
.constraints(grid_constraints)
.split(content_area);

for (i, panel_type) in panels.iter().enumerate() {
match panel_type.as_str() {
"cpu" => render_cpu_panel(f, app, panel_chunks[i]),
"mem" => render_mem_panel(f, app, panel_chunks[i]),
"proc" => render_proc_panel(f, app, panel_chunks[i]),
_ => render_fallback_panel(f, panel_chunks[i], panel_type),
}
}
}

// 4. FOOTER INTERACTIVE SHORTCUT CAPTION
let footer = Paragraph::new("[Press 'S' or 'F1' to toggle all shortcuts] | Config: Read-Only")
.style(Style::default().fg(Color::DarkGray));
f.render_widget(footer, chunks[idx]);

// 5. SHORTCUT OVERLAY POPUP
if app.show_shortcuts_popup {
let block = Block::default().title(" Shortcuts Help ").borders(Borders::ALL);
let area = centered_rect(60, 40, f.size());
f.render_widget(Clear, area);

let items = vec![
ListItem::new(" 'q' : Quit Application"),
ListItem::new(" 'r' : Force Refresh System Metrics"),
ListItem::new(" Tab / BackTab: Switch Active Dashboard Tabs"),
ListItem::new(" Up/Down, j/k : Scroll Process Table"),
ListItem::new(" 's' / F1 : Toggle This Help Menu"),
];

let list = List::new(items).block(block).highlight_style(Style::default().fg(Color::Yellow));
f.render_widget(list, area);
}
}

// ==========================================
// INDIVIDUAL PANEL RENDERERS
// ==========================================
fn render_cpu_panel(f: &mut Frame, app: &App, area: Rect) {
let usage = app.metrics.cpu_usage_pct;
let high = app.config.thresholds.cpu_high;

let color = if usage >= high { Color::Red } else { Color::Green };

let text = vec![
format!("CPU Usage: {:.2}%", usage),
format!("Threshold High: {:.1}%", high),
format!("Temperature: {:.1}°C", app.metrics.cpu_temp_c),
];

let items: Vec<ListItem> = text.into_iter().map(ListItem::new).collect();
let list = List::new(items)
.block(Block::default().borders(Borders::ALL).title(" CPU Metrics "))
.style(Style::default().fg(color));
f.render_widget(list, area);
}

fn render_mem_panel(f: &mut Frame, app: &App, area: Rect) {
let total = app.metrics.mem_total_kb as f32;
let avail = app.metrics.mem_available_kb as f32;
let used_pct = if total > 0.0 { ((total - avail) / total) * 100.0 } else { 0.0 };

let color = if used_pct >= app.config.thresholds.mem_high {
Color::Red
} else if used_pct <= 10.0 {
Color::Blue
} else {
Color::Green
};

let text = vec![
format!("Total RAM: {:.2} GB", total / 1024.0 / 1024.0),
format!("Available RAM: {:.2} GB", avail / 1024.0 / 1024.0),
format!("Memory Usage: {:.2}%", used_pct),
format!("Swap Total: {} MB", app.metrics.swap_total_kb / 1024),
];

let items: Vec<ListItem> = text.into_iter().map(ListItem::new).collect();
let list = List::new(items)
.block(Block::default().borders(Borders::ALL).title(" Memory Metrics "))
.style(Style::default().fg(color));
f.render_widget(list, area);
}

fn render_proc_panel(f: &mut Frame, app: &mut App, area: Rect) {
let rows: Vec<Row> = app
.metrics
.processes
.iter()
.map(|p| {
Row::new(vec![
p.pid.to_string(),
p.name.clone(),
format!("{:.2} MB", p.mem_bytes as f32 / 1024.0 / 1024.0),
])
})
.collect();

let table = Table::new(
rows,
[Constraint::Length(8), Constraint::Percentage(50), Constraint::Percentage(40)],
)
.header(
Row::new(vec!["PID", "Name", "Mem Usage"])
.style(Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)),
)
.block(Block::default().borders(Borders::ALL).title(" Process Table "))
.highlight_style(Style::default().bg(Color::DarkGray));

f.render_stateful_widget(table, area, &mut app.table_state);
}

fn render_fallback_panel(f: &mut Frame, area: Rect, panel_type: &str) {
let p = Paragraph::new(format!("Panel '{}' configured", panel_type))
.block(Block::default().borders(Borders::ALL).title(" Info "));
f.render_widget(p, area);
}

fn centered_rect(percent_x: u16, percent_y: u16, r: Rect) -> Rect {
let popup_layout = Layout::default()
.direction(Direction::Vertical)
.constraints([
Constraint::Percentage((100 - percent_y) / 2),
Constraint::Percentage(percent_y),
Constraint::Percentage((100 - percent_y) / 2),
])
.split(r);

Layout::default()
.direction(Direction::Horizontal)
.constraints([
Constraint::Percentage((100 - percent_x) / 2),
Constraint::Percentage(percent_x),
Constraint::Percentage((100 - percent_x) / 2),
])
.split(popup_layout[1])[1]
}