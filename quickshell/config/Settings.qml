pragma Singleton

import QtQuick
import Quickshell

QtObject {
    id: settings

    // =========================================================================
    // APPEARANCE
    // =========================================================================

    property bool darkMode: true
    property bool useMatugen: false

    // =========================================================================
    // SCALING
    // =========================================================================

    property real uiScale: 1.0
    property real fontScale: 1.0

    readonly property real scale: Math.max(0.75, Math.min(uiScale, 10.0))

    // =========================================================================
    // ACCESSIBILITY
    // =========================================================================

    property bool reducedMotion: false

    // =========================================================================
    // TASKBAR STYLE
    // =========================================================================

    // island | band
    property string taskBarStyle: "band"
    // top | bottom ?? TODO: left & right ??
    property string taskBarPosition: "top"
    // raised | flat
    property string taskBarWidgetStyle: "raised"
    // sm | md | lg
    property string taskBarSize: "sm"

    // =========================================================================
    // MODULES
    // =========================================================================

    readonly property var availableModules: [
        // ================================================================
        // GENERAL / APPS
        // ================================================================
        {
            id: "home",
            name: "Home",
            category: "general",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "settings",
            name: "Settings",
            category: "general",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "tray",
            name: "Running Apps",
            category: "general",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "browser",
            name: "Browser",
            category: "apps",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "terminal",
            name: "Terminal",
            category: "apps",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "files",
            name: "Files",
            category: "apps",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },

        // ================================================================
        // DESKTOP / NAVIGATION
        // ================================================================
        {
            id: "workspaces",
            name: "Workspaces",
            category: "desktop",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "windowTitle",
            name: "Window Title",
            category: "desktop",
            defaultDisplay: "text",
            displays: ["text", "iconText"]
        },
        {
            id: "windowSwitcher",
            name: "Window Switcher",
            category: "desktop",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "showDesktop",
            name: "Show Desktop",
            category: "desktop",
            defaultDisplay: "icon",
            displays: ["icon"]
        },

        // ================================================================
        // SYSTEM / HARDWARE
        // ================================================================
        {
            id: "performance",
            name: "System Monitor",
            category: "system",
            defaultDisplay: "icon",
            displays: ["icon", "text", "iconText"]
        },
        {
            id: "network",
            name: "Network",
            category: "system",
            defaultDisplay: "icon",
            displays: ["icon", "text", "iconText"]
        },
        {
            id: "bluetooth",
            name: "Bluetooth",
            category: "system",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "audio",
            name: "Audio",
            category: "system",
            defaultDisplay: "icon",
            displays: ["icon", "text", "iconText"]
        },
        {
            id: "battery",
            name: "Battery",
            category: "system",
            defaultDisplay: "icon",
            displays: ["icon", "text", "iconText"]
        },
        {
            id: "brightness",
            name: "Brightness",
            category: "system",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "keyboardLayout",
            name: "Keyboard Layout",
            category: "system",
            defaultDisplay: "text",
            displays: ["icon", "text"]
        },
        {
            id: "microphone",
            name: "Microphone",
            category: "system",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },

        // ================================================================
        // CONTROLS
        // ================================================================
        {
            id: "tools",
            name: "Tools",
            category: "controls",
            defaultDisplay: "iconSet",
            displays: ["iconSet", "text"]
        },
        {
            id: "quickcontrols",
            name: "Quick Controls",
            category: "controls",
            defaultDisplay: "iconSet",
            displays: ["icon", "iconSet", "text"]
        },
        {
            id: "darkmode",
            name: "Dark Mode",
            category: "controls",
            defaultDisplay: "icon",
            displays: ["icon"]
        },
        {
            id: "airplanemode",
            name: "Airplane Mode",
            category: "controls",
            defaultDisplay: "icon",
            displays: ["icon"]
        },
        {
            id: "concentration",
            name: "Focus Mode",
            category: "controls",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "nightLight",
            name: "Night Light",
            category: "controls",
            defaultDisplay: "icon",
            displays: ["icon"]
        },
        {
            id: "power",
            name: "Power",
            category: "controls",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },

        // ================================================================
        // UTILITIES
        // ================================================================
        {
            id: "media",
            name: "Media Player",
            category: "utilities",
            defaultDisplay: "icon",
            displays: ["icon", "text", "iconText"]
        },
        {
            id: "pomodoro",
            name: "Pomodoro",
            category: "utilities",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "colorpicker",
            name: "Color Picker",
            category: "utilities",
            defaultDisplay: "icon",
            displays: ["icon"]
        },
        {
            id: "screenshot",
            name: "Screenshot",
            category: "utilities",
            defaultDisplay: "icon",
            displays: ["icon"]
        },
        {
            id: "screenRecording",
            name: "Screen Recording",
            category: "utilities",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "search",
            name: "Search / Spotlight",
            category: "utilities",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "clipboard",
            name: "Clipboard History",
            category: "utilities",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "shortcuts",
            name: "Shortcuts",
            category: "utilities",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },

        // ================================================================
        // INFORMATION / STATUS
        // ================================================================
        {
            id: "notifications",
            name: "Notifications",
            category: "information",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        },
        {
            id: "clock",
            name: "Clock",
            category: "information",
            defaultDisplay: "text",
            displays: ["text"]
        },
        {
            id: "daylyHub",
            name: "Dayly Hub",
            category: "information",
            defaultDisplay: "iconText",
            displays: ["icon", "text", "iconText"]
        },
        {
            id: "weather",
            name: "Weather",
            category: "information",
            defaultDisplay: "iconText",
            displays: ["icon", "text", "iconText"]
        },
        {
            id: "calendar",
            name: "Calendar",
            category: "information",
            defaultDisplay: "text",
            displays: ["icon", "text", "iconText"]
        },
        {
            id: "privacy",
            name: "Privacy Indicators",
            category: "information",
            defaultDisplay: "icon",
            displays: ["icon", "text"]
        }
    ]

    property var taskBarLeftModules: [
        {
            id: "home",
            name: "Home",
            display: "icon"
        },
        {
            id: "settings",
            name: "Settings",
            display: "text"
        },
        {
            id: "browser",
            name: "Browser",
            display: "text"
        },
        {
            id: "files",
            name: "Files",
            display: "text"
        },
        {
            id: "terminal",
            name: "Terminal",
            display: "text"
        }
    ]

    property var taskBarCenterModules: [
        {
            id: "workspaces",
            name: "Workspaces",
            display: "icon"
        }
    ]

    property var taskBarRightModules: [
        {
            id: "tools",
            name: "Tools",
            display: "icon"
        },
        {
            id: "quickcontrols",
            name: "Quickcontrols",
            display: "iconSet"
        },
        {
            id: "daylyHub",
            name: "Dayly Hub",
            display: "iconText"
        }
    ]

    // =========================================================================
    // APPLICATIONS
    // =========================================================================

    property QtObject apps: QtObject {
        property var terminal: ["kitty"]
        property var browser: ["zen-browser"]
        property var fileManager: ["thunar"]
        property var colorPicker: ["hyprpicker", "-a", "-n"]
        property var screenshot: ["sh", "-c", `
            file="/tmp/quickshell-screenshot.png"

            grim -g "$(slurp)" "$file" || exit 1

            wl-copy --type image/png < "$file"

            action=$(notify-send \
                --wait \
                --icon="$file" \
                --action="save=Save to file" \
                --action="delete=Dismiss" \
                "Screenshot" \
                "Copied to clipboard")

            if [ "$action" = "save" ]; then
                mkdir -p "$HOME/Pictures/Screenshots"

                target="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"

                cp "$file" "$target"

                notify-send \
                    "Screenshot saved" \
                    "$target"
            fi

            rm -f "$file"
            `]
    }

    // =========================================================================
    // WIDGETS
    // =========================================================================

    property QtObject widgets: QtObject {
        property bool clockEnabled: true
        property bool trayEnabled: true
        property bool colorPickerEnabled: true
    }
}
