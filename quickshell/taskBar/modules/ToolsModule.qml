pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import "../../components/neomorphism/buttons" as Buttons
import "../../components/neomorphism/icons" as Icons
import "../../components/neomorphism/surfaces" as Surfaces

import "../../style"
import "../../config"
import "../../services"

Surfaces.Revealer {
    id: control

    // =========================================================================
    // MODULE API
    // =========================================================================

    property string displayName: "Tools"
    property string displayMode: "iconSet"
    property var taskBarWindow: null
    property bool buttonMode: true
    property real toolSpacing: Dimensions.spacingSm

    // =========================================================================
    // REVEALER
    // =========================================================================

    direction: "left"
    revealOnHover: true
    elevation: Settings.taskBarWidgetStyle
    contentSpacing: Dimensions.spacingXs
    customHeight: Dimensions.taskBarWidgetSizeMd

    triggerContent: [
        Item {
            width: Dimensions.taskBarWidgetSizeMd
            height: Dimensions.taskBarWidgetSizeMd

            Icons.Icon {
                anchors.centerIn: parent

                iconName: "tools-symbolic"
                size: Dimensions.taskBarIconSizeMd

                iconColor: Colors.textPrimary
                colorize: true
            }
        }
    ]

    revealedContent: [
        Row {
            spacing: control.toolSpacing
            anchors.verticalCenter: control.verticalCenter
            height: Dimensions.taskBarWidgetSizeMd
            leftPadding: control.direction == "left" ? Dimensions.spacingXs : 0
            rightPadding: control.direction == "right" ? Dimensions.spacingXs : 0

            // TODO (popupcontroller)
            Buttons.IconButton {
                anchors.verticalCenter: parent.verticalCenter
                buttonHeight: Dimensions.taskBarWidgetSizeSm
                iconSize: Dimensions.taskBarIconSizeMd
                iconName: "tomato-symbolic"
                elevation: "flat"

                onClicked: console.log("TODO: Pomodoro")
            }

            Buttons.IconButton {
                anchors.verticalCenter: parent.verticalCenter
                buttonHeight: Dimensions.taskBarWidgetSizeSm
                iconSize: Dimensions.taskBarIconSizeMd
                iconName: "eyedropper-symbolic"
                elevation: "flat"

                onClicked: Quickshell.execDetached(Settings.apps.colorPicker)
            }

            Buttons.IconButton {
                anchors.verticalCenter: parent.verticalCenter
                buttonHeight: Dimensions.taskBarWidgetSizeSm
                iconSize: Dimensions.taskBarIconSizeMd
                iconName: "screenshot-symbolic"
                elevation: "flat"

                onClicked: Quickshell.execDetached(Settings.apps.screenshot)
            }

            Buttons.IconButton {
                anchors.verticalCenter: parent.verticalCenter
                buttonHeight: Dimensions.taskBarWidgetSizeSm
                iconSize: Dimensions.taskBarIconSizeMd
                iconName: Theme.darkMode ? "dark-mode-symbolic" : "light-mode-symbolic"
                elevation: "flat"

                onClicked: Settings.darkMode = !Settings.darkMode
            }

            Buttons.IconButton {
                anchors.verticalCenter: parent.verticalCenter
                buttonHeight: Dimensions.taskBarWidgetSizeSm
                iconSize: Dimensions.taskBarIconSizeMd
                iconName: AirplaneModeService.iconName
                iconColor: AirplaneModeService.iconColor
                elevation: "flat"

                onClicked: AirplaneModeService.toggleMode()
            }

            Buttons.IconButton {
                anchors.verticalCenter: parent.verticalCenter
                buttonHeight: Dimensions.taskBarWidgetSizeSm
                iconSize: Dimensions.taskBarIconSizeMd
                iconName: "concentration-disabled-symbolic"
                elevation: "flat"

                onClicked: console.log("TODO: Focus mode")
            }
        }
    ]
}
