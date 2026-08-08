#include <gtk/gtk.h>
#include <gtk-layer-shell/gtk-layer-shell.h>
#include <gio/gio.h>
#include <gio/gdesktopappinfo.h>
#include <glib.h>
#include <string.h>
#include <stdlib.h>

// Constants
#define ICON_SIZE 48
#define ICON_WIDTH 110
#define ICON_HEIGHT 100
#define MAX_LABEL_LEN 15
#define WRAPPED_LABEL_LEN 12
#define GRID_COLUMN_SPACING 20
#define GRID_ROW_SPACING 15
#define WINDOW_MARGIN 20
#define CONFIG_DIR "desktop-icons"
#define ORDER_FILE "order.conf"
#define CONFIG_FILE "config.conf"

// Type definitions
typedef struct {
    GtkGrid *grid;
    GList *icons;
    GList *icon_files;
    int icons_per_column;
} DesktopIcons;

typedef struct {
    int bottom_reserved;
} DesktopConfig;

// Function prototypes
static GdkPixbuf* load_icon_for_file(const char *filepath);
static GtkWidget* create_icon_widget(const char *filepath);
static gboolean on_icon_double_click(GtkWidget *widget, GdkEventButton *event, gpointer user_data);
static void apply_css_styling(GtkWidget *widget, const char *css);
static void reload_grid_layout(DesktopIcons *desktop);
static void add_icon(DesktopIcons *desktop, const char *filepath);
static void load_desktop_files(DesktopIcons *desktop);
static void calculate_icons_per_column(DesktopIcons *desktop, GtkWidget *window, DesktopConfig *config);
static void setup_layer_shell_window(GtkWidget *window, DesktopConfig *config);
static void cleanup(DesktopIcons *desktop);
static GList* load_icon_order(void);
static GList* get_ordered_icon_list(const char *desktop_path, GList *order_list);
static DesktopConfig* load_configuration(void);

static DesktopConfig* load_configuration(void) {
    DesktopConfig *config = g_new0(DesktopConfig, 1);
    
    // Default to no reserved space
    config->bottom_reserved = 0;
    
    char *config_dir = g_build_filename(g_get_user_config_dir(), CONFIG_DIR, NULL);
    char *config_path = g_build_filename(config_dir, CONFIG_FILE, NULL);
    
    if (g_file_test(config_path, G_FILE_TEST_EXISTS)) {
        GError *error = NULL;
        char *contents = NULL;
        
        if (g_file_get_contents(config_path, &contents, NULL, &error)) {
            char **lines = g_strsplit(contents, "\n", -1);
            for (int i = 0; lines[i]; i++) {
                char *line = g_strstrip(lines[i]);
                if (strlen(line) == 0 || line[0] == '#') continue;
                
                char **parts = g_strsplit(line, "=", 2);
                if (g_strv_length(parts) == 2) {
                    char *key = g_strstrip(parts[0]);
                    char *value = g_strstrip(parts[1]);
                    
                    if (g_strcmp0(key, "bottom_reserved") == 0)
                        config->bottom_reserved = atoi(value);
                }
                g_strfreev(parts);
            }
            g_strfreev(lines);
            g_free(contents);
        } else if (error) {
            g_warning("Failed to read config: %s", error->message);
            g_error_free(error);
        }
    }
    
    g_free(config_dir);
    g_free(config_path);
    return config;
}

static GList* load_icon_order(void) {
    GList *order_list = NULL;
    char *config_path = g_build_filename(g_get_user_config_dir(), CONFIG_DIR, ORDER_FILE, NULL);
    
    if (g_file_test(config_path, G_FILE_TEST_EXISTS)) {
        GError *error = NULL;
        char *contents = NULL;
        
        if (g_file_get_contents(config_path, &contents, NULL, &error)) {
            char **lines = g_strsplit(contents, "\n", -1);
            for (int i = 0; lines[i]; i++) {
                char *line = g_strstrip(lines[i]);
                if (strlen(line) == 0 || line[0] == '#') continue;
                order_list = g_list_append(order_list, g_strdup(line));
            }
            g_strfreev(lines);
            g_free(contents);
        } else if (error) {
            g_warning("Failed to read order config: %s", error->message);
            g_error_free(error);
        }
    }
    
    g_free(config_path);
    return order_list;
}

static GList* get_ordered_icon_list(const char *desktop_path, GList *order_list) {
    GList *ordered_files = NULL;
    
    if (!order_list) return NULL;
    
    for (GList *order_item = order_list; order_item; order_item = order_item->next) {
        char *order_name = (char*)order_item->data;
        char *full_path = g_build_filename(desktop_path, order_name, NULL);
        
        if (g_file_test(full_path, G_FILE_TEST_EXISTS)) {
            ordered_files = g_list_append(ordered_files, full_path);
        } else {
            g_warning("File listed in config does not exist: %s", full_path);
            g_free(full_path);
        }
    }
    
    return ordered_files;
}

