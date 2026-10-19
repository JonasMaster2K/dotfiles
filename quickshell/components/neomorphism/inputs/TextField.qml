import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces
import "../icons" as Icons

Controls.TextField {
    id: control

    // "flat", "raised", "sunken"
    property string elevation: "sunken"
    property string sizeVariant: "md" // xs, sm, md, lg, xl
    property real borderSize: Dimensions.borderWidth * 3
    property real cornerRadius: height / 2

    property color hoverSurfaceColor: Colors.surfaceHover
    property color textColor: Colors.textPrimary
    property color iconColor: Colors.textSecondary

    property string leadingIcon: ""
    property string trailingIcon: ""
    property real iconSize: Dimensions.iconSizeMd

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
    readonly property real horizontalInset: Dimensions.spacingLg
    readonly property real iconGap: Dimensions.spacingSm

    implicitWidth: 240 * Settings.scale
    implicitHeight: variantHeight
    leftPadding: horizontalInset + (leadingIcon.length > 0 ? iconSize + iconGap : 0)
    rightPadding: horizontalInset + (trailingIcon.length > 0 ? iconSize + iconGap : 0)
    topPadding: 0
    bottomPadding: 0

    color: enabled ? textColor : Colors.textSecondary
    placeholderTextColor: Colors.textSecondary
    selectionColor: Colors.accent
    selectedTextColor: Colors.textPrimary
    font.family: Typography.fontFamilyBody
    font.pixelSize: Typography.bodySize
    verticalAlignment: TextInput.AlignVCenter
    selectByMouse: true
    hoverEnabled: true
    opacity: enabled ? 1 : 0.48

    background: Surfaces.Surface {
        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius
        hoverColor: control.hoverSurfaceColor
        hovered: control.hovered && control.enabled && !control.activeFocus
    }

    Icons.Icon {
        visible: control.leadingIcon.length > 0
        iconName: control.leadingIcon
        iconColor: control.iconColor
        size: control.iconSize
        colorize: true
        x: control.horizontalInset
        y: (control.height - height) / 2
    }

    Icons.Icon {
        visible: control.trailingIcon.length > 0
        iconName: control.trailingIcon
        iconColor: control.iconColor
        size: control.iconSize
        colorize: true
        x: control.width - control.horizontalInset - width
        y: (control.height - height) / 2
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -2 * Settings.scale
        radius: control.cornerRadius + 2 * Settings.scale
        color: "transparent"
        border.width: Math.max(1, Settings.scale)
        border.color: Colors.accent
        visible: control.activeFocus
        opacity: 0.65
    }
}
