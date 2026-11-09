import QtQuick

import "../config"
import "../components/neomorphism/surfaces" as Surfaces

Surfaces.Popup {
    id: osd

    // =========================================================================
    // Public Settings
    // =========================================================================
    property string position: "bottom"
    property QtObject connectionTarget: null
    property bool useSecondarySignal: false

    // =========================================================================
    // Private Properties
    // =========================================================================
    readonly property bool vertical: position === "left" || position === "right"
    readonly property int hideDelay: Settings.osdTimeout

    autoSizeWidth: true
    autoSizeHeight: true
    closeOnFocusLost: false
    mode: Surfaces.Popup.Mode.OSD
    edge: {
        switch (position) {
        case "left":
            return Surfaces.Popup.Edge.Left;
        case "top":
            return Surfaces.Popup.Edge.Top;
        case "bottom":
            return Surfaces.Popup.Edge.Bottom;
        case "right":
        default:
            return Surfaces.Popup.Edge.Right;
        }
    }

    Connections {
        target: osd.connectionTarget
        ignoreUnknownSignals: true

        function onOsdSignalChanged() {
            if (!osd.useSecondarySignal)
                osd.handleSignal();
        }

        function onOsdSignalSecondaryChanged() {
            if (osd.useSecondarySignal)
                osd.handleSignal();
        }
    }

    function handleSignal() {
        if (!visibleRequested)
            show();

        hideTimer.restart();
    }

    Timer {
        id: hideTimer

        interval: osd.hideDelay
        repeat: false

        onTriggered: osd.hide()
    }
}