static void apply_css_styling(GtkWidget *widget, const char *css) {
    GtkStyleContext *context = gtk_widget_get_style_context(widget);
    GtkCssProvider *provider = gtk_css_provider_new();
    
    gtk_css_provider_load_from_data(provider, css, -1, NULL);
    gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
    g_object_unref(provider);
}

static GdkPixbuf* load_desktop_file_icon(const char *filepath, GtkIconTheme *theme) {
    char *contents = NULL;
    GError *error = NULL;
    GdkPixbuf *pixbuf = NULL;
    
    if (!g_file_get_contents(filepath, &contents, NULL, &error)) {
        if (error) g_error_free(error);
        return NULL;
    }
    
    char **lines = g_strsplit(contents, "\n", -1);
    for (int i = 0; lines[i]; i++) {
        if (g_str_has_prefix(lines[i], "Icon=")) {
            char *icon_value = lines[i] + 5;
            
            // Trim whitespace
            while (g_ascii_isspace(*icon_value)) icon_value++;
            char *end = icon_value + strlen(icon_value) - 1;
            while (end > icon_value && g_ascii_isspace(*end)) *end-- = '\0';
            
            if (strlen(icon_value) > 0) {
                // Check if it's a file path (contains '/' or ends with .png/.svg/.xpm)
                if (strchr(icon_value, '/') || g_str_has_suffix(icon_value, ".png") || g_str_has_suffix(icon_value, ".svg") || g_str_has_suffix(icon_value, ".xpm")) {
                    // It's a file path - load directly
                    if (g_file_test(icon_value, G_FILE_TEST_EXISTS)) {
                        pixbuf = gdk_pixbuf_new_from_file_at_size(icon_value, ICON_SIZE, ICON_SIZE, NULL);
                    }
                } else if (gtk_icon_theme_has_icon(theme, icon_value)) {
                    pixbuf = gtk_icon_theme_load_icon(theme, icon_value, ICON_SIZE, GTK_ICON_LOOKUP_FORCE_SIZE, NULL);
                }
            }
            break;
        }
    }
    
    g_strfreev(lines);
    g_free(contents);
    return pixbuf;
}

// Create a fallback icon (gray square)
static GdkPixbuf* create_fallback_icon(void) {
    GdkPixbuf *pixbuf = gdk_pixbuf_new(GDK_COLORSPACE_RGB, TRUE, 8, ICON_SIZE, ICON_SIZE);
    gdk_pixbuf_fill(pixbuf, 0x888888FF);
    return pixbuf;
}

static GdkPixbuf* load_icon_for_file(const char *filepath) {
    GtkIconTheme *theme = gtk_icon_theme_get_default();
    GdkPixbuf *pixbuf = NULL;
    
    if (g_str_has_suffix(filepath, ".desktop")) {
        pixbuf = load_desktop_file_icon(filepath, theme);
        if (pixbuf) return pixbuf;
    }
    
    // Return fallback icon for all other files
    return create_fallback_icon();
}

static char* create_display_text(const char *filepath) {
    char *basename = g_path_get_basename(filepath);
    char *display_text;
    
    // Remove .desktop extension for display
    char *dot_desktop = strstr(basename, ".desktop");
    if (dot_desktop) {
        *dot_desktop = '\0';
    }
    
    if (strlen(basename) > MAX_LABEL_LEN) {
        char *temp = g_strndup(basename, WRAPPED_LABEL_LEN);
        display_text = g_strdup_printf("%s...", temp);
        g_free(temp);
    } else {
        display_text = g_strdup(basename);
    }
    
    g_free(basename);
    return display_text;
}

