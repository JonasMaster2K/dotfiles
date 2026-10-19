import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../surfaces"

Controls.AbstractButton {
    id: control

    // Public API: PageIndicator animates emphasis continuously from 0 to 1.
    property bool active: false
    property real emphasis: active ? 1.0 : 0.0

    property real dotSize: Dimensions.spacingSm
    property real activeSize: Dimensions.spacingLg
    property real hitSize: Dimensions.hitTargetMin

    property color activeColor: Colors.accent
    property color inactiveColor: Colors.surfaceSunken
    property color hoverColor: Colors.surfaceHover
    property int animationDuration: Animations.animationNormal

    readonly property real amount: Math.max(0, Math.min(1, emphasis))
    readonly property real drawnSize: dotSize + (activeSize - dotSize) * amount

    implicitWidth: Math.max(hitSize, dotSize, activeSize)
    implicitHeight: Math.max(hitSize, dotSize, activeSize)
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    background: Item {}

    contentItem: Item {
        id: canvas

        Item {
            id: dot
            anchors.centerIn: parent
            width: control.drawnSize
            height: control.drawnSize
            scale: control.down ? 0.9 : 1.0

            Behavior on scale {
                NumberAnimation {
                    duration: control.animationDuration
                    easing.type: Animations.easingSmooth
                }
            }

            // Both surfaces are always present. Blending their opacity
            // keeps the original PageIndicator's continuous emphasis smooth:
            // small / sunken / neutral -> large / raised / accent.
            Surface {
                anchors.fill: parent
                elevation: "sunken"
                cornerRadius: width / 2
                surfaceColor: control.inactiveColor
                pressedColor: control.inactiveColor
                hoverColor: control.hoverColor
                hovered: control.hovered && control.enabled
                opacity: 1.0 - control.amount
            }

            Surface {
                anchors.fill: parent
                elevation: "raised"
                cornerRadius: width / 2
                surfaceColor: control.activeColor
                pressedColor: control.activeColor
                hoverColor: control.activeColor
                opacity: control.amount
            }
        }

        // Keep the focus indication independent of the visual dot size.
        Rectangle {
            anchors.centerIn: parent
            width: Math.max(control.drawnSize + 6, control.activeSize + 6)
            height: width
            radius: width / 2
            color: "transparent"
            border.width: 2
            border.color: control.activeColor
            visible: control.visualFocus
        }
    }
}
