//@ pragma IconTheme LunaIcons
//@ pragma UseQApplication

import QtQuick
import Quickshell

import "./taskBar"
import "./osd"

ShellRoot {
    id: root

    TaskBar {
        id: taskBar
    }

    // OSD's
    VolumeOSD {
        id: volumeOSD
    }
    KeyboardBacklightOSD {
        id: keyboardBacklightOSD
    }
}
