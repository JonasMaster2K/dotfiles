use gtk4 as gtk;
use gtk::prelude::*;
use gtk::{Box, Label, ListBox, Orientation, Stack};
use gtk::glib::clone;

pub const ENTRIES: &[(&str, &str); 15] = &[
    ("Welcome",    "welcome"),
    ("Profile",    "profile"),
    ("Monitor",    "monitor"),
    ("SDDM",       "sddm"),
    ("Hyprland",   "hyprland"),
    ("Hyprlock",   "hyprlock"),
    ("Hyprpaper",  "hyprpaper"),
    ("Hypridle",   "hypridle"),
    ("Hyprsunset", "hyprsunset"),
    ("Audio",      "audio"),
    ("Touchpad",   "touchpad"),
    ("Samsung",    "samsung"),
    ("System",     "system"),
    ("Apps",       "apps"),
    ("Info",       "info"),
];

pub fn build(stack: &Stack) -> Box {
    let sidebar = Box::new(Orientation::Vertical, 0);
    sidebar.set_width_request(200);

    let list_box = ListBox::new();
    list_box.set_selection_mode(gtk::SelectionMode::Single);

    for (label, _) in ENTRIES {
        let lbl = Label::builder()
            .label(*label)
            .xalign(0.0)
            .margin_start(12)
            .margin_top(6)
            .margin_bottom(6)
            .vexpand(true)
            .build();
        list_box.append(&lbl);
    }

    let pages: Vec<&str> = ENTRIES.iter().map(|(_, p)| *p).collect();

    list_box.connect_row_selected(clone!(
        #[weak] stack,
        move |_, row| {
            if let Some(row) = row {
                if let Some(target) = pages.get(row.index() as usize) {
                    stack.set_visible_child_name(target);
                }
            }
        }
    ));

    sidebar.append(&list_box);
    sidebar
}