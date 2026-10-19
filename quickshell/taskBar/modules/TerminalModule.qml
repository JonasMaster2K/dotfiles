pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "../../components/neomorphism/buttons" as Buttons
import "../../config"
import "../../style"

Buttons.Button {
    id: root

    property string displayName: "Terminal"
    property string displayMode: "text"
    property string moduleIcon: "applications-system-symbolic"
    property var taskBarWindow: null

    buttonHeight: Dimensions.taskBarWidgetSizeMd
    iconSize: Dimensions.taskBarIconSizeMd
    iconName: displayMode === "icon" || displayMode === "iconText" || displayMode === "iconSet" ? moduleIcon : ""
    text: displayMode === "text" || displayMode === "iconText" ? displayName : ""
    elevation: Settings.taskBarWidgetStyle

    onClicked: {
        Quickshell.execDetached(Settings.apps.terminal);
    }
}
