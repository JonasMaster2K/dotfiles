use gtk4 as gtk;
use gtk::prelude::*;
use gtk::{
    Application, ApplicationWindow, Box, HeaderBar, Label, Orientation,
};
use super::{sidebar, pages};

pub fn build(app: &Application) -> ApplicationWindow {
    let main_box = Box::new(Orientation::Vertical, 0);

    let header = HeaderBar::builder()
        .title_widget(&Label::new(Some("Dotfiles Installer")))
        .build();
    main_box.append(&header);

    let content_box = Box::new(Orientation::Horizontal, 0);
    main_box.append(&content_box);

    let stack = pages::build_stack();
    let list_box = sidebar::build(&stack);

    content_box.append(&list_box);
    content_box.append(&stack);

    ApplicationWindow::builder()
        .application(app)
        .child(&main_box)
        .title("Dotfiles Installer")
        .default_width(800)
        .default_height(600)
        .build()
}