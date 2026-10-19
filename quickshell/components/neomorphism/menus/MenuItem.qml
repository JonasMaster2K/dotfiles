import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces
import "../icons" as Icons

Controls.MenuItem {
    id: control

    property string sizeVariant: "md"
    property string iconName: ""
    property string shortcutLabel: ""
    property string selectedIconName: "object-select-symbolic"
    property string submenuIconName: "go-next-symbolic"
    property real cornerRadius: Dimensions.radiusButton
    property real borderSize: 1 * Settings.scale
    property color surfaceColor: Colors.surface
    property color textColor: Colors.textPrimary
    property color secondaryTextColor: Colors.textSecondary
    property color activeColor: Colors.accent

    readonly property real variantHeight: {
        switch (sizeVariant) {
        case "xs": return Dimensions.controlHeightXs
        case "sm": return Dimensions.controlHeightSm
        case "lg": return Dimensions.controlHeightLg
        case "xl": return Dimensions.controlHeightXl
        default: return Dimensions.controlHeightMd
        }
    }
    readonly property real iconSize: Dimensions.iconSizeMd

    hoverEnabled: true
    implicitHeight: variantHeight
    implicitWidth: Math.max(200 * Settings.scale,
                            contentRow.implicitWidth + 2 * Dimensions.spacingMd)
    leftPadding: Dimensions.spacingMd
    rightPadding: Dimensions.spacingMd
    opacity: enabled ? 1 : 0.48

    background: Surfaces.Surface {
        elevation: control.down ? "sunken"
                   : control.highlighted || control.hovered ? "raised" : "flat"
        cornerRadius: control.cornerRadius
        borderSize: control.borderSize
        surfaceColor: control.surfaceColor
        hoverColor: Colors.surfaceHover
        pressedColor: Colors.surfacePressed
        hovered: control.hovered && control.enabled
    }

    contentItem: Item {
        Row {
            id: contentRow
            anchors.fill: parent
            spacing: Dimensions.spacingSm

            Item {
                width: control.iconSize
                height: parent.height
                Icons.Icon {
                    anchors.centerIn: parent
                    visible: control.iconName.length > 0
                    iconName: control.iconName
                    iconColor: control.textColor
                    size: control.iconSize
                }
            }

            Text {
                text: control.text
                color: control.checked ? control.activeColor : control.textColor
                font.family: Typography.fontFamilyBody
                font.pixelSize: Typography.bodySize
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                width: Math.max(0, parent.width - control.iconSize
                                - Dimensions.spacingSm * 3
                                - trailing.implicitWidth)
                height: parent.height
            }

            Row {
                id: trailing
                spacing: Dimensions.spacingSm
                height: parent.height

                Text {
                    visible: control.shortcutLabel.length > 0 && !control.checkable
                    text: control.shortcutLabel
                    color: control.secondaryTextColor
                    font.family: Typography.fontFamilyBody
                    font.pixelSize: Typography.labelSize
                    verticalAlignment: Text.AlignVCenter
                    height: parent.height
                }
                Icons.Icon {
                    visible: control.checkable && control.checked
                    iconName: control.selectedIconName
                    iconColor: control.activeColor
                    size: control.iconSize
                    anchors.verticalCenter: parent.verticalCenter
                }
                Icons.Icon {
                    visible: control.subMenu !== null
                    iconName: control.submenuIconName
                    iconColor: control.secondaryTextColor
                    size: control.iconSize
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