static GtkWidget* create_icon_widget(const char *filepath) {
    GdkPixbuf *pixbuf = load_icon_for_file(filepath);
    char *display_text = create_display_text(filepath);
    
    // Create container grid
    GtkWidget *grid = gtk_grid_new();
    gtk_grid_set_row_spacing(GTK_GRID(grid), 8);
    
    // Create image and label
    GtkWidget *image = gtk_image_new_from_pixbuf(pixbuf);
    GtkWidget *label = gtk_label_new(display_text);
    
    if (pixbuf) g_object_unref(pixbuf);
    g_free(display_text);
    
    // Configure label
    gtk_label_set_line_wrap(GTK_LABEL(label), TRUE);
    gtk_label_set_max_width_chars(GTK_LABEL(label), WRAPPED_LABEL_LEN);
    gtk_label_set_xalign(GTK_LABEL(label), 0.5);
    gtk_label_set_yalign(GTK_LABEL(label), 0.5);
    
    // Assemble widget
    gtk_grid_attach(GTK_GRID(grid), image, 0, 0, 1, 1);
    gtk_grid_attach(GTK_GRID(grid), label, 0, 1, 1, 1);
    
    // Make it clickable with double-click
    GtkWidget *event_box = gtk_event_box_new();
    gtk_container_add(GTK_CONTAINER(event_box), grid);
    
    // Store filepath in the widget
    g_object_set_data_full(G_OBJECT(event_box), "filepath", g_strdup(filepath), g_free);
    
    // Connect double-click event
    g_signal_connect(event_box, "button-press-event", G_CALLBACK(on_icon_double_click), NULL);
    
    apply_css_styling(grid,
        "grid { background-color: transparent; padding: 8px; border-radius: 5px; }"
        "grid:hover { background-color: rgba(255, 255, 255, 0.1); }"
    );
    
    apply_css_styling(label,
        "label { color: white; text-shadow: 1px 1px 2px black; font-size: 11px; font-weight: bold; }"
    );
    
    gtk_widget_set_size_request(event_box, ICON_WIDTH, ICON_HEIGHT);
    return event_box;
}

static gboolean on_icon_double_click(GtkWidget *widget, GdkEventButton *event, gpointer user_data) {
    // Only trigger on double-click
    if (event->type != GDK_2BUTTON_PRESS || event->button != 1) {
        return FALSE;
    }
    
    char *filepath = g_object_get_data(G_OBJECT(widget), "filepath");
    if (!filepath) return FALSE;
    
    // Try launching .desktop file
    if (g_str_has_suffix(filepath, ".desktop")) {
        GDesktopAppInfo *app_info = g_desktop_app_info_new_from_filename(filepath);
        if (app_info) {
            char *command_line = g_strdup(g_app_info_get_commandline(G_APP_INFO(app_info)));
            GError *error = NULL;
            
            gboolean success = g_spawn_command_line_async(command_line, &error);
            
            if (!success && error) {
                g_warning("Failed to launch: %s", error->message);
                g_error_free(error);
            }
            
            g_free(command_line);
            g_object_unref(app_info);
            return TRUE;
        }
    }
    
    // Fallback
    GError *error = NULL;
    char *command = g_strdup_printf("xdg-open \"%s\"", filepath);
    g_spawn_command_line_async(command, &error);
    g_free(command);
    
    if (error) {
        g_warning("Failed to launch fallback: %s", error->message);
        g_error_free(error);
    }
    
    return TRUE;
}

static void reload_grid_layout(DesktopIcons *desktop) {
    int total = g_list_length(desktop->icon_files);
    
    // Clear existing children
    GList *children = gtk_container_get_children(GTK_CONTAINER(desktop->grid));
    for (GList *child = children; child != NULL; child = child->next) {
        gtk_container_remove(GTK_CONTAINER(desktop->grid), GTK_WIDGET(child->data));
    }
    g_list_free(children);
    
    // Add icons in grid formation (column-major order)
    for (int i = 0; i < total; i++) {
        int column = i / desktop->icons_per_column;
        int row = i % desktop->icons_per_column;
        
        GtkWidget *icon = GTK_WIDGET(g_list_nth_data(desktop->icons, i));
        gtk_grid_attach(desktop->grid, icon, column, row, 1, 1);
    }
    
    gtk_widget_show_all(GTK_WIDGET(desktop->grid));
}

static void add_icon(DesktopIcons *desktop, const char *filepath) {
    GtkWidget *icon = create_icon_widget(filepath);
    desktop->icons = g_list_append(desktop->icons, icon);
}

static void load_desktop_files(DesktopIcons *desktop) {
    const char *desktop_path = g_get_user_special_dir(G_USER_DIRECTORY_DESKTOP);
    if (!desktop_path) {
        g_warning("Could not find desktop directory");
        return;
    }
    
    GList *order_list = load_icon_order();
    
    if (!order_list) {
        g_warning("No order config found. Please create %s/.config/%s/%s", g_get_user_config_dir(), CONFIG_DIR, ORDER_FILE);
        return;
    }
    
    desktop->icon_files = get_ordered_icon_list(desktop_path, order_list);
    g_list_free_full(order_list, g_free);
    
    if (!desktop->icon_files) {
        g_warning("No valid files found from order config");
        return;
    }
    
    for (GList *item = desktop->icon_files; item; item = item->next) {
        add_icon(desktop, (char*)item->data);
    }
}

