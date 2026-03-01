#!/bin/bash
if [[ "$EUID" -eq 0 ]]; then
    echo "This script must NOT be run as root or with sudo."
    echo "Run it as a normal user: ./install.sh"
    exit 1
fi

set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

trap 'echo "==> Error on line $LINENO. Aborting."; exit 1' ERR

# ── Helper ────────────────────────────────────────────────
confirm() {
    echo ""
    echo "==> Step: $1"
    read -rp "    Continue? [Y/n] " yn
    [[ "$yn" =~ ^[Nn]$ ]] && echo "    Skipped." && return 1
    return 0
}

# ── Profil wählen ─────────────────────────────────────────
echo "Select device profile:"
echo "  1) PC"
echo "  2) Laptop (generic)"
echo "  3) Samsung Galaxy Book5"
read -rp "Choice [1-3]: " choice

case $choice in
    1) PROFILE="pc" ;;
    2) PROFILE="laptop" ;;
    3) PROFILE="galaxybook5" ;;
    *) echo "Invalid choice"; exit 1 ;;
esac

echo "==> Profile: $PROFILE"
read -rp "Press Enter to start or Ctrl+C to abort..."

# ── Sudo keepalive ────────────────────────────────────────
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ── Step 1a: Hyprland / Display ───────────────────────────
if confirm "Install Hyprland & display packages"; then
    sudo pacman -S --needed \
        hyprland xdg-desktop-portal-hyprland hypridle hyprpicker hyprpaper hyprsunset \
        polkit-kde-agent sddm
fi

# ── Step 1b: Shell & Terminal ─────────────────────────────
if confirm "Install shell & terminal (kitty, fish, starship, eza)"; then
    sudo pacman -S --needed kitty fish eza starship
fi

# ── Step 1c: UI Tools ─────────────────────────────────────
if confirm "Install UI tools (wofi, dunst, clipboard)"; then
    sudo pacman -S --needed wofi dunst wl-clipboard cliphist
fi

# ── Step 1d: Network & Bluetooth ─────────────────────────
if confirm "Install network & bluetooth"; then
    sudo pacman -S --needed \
        networkmanager network-manager-applet \
        bluez bluez-utils blueman
fi

# ── Step 1e: Audio ────────────────────────────────────────
if confirm "Install audio (pipewire, pavucontrol)"; then
    sudo pacman -S --needed pipewire pipewire-pulse wireplumber pavucontrol
fi

# ── Step 1f: Fonts ────────────────────────────────────────
if confirm "Install fonts"; then
    sudo pacman -S --needed ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
fi

# ── Step 1g: CLI Tools ────────────────────────────────────
if confirm "Install CLI tools (btop, fzf, ffmpeg, ...)"; then
    sudo pacman -S --needed \
        git base-devel \
        nano btop grim slurp unzip p7zip ffmpeg fzf
fi

# ── Step 1h: File Manager & Remote ────────────────────────
if confirm "Install file manager & remote tools (dolphin, remmina, ...)"; then
    sudo pacman -S --needed \
        kvantum dolphin ffmpegthumbnailer gvfs ranger \
        remmina freerdp openssh
fi

# ── Step 2: Laptop Packages ───────────────────────────────
if [[ "$PROFILE" == "laptop" || "$PROFILE" == "galaxybook5" ]]; then
    if confirm "Install laptop packages (brightnessctl, acpid, power-profiles-daemon, ...)"; then
        sudo pacman -S --needed \
            brightnessctl acpid dkms linux-headers i2c-tools power-profiles-daemon
        sudo systemctl enable --now acpid
        sudo systemctl enable --now power-profiles-daemon
    fi
fi

# ── Step 3: Services ──────────────────────────────────────
if confirm "Enable system services (NetworkManager, Bluetooth, SDDM)"; then
    sudo systemctl enable --now NetworkManager
    sudo systemctl enable --now bluetooth
    sudo systemctl enable sddm
fi

# ── Step 4: Default Shell ─────────────────────────────────
if confirm "Set fish as default shell"; then
    chsh -s /usr/bin/fish
fi

