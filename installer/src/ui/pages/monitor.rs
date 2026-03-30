use gtk4 as gtk;
use gtk::Label;

fn placeholder(text: &str) -> Label {
    Label::builder()
        .label(text)
        .vexpand(true)
        .hexpand(true)
        .build()
}

// ── monitor ───────────────────────────────────────────────
pub fn build() -> Label { placeholder("Monitor Setup (DrawingArea, Drag & Drop) — TODO") }