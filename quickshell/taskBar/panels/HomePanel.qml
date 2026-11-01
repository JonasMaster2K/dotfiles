import QtQuick

import "../../components/neomorphism/surfaces" as Surfaces
import "../../style"

// TODO:
// - Alignment (Start, Center, End) sollte davon abhängen in welcher Taskbar Group das Widget ist

Surfaces.Popup {
    alignment: Surfaces.Popup.Alignment.Start

    autoSizeWidth: false
    autoSizeHeight: true
    Column {
        width: Dimensions.popupMinWidth
        spacing: 10

        Text {
            id: t1
            text: "Home (TODO)"
            color: "white"
        }
    }
}
