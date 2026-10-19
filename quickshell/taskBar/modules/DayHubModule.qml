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

    property string moduleName: "Info Center"
    property string displayMode: "iconText"
    property var taskBarWindow: null

    property bool buttonMode: true
    buttonHeight: Dimensions.taskBarWidgetSizeMd

    property real moduleSpacing: Dimensions.spacingMd

    text: ""
    iconName: ""
    elevation: Settings.taskBarWidgetStyle
    implicitWidth: root.displayMode === "iconText" ? Math.max(buttonHeight, infoContent.implicitWidth + paddingHorizontal * 2) : Math.max(buttonHeight, (hasIcon ? effectiveIconSize : 0) + (hasIcon && hasText ? contentSpacing : 0) + labelWidth + paddingHorizontal * 2)

    Row {
        id: infoContent

        anchors.centerIn: parent
        spacing: root.moduleSpacing

        Icons.Icon {
            id: notificationIcon
            iconName: NotificationService.iconName
            size: Dimensions.iconSizeMd
            iconColor: NetworkService.iconColor
            colorize: true
            anchors.verticalCenter: parent.verticalCenter

            HoverHandler {
                id: networkHover
            }
            Feedback.ToolTip {
                text: "TODO..."
                visible: networkHover.hovered
                targetItem: notificationIcon
                xOff: notificationIcon.implicitWidth / 2 - implicitWidth / 2
                yOff: Settings.taskBarPosition == "top" ? Dimensions.spacingMd : -Dimensions.spacingMd
            }
        }

        Row {
            spacing: Dimensions.spacingXs
            Text {
                id: timeText

                text: Time.time
                color: Theme.foreground

                font.family: Theme.fontFamilyMono
                font.pixelSize: Theme.fontSizeLg
                font.weight: Theme.fontWeightRegular
            }

            Text {
                anchors.baseline: timeText.baseline

                text: Time.period
                color: Theme.foregroundSecondary

                font.family: Theme.fontFamilyMono
                font.pixelSize: Theme.fontSizeMd
                font.weight: Theme.fontWeightRegular
            }
        }
    }

    onClicked: {}
}
