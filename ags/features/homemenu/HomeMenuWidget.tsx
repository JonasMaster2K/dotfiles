/**
 * @file HomeMenuWidget.ts
 * @description Ein AGS (Aylur's GTK Shell) Widget für GTK4, das den Hauptmenü-Button (App-Launcher / Startmenü) der Statusleiste bereitstellt.
 * 
 * Kernfeatures:
 * - **Popover-Verknüpfung:** Erstellt einen interaktiven Button, der bei Klick ein GTK4-Popover (`HomeMenuPopup`) anzeigt.
 * - **Zentrales Popover-Registry:** Registriert das erzeugte Popover in einer exportierten, globalen `Map` (`popovers`), um es bei Bedarf programmgesteuert von außerhalb (z. B. durch globale Keybinds oder andere Widgets) schließen oder öffnen zu können.
 * 
 * @dependencies ags/gtk4, HomeMenuPopup, TaskBarIconButton
 */

import { Gtk } from "ags/gtk4"
import TaskBarIconButton from "../../components/BarButton"
import HomeMenuPopup from "./HomeMenuPopup"

/**
 * Eine globale Map, die als Registry für systemweite Popover-Instanzen dient.
 * Ermöglicht es anderen Komponenten, das Home-Menü geräteübergreifend zu steuern.
 * Wird genutzt um es hyprland zu ermöglichen das Menü mit einem Keybind zu öffnen (in app.tsx)
 */
export const popovers = new Map<string, Gtk.Popover>()

/**
 * Erstellt das Home-Menü-Widget (Button inkl. verknüpftem Popover-Menü).
 * 
 * @returns {Gtk.Widget} Ein konfigurierter GTK-Button, der das Startmenü umschaltet.
 */
export default function HomeMenuWidget(): Gtk.Widget {
    // Erstellt den Button mit dem Standard-Symbol für App-Grids / Startmenüs
    const btn = new TaskBarIconButton({ iconName: "view-app-grid-symbolic" })

    // Instanziiert das Popover-Menü und verankert es visuell am Button
    const popover = HomeMenuPopup()
    popover.set_parent(btn)
    
    // Registriert das Popover für externen Zugriff
    popovers.set("home-menu", popover)
    
    // Öffnet das Menü bei einem Klick-Ereignis
    btn.connect("clicked", () => popover.popup())

    return btn
}