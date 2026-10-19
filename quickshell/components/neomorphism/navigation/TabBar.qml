import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.TabBar {
    id: control

    property string elevation: "sunken"
    property real borderSize: 4 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton

    property color surfaceColor: Colors.surface

    spacing: Dimensions.spacingSm
    padding: Dimensions.spacingSm

    background: Surfaces.Surface {
        elevation: control.elevation

        borderSize: control.borderSize
        cornerRadius: control.cornerRadius

        surfaceColor: control.surfaceColor
        hoverColor: Colors.surfaceHover
        pressedColor: Colors.surfacePressed
    }
}
