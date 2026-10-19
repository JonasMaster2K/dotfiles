import QtQuick

// Central coordinator for FloatingWindow items.
// Windows remain visual Items in their own windowZone.
QtObject {
    id: controller

    property var registeredWindows: ({})
    property int topZ: 100

    signal windowRegistered(string name)
    signal windowUnregistered(string name)

    function registerWindow(name, windowItem) {
        if (!name || !windowItem) {
            console.warn("WindowController: name and windowItem are required");
            return;
        }
        const next = Object.assign({}, registeredWindows);
        next[name] = windowItem;
        registeredWindows = next;
        windowRegistered(name);
    }

    function unregisterWindow(name) {
        const next = Object.assign({}, registeredWindows);
        delete next[name];
        registeredWindows = next;
        windowUnregistered(name);
    }

    function windowFor(name) {
        return registeredWindows[name] || null;
    }

    function bringToFront(name) {
        const windowItem = windowFor(name);
        if (!windowItem) return;
        topZ += 1;
        windowItem.z = topZ;
    }

    function showWindow(name) {
        const windowItem = windowFor(name);
        if (!windowItem) return;
        windowItem.show();
        bringToFront(name);
    }

    function hideWindow(name) {
        const windowItem = windowFor(name);
        if (windowItem) windowItem.close();
    }

    function toggleWindow(name) {
        const windowItem = windowFor(name);
        if (!windowItem) return;
        if (windowItem.visible)
            hideWindow(name);
        else
            showWindow(name);
    }

    function minimizeWindow(name) {
        const windowItem = windowFor(name);
        if (windowItem) windowItem.collapsed = true;
    }

    function restoreWindow(name) {
        const windowItem = windowFor(name);
        if (!windowItem) return;
        windowItem.collapsed = false;
        showWindow(name);
    }
}
