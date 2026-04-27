#!/bin/bash
# ============================================================
#  Dotfiles Installer
#  Usage: ./install.sh [--noconfirm]
# ============================================================

# ── Guards ────────────────────────────────────────────────
if [[ "$EUID" -eq 0 ]]; then
    echo "ERROR: Do not run as root or with sudo."
    exit 1
fi

if ! command -v pacman &>/dev/null; then
    echo "ERROR: This script requires Arch Linux / pacman."
    exit 1
fi

set -euo pipefail

# ── Config ────────────────────────────────────────────────
NOCONFIRM=false
[[ "${1:-}" == "--noconfirm" ]] && NOCONFIRM=true

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
PARU=false
LOG="$DOTFILES/install.log"
CURRENT_USER="$(whoami)"

# ── Logging ───────────────────────────────────────────────
: > "$LOG"
exec > >(tee -a "$LOG") 2>&1> >(tee -a "$LOG") 2>&1
echo "==> Install started: $(date)"

# ── Error trap (initial, before sudo keepalive) ───────────
trap 'echo ""; echo "ERROR on line $LINENO. Check $LOG for details."; exit 1' ERR

# ── Helpers ───────────────────────────────────────────────
confirm() {
    if $NOCONFIRM; then
        echo "==> [auto] $1"
        return 0
    fi
    echo ""
    echo "==> $1"
    read -rp "    Continue? [Y/n] " yn
    [[ "$yn" =~ ^[Nn]$ ]] && echo "    Skipped." && return 1
    return 0
}

pacman_install() {
    sudo pacman -S --needed --noconfirm "$@"
}

paru_install() {
    paru -S --needed --noconfirm "$@"
}

safe_link() {
    local src="$1" dst="$2"
    if [[ ! -e "$src" ]]; then
        echo "    WARNING: Source not found, skipping: $src"
        return
    fi
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "${dst}.bak"
        echo "    Backed up: $dst → ${dst}.bak"
    fi
    ln -sf "$src" "$dst"
}

sudo_safe_link() {
    local src="$1" dst="$2"
    if [[ ! -e "$src" ]]; then
        echo "    WARNING: Source not found, skipping: $src"
        return
    fi
    sudo mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        sudo mv "$dst" "${dst}.bak"
        echo "    Backed up: $dst → ${dst}.bak"
    fi
    sudo ln -sf "$src" "$dst"
}

require_file() {
    [[ -f "$1" ]] || { echo "ERROR: Required file missing: $1"; exit 1; }
}

# ── Profile selection ─────────────────────────────────────
echo ""
echo "Select device profile:"
echo "  1) PC"
echo "  2) Laptop (generic)"
echo "  3) Samsung Galaxy Book5"
read -rp "Choice [1-3]: " choice

case $choice in
    1) PROFILE="pc" ;;
    2) PROFILE="laptop" ;;
    3) PROFILE="galaxybook5" ;;
    *) echo "Invalid choice."; exit 1 ;;
esac

echo "==> Profile: $PROFILE"
read -rp "Press Enter to start or Ctrl+C to abort..."

# ── Sudo keepalive ────────────────────────────────────────
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_PID=$!
trap 'kill $SUDO_PID 2>/dev/null; echo ""; echo "ERROR on line $LINENO. Check $LOG for details."; exit 1' ERR
trap 'kill $SUDO_PID 2>/dev/null' EXIT


# ╔══════════════════════════════════════════════════════════╗
# ║  CORE — Immer installiert (kein confirm)                ║
# ╚══════════════════════════════════════════════════════════╝

# ── CORE 1: Hyprland & Display Stack ─────────────────────
echo ""
echo "==> [CORE] Hyprland & display stack"
pacman_install \
    hyprland xdg-desktop-portal-hyprland \
    hypridle hyprlock hyprpicker hyprpaper hyprsunset \
    polkit-gnome sddm jq papirus-icon-theme which wget playerctl cava

require_file "$DOTFILES/sddm/sddm.conf"
sudo cp -r "$DOTFILES/sddm/Sugar-Candy" /usr/share/sddm/themes/
sudo mkdir -p /usr/share/sddm/themes/Sugar-Candy/Backgrounds

case $PROFILE in
    galaxybook5)
        wallpaper="$DOTFILES/assets/wallpaper_8x5/spaceman_floating_in_space-wallpaper.jpg" ;;
    pc)
        wallpaper="$DOTFILES/assets/wallpaper_21x9/spaceman_floating_in_space-wallpaper.jpg" ;;
    *)
        wallpaper="" ;;
esac
[[ -n "$wallpaper" && -f "$wallpaper" ]] && \
    sudo cp "$wallpaper" /usr/share/sddm/themes/Sugar-Candy/Backgrounds/


