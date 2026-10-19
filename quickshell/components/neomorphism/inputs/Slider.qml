import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.Slider {
    id: control

    // =========================================================================
    // PUBLIC API
    // =========================================================================

    property string sizeVariant: "md"

    property bool showActiveFill: false
    property bool showValue: false

    property string valueSuffix: ""
    property int valueDecimals: 0

    // -1: Standardwert aus Surface.qml verwenden.
    property real borderSize: -1
    property real handleBorderSize: -1

    property string trackElevation: "sunken"
    property string handleElevation: "raised"

    // =========================================================================
    // COLORS
    // =========================================================================

    property color accentColor: Colors.accent

    property color trackColor: Colors.surface
    property color trackHoverColor: Colors.surfaceHover
    property color trackPressedColor: Colors.surfacePressed

    property color thumbColor: Colors.surfaceRaised
    property color thumbHoverColor: Colors.surfaceHover
    property color thumbPressedColor: Colors.surfacePressed

    property color shadowColor: Colors.shadowDark
    property color highlightColor: Colors.shadowLight

    property color valueColor: Colors.textPrimary

    property int animationDuration: Animations.animationNormal

    // =========================================================================
    // GEOMETRY
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

    readonly property real trackThickness: Math.max(5 * Settings.scale, baseHeight * 0.29)

    readonly property real thumbSize: Math.max(trackThickness + 5 * Settings.scale, baseHeight * 0.68)

    readonly property bool isHorizontal: orientation === Qt.Horizontal

    readonly property real travel: Math.max(0, (isHorizontal ? availableWidth : availableHeight) - thumbSize)

    // =========================================================================
    // CONTROL
    // =========================================================================

    from: 0
    to: 100
    value: 50
    stepSize: 1

    snapMode: Controls.Slider.SnapOnRelease

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    padding: 0

    opacity: enabled ? 1 : 0.48

    rightPadding: isHorizontal && showValue ? valueLabel.implicitWidth + Dimensions.spacingSm : 0

    bottomPadding: !isHorizontal && showValue ? valueLabel.implicitHeight + Dimensions.spacingSm : 0

    implicitWidth: isHorizontal ? 200 * Settings.scale + rightPadding : Math.max(baseHeight, thumbSize)

    implicitHeight: isHorizontal ? Math.max(baseHeight, thumbSize) : 200 * Settings.scale + bottomPadding

    // =========================================================================
    // TRACK
    // =========================================================================

    background: Item {
        id: trackArea

        x: control.leftPadding
        y: control.topPadding

        width: control.availableWidth
        height: control.availableHeight

        Item {
            id: track

            width: control.isHorizontal ? parent.width : control.trackThickness

            height: control.isHorizontal ? control.trackThickness : parent.height

            anchors.centerIn: parent

            // =============================================================
            // TRACK SURFACE
            // =============================================================

            Surfaces.Surface {
                id: trackSurface

                anchors.fill: parent

                elevation: control.trackElevation
                cornerRadius: Dimensions.radiusPill

                // Standard-Border bleibt aus Surface.qml.
                surfaceColor: control.trackColor
                hoverColor: control.trackHoverColor
                pressedColor: control.trackPressedColor

                hovered: control.hovered && control.enabled

                shadowDarkColor: control.shadowColor
                shadowLightColor: control.highlightColor

                Binding on borderSize {
                    when: control.borderSize >= 0
                    value: control.borderSize
                    restoreMode: Binding.RestoreBindingOrValue
                }
            }

            // =============================================================
            // OPTIONAL ACTIVE FILL
            // =============================================================

            Rectangle {
                id: activeFill

                visible: control.showActiveFill

                color: control.accentColor
                opacity: 0.85

                radius: Math.min(width, height) / 2

                width: control.isHorizontal ? Math.max(0, (track.width - control.thumbSize) * control.visualPosition + control.thumbSize / 2) : Math.max(2 * Settings.scale, track.width * 0.42)

                height: control.isHorizontal ? Math.max(2 * Settings.scale, track.height * 0.42) : Math.max(0, (track.height - control.thumbSize) * (1 - control.visualPosition) + control.thumbSize / 2)

                x: control.isHorizontal ? 0 : (track.width - width) / 2

                y: control.isHorizontal ? (track.height - height) / 2 : track.height - height

                Behavior on color {
                    ColorAnimation {
                        duration: control.animationDuration
                        easing.type: Easing.InOutCubic
                    }
                }

                Behavior on width {
                    enabled: !control.pressed && control.isHorizontal

                    NumberAnimation {
                        duration: control.animationDuration
                        easing.type: Easing.InOutCubic
                    }
                }

                Behavior on height {
                    enabled: !control.pressed && !control.isHorizontal

                    NumberAnimation {
                        duration: control.animationDuration
                        easing.type: Easing.InOutCubic
                    }
                }
            }
        }
    }

    // =========================================================================
    // HANDLE
    // =========================================================================

    handle: Item {
        id: thumb

        width: control.thumbSize
        height: control.thumbSize

        x: control.leftPadding + (control.isHorizontal ? control.visualPosition * control.travel : (control.availableWidth - width) / 2)

        y: control.topPadding + (control.isHorizontal ? (control.availableHeight - height) / 2 : control.visualPosition * control.travel)

        scale: control.pressed ? 0.94 : 1

        // =============================================================
        // MOVEMENT ANIMATION
        // =============================================================

        Behavior on x {
            enabled: !control.pressed

            NumberAnimation {
                duration: control.animationDuration
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on y {
            enabled: !control.pressed

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

        // =============================================================
        // HANDLE SURFACE
        // =============================================================

        Surfaces.Surface {
            id: thumbSurface

            anchors.fill: parent

            elevation: control.handleElevation

            cornerRadius: Dimensions.radiusPill

            // Standard-Border bleibt aus Surface.qml.
            surfaceColor: control.thumbColor
            hoverColor: control.thumbHoverColor
            pressedColor: control.thumbPressedColor

            hovered: control.hovered && control.enabled

            shadowDarkColor: control.shadowColor
            shadowLightColor: control.highlightColor

            Binding on borderSize {
                when: control.handleBorderSize >= 0
                value: control.handleBorderSize
                restoreMode: Binding.RestoreBindingOrValue
            }
        }
    }

    // =========================================================================
    // VALUE LABEL
    // =========================================================================

    Text {
        id: valueLabel

        visible: control.showValue

        text: Number(control.value).toFixed(Math.max(0, control.valueDecimals)) + control.valueSuffix

        color: control.valueColor

        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.labelSize

        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        x: control.isHorizontal ? control.width - width : (control.width - width) / 2

        y: control.isHorizontal ? (control.height - height) / 2 : control.height - height
    }

    // =========================================================================
    // KEYBOARD FOCUS
    // =========================================================================

    Rectangle {
        visible: control.visualFocus

        x: thumb.x - 3 * Settings.scale
        y: thumb.y - 3 * Settings.scale

        width: thumb.width + 6 * Settings.scale
        height: thumb.height + 6 * Settings.scale

        radius: width / 2

        color: "transparent"

        border.color: control.accentColor
        border.width: Math.max(1, Settings.scale)
    }
}
