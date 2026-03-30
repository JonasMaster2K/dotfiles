use gtk4 as gtk;
use gtk::prelude::*;
use gtk::{Box, Button, Label, Orientation};
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Debug, Clone, PartialEq)]
pub enum Profile {
    Pc,
    Laptop,
    GalaxyBook5,
}

pub fn build(selected_profile: Rc<RefCell<Option<Profile>>>) -> Box {
    let container = Box::builder()
        .orientation(Orientation::Vertical)
        .hexpand(true)
        .spacing(24)
        .margin_top(40)
        .margin_bottom(40)
        .margin_start(40)
        .margin_end(40)
        .build();

    // ── Welcome Text ─────────────────────────────────────
    let title = Label::builder()
        .label("Welcome to Dotfiles Installer")
        .halign(gtk::Align::Center)
        .build();

    let subtitle = Label::builder()
        .label("Select your device profile to get started.")
        .halign(gtk::Align::Center)
        .build();

    // ── Profile Buttons ───────────────────────────────────
    let btn_row = Box::builder()
        .orientation(Orientation::Horizontal)
        .halign(gtk4::Align::Center)
        .spacing(12)
        .build();

    let btn_pc        = Button::builder().label("PC").build();
    let btn_laptop    = Button::builder().label("Laptop").build();
    let btn_galaxy    = Button::builder().label("Galaxy Book 5").build();

    let buttons = vec![
        (btn_pc.clone(),     Profile::Pc),
        (btn_laptop.clone(), Profile::Laptop),
        (btn_galaxy.clone(), Profile::GalaxyBook5),
    ];

    for (btn, profile) in &buttons {
        let all_btns = vec![btn_pc.clone(), btn_laptop.clone(), btn_galaxy.clone()];
        let state = selected_profile.clone();
        let profile = profile.clone();
        btn.connect_clicked(move |active| {
            // Alle zurücksetzen
            for b in &all_btns {
                b.remove_css_class("suggested-action");
            }
            // Aktiven markieren
            active.add_css_class("suggested-action");
            *state.borrow_mut() = Some(profile.clone());
        });
        btn_row.append(btn);
    }

    container.append(&title);
    container.append(&subtitle);
    container.append(&btn_row);
    container
}