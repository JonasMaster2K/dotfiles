#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

trap 'echo "==> Error on line $LINENO. Aborting."; exit 1' ERR

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
echo "Press Enter to continue or Ctrl+C to abort..."
read -r

# ── Sudo keepalive ────────────────────────────────────────
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ── Pakete: Alle Profile ───────────────────────────────────
echo "==> Installing base packages..."
sudo pacman -S --needed \
    hyprland xdg-desktop-portal-hyprland hypridle hyprpicker hyprpaper hyprsunset \
    polkit-kde-agent \
    sddm \
    kitty fish eza starship \
    wofi dunst \
    wl-clipboard cliphist \
    networkmanager network-manager-applet \
    bluez bluez-utils blueman \
    pipewire pipewire-pulse wireplumber \
    pavucontrol \
    git base-devel \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
    nano btop grim slurp unzip p7zip ffmpeg fzf qalculate-gtk \
    kvantum \
    dolphin ffmpegthumbnailer gvfs \
    remmina freerdp openssh

# ── Pakete: Laptop + Galaxy Book ──────────────────────────
if [[ "$PROFILE" == "laptop" || "$PROFILE" == "galaxybook5" ]]; then
    echo "==> Installing laptop packages..."
    sudo pacman -S --needed \
        brightnessctl \
        acpid \
        dkms linux-headers \
        i2c-tools \
        power-profiles-daemon
    sudo systemctl enable --now acpid
    sudo systemctl enable --now power-profiles-daemon
fi

# ── Services: Alle Profile ────────────────────────────────
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable sddm

# ── Fish als Standard-Shell ───────────────────────────────
echo "==> Setting fish as default shell..."
chsh -s /usr/bin/fish

# ── AUR Helper ────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    echo "==> Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si && cd "$DOTFILES"
fi

# ── AUR: Alle Profile ─────────────────────────────────────
echo "==> Installing AUR packages..."
yay -S --needed zen-browser-bin vscodium-bin aylurs-gtk-shell libastal-meta

# ── AUR: Laptop + Galaxy Book ─────────────────────────────
if [[ "$PROFILE" == "laptop" || "$PROFILE" == "galaxybook5" ]]; then
    yay -S --needed swayosd-git
fi

# ── Configs verlinken ─────────────────────────────────────
echo "==> Linking configs..."
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

# ── Samsung Galaxy Book5 spezifisch ───────────────────────
if [[ "$PROFILE" == "galaxybook5" ]]; then
    echo "==> Installing Samsung acpid files..."
    sudo cp "$DOTFILES/acpi/samsung-kbd-backlight.sh" /etc/acpi/samsung-kbd-backlight.sh
    sudo chmod +x /etc/acpi/samsung-kbd-backlight.sh
    sudo cp "$DOTFILES/acpi/events/samsung-kbd-backlight" /etc/acpi/events/samsung-kbd-backlight
    sudo systemctl restart acpid

    echo "==> Installing Samsung udev rules (battery threshold 80%)..."
    sudo cp "$DOTFILES/udev/99-samsung-galaxybook.rules" /etc/udev/rules.d/99-samsung-galaxybook.rules
    sudo udevadm control --reload-rules

    echo "==> Installing Samsung speaker fix..."
    if [ ! -d "$DOTFILES/repos/samsung-galaxy-book4-linux-fixes" ]; then
        git clone https://github.com/Andycodeman/samsung-galaxy-book4-linux-fixes \
            "$DOTFILES/repos/samsung-galaxy-book4-linux-fixes"
    fi
    cd "$DOTFILES/repos/samsung-galaxy-book4-linux-fixes/speaker-fix"
    sudo ./install.sh
    cd "$DOTFILES"

    echo "==> Installing EasyEffects + presets..."
    sudo pacman -S --needed easyeffects calf
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/JackHack96/EasyEffects-Presets/master/install.sh)"
    echo "==> To change audio presets open EasyEffects and choose a preset."
fi

echo ""
echo "==> Done! Reboot to apply all changes."