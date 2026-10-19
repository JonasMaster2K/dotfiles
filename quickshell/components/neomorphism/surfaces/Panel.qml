import QtQuick

import "../../../style"
import "../../../config"

Item {
    id: control

    // All child items go into the body below the optional header.
    default property alias content: contentHost.data

    property string title: ""
    property string subtitle: ""
    property bool showHeader: title.length > 0 || subtitle.length > 0

    property string elevation: "raised"
    property color surfaceColor: Colors.surface
    property color hoverColor: Colors.surfaceHover
    property color pressedColor: Colors.surfacePressed
    property real cornerRadius: Dimensions.radiusButton
    property real borderSize: Dimensions.borderWidth
    property real contentPadding: Dimensions.spacingXl
    property real headerSpacing: Dimensions.spacingMd
    property bool showHeaderDivider: true

    implicitWidth: 360 * Settings.scale
    implicitHeight: 260 * Settings.scale

    Surface {
        anchors.fill: parent
        elevation: control.elevation
        surfaceColor: control.surfaceColor
        hoverColor: control.hoverColor
        pressedColor: control.pressedColor
        cornerRadius: control.cornerRadius
        borderSize: control.borderSize
    }

    Item {
        id: headerArea
        visible: control.showHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: control.contentPadding
        anchors.rightMargin: control.contentPadding
        anchors.topMargin: control.contentPadding
        height: visible ? heading.implicitHeight + (control.showHeaderDivider ? control.headerSpacing + divider.implicitHeight : 0) : 0

        Column {
            id: heading
            width: parent.width
            spacing: Dimensions.spacingSm

            Text {
                visible: control.title.length > 0
                width: parent.width
                text: control.title
                color: Colors.textPrimary
                font.family: Typography.fontFamilyHeading
                font.pixelSize: Typography.titleSize
                font.weight: Typography.weightSemibold
                elide: Text.ElideRight
            }

            Text {
                visible: control.subtitle.length > 0
                width: parent.width
                text: control.subtitle
                color: Colors.textSecondary
                font.family: Typography.fontFamilyBody
                font.pixelSize: Typography.labelSize
                wrapMode: Text.Wrap
            }
        }

        Divider {
            id: divider
            visible: control.showHeaderDivider
            width: parent.width
            y: heading.implicitHeight + control.headerSpacing
        }
    }

    Item {
        id: contentHost
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: control.showHeader ? headerArea.bottom : parent.top
        anchors.leftMargin: control.contentPadding
        anchors.rightMargin: control.contentPadding
        anchors.bottomMargin: control.contentPadding
        anchors.topMargin: control.showHeader ? control.headerSpacing : control.contentPadding
    }
}