# ── CORE 2: Audio ────────────────────────────────────────
echo ""
echo "==> [CORE] Audio (pipewire, pavucontrol)"
pacman_install pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol


# ── CORE 3: Network & Bluetooth ──────────────────────────
echo ""
echo "==> [CORE] Network & Bluetooth"
pacman_install \
    networkmanager network-manager-applet \
    bluez bluez-utils blueman


# ── CORE 4: Laptop-specific (immer, wenn Laptop-Profil) ──
if [[ "$PROFILE" == "laptop" || "$PROFILE" == "galaxybook5" ]]; then
    echo ""
    echo "==> [CORE] Laptop packages (brightness, power, ACPI)"
    pacman_install \
        brightnessctl acpid dkms linux-headers i2c-tools power-profiles-daemon
    sudo systemctl enable --now acpid
    sudo systemctl enable --now power-profiles-daemon

    if [[ "$PROFILE" == "galaxybook5" ]]; then
        echo ""
        echo "==> [CORE] Samsung ACPI buttons log spam fix"
        require_file "$DOTFILES/acpi/events/buttons"
        sudo cp "$DOTFILES/acpi/events/buttons" /etc/acpi/events/buttons

        echo ""
        echo "==> [CORE] Samsung ACPI keyboard backlight"
        require_file "$DOTFILES/acpi/samsung-kbd-backlight.sh"
        require_file "$DOTFILES/acpi/events/samsung-kbd-backlight"
        sudo install -m 755 "$DOTFILES/acpi/samsung-kbd-backlight.sh" /etc/acpi/samsung-kbd-backlight.sh
        sudo cp "$DOTFILES/acpi/events/samsung-kbd-backlight" /etc/acpi/events/samsung-kbd-backlight

        echo ""
        echo "==> [CORE] Samsung ACPI mic mute button"
        require_file "$DOTFILES/acpi/samsung-mic-mute.sh"
        require_file "$DOTFILES/acpi/events/samsung-mic-mute"
        sudo install -m 755 "$DOTFILES/acpi/samsung-mic-mute.sh" /etc/acpi/samsung-mic-mute.sh
        sudo cp "$DOTFILES/acpi/events/samsung-mic-mute" /etc/acpi/events/samsung-mic-mute

        echo ""
        echo "==> [CORE] Battery charge threshold (80%)"
        require_file "$DOTFILES/udev/99-samsung-galaxybook.rules"
        sudo cp "$DOTFILES/udev/99-samsung-galaxybook.rules" /etc/udev/rules.d/
        sudo udevadm control --reload-rules

        echo ""
        echo "==> [CORE] S Pen / libwacom tablet profile"
        pacman_install libwacom
        require_file "$DOTFILES/libwacom/samsung-galaxy-book5-pro-360.tablet"
        sudo cp "$DOTFILES/libwacom/samsung-galaxy-book5-pro-360.tablet" \
            /usr/share/libwacom/samsung-galaxy-book5-pro-360.tablet

        echo ""
        echo "==> [CORE] Intel ISH Firmware für Tablet Mode"
        require_file "$DOTFILES/driver/ish_lnlm_053dca6a.bin"
        sudo mkdir -p /lib/firmware/intel/ish
        sudo cp "$DOTFILES/driver/ish_lnlm_053dca6a.bin" /lib/firmware/intel/ish/

        echo ""
        echo "==> [CORE] iio-sensor-proxy & Autorotation"
        pacman_install iio-sensor-proxy
        paru_install iio-hyprland-git

        echo ""
        echo "==> [CORE] Tablet mode"
        require_file "$DOTFILES/acpi/events/tablet-mode"
        require_file "$DOTFILES/acpi/tablet-mode.sh"
        sudo install -m 755 "$DOTFILES/acpi/tablet-mode.sh" /etc/acpi/tablet-mode.sh
        sudo cp "$DOTFILES/acpi/events/tablet-mode" /etc/acpi/events/tablet-mode

        sudo systemctl restart acpid
    fi
fi


# ── CORE 5: System Services ───────────────────────────────
echo ""
echo "==> [CORE] Enable system services (NetworkManager, Bluetooth, SDDM)"
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable sddm

if [[ "$PROFILE" == "laptop" || "$PROFILE" == "galaxybook5" ]]; then
    echo ""
    echo "==> [CORE] Power button → hibernate"
    require_file "$DOTFILES/logind/power.conf"
    sudo_safe_link "$DOTFILES/logind/power.conf" /etc/systemd/logind.conf.d/power.conf
fi

# ── CORE 6: AUR ────────────────────────────────────────────
echo ""
echo "==> [CORE] Install AUR package-manager: Paru"
if ! command -v paru &>/dev/null; then
    pacman_install rust base-devel
    [[ -d /tmp/paru ]] && rm -rf /tmp/paru
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm && cd "$DOTFILES"
    PARU=true
