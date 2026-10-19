import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

// A styled Qt Quick Controls Menu. Add MenuItem children directly.
// Keeps Qt's built-in keyboard navigation, actions and submenu handling.
Controls.Menu {
    id: control

    property string elevation: "raised"  // "raised", "flat", "sunken"
    property real borderSize: 1 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton
    property color surfaceColor: Colors.surface
    property color hoverSurfaceColor: Colors.surfaceHover
    property color pressedSurfaceColor: Colors.surfacePressed
    property real menuPadding: Dimensions.spacingSm
    property real minimumMenuWidth: 200 * Settings.scale

    modal: false
    focus: true
    padding: menuPadding
    spacing: Dimensions.spacingSm
    implicitWidth: minimumMenuWidth
    closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside

    background: Surfaces.Surface {
        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius
        surfaceColor: control.surfaceColor
        hoverColor: control.hoverSurfaceColor
        pressedColor: control.pressedSurfaceColor
    }
}
