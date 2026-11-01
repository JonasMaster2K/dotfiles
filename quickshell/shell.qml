//@ pragma IconTheme LunaIcons
//@ pragma UseQApplication

import QtQuick
import Quickshell

import "./taskBar"

ShellRoot {
    id: root

    TaskBar {
        id: taskBar
    }
}
