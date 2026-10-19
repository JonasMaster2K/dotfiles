pragma ComponentBehavior: Bound

import QtQuick
import "./modules" as Modules

Loader {
    id: root

    required property string moduleId
    property string displayMode: "icon"
    property string displayName: ""
    property var taskBarWindow: null

    sourceComponent: {
        switch (moduleId) {
        case "home":
            return homeComponent;
        case "settings":
            return settingsComponent;
        case "browser":
            return browserComponent;
        case "files":
            return filesComponent;
        case "terminal":
            return terminalComponent;
        case "workspaces":
            return workspacesComponent;
        case "daylyHub":
            return dayHubComponent;
        case "quickcontrols":
            return quickControlsComponent;
        case "tools":
            return toolsComponent;
        default:
            return null;
        }
    }

    Component {
        id: homeComponent
        Modules.HomeModule {
            displayName: root.displayName
            displayMode: root.displayMode
        }
    }
    Component {
        id: settingsComponent
        Modules.SettingsModule {
            displayName: root.displayName
            displayMode: root.displayMode
        }
    }
    Component {
        id: browserComponent
        Modules.BrowserModule {
            displayName: root.displayName
            displayMode: root.displayMode
        }
    }
    Component {
        id: filesComponent
        Modules.FilesModule {
            displayName: root.displayName
            displayMode: root.displayMode
        }
    }
    Component {
        id: terminalComponent
        Modules.TerminalModule {
            displayName: root.displayName
            displayMode: root.displayMode
        }
    }
    Component {
        id: workspacesComponent
        Modules.WorkspacesModule {}
    }
    Component {
        id: dayHubComponent
        Modules.DayHubModule {}
    }
    Component {
        id: quickControlsComponent
        Modules.QuickControlsModule {}
    }
    Component {
        id: toolsComponent
        Modules.ToolsModule {
            displayName: root.displayName
            displayMode: root.displayMode
        }
    }
}
