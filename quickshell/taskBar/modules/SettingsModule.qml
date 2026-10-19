pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

import "../../components/neomorphism/buttons" as Buttons
import "../../config"
import "../../style"

Buttons.Button {
    id: root

    property string displayName: "Settings"
    property string displayMode: "text"
    property string moduleIcon: "applications-system-symbolic"
    property var taskBarWindow: null

    buttonHeight: Dimensions.taskBarWidgetSizeMd
    iconSize: Dimensions.taskBarIconSizeMd
    iconName: displayMode === "icon" || displayMode === "iconText" || displayMode === "iconSet" ? moduleIcon : ""
    text: displayMode === "text" || displayMode === "iconText" ? displayName : ""
    elevation: Settings.taskBarWidgetStyle

    onClicked: {}

    //TODO: Settings App in Rust schreiben
}
