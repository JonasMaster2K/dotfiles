pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Item {
    id: root

    // Example: ["Home", "Settings", "Appearance"]
    property var items: []
    property string sizeVariant: "md"
    property string elevation: "flat"
    property real borderSize: 1 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton
    property color surfaceColor: Colors.surface
    property color textColor: Colors.textSecondary
    property color activeColor: Colors.textPrimary
    property color separatorColor: Colors.textSecondary
    property string separator: "/"
    property real spacing: Dimensions.spacingSm
    signal itemClicked(int index)

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

    implicitWidth: breadcrumbRow.implicitWidth + 2 * Dimensions.spacingSm
    implicitHeight: itemHeight + 2 * Dimensions.spacingSm

    Surfaces.Surface {
        anchors.fill: parent
        elevation: root.elevation
        borderSize: root.borderSize
        cornerRadius: root.cornerRadius
        surfaceColor: root.surfaceColor
    }

    Row {
        id: breadcrumbRow
        anchors.verticalCenter: parent.verticalCenter
        x: Dimensions.spacingSm
        spacing: root.spacing

        Repeater {
            model: root.items
            delegate: Row {
                id: crumb
                required property int index
                required property var modelData
                readonly property bool isLast: index === root.items.length - 1
                spacing: root.spacing

                Controls.AbstractButton {
                    id: crumbButton
                    enabled: !crumb.isLast
                    hoverEnabled: true
                    implicitHeight: root.itemHeight
                    implicitWidth: crumbLabel.implicitWidth + 2 * Dimensions.spacingSm
                    background: Surfaces.Surface {
                        elevation: crumbButton.down ? "sunken" : (crumbButton.hovered ? "raised" : "flat")
                        cornerRadius: root.cornerRadius
                        borderSize: root.borderSize
                        surfaceColor: root.surfaceColor
                    }
                    contentItem: Text {
                        id: crumbLabel
                        text: String(crumb.modelData)
                        font.family: Typography.fontFamilyBody
                        font.pixelSize: Typography.labelSize
                        font.weight: crumb.isLast ? Font.DemiBold : Font.Normal
                        color: crumb.isLast ? root.activeColor : root.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onClicked: root.itemClicked(crumb.index)
                }

                Text {
                    visible: !crumb.isLast
                    text: root.separator
                    color: root.separatorColor
                    font.family: Typography.fontFamilyBody
                    font.pixelSize: Typography.labelSize
                    height: root.itemHeight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
