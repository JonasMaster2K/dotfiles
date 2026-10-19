import QtQuick
import QtQuick.Controls as Controls
import Qt5Compat.GraphicalEffects as Effects

import "../../../style"
import "../../../config"
import "../icons" as Icons
import "../surfaces" as Surfaces

Controls.Switch {
    id: control

    // Public API
    property string sizeVariant: "md"  // xs, sm, md, lg, xl
    property bool showActiveBackground: false
    property bool showRail: true
    property string iconName: ""

    // -1 = use Surface.qml's own default borderSize.
    // Set e.g. borderSize: 5 * Settings.scale to override the track border.
    property real borderSize: -1

    property color accentColor: Colors.accent
    property color trackColor: Colors.surface
    property color trackHoverColor: Colors.surfaceHover
    property color trackPressedColor: Colors.surfacePressed
    property color thumbColor: Colors.surfaceRaised
    property color thumbHoverColor: Colors.surfaceHover
    property color thumbPressedColor: Colors.surfacePressed
    property color labelColor: Colors.textPrimary
    property color shadowColor: Colors.shadowDark
    property color highlightColor: Colors.shadowLight
    property int animationDuration: Animations.animationNormal

    readonly property real baseHeight: {
        switch (sizeVariant) {
        case "xs":
            return Dimensions.controlHeightXs;
        case "sm":
            return Dimensions.controlHeightSm;
        case "lg":
            return Dimensions.controlHeightLg;
        case "xl":
            return Dimensions.controlHeightXl;
        default:
            return Dimensions.controlHeightMd;
        }
    }
    readonly property real trackHeight: Math.round(baseHeight * 0.66)
    readonly property real trackWidth: Math.round(trackHeight * 1.9)
    readonly property real inset: Math.max(2.5 * Settings.scale, trackHeight * 0.12)
    readonly property real handleSize: trackHeight - 2 * inset
    readonly property real handleTravel: trackWidth - handleSize - 2 * inset
    readonly property real labelGap: Dimensions.spacingSm

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    padding: 0
    spacing: labelGap
    opacity: enabled ? 1 : 0.48
    implicitWidth: Math.max(indicator.implicitWidth, contentItem.implicitWidth)
    implicitHeight: Math.max(indicator.implicitHeight, contentItem.implicitHeight)

    indicator: Item {
        id: indicatorRoot
        implicitWidth: control.trackWidth
        implicitHeight: control.baseHeight
        x: control.leftPadding
        y: (control.height - height) / 2

        Item {
            id: trackRoot
            width: control.trackWidth
            height: control.trackHeight
            anchors.centerIn: parent

            Surfaces.Surface {
                id: trackSurface
                anchors.fill: parent
                elevation: "sunken"
                cornerRadius: Dimensions.radiusPill

                // Keep the neutral Surface rim and its default border width.
                surfaceColor: control.trackColor
                hoverColor: control.trackHoverColor
                pressedColor: control.trackPressedColor
                hovered: control.hovered && control.enabled

                shadowDarkColor: control.shadowColor
                shadowLightColor: control.highlightColor

                Behavior on surfaceColor {
                    ColorAnimation {
                        duration: control.animationDuration
                    }
                }
            }

            // Accent goes INSIDE the rim rather than recoloring the entire Surface.
            Rectangle {
                id: accentFill
                visible: control.showActiveBackground
                opacity: control.checked ? 1 : 0
                color: control.accentColor
                anchors.fill: parent
                anchors.margins: trackSurface.borderSize
                radius: Math.max(0, height / 2)

                Behavior on opacity {
                    NumberAnimation {
                        duration: control.animationDuration
                        easing.type: Easing.InOutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: control.animationDuration
                        easing.type: Easing.InOutCubic
                    }
                }
            }

            // Apply a custom border only if explicitly requested.
            // Without this Binding, trackSurface keeps Surface.qml's default.
            Binding {
                target: trackSurface
                property: "borderSize"
                value: control.borderSize
                when: control.borderSize >= 0
                restoreMode: Binding.RestoreBindingOrValue
            }

            // Small inset runner underneath the moving thumb.
            Rectangle {
                id: railSource
                visible: false
                width: Math.max(0, parent.width - control.handleSize - 2 * control.inset)
                height: Math.max(1, control.trackHeight * 0.12)
                x: (parent.width - width) / 2
                y: (parent.height - height) / 2
                radius: height / 2
                color: control.checked && control.showActiveBackground ? Qt.darker(control.accentColor, 1.12) : Colors.surfacePressed

                Behavior on color {
                    ColorAnimation {
                        duration: control.animationDuration
                        easing.type: Easing.InOutCubic
                    }
                }
            }
            Effects.InnerShadow {
                visible: control.showRail
                anchors.fill: railSource
                source: railSource
                radius: Math.max(1, 2 * Settings.scale)
                samples: 12
                horizontalOffset: 0
                verticalOffset: 1 * Settings.scale
                color: control.checked && control.showActiveBackground ? Qt.darker(control.accentColor, 1.45) : control.shadowColor
            }

            Item {
                id: handle
                width: control.handleSize
                height: control.handleSize
                x: control.inset + control.visualPosition * control.handleTravel
                y: (trackRoot.height - height) / 2
                scale: control.down ? 0.94 : 1

                Behavior on x {
                    enabled: !control.down
                    NumberAnimation {
                        duration: control.animationDuration
                        easing.type: Easing.InOutCubic
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: control.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Surfaces.Surface {
                    anchors.fill: parent
                    cornerRadius: Dimensions.radiusPill
                    elevation: "raised"
                    // Intentionally no borderSize: use Surface.qml default.
                    surfaceColor: control.thumbColor
                    hoverColor: control.thumbHoverColor
                    pressedColor: control.thumbPressedColor
                    hovered: control.hovered && control.enabled
                    shadowDarkColor: control.shadowColor
                    shadowLightColor: control.highlightColor
                }

                Icons.Icon {
                    visible: control.iconName.length > 0
                    anchors.centerIn: parent
                    iconName: control.iconName
                    size: control.handleSize * 0.52
                    iconColor: control.checked ? control.accentColor : control.labelColor
                    colorize: true
                }
            }
        }

        Rectangle {
            anchors.centerIn: trackRoot
            width: trackRoot.width + 4 * Settings.scale
            height: trackRoot.height + 4 * Settings.scale
            radius: height / 2
            color: "transparent"
            border.width: Math.max(1, Settings.scale)
            border.color: control.accentColor
            visible: control.visualFocus
        }
    }

    contentItem: Text {
        text: control.text
        color: control.labelColor
        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.labelSize
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        leftPadding: control.mirrored ? 0 : control.indicator.width + control.spacing
        rightPadding: control.mirrored ? control.indicator.width + control.spacing : 0
    }

    background: Item {}
}
