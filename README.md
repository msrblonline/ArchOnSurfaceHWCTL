# ArchOnSurfaceHWCTL
*MS Surface SE Hardware Control Script (Arch + KDE)*

Brightness and volume control for the Microsoft Surface Laptop SE
running Arch Linux with KDE Plasma.

------------------------------------------------------------------------

## Overview

The Linux kernel currently does not support the hardware keys for
adjusting brightness or volume on the Microsoft Surface Laptop SE.\
This script provides a simple workaround by allowing brightness and
volume to be controlled via custom keyboard shortcuts.

------------------------------------------------------------------------

## Features

-   Screen brightness control
-   Audio volume control
-   Designed for KDE Plasma
-   Lightweight shell script with minimal dependencies

------------------------------------------------------------------------

## Requirements

### Brightness Control

Brightness control uses `qdbus`, which is included in the `qt5-tools`
package:

``` bash
pacman -S qt5-tools
```

### Volume Control

Volume control uses `pactl`, which is typically available on systems
with a working PulseAudio or PipeWire audio setup.

------------------------------------------------------------------------

## Usage

``` text
hwctl.sh MODE ACTION
```

### Modes (required)

Choose exactly one:

-   `-b`, `--brightness`\
    Control screen brightness

-   `-v`, `--volume`\
    Control audio volume

### Actions (required)

Choose exactly one:

-   `-u`, `--up`\
    Increase value

-   `-d`, `--down`\
    Decrease value

-   `--min`\
    Set to minimum

-   `--max`\
    Set to maximum

### Other Options

-   `-h`, `--help`\
    Show the help message

------------------------------------------------------------------------

## Examples

``` bash
# Increase brightness
hwctl.sh -b -u

# Set volume to maximum
hwctl.sh --volume --max
```

------------------------------------------------------------------------

## KDE Keyboard Shortcuts

The script is intended to be used with KDE keyboard shortcuts:

    Settings → Input & Output → Keyboard → Shortcuts

You can map key combinations (for example, **Ctrl + Shift + Arrow
Keys**) to execute the script with the desired parameters.

------------------------------------------------------------------------

## License

This project is licensed under the **GNU General Public License v3.0 or
later**.\
See the `LICENSE` file for details.
