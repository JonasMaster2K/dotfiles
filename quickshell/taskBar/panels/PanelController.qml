pragma Singleton

import QtQuick

QtObject {
    id: root

    property string activePanel: ""
    property var activeTaskBar: null

    function toggle(panelName, taskBar) {
        if (activePanel === panelName && activeTaskBar === taskBar) {
            close();
            return;
        }

        activePanel = panelName;
        activeTaskBar = taskBar;
    }

    function close() {
        activePanel = "";
        activeTaskBar = null;
    }

    function isOpen(panelName, taskBar) {
        return activePanel === panelName && activeTaskBar === taskBar;
    }
}
