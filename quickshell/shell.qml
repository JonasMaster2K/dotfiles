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
    BatteryOSD {
        id: batteryOSD
    }
    VolumeOSD {
        id: volumeOSD
    }
    MicrophoneOSD {
        id: microphoneOSD
    }
    KeyboardBacklightOSD {
        id: keyboardBacklightOSD
    }
    CapslockOSD {
        id: capslockOSD
    }
    NumlockOSD {
        id: numlockOSD
    }
    DisplayBrightnessOSD {
        id: displayBrightnessOSD
    }
}
