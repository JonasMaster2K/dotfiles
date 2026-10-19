import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces
import "../icons" as Icons

Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool expanded: false
    property bool interactive: true
    property string sizeVariant: "md"
    property Component contentComponent: null
    property real contentPadding: Dimensions.spacingMd
    property color titleColor: Colors.textPrimary
    property color subtitleColor: Colors.textSecondary
    property color surfaceColor: Colors.surface
    property color hoverColor: Colors.surfaceHover
    property color accentColor: Colors.accent
    property int animationDuration: Animations.animationNormal

    signal toggled(bool expanded)

    readonly property real headerHeight: {
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

    implicitWidth: 240 * Settings.scale
    implicitHeight: header.height + contentArea.height

    Controls.AbstractButton {
        id: header
        x: 0
        y: 0
        width: parent.width
        height: root.headerHeight
        enabled: root.interactive
        hoverEnabled: true
        focusPolicy: Qt.StrongFocus

        background: Surfaces.Surface {
            elevation: root.expanded ? "sunken" : "raised"
            cornerRadius: Dimensions.radiusButton
            surfaceColor: root.surfaceColor
            hoverColor: root.hoverColor
            hovered: header.hovered && header.enabled
        }

        contentItem: RowLayout {
            spacing: Dimensions.spacingSm

            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: Dimensions.spacingMd
                spacing: 1 * Settings.scale

                Text {
                    width: parent.width
                    text: root.title
                    color: root.titleColor
                    font.family: Typography.fontFamilyBody
                    font.pixelSize: Typography.labelSize
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    visible: root.subtitle.length > 0
                    text: root.subtitle
                    color: root.subtitleColor
                    font.family: Typography.fontFamilyBody
                    font.pixelSize: Math.max(9, Typography.labelSize * 0.85)
                    elide: Text.ElideRight
                }
            }

            Icons.Icon {
                id: indicator
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: Dimensions.spacingMd
                iconName: "arrow-down-symbolic"
                size: 18 * Settings.scale
                iconColor: root.expanded ? root.accentColor : root.titleColor
                colorize: true
                rotation: root.expanded ? 180 : 0
                Behavior on rotation {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.InOutCubic
                    }
                }
            }
        }

        onClicked: {
            root.expanded = !root.expanded;
            root.toggled(root.expanded);
        }
    }

    Item {
        id: contentArea
        x: 0
        y: header.height
        width: parent.width
        height: root.expanded ? loader.implicitHeight + root.contentPadding * 2 : 0
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.InOutCubic
            }
        }

        Loader {
            id: loader
            x: root.contentPadding
            y: root.contentPadding
            width: Math.max(0, parent.width - root.contentPadding * 2)
            sourceComponent: root.contentComponent
        }
    }
}
