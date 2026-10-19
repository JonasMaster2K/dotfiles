pragma ComponentBehavior: Bound

import QtQuick

import "../../components/neomorphism/buttons" as Buttons
import "../../components/neomorphism/icons" as Icons
import "../../components/neomorphism/feedback" as Feedback

import "../../style"
import "../../services"
import "../../config"

Buttons.Button {
    id: root

    // ========================================================================
    // MODULE API
    // ========================================================================

    property string moduleName: "Quick Controls"
    property string displayMode: "iconSet"
    property var taskBarWindow: null
    buttonHeight: Dimensions.taskBarWidgetSizeMd

    // ========================================================================
    // ICONS
    // ========================================================================

    property real moduleSpacing: Dimensions.spacingMd
    property real moduleIconSize: Dimensions.taskBarIconSizeMd
    property color moduleIconColor: Colors.textPrimary

    signal openRequested

    // ========================================================================
    // BUTTON
    // ========================================================================

    text: root.displayMode === "text" ? root.moduleName : ""
    elevation: Settings.taskBarWidgetStyle
    iconName: root.displayMode === "icon" ? "preferences-system-symbolic" : ""

    implicitWidth: root.displayMode === "iconSet" ? Math.max(buttonHeight, iconsRow.implicitWidth + paddingHorizontal * 2) : Math.max(buttonHeight, (hasIcon ? effectiveIconSize : 0) + (hasIcon && hasText ? contentSpacing : 0) + labelWidth + paddingHorizontal * 2)

    // ========================================================================
    // ICON SET
    // ========================================================================

    Row {
        id: iconsRow

        visible: root.displayMode === "iconSet"

        anchors.centerIn: parent
        spacing: root.moduleSpacing

        Icons.Icon {
            id: networkIcon
            iconName: NetworkService.iconName
            size: root.moduleIconSize
            iconColor: NetworkService.iconColor
            colorize: true

            HoverHandler {
                id: networkHover
            }
            Feedback.ToolTip {
                text: NetworkService.connected ? NetworkService.name : "Not connected"
                visible: networkHover.hovered
                targetItem: networkIcon
                xOff: networkIcon.implicitWidth / 2 - implicitWidth / 2
                yOff: Settings.taskBarPosition == "top" ? Dimensions.spacingMd : -Dimensions.spacingMd
            }
        }

        Icons.Icon {
            iconName: BluetoothService.iconName
            size: root.moduleIconSize
            iconColor: BluetoothService.iconColor
            colorize: true
        }

        Icons.Icon {
            id: audioIcon
            iconName: AudioService.iconName
            size: root.moduleIconSize
            iconColor: AudioService.iconColor
            colorize: true

            HoverHandler {
                id: audioHover
            }
            Feedback.ToolTip {
                text: Math.round(AudioService.volume) + "% volume"
                visible: audioHover.hovered
                targetItem: audioIcon
                xOff: audioIcon.implicitWidth / 2 - implicitWidth / 2
                yOff: Settings.taskBarPosition == "top" ? Dimensions.spacingMd : -Dimensions.spacingMd
            }
        }

        Icons.Icon {
            id: batteryIcon
            iconName: BatteryService.iconName
            size: root.moduleIconSize
            iconColor: BatteryService.iconColor
            colorize: true

            HoverHandler {
                id: batteryHover
            }
            Feedback.ToolTip {
                text: Math.round(BatteryService.level) + "% · " + (BatteryService.timeToEmpty != 0 ? "Remaining: " + BatteryService.formatTime(BatteryService.timeToEmpty) : BatteryService.timeToFull != 0 ? "Until full: " + BatteryService.formatTime(BatteryService.timeToFull) : "Fully charged")
                visible: batteryHover.hovered
                targetItem: batteryIcon
                xOff: batteryIcon.implicitWidth / 2 - implicitWidth / 2
                yOff: Settings.taskBarPosition == "top" ? Dimensions.spacingMd : -Dimensions.spacingMd
            }
        }
    }

    // ========================================================================
    // INTERACTION
    // ========================================================================

    onClicked: root.openRequested()
}
