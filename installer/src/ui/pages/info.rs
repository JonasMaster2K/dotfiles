use gtk4 as gtk;
use gtk::Label;

fn placeholder(text: &str) -> Label {
    Label::builder()
        .label(text)
        .vexpand(true)
        .hexpand(true)
        .build()
}

// ── info ──────────────────────────────────────────────────
pub fn build() -> Label { placeholder("Info & Install — TODO") }