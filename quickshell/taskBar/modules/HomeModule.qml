pragma ComponentBehavior: Bound

import QtQuick

import "../../components/neomorphism/buttons" as Buttons
import "../../config"
import "../../style"

Buttons.Button {
    id: root

    property string displayName: "Home"
    property string displayMode: "icon"
    property string moduleIcon: "home-symbolic"
    property var taskBarWindow: null

    buttonHeight: Dimensions.taskBarWidgetSizeMd
    iconSize: Dimensions.taskBarIconSizeMd
    iconName: displayMode === "icon" || displayMode === "iconText" || displayMode === "iconSet" ? moduleIcon : ""
    text: displayMode === "text" || displayMode === "iconText" ? displayName : ""
    elevation: Settings.taskBarWidgetStyle

    onClicked: {}
}
