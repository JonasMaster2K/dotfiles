import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.Popup {
    id: control

    property string elevation: "raised"
    property real borderSize: 1 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton
    property real popoverPadding: Dimensions.spacingLg
    property color surfaceColor: Colors.surface

    // A PopOver is non-modal by default; clicking outside dismisses it.
    modal: false
    focus: true
    closePolicy: Controls.Popup.CloseOnEscape
                 | Controls.Popup.CloseOnPressOutside

    implicitWidth: 260 * Settings.scale
    padding: popoverPadding

    background: Surfaces.Surface {
        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius
        surfaceColor: control.surfaceColor
    }
}
