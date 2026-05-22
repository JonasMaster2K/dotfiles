/**
 * @file NotificationWidget.ts
 * @description Ein AGS (Aylur's GTK Shell) Widget für GTK4, das als Benachrichtigungs-Indikator in der Statusleiste dient.
 * 
 * Kernfeatures:
 * - **Dynamische Status-Icons:** Wechselt das Symbol basierend auf dem Systemstatus ("Bitte nicht stören", "Neue Benachrichtigungen" oder "Keine Benachrichtigungen").
 * - **Kontextuelle Tooltips:** Zeigt dem Nutzer via Mouse-Over die exakte Anzahl der ungelesenen Benachrichtigungen oder den DND-Status an.
 * - **Visuelle Warnstufen (CSS):** Färbt das Icon über CSS-Klassen je nach Dringlichkeit ein:
 *   - Keine Benachrichtigungen: Standard-Stil.
 *   - \> 0 Benachrichtigungen: Warn-Status (`icon--warn`).
 *   - \> 10 Benachrichtigungen: Kritischer Fehler-Status (`icon--err`).
 * - **Popover-Integration:** Öffnet bei Klick ein angehängtes `NotificationPopup` zur detaillierten Ansicht.
 * 
 * @dependencies AstalNotifd, ags/gtk4, TaskBarIconButton, NotificationPopup
 */

import { Gtk } from "ags/gtk4"
import AstalNotifd from "gi://AstalNotifd?version=0.1"
import TaskBarIconButton from "../../components/BarButton"
import NotificationPopup from "./NotificationPopup"

const notify = AstalNotifd.get_default()

/**
 * Erstellt das Benachrichtigungs-Widget für die Statusleiste.
 * Überwacht den AstalNotifd-Daemon auf neue, gelöschte oder blockierte Benachrichtigungen.
 * 
 * @returns {Gtk.Widget} Ein konfigurierter Button mit dynamischen Indikatoren.
 */
export default function NotificationWidget(): Gtk.Widget {
    const btn = new TaskBarIconButton({ iconName: "notifications-enabled-symbolic" })

    // POPOVER-SETUP ===========================================
    const popover = NotificationPopup()
    popover.set_parent(btn)

    // DYNAMISCHE UPDATE-LOGIK ==================================
    const update = () => {
        const count = notify.notifications.length
        let tooltip: string
        let iconName: string
        let cssClasses: string[] = []

        // 1. Tooltip & Icon-Name ermitteln
        if (notify.dontDisturb) {
            tooltip = "Do not disturb"
            iconName = "notifications-disabled-symbolic"
        } else {
            iconName = count > 0 ? "notification-new-symbolic" : "notifications-enabled-symbolic"
            
            if (count === 0) {
                tooltip = "No notifications"
            } else if (count === 1) {
                tooltip = "1 notification"
            } else {
                tooltip = `${count} notifications`
            }
        }

        // 2. Visuelle Dringlichkeitsstufe festlegen (GTK4 css_classes)
        if (!notify.dontDisturb && count > 0) {
            cssClasses = count > 10 ? ["icon--err"] : ["icon--warn"]
        }

        // 3. GTK-Widget-Eigenschaften anwenden
        btn.icon.icon_name = iconName
        btn.icon.css_classes = cssClasses
        btn.tooltip_text = tooltip
    }

    // EVENT-LISTENERS =========================================
    notify.connect("notified",             update)
    notify.connect("resolved",             update)
    notify.connect("notify::dont-disturb", update)
    
    // Initialer Aufruf beim Starten der Bar
    update()

    // Interaktion: Popover umschalten
    btn.connect("clicked", () => popover.popup())

    return btn
}