I can include other files using:
```
include "file.widget"
```

---

The top-level container can be either `bar`, `popup` or `widget_grid`

`bar`: A permanent panel stuck to an edge of your screen (top, bottom, left, right)

`popup`: A temporary floating window that appears when triggered and disappears when you click away. Used for things like displaying the calender, WiFi list and power options

`widget_grid`: A free-floating group of widgets placed anywhere on the screen (not tied to a bar). Good for little desktop gadgets (CPU, RAM, weather). Can also be used inside a bar or popup to group widgets together. Works like a mini-container.