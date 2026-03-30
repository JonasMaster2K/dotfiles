pub mod window;
pub mod sidebar;
pub mod pages;

use gtk4 as gtk;
use gtk::prelude::*;
use gtk::{Application};

pub fn build_ui(app: &Application) {
    let window = window::build(app);
    window.present();
}