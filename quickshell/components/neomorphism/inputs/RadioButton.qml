import QtQuick
import QtQuick.Controls as Controls
import Qt5Compat.GraphicalEffects as Effects

import "../../../style"
import "../../../config"

Controls.RadioButton {
    id: control

    // =========================================================================
    // PUBLIC API
    // =========================================================================

    property string sizeVariant: "md"

    property color accentColor: Colors.accent
    property color surfaceColor: Colors.surface
    property color textColor: Colors.textPrimary

    property int animationDuration: Animations.animationNormal

    // =========================================================================
    // DIMENSIONS
    // =========================================================================

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

    readonly property real radioSize: Math.round(baseHeight * 0.58)

    readonly property real borderInset: Math.max(1 * Settings.scale, radioSize * 0.075)

    readonly property real centerSize: radioSize * 0.48

    readonly property real labelGap: Dimensions.spacingSm

    // =========================================================================
    // CONTROL
    // =========================================================================

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    padding: 0
    spacing: labelGap

    opacity: enabled ? 1 : 0.48

    implicitHeight: Math.max(baseHeight, indicator.implicitHeight, contentItem.implicitHeight)

    implicitWidth: indicator.implicitWidth + (text.length > 0 ? labelGap + contentItem.implicitWidth : 0)

    // =========================================================================
    // RADIO INDICATOR
    // =========================================================================

    indicator: Item {
        id: radioIndicator

        implicitWidth: control.radioSize
        implicitHeight: control.radioSize

        x: 0
        y: (control.height - height) / 2

        scale: control.down ? 0.94 : 1

        Behavior on scale {
            NumberAnimation {
                duration: control.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        // ---------------------------------------------------------------------
        // GRADIENT BORDER
        // ---------------------------------------------------------------------

        Rectangle {
            anchors.fill: parent

            radius: width / 2
            antialiasing: true

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Qt.lighter(control.surfaceColor, 1.15)
                }

                GradientStop {
                    position: 1
                    color: Qt.darker(control.surfaceColor, 1.18)
                }
            }
        }

        // ---------------------------------------------------------------------
        // RECESSED SURFACE
        // ---------------------------------------------------------------------

        Rectangle {
            id: radioSurface

            anchors.fill: parent
            anchors.margins: control.borderInset

            radius: width / 2
            antialiasing: true

            color: control.surfaceColor
            visible: false
        }

        // ---------------------------------------------------------------------
        // DARK INNER SHADOW
        // ---------------------------------------------------------------------

        Effects.InnerShadow {
            id: darkInnerShadow

            anchors.fill: radioSurface
            source: radioSurface

            radius: Math.max(2, 3 * Settings.scale)
            samples: 16

            horizontalOffset: 1 * Settings.scale
            verticalOffset: 1 * Settings.scale

            color: Qt.darker(control.surfaceColor, 1.5)

            visible: false
        }

        // ---------------------------------------------------------------------
        // LIGHT INNER SHADOW
        // ---------------------------------------------------------------------

        Effects.InnerShadow {
            anchors.fill: radioSurface
            source: darkInnerShadow

            radius: Math.max(2, 3 * Settings.scale)
            samples: 16

            horizontalOffset: -1 * Settings.scale
            verticalOffset: -1 * Settings.scale

            color: Qt.lighter(control.surfaceColor, 1.35)
        }

        // ---------------------------------------------------------------------
        // ACTIVE CENTER
        // ---------------------------------------------------------------------

        Item {
            id: activeCenter

            anchors.centerIn: parent

            width: control.centerSize
            height: control.centerSize

            opacity: control.checked ? 1 : 0
            scale: control.checked ? 1 : 0.35

            Behavior on opacity {
                NumberAnimation {
                    duration: control.animationDuration
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: control.animationDuration
                    easing.type: Easing.OutBack
                }
            }

            Rectangle {
                id: centerSurface

                anchors.fill: parent
                radius: width / 2
                antialiasing: true

                color: control.accentColor
                visible: false
            }

            Effects.DropShadow {
                anchors.fill: centerSurface
                source: centerSurface

                radius: Math.max(2, 3 * Settings.scale)
                samples: 16

                horizontalOffset: 1 * Settings.scale
                verticalOffset: 2 * Settings.scale

                color: Qt.darker(control.surfaceColor, 1.6)
            }

            // Subtle light reflection
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.16

                width: parent.width * 0.45
                height: Math.max(1, parent.height * 0.13)

                radius: height / 2

                color: Colors.surfaceRaised
                opacity: 0.5
            }
        }

        // ---------------------------------------------------------------------
        // FOCUS RING
        // ---------------------------------------------------------------------

        Rectangle {
            anchors.fill: parent
            anchors.margins: -3 * Settings.scale

            radius: width / 2
            color: "transparent"

            border.width: Math.max(1, Settings.scale)
            border.color: control.accentColor

            visible: control.visualFocus
        }
    }

    // =========================================================================
    // LABEL
    // =========================================================================

    contentItem: Text {
        text: control.text
        color: control.textColor

        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.labelSize

        leftPadding: control.radioSize + (control.text.length > 0 ? control.labelGap : 0)

        verticalAlignment: Text.AlignVCenter
    }
}
