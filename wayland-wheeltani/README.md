[![CI](https://github.com/docloulou/Wayland-Wheeltani/actions/workflows/ci.yml/badge.svg)](https://github.com/docloulou/Wayland-Wheeltani/actions/workflows/ci.yml)
[![CodeQL](https://github.com/docloulou/Wayland-Wheeltani/actions/workflows/codeql.yml/badge.svg)](https://github.com/docloulou/Wayland-Wheeltani/actions/workflows/codeql.yml)
[![License: 0BSD](https://img.shields.io/badge/license-0BSD-brightgreen.svg)](LICENSE)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/W7W01LZHA2)

# Wayland-Wheeltani

Progressive middle-click autoscroll for Wayland.

Hold the middle mouse button, move vertically or horizontally, and
Wayland-Wheeltani emits smooth wheel events through a virtual mouse. Release the
middle button and scrolling stops immediately. A short middle click still
behaves like a normal middle click.

```text
hold middle button
  ├─ tiny movement inside deadzone       -> normal middle click on release
  ├─ move down from press position       -> continuous scroll down
  ├─ move right from press position      -> continuous horizontal scroll right
  ├─ move farther from press position    -> faster scroll
  ├─ return near press position          -> scroll slows/stops
  └─ cross the press position            -> scroll reverses on that axis
```

Prefer clicking once instead of holding? `mode = "toggle_progressive"` latches
scroll mode on a click and ends it on the next one.

No GUI, no overlay, no network, no keyboard capture. The project is split into a
portable, unit-tested Rust core and a Linux backend using `evdev` + `uinput`.


## License

Released under the [BSD Zero Clause License](LICENSE) (0BSD) — do whatever you
want with it, no attribution required.
