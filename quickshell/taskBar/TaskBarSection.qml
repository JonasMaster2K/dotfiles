pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "./style"

RowLayout {
    id: root

    property var modules: []
    property var taskBarWindow: null

    spacing: Dimensions.spacingSm

    Repeater {
        model: root.modules

        delegate: TaskBarModuleLoader {
            required property var modelData

            moduleId: modelData.id
            displayMode: modelData.display || "icon"
            displayName: modelData.name

            taskBarWindow: root.taskBarWindow

            Layout.alignment: Qt.AlignVCenter
        }
    }
}
