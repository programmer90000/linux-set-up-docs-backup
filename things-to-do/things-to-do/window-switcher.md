Display the windows in a horizontal layout, like the screenshot

If an app contains 1 window, that window should be displayed in the initial screen. If an app contains multiple windows, only the app name should be shown, along with an indication that it contains multiple windows. Clicking the app should display all windows of that app.

There should be a search box at the top of the screen. On the right edge of the search box, inside the white area, add buttons for filter and sort

Features to set via the config file

| Feature | Done |
|---------|-----------|
| width | ✅ |
| height | ✅ |
| window decorations | ✅ |
| background colour | ✅ |
| opacity | ✅ |
| text colour | ✅ |
| text size | ✅ |
| size of app icons in the app | ❌ |
| item spacing | ❌ |
| Layout of items (horizontal, vertical, grid) | ❌ |
| Enable/ Disable search bar | ❌ |
| Search bar size | ❌ |
| Keyboard shortcuts | ❌ |
| Mouse behaviour (single/ double click to select) | ❌ |
| Show windows from current workspace or all workspaces | ❌ |
| Group windows by app or not | ❌ |
| location Note: The location can't be changed by Rust. I will need to update LabWC to set the location | ❌ |

Make a file which maps each app to an icon. For example:
```
[icons]
firefox = "/home/user/icons/custom-firefox.png"
chromium = "/home/user/icons/chromium-custom.svg"
alacritty = "/usr/share/pixmaps/alacritty.png"
# Or use app IDs
"org.gnome.Calculator" = "/home/user/icons/calc.png"
```