else
    echo "==> paru already installed."
    PARU=true
fi

# ── CORE 7: AGS-Shell ────────────────────────────────────────────
echo ""
echo "==> [CORE] Install AGS-Shell"
if $PARU; then
    paru_install aylurs-gtk-shell-git libastal-meta swayosd-git wlogout
fi

# ── CORE 8: Dotfile Links ─────────────────────────────────
echo ""
echo "==> [CORE] Link dotfile configs"
if command -v xdg-user-dirs-update &>/dev/null; then
    xdg-user-dirs-update
else
    mkdir -p ~/Pictures/Screenshots ~/Documents ~/Videos ~/Dev
fi

sudo_safe_link "$DOTFILES/sddm/sddm.conf" /etc/sddm.conf
sudo sed -i.bak "s/^User=.*/User=$CURRENT_USER/" /etc/sddm.conf

safe_link "$DOTFILES/hypr/hyprland.conf"                       ~/.config/hypr/hyprland.conf
safe_link "$DOTFILES/hypr/hyprpaper.conf"                      ~/.config/hypr/hyprpaper.conf
safe_link "$DOTFILES/hypr/hypridle.conf"                       ~/.config/hypr/hypridle.conf
if [[ "$PROFILE" == "pc" ]]; then
    safe_link "$DOTFILES/hypr/hyprlock_pc.conf" ~/.config/hypr/hyprlock.conf
else
    safe_link "$DOTFILES/hypr/hyprlock.conf"    ~/.config/hypr/hyprlock.conf
fi
safe_link "$DOTFILES/hypr/hyprsunset.conf"                     ~/.config/hypr/hyprsunset.conf
safe_link "$DOTFILES/xdg-desktop-portal/hyprland-portals.conf" ~/.config/xdg-desktop-portal/portals.conf


# ╔══════════════════════════════════════════════════════════╗
# ║  EXTRAS — Mit confirm                                   ║
# ╚══════════════════════════════════════════════════════════╝

if $PARU && confirm "EXTRA — Theming (ags, wlogout, nordzy-cursors, tokyonight-theme)"; then
    paru_install aylurs-gtk-shell-git libastal-meta swayosd-git wlogout \
        nordzy-cursors tokyonight-gtk-theme-git

    if command -v wlogout &>/dev/null; then
        safe_link "$DOTFILES/wlogout/layout" ~/.config/wlogout/layout
    fi
fi

