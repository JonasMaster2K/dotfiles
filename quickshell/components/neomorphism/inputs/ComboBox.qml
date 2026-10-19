pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces
import "../icons" as Icons

Controls.ComboBox {
    id: control

    // Appearance follows TextField and Button.
    property string sizeVariant: "md"
    property string elevation: "raised" // flat, raised, sunken
    property string popupElevation: "sunken"
    property real borderSize: 1 * Settings.scale
    property real popupBorderSize: 1 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton
    property color surfaceColor: Colors.surface
    property color hoverSurfaceColor: Colors.surfaceHover
    property color pressedSurfaceColor: Colors.surfacePressed
    property color textColor: Colors.textPrimary
    property color secondaryTextColor: Colors.textSecondary
    property color accentColor: Colors.accent
    property string arrowIconName: "arrow-down-symbolic"
    property real iconSize: Dimensions.iconSizeMd
    property int animationDuration: Animations.animationNormal
    property int maximumVisibleItems: 7

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
    readonly property real itemHeight: Math.max(variantHeight, 28 * Settings.scale)
    readonly property real popupPadding: Dimensions.spacingSm

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    implicitWidth: 220 * Settings.scale
    implicitHeight: variantHeight
    leftPadding: horizontalInset
    rightPadding: horizontalInset + iconSize + Dimensions.spacingSm
    topPadding: Theme.spacingSm
    bottomPadding: Theme.spacingSm
    opacity: enabled ? 1 : 0.48

    // Let Qt Quick Controls retain keyboard navigation and selection handling.
    contentItem: Text {
        text: control.displayText
        color: control.enabled ? control.textColor : control.secondaryTextColor
        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.bodySize
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        leftPadding: control.leftPadding
        rightPadding: control.rightPadding
    }

    background: Surfaces.Surface {
        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius
        surfaceColor: control.surfaceColor
        hoverColor: control.hoverSurfaceColor
        pressedColor: control.pressedSurfaceColor
        hovered: control.hovered && control.enabled && !control.down
    }

    indicator: Item {
        x: control.width - control.horizontalInset - width
        y: (control.height - height) / 2
        width: control.iconSize
        height: control.iconSize

        Icons.Icon {
            anchors.centerIn: parent
            iconName: control.arrowIconName
            size: control.iconSize
            iconColor: control.secondaryTextColor
            colorize: true
            rotation: control.popup.visible ? 180 : 0
            Behavior on rotation {
                NumberAnimation {
                    duration: control.animationDuration
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    delegate: Controls.ItemDelegate {
        id: option
        required property int index

        anchors.horizontalCenter: parent.horizontalCenter
        width: control.popup.width - 3 * control.popupPadding
        height: control.itemHeight
        hoverEnabled: true
        highlighted: control.highlightedIndex === index

        onClicked: {
            control.currentIndex = index;
            control.activated(index);
            control.popup.close();
        }

        contentItem: Text {
            text: control.textAt(option.index)
            color: option.enabled ? control.textColor : control.secondaryTextColor
            font.family: Typography.fontFamilyBody
            font.pixelSize: Typography.bodySize
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            leftPadding: Dimensions.spacingMd
            rightPadding: Dimensions.spacingMd
        }

        background: Surfaces.Surface {
            elevation: option.highlighted || option.hovered ? "raised" : "flat"
            borderSize: 1 * Settings.scale
            cornerRadius: control.cornerRadius
            surfaceColor: control.surfaceColor
            hoverColor: control.hoverSurfaceColor
            pressedColor: control.pressedSurfaceColor
            hovered: option.hovered
        }
    }

    popup: Controls.Popup {
        id: optionsPopup
        y: control.height + Dimensions.spacingSm
        width: control.width
        implicitHeight: Math.min(optionsView.contentHeight, control.itemHeight * Math.max(1, control.maximumVisibleItems)) + topPadding + bottomPadding
        padding: control.popupPadding
        modal: false
        focus: true
        closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside

        background: Surfaces.Surface {
            elevation: control.popupElevation
            borderSize: control.popupBorderSize
            cornerRadius: control.cornerRadius
            surfaceColor: control.surfaceColor
            hoverColor: control.hoverSurfaceColor
            pressedColor: control.pressedSurfaceColor
        }

        contentItem: ListView {
            id: optionsView
            clip: true
            implicitHeight: contentHeight
            spacing: Dimensions.spacingSm
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            boundsBehavior: Flickable.StopAtBounds
            Controls.ScrollBar.vertical: Controls.ScrollBar {}
        }

        enter: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: control.animationDuration
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.97
                    to: 1
                    duration: control.animationDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: Math.max(80, control.animationDuration / 2)
            }
        }
    }
}
