import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces
import "../icons" as Icons

Controls.AbstractButton {
    id: control

    property string sizeVariant: "sm"
    property string iconName: ""
    property bool removable: false
    property bool accentWhenChecked: true
    property color accentColor: Colors.accent
    property color labelColor: Colors.textPrimary
    property color surfaceColor: Colors.surface
    property color hoverColor: Colors.surfaceHover
    property color pressedColor: Colors.surfacePressed

    signal removeRequested

    readonly property real controlHeight: {
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
    horizontalPadding: Dimensions.spacingSm

    checkable: false
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    opacity: enabled ? 1 : 0.48
    implicitHeight: controlHeight
    implicitWidth: chipContents.implicitWidth + 2 * horizontalPadding

    background: Surfaces.Surface {
        elevation: control.down ? "sunken" : "raised"
        cornerRadius: Dimensions.radiusPill
        surfaceColor: control.surfaceColor
        hoverColor: control.hoverColor
        pressedColor: control.pressedColor
        hovered: control.hovered && control.enabled
    }

    contentItem: Row {
        id: chipContents
        spacing: Dimensions.spacingXs
        anchors.centerIn: parent

        Icons.Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: control.iconName.length > 0
            iconName: control.iconName
            size: Math.min(control.height * 0.46, 20 * Settings.scale)
            iconColor: control.checked && control.accentWhenChecked ? control.accentColor : control.labelColor
            colorize: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: control.text
            color: control.checked && control.accentWhenChecked ? control.accentColor : control.labelColor
            font.family: Typography.fontFamilyBody
            font.pixelSize: Typography.labelSize
        }

        Controls.AbstractButton {
            id: removeButton
            anchors.verticalCenter: parent.verticalCenter
            visible: control.removable
            width: Math.min(control.height * 0.58, Dimensions.hitTargetMin)
            height: width
            hoverEnabled: true
            focusPolicy: Qt.NoFocus
            background: Item {}
            contentItem: Icons.Icon {
                iconName: "window-close-symbolic"
                size: Math.min(removeButton.width * 0.65, 16 * Settings.scale)
                iconColor: removeButton.hovered ? control.accentColor : control.labelColor
                colorize: true
            }
            onClicked: control.removeRequested()
        }
    }
}
