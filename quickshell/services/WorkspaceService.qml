pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    // ===========================================================================================
    // Properties

    readonly property var workspaces: {
        const normal = []
        const special = []

        for (const workspace of Hyprland.workspaces.values) {
            if (workspace.id < 0)
                special.push(workspace)
            else
                normal.push(workspace)
        }

        normal.sort((a, b) => a.id - b.id)
        special.sort((a, b) => a.id - b.id)

        const result = []

        for (const workspace of normal) {
            result.push({
                workspace: workspace,
                name: workspace.name,
                special: false
            })
        }

        for (let i = 0; i < special.length; ++i) {
            result.push({
                workspace: special[i],
                name: "S" + (i + 1),
                special: true
            })
        }

        return result
    }

    readonly property var activeWorkspace: Hyprland.focusedWorkspace

    readonly property var activeApp: Hyprland.activeToplevel

    // ===========================================================================================
    // Workspace API

    function find(id) {
        return Hyprland.workspaces.values.find(
            workspace => workspace.id === id
        ) ?? null
    }

    function apps(workspace) {
        if (!workspace)
            return []

        return workspace.toplevels.values
    }

    function appCount(workspace) {
        return apps(workspace).length
    }

    function isActive(workspace) {
        return workspace === activeWorkspace
    }

    function activate(workspace) {
        if (!workspace)
            return

        workspace.activate()
    }

    // ===========================================================================================
    // App API

    function appId(toplevel) {
        if (!toplevel)
            return ""

        return toplevel.wayland?.appId ?? ""
    }

    function appTitle(toplevel) {
        return toplevel?.title ?? ""
    }

    function appAddress(toplevel) {
        return toplevel?.address ?? ""
    }

    function appActive(toplevel) {
        return toplevel?.activated ?? false
    }
}