# ── Splash screen (nur mit systemd-boot) ─────────────────
if bootctl status &>/dev/null; then
    if confirm "EXTRA — Plymouth splash screen"; then
        pacman_install plymouth
        grep -q "plymouth" /etc/mkinitcpio.conf || \
            sudo sed -i 's/\(HOOKS=.*udev\)/\1 plymouth/' /etc/mkinitcpio.conf
        for entry in /boot/loader/entries/*.conf; do
            grep -q "quiet splash" "$entry" || \
                sudo sed -i '/^options/ s/$/ quiet splash/' "$entry"
        done
        require_file "$DOTFILES/plymouth/sweet-arch/sweet-arch.plymouth"
        sudo cp -a "$DOTFILES/plymouth/sweet-arch" /usr/share/plymouth/themes/
        sudo plymouth-set-default-theme -R sweet-arch
    fi
fi


# ── Shell & Terminal ──────────────────────────────────────
if confirm "EXTRA — Shell & terminal (kitty, fish, starship, eza, fastfetch)"; then
    pacman_install kitty fish eza starship fastfetch

    safe_link "$DOTFILES/kitty/kitty.conf"     ~/.config/kitty/kitty.conf
    safe_link "$DOTFILES/kitty/colors.conf"    ~/.config/kitty/colors.conf
    safe_link "$DOTFILES/kitty/search.py"      ~/.config/kitty/search.py
    safe_link "$DOTFILES/kitty/scroll_mark.py" ~/.config/kitty/scroll_mark.py
    safe_link "$DOTFILES/fish/config.fish"     ~/.config/fish/config.fish
    safe_link "$DOTFILES/fish/fish_variables"  ~/.config/fish/fish_variables
    [[ -f "$DOTFILES/starship.toml" ]] && \
        safe_link "$DOTFILES/starship.toml"    ~/.config/starship.toml

    if confirm "EXTRA — Set fish as default shell"; then
        if command -v fish &>/dev/null; then
            chsh -s "$(command -v fish)"
        else
            echo "    WARNING: fish not found, skipping chsh."
        fi
    fi
fi


# ── UI & Wayland Tools ────────────────────────────────────
if confirm "EXTRA — UI & Wayland tools (wofi, clipboard, grim, slurp)"; then
    pacman_install wofi wl-clipboard cliphist pacman-contrib grim slurp

    safe_link "$DOTFILES/wofi/config"    ~/.config/wofi/config
    safe_link "$DOTFILES/wofi/style.css" ~/.config/wofi/style.css
fi


# ── Fonts ─────────────────────────────────────────────────
if confirm "EXTRA — Fonts (JetBrains Nerd-Font, Inter-Font, Noto-Emojis)"; then
    pacman_install ttf-jetbrains-mono-nerd noto-fonts-emoji inter-font
fi


# ── File Manager & CLI Tools ──────────────────────────────
if confirm "EXTRA — File manager & CLI tools (thunar, ranger, btop, fzf …)"; then
    pacman_install \
        thunar thunar-archive-plugin thunar-media-tags-plugin tumbler \
        ffmpegthumbnailer gvfs \
        ranger \
        nano btop unzip fzf \
        xdg-user-dirs

    if confirm "EXTRA — Remote desktop tools (remmina, freerdp, openssh)"; then
        pacman_install remmina freerdp openssh
    fi
fi


# ── Dev Tools ─────────────────────────────────────────────
if confirm "EXTRA — Programming languages"; then
    pacman_install git cmake ninja meson

    confirm "DEV — C/C++ (gcc, clang, clangd, gdb)" && pacman_install gcc clang gdb
    confirm "DEV — Rust (rustc, cargo)"              && pacman_install rust
    confirm "DEV — Java (jdk21-openjdk)"             && pacman_install jdk21-openjdk
    confirm "DEV — Kotlin"                           && pacman_install kotlin
    confirm "DEV — Go"                               && pacman_install go
    confirm "DEV — Node.js / TypeScript"             && pacman_install nodejs npm && npm config set prefix ~/.local && npm install -g typescript
    confirm "DEV — Python"                           && pacman_install python python-pip
    confirm "DEV — PHP"                              && pacman_install php
    confirm "DEV — Lua"                              && pacman_install lua
    confirm "DEV — Zig"                              && pacman_install zig
fi

# ── Extra Tools ───────────────────────────────────────────
if confirm "EXTRA — Tools"; then
    confirm "Obsidian"   && pacman_install obsidian
    confirm "Email"      && pacman_install thunderbird
    confirm "Backup"     && pacman_install timeshift
    confirm "Antivirus"  && pacman_install clamtk
    if $PARU; then
        confirm "Airdrop"       && paru_install localsend-bin
        confirm "Firewall"      && paru_install portmaster-bin
        confirm "Zen-Browser"   && paru_install zen-browser-bin
        confirm "VS-Codium"     && paru_install vscodium-bin
        confirm "Spotify"       && paru_install spotify
    fi
fi

# ── Samsung Galaxy Book5 Extras ───────────────────────────
if [[ "$PROFILE" == "galaxybook5" ]]; then
    if confirm "EXTRA — Samsung speaker fix"; then
        pacman_install sof-firmware
        REPO_DIR="/tmp/samsung-galaxy-book4-linux-fixes"
        [[ -d "$REPO_DIR" ]] && rm -rf "$REPO_DIR"
        git clone https://github.com/Andycodeman/samsung-galaxy-book4-linux-fixes "$REPO_DIR"
        [[ -d "$REPO_DIR/speaker-fix" ]] || { echo "ERROR: speaker-fix missing."; exit 1; }
        cd "$REPO_DIR/speaker-fix" && sudo ./install.sh && cd "$DOTFILES"
    fi

    if confirm "EXTRA — EasyEffects + presets"; then
        pacman_install easyeffects calf lsp-plugins
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/EasyEffects-Presets/master/install.sh)"
        echo "==> Open EasyEffects to select a preset."
    fi
fi

# ── GTK Theme, Icons, Cursor ──────────────────────────────
if confirm "EXTRA — Apply GTK theme, icons & cursor"; then
    mkdir -p ~/.config/gtk-3.0
    cat > ~/.config/gtk-3.0/settings.ini << 'INI'
[Settings]
gtk-theme-name=Tokyonight-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Nordzy-cursors
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 11
INI

    gsettings set org.gnome.desktop.interface gtk-theme    "Tokyonight-Dark"
    sudo_safe_link "$DOTFILES/LunaIcons" /usr/share/icons/LunaIcons
    gsettings set org.gnome.desktop.interface icon-theme   "LunaIcons"
    gsettings set org.gnome.desktop.interface cursor-theme "Nordzy-cursors"
    gsettings set org.gnome.desktop.interface cursor-size  24
    gsettings set org.gnome.desktop.interface font-name    "JetBrainsMono Nerd Font 11"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
fi


# ── Done ──────────────────────────────────────────────────
echo ""
echo "==> Install finished: $(date)"
echo "==> Log saved to: $LOG"
echo "==> Reboot to apply all changes."