# ── Step 5: AUR Helper ────────────────────────────────────
if ! command -v yay &>/dev/null; then
    if confirm "Install yay (AUR helper)"; then
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si && cd "$DOTFILES"
    fi
else
    echo "==> yay already installed, skipping."
fi

# ── Step 6: AUR Packages ─────────────────────────────────
if confirm "Install AUR packages (zen-browser, vscodium, ags)"; then
    yay -S --needed zen-browser-bin vscodium-bin aylurs-gtk-shell-git
    if [[ "$PROFILE" == "laptop" || "$PROFILE" == "galaxybook5" ]]; then
        yay -S --needed swayosd-git
    fi
fi

# ── Step 7: Link Configs ──────────────────────────────────
if confirm "Link dotfile configs (~/.config/...)"; then
    mkdir -p ~/.config/hypr ~/.config/kitty ~/.config/Kvantum \
             ~/.config/fish ~/.config/xdg-desktop-portal

    ln -sf "$DOTFILES/hypr/hyprland.conf"                          ~/.config/hypr/hyprland.conf
    ln -sf "$DOTFILES/kitty/kitty.conf"                            ~/.config/kitty/kitty.conf
    ln -sf "$DOTFILES/fish/config.fish"                            ~/.config/fish/config.fish
    ln -sf "$DOTFILES/fish/fish_variables"                         ~/.config/fish/fish_variables
    ln -sf "$DOTFILES/Kvantum"                                     ~/.config/Kvantum
    ln -sf "$DOTFILES/xdg-desktop-portal/hyprland-portals.conf"   ~/.config/xdg-desktop-portal/portals.conf
    ln -sf "$DOTFILES/dolphinrc"                                   ~/.config/dolphinrc
    [ -f "$DOTFILES/starship.toml" ] && \
        ln -sf "$DOTFILES/starship.toml"                           ~/.config/starship.toml
fi

# ── Step 8: Samsung Galaxy Book5 ─────────────────────────
if [[ "$PROFILE" == "galaxybook5" ]]; then

    if confirm "Install Samsung ACPI keyboard backlight"; then
        sudo cp "$DOTFILES/acpi/samsung-kbd-backlight.sh" /etc/acpi/samsung-kbd-backlight.sh
        sudo chmod +x /etc/acpi/samsung-kbd-backlight.sh
        sudo cp "$DOTFILES/acpi/events/samsung-kbd-backlight" /etc/acpi/events/samsung-kbd-backlight
        sudo systemctl restart acpid
    fi

    if confirm "Install udev rules (battery threshold 80%)"; then
        sudo cp "$DOTFILES/udev/99-samsung-galaxybook.rules" /etc/udev/rules.d/99-samsung-galaxybook.rules
        sudo udevadm control --reload-rules
    fi

    if confirm "Install Samsung speaker fix"; then
        sudo pacman -S sof-firmware

        REPO_BASE="$DOTFILES/repos"
        REPO_DIR="$REPO_BASE/samsung-galaxy-book4-linux-fixes"
        mkdir -p "$REPO_BASE"

        if [ -L "$REPO_BASE" ]; then
            echo "ERROR: $REPO_BASE is a symlink. Aborting."
            exit 1
        fi

        if [ -d "$REPO_DIR" ]; then
            echo "Removing existing samsung-galaxy-book4-linux-fixes repo..."
            rm -rf "$REPO_DIR"
        fi

        git clone https://github.com/Andycodeman/samsung-galaxy-book4-linux-fixes "$REPO_DIR"

        if [ ! -d "$REPO_DIR/speaker-fix" ]; then
            echo "ERROR: speaker-fix directory missing after clone."
            exit 1
        fi

        cd "$REPO_DIR/speaker-fix"
        sudo ./install.sh
        cd "$DOTFILES"
    fi

    if confirm "Install EasyEffects + presets"; then
        sudo pacman -S --needed easyeffects calf
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/EasyEffects-Presets/master/install.sh)"
        echo "==> To change audio presets open EasyEffects and choose a preset."
    fi
fi

echo ""
echo "==> Done! Reboot to apply all changes."
