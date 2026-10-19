import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.RangeSlider {
    id: control

    property string sizeVariant: "md"
    property bool showActiveFill: true
    property color accentColor: Colors.accent
    property color trackColor: Colors.surface
    property color trackHoverColor: Colors.surfaceHover
    property color thumbColor: Colors.surfaceRaised
    property color thumbHoverColor: Colors.surfaceHover
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
    readonly property real trackThickness: Math.max(5 * Settings.scale, baseHeight * 0.29)
    readonly property real thumbSize: Math.max(trackThickness + 5 * Settings.scale, baseHeight * 0.68)
    readonly property real travel: Math.max(0, (horizontal ? availableWidth : availableHeight) - thumbSize)
    readonly property real firstCenter: thumbSize / 2 + first.visualPosition * travel
    readonly property real secondCenter: thumbSize / 2 + second.visualPosition * travel

    from: 0
    to: 100
    first.value: 25
    second.value: 75
    stepSize: 1
    snapMode: Controls.RangeSlider.SnapOnRelease
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    padding: 0
    opacity: enabled ? 1 : 0.48
    implicitWidth: horizontal ? 200 * Settings.scale : Math.max(baseHeight, thumbSize)
    implicitHeight: horizontal ? Math.max(baseHeight, thumbSize) : 200 * Settings.scale

    background: Item {
        x: control.leftPadding
        y: control.topPadding
        width: control.availableWidth
        height: control.availableHeight

        Item {
            id: track
            width: control.horizontal ? parent.width : control.trackThickness
            height: control.horizontal ? control.trackThickness : parent.height
            anchors.centerIn: parent

            Surfaces.Surface {
                id: trackSurface
                anchors.fill: parent
                elevation: "sunken"
                cornerRadius: Dimensions.radiusPill
                surfaceColor: control.trackColor
                hoverColor: control.trackHoverColor
                hovered: control.hovered
                shadowDarkColor: control.shadowColor
                shadowLightColor: control.highlightColor
            }

            Rectangle {
                visible: control.showActiveFill
                color: control.accentColor
                opacity: 0.85
                radius: Math.min(width, height) / 2
                readonly property real start: Math.min(control.firstCenter, control.secondCenter)
                readonly property real end: Math.max(control.firstCenter, control.secondCenter)
                x: control.horizontal ? start : (track.width - width) / 2
                y: control.horizontal ? (track.height - height) / 2 : start
                width: control.horizontal ? Math.max(0, end - start) : Math.max(2 * Settings.scale, track.width * 0.42)
                height: control.horizontal ? Math.max(2 * Settings.scale, track.height * 0.42) : Math.max(0, end - start)
            }
        }
    }

    first.handle: Item {
        width: control.thumbSize
        height: control.thumbSize
        x: control.leftPadding + (control.horizontal ? control.first.visualPosition * control.travel : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.first.visualPosition * control.travel)
        scale: control.first.pressed ? 0.94 : 1

        Behavior on x {
            enabled: !control.first.pressed
            NumberAnimation {
                duration: control.animationDuration
                easing.type: Easing.InOutCubic
            }
        }
        Behavior on y {
            enabled: !control.first.pressed
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
            elevation: "raised"
            cornerRadius: Dimensions.radiusPill
            surfaceColor: control.thumbColor
            hoverColor: control.thumbHoverColor
            hovered: control.first.hovered
            shadowDarkColor: control.shadowColor
            shadowLightColor: control.highlightColor
        }
    }

    second.handle: Item {
        width: control.thumbSize
        height: control.thumbSize
        x: control.leftPadding + (control.horizontal ? control.second.visualPosition * control.travel : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.second.visualPosition * control.travel)
        scale: control.second.pressed ? 0.94 : 1

        Behavior on x {
            enabled: !control.second.pressed
            NumberAnimation {
                duration: control.animationDuration
                easing.type: Easing.InOutCubic
            }
        }
        Behavior on y {
            enabled: !control.second.pressed
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
            elevation: "raised"
            cornerRadius: Dimensions.radiusPill
            surfaceColor: control.thumbColor
            hoverColor: control.thumbHoverColor
            hovered: control.second.hovered
            shadowDarkColor: control.shadowColor
            shadowLightColor: control.highlightColor
        }
    }
}
