mod ui;

use gtk4 as gtk;
use gtk::prelude::*;
use gtk::Application;
fn main() -> gtk::glib::ExitCode {
    let app = Application::builder()
        .application_id("io.github.JonasMaster2K.dotfiles.installer")
        .build();

    app.connect_activate(ui::build_ui);

    app.run()
}