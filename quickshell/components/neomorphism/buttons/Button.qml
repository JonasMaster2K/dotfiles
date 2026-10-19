import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../surfaces"
import "../icons" as Icons
import "../../../config"

Controls.Button {
    id: control

    // =========================================================================
    // PUBLIC API
    // =========================================================================

    // Content
    property string iconName: ""
    property bool elideText: true

    // Size variant: xs | sm | md | lg | xl
    property string sizeVariant: "md"

    property string elevation: "raised"

    // 0 = automatic
    property real buttonHeight: 0
    property real iconSize: 0
    property real textSize: 0
    property real maxTextWidth: 180 * Dimensions.spacingMd / 12

    // Typography
    property string textFontFamily: Typography.fontFamilyButton

    // Colors
    property color iconColor: Colors.textPrimary
    property color textColor: Colors.textPrimary

    property color surfaceColor: Colors.surface
    property color hoverSurfaceColor: Colors.surfaceHover
    property color pressedSurfaceColor: Colors.surface

    // Geometry
    property real cornerRadius: Dimensions.radiusButton
    property real contentSpacing: Dimensions.spacingSm
    property real paddingHorizontal: Dimensions.controlPaddingHorizontal

    // =========================================================================
    // SIZE RESOLUTION
    // =========================================================================

    readonly property real variantHeight: {
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

    readonly property real variantIconSize: {
        switch (sizeVariant) {
        case "xs":
            return Dimensions.iconSizeXs;
        case "sm":
            return Dimensions.iconSizeSm;
        case "lg":
            return Dimensions.iconSizeLg;
        case "xl":
            return Dimensions.iconSizeXl;
        default:
            return Dimensions.iconSizeMd;
        }
    }

    // =========================================================================
    // DERIVED PROPERTIES
    // =========================================================================

    readonly property real effectiveButtonHeight: buttonHeight > 0 ? buttonHeight : variantHeight

    readonly property real effectiveIconSize: iconSize > 0 ? iconSize : variantIconSize

    readonly property real effectiveTextSize: textSize > 0 ? textSize : Typography.buttonSize

    readonly property bool hasIcon: iconName.length > 0
    readonly property bool hasText: text.length > 0

    readonly property real labelWidth: hasText ? (elideText ? Math.min(textMetrics.advanceWidth + 2, Math.max(1, maxTextWidth)) : textMetrics.advanceWidth + 2) : 0

    // =========================================================================
    // LAYOUT & INTERACTION
    // =========================================================================

    hoverEnabled: true
    padding: 0

    implicitHeight: effectiveButtonHeight
    implicitWidth: Math.max(variantHeight, (hasIcon ? effectiveIconSize : 0) + (hasIcon && hasText ? contentSpacing : 0) + labelWidth + paddingHorizontal * 2)

    opacity: enabled ? 1.0 : 0.6

    // =========================================================================
    // BACKGROUND
    // =========================================================================

    background: Surface {
        id: background

        elevation: control.down ? "sunken" : control.elevation

        hovered: control.hovered && !control.down && control.enabled

        surfaceColor: control.surfaceColor
        hoverColor: control.hoverSurfaceColor
        pressedColor: control.pressedSurfaceColor

        cornerRadius: control.cornerRadius
        borderSize: 1 * Settings.scale
    }

    // =========================================================================
    // CONTENT
    // =========================================================================

    contentItem: Item {
        scale: control.down ? Animations.scalePressed : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: control.down ? Animations.pressDuration : Animations.releaseDuration

                easing.type: Animations.easingStandard
            }
        }

        Row {
            anchors.centerIn: parent

            spacing: control.hasIcon && control.hasText ? control.contentSpacing : 0

            // -----------------------------------------------------------------
            // Icon
            // -----------------------------------------------------------------

            Item {
                width: control.hasIcon ? control.effectiveIconSize : 0
                height: control.variantHeight
                visible: control.hasIcon

                Icons.Icon {
                    anchors.centerIn: parent

                    iconName: control.iconName
                    size: control.effectiveIconSize

                    iconColor: control.enabled ? control.iconColor : Colors.textDisabled

                    colorize: true
                }
            }

            // -----------------------------------------------------------------
            // Text
            // -----------------------------------------------------------------

            Text {
                visible: control.hasText

                width: control.hasText ? control.labelWidth : 0
                height: control.variantHeight

                text: control.text

                color: control.enabled ? control.textColor : Colors.textDisabled

                font.family: control.textFontFamily
                font.pixelSize: control.effectiveTextSize
                font.weight: Typography.weightRegular

                elide: control.elideText ? Text.ElideRight : Text.ElideNone

                wrapMode: Text.NoWrap

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    // =========================================================================
    // TEXT METRICS
    // =========================================================================

    TextMetrics {
        id: textMetrics

        font.family: control.textFontFamily
        font.pixelSize: control.effectiveTextSize
        font.weight: Typography.weightRegular

        text: control.text
    }
}
