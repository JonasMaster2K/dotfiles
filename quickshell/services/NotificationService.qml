pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

import "../style"

Singleton {
    id: root

    property var targetWindow: null

    readonly property string iconName: !enabled ? "notifications-disabled-symbolic" : activeNotifications.count > 0 ? "notification-new-symbolic" : "notifications-enabled-symbolic"
    readonly property color iconColor: !enabled ? Theme.warning : Theme.foreground

    property bool enabled: true
    property ListModel activeNotifications: ListModel {}
    property ListModel popupNotifications: ListModel {}

    NotificationServer {
        id: server

        actionsSupported: true
        actionIconsSupported :  true
        bodyImagesSupported :  true
        bodyMarkupSupported :  true
        bodyHyperlinksSupported: true
        imageSupported: true

        onNotification: function(n) {
            if (!root.enabled)
                return

            n.tracked = true

            root.activeNotifications.append({
                "notifObj": n
            })

            root.popupNotifications.append({
                "notifObj": n
            })

            n.closed.connect(function() {
                for (let i = 0; i < root.activeNotifications.count; i++) {
                    if (root.activeNotifications.get(i).notifObj === n) {
                        root.activeNotifications.remove(i)
                        break
                    }
                }

                for (let i = 0; i < root.popupNotifications.count; i++) {
                    if (root.popupNotifications.get(i).notifObj === n) {
                        root.popupNotifications.remove(i)
                        break
                    }
                }
            })
        }
    }
}