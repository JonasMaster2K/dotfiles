import QtQuick
import QtQuick.Controls as Controls
import Qt5Compat.GraphicalEffects as Effects

import "../../../style"
import "../../../config"

Controls.CheckBox {
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

    readonly property real boxSize: Math.round(baseHeight * 0.58)
    readonly property real boxRadius: Math.max(3 * Settings.scale, boxSize * 0.25)
    readonly property real borderInset: Math.max(1 * Settings.scale, boxSize * 0.075)
    readonly property real labelGap: Dimensions.spacingSm
    readonly property bool marked: checkState !== Qt.Unchecked
    readonly property bool partial: checkState === Qt.PartiallyChecked

    // =========================================================================
    // CONTROL
    // =========================================================================

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    padding: 0
    spacing: labelGap
    opacity: enabled ? 1 : 0.48
    implicitHeight: Math.max(baseHeight, indicator.implicitHeight, contentItem.implicitHeight)
    implicitWidth: Math.max(indicator.implicitWidth, contentItem.implicitWidth)

    // =========================================================================
    // INDICATOR
    // =========================================================================

    indicator: Item {
        id: checkboxIndicator

        implicitWidth: control.boxSize
        implicitHeight: control.boxSize

        x: 0
        y: (control.height - height) / 2

        // ---------------------------------------------------------------------
        // GRADIENT BORDER
        // ---------------------------------------------------------------------

        Rectangle {
            anchors.fill: parent

            radius: control.boxRadius
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
            id: checkboxSurface

            anchors.fill: parent
            anchors.margins: control.borderInset

            radius: Math.max(0, control.boxRadius - control.borderInset)

            color: control.surfaceColor
            antialiasing: true
            visible: false
        }

        // ---------------------------------------------------------------------
        // DARK INNER SHADOW
        // ---------------------------------------------------------------------

        Effects.InnerShadow {
            id: darkInnerShadow

            anchors.fill: checkboxSurface

            source: checkboxSurface

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
            anchors.fill: checkboxSurface

            source: darkInnerShadow

            radius: Math.max(2, 3 * Settings.scale)
            samples: 16

            horizontalOffset: -1 * Settings.scale
            verticalOffset: -1 * Settings.scale

            color: Qt.lighter(control.surfaceColor, 1.35)
        }

        // ---------------------------------------------------------------------
        // ACTIVE TINT
        // ---------------------------------------------------------------------

        Rectangle {
            anchors.fill: checkboxSurface

            radius: checkboxSurface.radius
            color: control.accentColor

            opacity: control.marked ? 0.13 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: control.animationDuration
                    easing.type: Easing.InOutCubic
                }
            }
        }

        // ---------------------------------------------------------------------
        // CHECKMARK / PARTIAL MARK
        // ---------------------------------------------------------------------

        Item {
            id: markContainer

            anchors.centerIn: parent

            width: parent.width * 0.72
            height: parent.height * 0.72

            opacity: control.marked ? 1 : 0
            scale: control.marked ? 1 : 0.5

            Behavior on opacity {
                NumberAnimation {
                    duration: control.animationDuration
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: control.animationDuration
                    easing.type: Easing.OutCubic
                }
            }

            Text {
                anchors.centerIn: parent

                visible: !control.partial

                text: "\u2713"
                color: control.accentColor

                font.family: Typography.fontFamilyBody
                font.pixelSize: parent.height * 0.95
                font.weight: Font.Bold

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                anchors.centerIn: parent

                visible: control.partial

                width: parent.width * 0.65
                height: Math.max(2 * Settings.scale, parent.height * 0.18)

                radius: height / 2
                color: control.accentColor
            }
        }

        // ---------------------------------------------------------------------
        // FOCUS RING
        // ---------------------------------------------------------------------

        Rectangle {
            anchors.fill: parent
            anchors.margins: -3 * Settings.scale

            radius: control.boxRadius + 3 * Settings.scale

            color: "transparent"

            border.width: Math.max(1, Settings.scale)
            border.color: control.accentColor

            visible: control.visualFocus
        }

        // ---------------------------------------------------------------------
        // PRESS ANIMATION
        // ---------------------------------------------------------------------

        scale: control.down ? 0.94 : 1

        Behavior on scale {
            NumberAnimation {
                duration: control.animationDuration
                easing.type: Easing.OutCubic
            }
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

        leftPadding: control.boxSize + (control.text.length > 0 ? control.labelGap : 0)

        verticalAlignment: Text.AlignVCenter
    }
}
