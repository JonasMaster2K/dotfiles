use gtk4 as gtk;
use gtk::Label;

fn placeholder(text: &str) -> Label {
    Label::builder()
        .label(text)
        .vexpand(true)
        .hexpand(true)
        .build()
}

pub mod sddm {
    use super::*;
    pub fn build() -> Label {
        placeholder("SDDM — Autologin, User, Theme — TODO")
    }
}

pub mod hyprland {
    use super::*;
    pub fn build() -> Label {
        placeholder("Hyprland — Tastatur-Layout, Maus-Sensitivity, Gaps, Animationen — TODO")
    }
}

pub mod hyprlock {
    use super::*;
    pub fn build() -> Label {
        placeholder("Hyprlock — Hintergrund, Clock-Format — TODO")
    }
}

pub mod hyprpaper {
    use super::*;
    pub fn build() -> Label {
        placeholder("Hyprpaper — Wallpaper pro Monitor — TODO")
    }
}

pub mod hypridle {
    use super::*;
    pub fn build() -> Label {
        placeholder("Hypridle — Screen-off, Lock, Suspend Timeouts — TODO")
    }
}

pub mod hyprsunset {
    use super::*;
    pub fn build() -> Label {
        placeholder("Hyprsunset — Farbtemperatur, Zeitplan — TODO")
    }
}

pub mod audio {
    use super::*;
    pub fn build() -> Label {
        placeholder("Audio — Standard-Ausgabegerät — TODO")
    }
}

pub mod sysconf {
    use super::*;
    pub fn build() -> Label {
        placeholder("System — Zeitzone, Locale, Hostname, Swap/Zram — TODO")
    }
}

pub mod touchpad {
    use super::*;
    pub fn build() -> Label {
        placeholder("Touchpad — Tap-to-click, Natural Scroll — TODO (nur Laptop)")
    }
}

pub mod samsung {
    use super::*;
    pub fn build() -> Label {
        placeholder("Samsung — Battery Threshold, Keyboard Backlight — TODO (nur Galaxy Book5)")
    }
}