//@ pragma IconTheme LunaIcons
//@ pragma UseQApplication

import QtQuick
import Quickshell

import "./services" as Services
import "./taskBar"

ShellRoot {
    id: root

    Services.WindowController {
        id: _windowController
    }

    TaskBar {
        id: taskBar
        windowController: _windowController
    }
}
