import QtQuick

import "../../components/neomorphism/surfaces" as Surfaces
import "../../style"

// TODO:
// - Alignment (Start, Center, End) sollte davon abhängen in welcher Taskbar Group das Widget ist

Surfaces.Popup {
    alignment: Surfaces.Popup.Alignment.End

    autoSizeWidth: false
    autoSizeHeight: true
    Column {
        spacing: 10

        Text {
            id: t1
            text: "Quick Controls (TODO)"
            color: "white"
        }
    }
}
