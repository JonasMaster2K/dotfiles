pub mod welcome;
pub mod monitor;
pub mod system;
pub mod apps;
pub mod info;

use std::cell::RefCell;
use std::rc::Rc;
use gtk4 as gtk;
use gtk::{Stack, StackTransitionType};

pub fn build_stack() -> Stack {
    let stack = Stack::builder()
        .transition_type(StackTransitionType::SlideLeftRight)
        .hexpand(true)
        .vexpand(true)
        .build();

    let profile = Rc::new(RefCell::new(None::<welcome::Profile>));
    stack.add_named(&welcome::build(profile.clone()),    Some("welcome"));
    stack.add_named(&monitor::build(),    Some("monitor"));

    // System-Unterseiten direkt im Haupt-Stack
    stack.add_named(&system::sddm::build(),      Some("sddm"));
    stack.add_named(&system::hyprland::build(),  Some("hyprland"));
    stack.add_named(&system::hyprlock::build(),  Some("hyprlock"));
    stack.add_named(&system::hyprpaper::build(), Some("hyprpaper"));
    stack.add_named(&system::hypridle::build(),  Some("hypridle"));
    stack.add_named(&system::hyprsunset::build(),Some("hyprsunset"));
    stack.add_named(&system::audio::build(),     Some("audio"));
    stack.add_named(&system::sysconf::build(),   Some("system"));
    stack.add_named(&system::touchpad::build(),  Some("touchpad"));
    stack.add_named(&system::samsung::build(),   Some("samsung"));

    stack.add_named(&apps::build(),       Some("apps"));
    stack.add_named(&info::build(),       Some("info"));

    stack
}