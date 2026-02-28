# dotfiles

Personal Arch Linux dotfiles for Hyprland.

## Supported Devices

| Profile | Description |
|---|---|
| `pc` | Desktop PC |
| `laptop` | Generic Laptop |
| `galaxybook5` | Samsung Galaxy Book5 Pro 360 |

## Install

```bash
git clone https://github.com/yourusername/dotfiles
cd dotfiles
./install.sh
```

The installer will ask for your device profile and then:
- Install all required packages
- Set fish as default shell
- Link config files
- Enable system services

For **Samsung Galaxy Book5**: also installs the speaker fix, keyboard backlight control and sets battery charge threshold to 80%.

## Structure

```
dotfiles/
├── install.sh
├── hypr/
│   └── hyprland.conf
├── kitty/
│   └── kitty.conf
├── fish/
│   ├── config.fish
│   └── fish_variables
├── Kvantum/
├── xdg-desktop-portal/
│   └── hyprland-portals.conf
├── dolphinrc
├── starship.toml
├── acpi/                          # Galaxy Book5 only
│   ├── samsung-kbd-backlight.sh
│   └── events/
│       └── samsung-kbd-backlight
└── udev/                          # Galaxy Book5 only
    └── 99-samsung-galaxybook.rules
```

## What's Included

**Shell:** fish + starship prompt  
**Terminal:** kitty  
**Window Manager:** Hyprland  
**Bar:** AGS v2 / Astal  
**Launcher:** wofi  
**Notifications:** dunst  
**Browser:** Zen Browser  
**Editor:** VSCodium  
**File Manager:** Dolphin  

## Galaxy Book5 Hardware Status

| Feature | Status |
|---|---|
| Audio (Speakers) | ✅ via MAX98390 DKMS fix |
| Battery Threshold | ✅ 80% limit |
| Keyboard Backlight (Fn+F9) | ✅ via acpid |
| Brightness / Volume Fn-Keys | ✅  |
| Bluetooth | ✅ |
| Camera | ⚠️ Work in progress |

## Credits

- [Andycodeman](https://github.com/Andycodeman/samsung-galaxy-book4-linux-fixes) – Speaker fix