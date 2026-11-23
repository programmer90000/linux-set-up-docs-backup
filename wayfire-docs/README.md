# [Wayfire]

[Wayfire]: https://wayfire.org

![Version](https://img.shields.io/github/v/release/WayfireWM/wayfire)
[![Matrix: #wayfire:matrix.org](https://img.shields.io/badge/matrix-%23wayfire%3Amatrix.org-blue)](https://matrix.to/#/#wayfire:matrix.org)
[![IRC: #wayfire on Libera.chat](https://img.shields.io/badge/IRC-%23wayfire%20at%20libera.chat-green)](https://web.libera.chat/#wayfire)
[![Discord](https://img.shields.io/discord/1144831589877043220?label=Discord)](https://discord.gg/5SWAxmBCUH)
[![CI](https://github.com/WayfireWM/wayfire/workflows/CI/badge.svg)](https://github.com/WayfireWM/wayfire/actions)
[![Packaging status](https://repology.org/badge/tiny-repos/wayfire.svg)](https://repology.org/project/wayfire/versions)
[![License](https://img.shields.io/github/license/WayfireWM/wayfire)](LICENSE)

###### [Get started] | [Manual] | [Configuration]

[Get started]: https://github.com/WayfireWM/wayfire/wiki/Tutorial
[Manual]: https://github.com/WayfireWM/wayfire/wiki/General
[Configuration]: https://github.com/WayfireWM/wayfire/wiki/Configuration

Wayfire is a 3D [Wayland] compositor, inspired by [Compiz] and based on [wlroots].

It aims to create a customizable, extendable and lightweight environment without sacrificing its appearance.

[![Wayfire demos](https://img.youtube.com/vi_webp/2PtNzxDsxYM/maxresdefault.webp)](https://youtube.com/playlist?list=PLb7YRKEhWEBUIoT-a29UoJW9mhfzjpNle "YouTube – Wayfire demos")
[![YouTube Play Button](https://www.iconfinder.com/icons/317714/download/png/16)](https://youtube.com/playlist?list=PLb7YRKEhWEBUIoT-a29UoJW9mhfzjpNle) · [Wayfire demos](https://youtube.com/playlist?list=PLb7YRKEhWEBUIoT-a29UoJW9mhfzjpNle)

[Wayland]: https://wayland.freedesktop.org
[wlroots]: https://github.com/swaywm/wlroots
[Compiz]: https://launchpad.net/compiz

## Dependencies

### Wayfire Dependencies

These are the dependencies needed for building Wayfire.

- [Cairo](https://cairographics.org)
- [Pango](https://pango.gnome.org/) and PangoCairo
- [FreeType](https://freetype.org)
- [GLM](https://glm.g-truc.net)
- [libdrm](https://dri.freedesktop.org/wiki/DRM/)
- [libevdev](https://freedesktop.org/wiki/Software/libevdev/)
- [libGL](https://mesa3d.org)
- [libinput](https://freedesktop.org/wiki/Software/libinput/)
- [libjpeg](https://libjpeg-turbo.org)
- [libpng](http://libpng.org/pub/png/libpng.html)
- [libxkbcommon](https://xkbcommon.org)
- [libxml2](http://xmlsoft.org/)
- [Pixman](https://pixman.org)
- [pkg-config](https://freedesktop.org/wiki/Software/pkg-config/)
- [Wayland](https://wayland.freedesktop.org)
- [wayland-protocols](https://gitlab.freedesktop.org/wayland/wayland-protocols)
- [wf-config](https://github.com/WayfireWM/wf-config)
- [wlroots](https://github.com/swaywm/wlroots)

### wlroots Dependencies

These are the dependencies needed for building wlroots, and should be installed before building it.
They are relevant for cases when the system doesn't have a version of wlroots installed.

#### DRM Backend (required)

- [libdisplay-info-dev](https://gitlab.freedesktop.org/emersion/libdisplay-info)
- [hwdata-dev](https://github.com/vcrhonek/hwdata)

#### GLES2 renderer (required)
- [libglvnd](https://gitlab.freedesktop.org/glvnd/libglvnd)
- [mesa](https://gitlab.freedesktop.org/mesa/mesa) (with libEGL and gbm support)

#### Libinput Backend (required)
- [libinput](https://gitlab.freedesktop.org/libinput/libinput)

#### Session Provider (required)

- libudev (via [systemd](https://systemd.io/) **or** other providers)
- [seatd](https://git.sr.ht/~kennylevinsen/seatd)

#### XWayland Support (optional)

- [xcb](https://xcb.freedesktop.org/)
- [xcb-composite](https://xorg.freedesktop.org/wiki/)
- [xcb-render](https://xorg.freedesktop.org/wiki/)
- [xcb-xfixes](https://xorg.freedesktop.org/wiki/)

#### X11 Backend (optional)

- [xcb](https://xcb.freedesktop.org/)
- [x11-xcb](https://xcb.freedesktop.org/)
- [xcb-xinput](https://xorg.freedesktop.org/wiki/)
- [xcb-xfixes](https://xorg.freedesktop.org/wiki/)

## Configuration

Copy [`wayfire.ini`] to `~/.config/wayfire.ini` or `~/.config/wayfire/wayfire.ini`