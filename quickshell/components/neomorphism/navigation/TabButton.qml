import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces
import "../icons" as Icons

Controls.TabButton {
    id: control

    property string sizeVariant: "md"
    property string iconName: ""

    property color textColor: Colors.textPrimary
    property color iconColor: Colors.textSecondary
    property color activeColor: Colors.accent

    property real cornerRadius: Dimensions.radiusButton
    property real borderSize: 1 * Settings.scale

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

    readonly property real effectiveIconSize: {
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

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus

    implicitHeight: variantHeight
    implicitWidth: Math.max(80 * Settings.scale, label.implicitWidth + (iconName.length > 0 ? effectiveIconSize + Dimensions.spacingSm : 0) + 2 * Dimensions.spacingLg)

    background: Surfaces.Surface {
        elevation: control.down ? "sunken" : control.checked ? "raised" : "flat"

        borderSize: control.borderSize
        cornerRadius: control.cornerRadius

        surfaceColor: Colors.surface
        hoverColor: Colors.surfaceHover
        pressedColor: Colors.surfacePressed

        hovered: control.hovered && control.enabled
    }

    contentItem: Item {
        Row {
            anchors.centerIn: parent
            spacing: Dimensions.spacingSm

            Icons.Icon {
                visible: control.iconName.length > 0

                iconName: control.iconName
                size: control.effectiveIconSize
                iconColor: control.checked ? control.activeColor : control.iconColor

                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: label

                text: control.text
                color: control.checked ? control.activeColor : control.textColor

                font.family: Typography.fontFamilyBody
                font.pixelSize: Typography.labelSize
                font.weight: control.checked ? Font.DemiBold : Font.Medium

                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: Animations.colorDuration
                    }
                }
            }
        }
    }

    opacity: enabled ? 1 : 0.48
}
