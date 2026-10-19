pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces
import "../icons" as Icons

Item {
    id: root

    // Example: [{ text: "Home", icon: "go-home-symbolic" }, ...]
    property var items: []
    property int currentIndex: 0
    property string sizeVariant: "md"
    property bool showLabels: true
    property string elevation: "sunken"
    property real borderSize: 4 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton
    property color surfaceColor: Colors.surface
    property color textColor: Colors.textSecondary
    property color activeColor: Colors.accent
    property real spacing: Dimensions.spacingSm
    property real railPadding: Dimensions.spacingMd
    signal itemSelected(int index)

    readonly property real itemHeight: {
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
    readonly property real iconSize: Dimensions.iconSizeMd

    implicitWidth: (showLabels ? 190 : 64) * Settings.scale
    implicitHeight: itemsColumn.implicitHeight + 2 * railPadding

    Surfaces.Surface {
        anchors.fill: parent
        elevation: root.elevation
        cornerRadius: root.cornerRadius
        borderSize: root.borderSize
        surfaceColor: root.surfaceColor
    }

    Column {
        id: itemsColumn
        x: root.railPadding
        y: root.railPadding
        width: Math.max(0, root.width - root.railPadding * 2)
        spacing: root.spacing

        Repeater {
            model: root.items
            delegate: Controls.AbstractButton {
                id: railButton
                required property int index
                required property var modelData
                readonly property bool selected: index === root.currentIndex

                width: itemsColumn.width
                height: root.itemHeight
                hoverEnabled: true
                focusPolicy: Qt.StrongFocus
                Accessible.name: String(modelData.text || "")
                Accessible.role: Accessible.Button

                background: Surfaces.Surface {
                    elevation: railButton.down ? "sunken" : railButton.selected ? "raised" : "flat"
                    cornerRadius: root.cornerRadius
                    borderSize: 1 * Settings.scale
                    surfaceColor: root.surfaceColor
                    hovered: railButton.hovered && !railButton.selected
                }

                contentItem: Item {
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Dimensions.spacingMd
                        spacing: Dimensions.spacingSm
                        Icons.Icon {
                            visible: String(railButton.modelData.icon || "").length > 0
                            iconName: String(railButton.modelData.icon || "")
                            size: root.iconSize
                            iconColor: railButton.selected ? root.activeColor : root.textColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            visible: root.showLabels
                            text: String(railButton.modelData.text || "")
                            color: railButton.selected ? root.activeColor : root.textColor
                            font.family: Typography.fontFamilyBody
                            font.pixelSize: Typography.labelSize
                            font.weight: railButton.selected ? Font.DemiBold : Font.Normal
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                onClicked: {
                    root.currentIndex = index;
                    root.itemSelected(index);
                }
            }
        }
    }
}
