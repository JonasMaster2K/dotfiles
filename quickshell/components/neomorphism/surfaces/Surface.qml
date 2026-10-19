import QtQuick
import Qt5Compat.GraphicalEffects as Effects

import "../../../style"
import "../../../config"

Item {
    id: root

    // Appearance
    property string elevation: "raised" // "raised", "flat", "sunken"
    property color surfaceColor: Colors.surface
    property color hoverColor: Colors.surfaceHover
    property color pressedColor: Colors.surfacePressed
    property bool hovered: false
    property bool animateColors: true

    // Geometry
    property real cornerRadius: Dimensions.radiusButton
    property real borderSize: Dimensions.borderWidth * 3
    property real shadowOffset: Dimensions.shadowOffsetSm
    property real shadowRadius: Dimensions.shadowRadiusSm
    property real innerShadowRadius: Dimensions.shadowRadiusMd

    // Shadow colors
    property color shadowDarkColor: Colors.shadowDark
    property color shadowLightColor: Colors.shadowLight

    readonly property bool raised: elevation === "raised"
    readonly property bool flat: elevation === "flat"
    readonly property bool sunken: elevation === "sunken"
    readonly property bool thickSunkenBorder: sunken && borderSize > Settings.scale

    readonly property real inset: Math.min(Math.max(0, borderSize), Math.max(0, Math.min(width, height) / 2 - 1))

    // One animated value drives both raised and sunken content.
    // Flat retains its previous pressedColor-as-default behavior.
    readonly property color targetFillColor: flat ? (hovered ? hoverColor : pressedColor) : (hovered ? hoverColor : surfaceColor)

    property color animatedFillColor: targetFillColor

    Behavior on animatedFillColor {
        enabled: root.animateColors
        ColorAnimation {
            duration: Animations.colorDuration
            easing.type: Animations.easingSmooth
        }
    }

    // ================================================================
    // RAISED: two outer shadows
    // ================================================================
    Item {
        anchors.fill: parent
        visible: root.raised

        Rectangle {
            id: raisedShadowSource
            anchors.fill: parent
            radius: root.cornerRadius
            color: root.surfaceColor
            visible: false
        }

        Effects.DropShadow {
            anchors.fill: raisedShadowSource
            source: raisedShadowSource
            color: root.shadowDarkColor
            horizontalOffset: root.shadowOffset
            verticalOffset: root.shadowOffset
            radius: root.shadowRadius
            samples: 17
            fast: true
        }

        Effects.DropShadow {
            anchors.fill: raisedShadowSource
            source: raisedShadowSource
            color: root.shadowLightColor
            horizontalOffset: -root.shadowOffset
            verticalOffset: -root.shadowOffset
            radius: root.shadowRadius
            samples: 17
            fast: true
        }
    }

    // ================================================================
    // FACE: raised / flat surface; sunken background underneath rim
    // ================================================================
    Rectangle {
        id: face
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.animatedFillColor
        antialiasing: true
    }

    // ================================================================
    // SUNKEN: rim plus inset shadows
    // ================================================================
    Item {
        anchors.fill: parent
        visible: root.sunken

        Rectangle {
            id: rimShadowSource
            anchors.fill: parent
            radius: root.cornerRadius
            color: root.surfaceColor
            visible: false
        }

        // Outer shadows only for the thick rim.
        Effects.DropShadow {
            anchors.fill: rimShadowSource
            source: rimShadowSource
            visible: root.thickSunkenBorder
            color: root.shadowDarkColor
            horizontalOffset: root.shadowOffset
            verticalOffset: root.shadowOffset
            radius: root.shadowRadius
            samples: 17
            fast: true
        }

        Effects.DropShadow {
            anchors.fill: rimShadowSource
            source: rimShadowSource
            visible: root.thickSunkenBorder
            color: root.shadowLightColor
            horizontalOffset: -root.shadowOffset
            verticalOffset: -root.shadowOffset
            radius: root.shadowRadius
            samples: 17
            fast: true
        }

        Rectangle {
            id: rim
            anchors.fill: parent
            radius: root.cornerRadius
            antialiasing: true
            color: root.surfaceColor
            gradient: root.thickSunkenBorder ? null : thinBorderGradient

            Gradient {
                id: thinBorderGradient
                orientation: Gradient.Vertical

                GradientStop {
                    position: 0
                    color: Qt.tint(root.surfaceColor, root.shadowLightColor)
                }
                GradientStop {
                    position: 0.5
                    color: root.surfaceColor
                }
                GradientStop {
                    position: 1
                    color: Qt.tint(root.surfaceColor, root.shadowDarkColor)
                }
            }
        }

        Rectangle {
            id: insetSource
            anchors.fill: parent
            anchors.margins: root.inset
            radius: Math.max(0, root.cornerRadius - root.inset)
            color: root.animatedFillColor
            antialiasing: true
            visible: false
        }

        Effects.InnerShadow {
            id: darkInset
            anchors.fill: insetSource
            source: insetSource
            color: root.shadowDarkColor
            horizontalOffset: root.shadowOffset
            verticalOffset: root.shadowOffset
            radius: Math.min(root.innerShadowRadius, insetSource.height / 6)
            samples: 25
            spread: 0.2
            fast: false
            visible: false
        }

        Effects.InnerShadow {
            anchors.fill: insetSource
            source: darkInset
            color: root.shadowLightColor
            horizontalOffset: -root.shadowOffset
            verticalOffset: -root.shadowOffset
            radius: Math.min(root.innerShadowRadius, insetSource.height / 6)
            samples: 25
            spread: 0.2
            fast: false
        }
    }
}
