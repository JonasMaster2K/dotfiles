use gtk4 as gtk;
use gtk::Label;

fn placeholder(text: &str) -> Label {
    Label::builder()
        .label(text)
        .vexpand(true)
        .hexpand(true)
        .build()
}

// ── apps ──────────────────────────────────────────────────
pub fn build() -> Label { placeholder("Apps & Extras (Toggles) — TODO") }