static void calculate_icons_per_column(DesktopIcons *desktop, GtkWidget *window, DesktopConfig *config) {
    int available_height = 0;
    GdkWindow *gdk_window = gtk_widget_get_window(window);
    
    // Try to get monitor info
    if (gdk_window) {
        GdkDisplay *display = gdk_window_get_display(gdk_window);
        if (display) {
            GdkMonitor *monitor = gdk_display_get_monitor_at_window(display, gdk_window);
            
            if (monitor && GDK_IS_MONITOR(monitor)) {
                GdkRectangle workarea;
                gdk_monitor_get_workarea(monitor, &workarea);
                available_height = workarea.height;
            }
        }
    }
    
    // Fallback to screen dimensions if monitor detection failed
    if (available_height == 0) {
        #pragma GCC diagnostic push
        #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        GdkScreen *screen = gtk_widget_get_screen(window);
        if (screen) {
            available_height = gdk_screen_get_height(screen);
        } else {
            available_height = 768;  // Reasonable fallback
        }
        #pragma GCC diagnostic pop
    }
    
    // Calculate icons per column
    int usable_height = available_height - config->bottom_reserved - (2 * WINDOW_MARGIN);
    
    if (usable_height > 0) {
        desktop->icons_per_column = (usable_height + GRID_ROW_SPACING) / (ICON_HEIGHT + GRID_ROW_SPACING);
    } else {
        desktop->icons_per_column = 1;
    }
    
    // Ensure at least 1 icon per column
    if (desktop->icons_per_column < 1) {
        desktop->icons_per_column = 1;
    }
}

static void setup_layer_shell_window(GtkWidget *window, DesktopConfig *config) {
    gtk_layer_init_for_window(GTK_WINDOW(window));
    gtk_layer_set_namespace(GTK_WINDOW(window), "desktop-icons");
    gtk_layer_set_layer(GTK_WINDOW(window), GTK_LAYER_SHELL_LAYER_BACKGROUND);
    gtk_layer_set_keyboard_mode(GTK_WINDOW(window), GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);
    gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_TOP, TRUE);
    gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
    
    gtk_layer_set_margin(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_LEFT, WINDOW_MARGIN);
    gtk_layer_set_margin(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_RIGHT, WINDOW_MARGIN);
    gtk_layer_set_margin(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_TOP, WINDOW_MARGIN);
    gtk_layer_set_margin(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_BOTTOM, config->bottom_reserved + WINDOW_MARGIN);
}

static void cleanup(DesktopIcons *desktop) {
    if (desktop->icons) {
        g_list_free_full(desktop->icons, (GDestroyNotify)gtk_widget_destroy);
    }
    
    if (desktop->icon_files) {
        g_list_free_full(desktop->icon_files, g_free);
    }
    
    g_free(desktop);
}

// Main application activation handler
static void activate(GtkApplication *app, gpointer user_data) {
    DesktopConfig *config = load_configuration();
    
    DesktopIcons *desktop = g_new0(DesktopIcons, 1);
    
    // Create main window
    GtkWidget *window = gtk_application_window_new(app);
    setup_layer_shell_window(window, config);
    
    // Calculate layout
    calculate_icons_per_column(desktop, window, config);
    
    // Create scrolled window
    GtkWidget *scrolled_window = gtk_scrolled_window_new(NULL, NULL);
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolled_window), GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);
    
    // Create grid for icons
    desktop->grid = GTK_GRID(gtk_grid_new());
    gtk_grid_set_column_spacing(desktop->grid, GRID_COLUMN_SPACING);
    gtk_grid_set_row_spacing(desktop->grid, GRID_ROW_SPACING);
    
    load_desktop_files(desktop);
    
    if (desktop->icon_files && g_list_length(desktop->icon_files) > 0) {
        reload_grid_layout(desktop);
    } else {
        g_warning("No icons to display. Please check your config file.");
    }
    
    gtk_container_add(GTK_CONTAINER(scrolled_window), GTK_WIDGET(desktop->grid));
    gtk_container_add(GTK_CONTAINER(window), scrolled_window);
    
    apply_css_styling(window, "window, window.background { background-color: transparent; }");
    apply_css_styling(scrolled_window, "scrolledwindow, scrolledwindow.viewport { background-color: transparent; }");
    
    gtk_widget_show_all(window);
    g_signal_connect_swapped(window, "destroy", G_CALLBACK(cleanup), desktop);
    g_signal_connect_swapped(window, "destroy", G_CALLBACK(g_free), config);
}

int main(int argc, char **argv) {
    GtkApplication *app = gtk_application_new("com.example.icons", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    
    return status;
}
