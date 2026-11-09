import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

PanelWindow {
    id: popup

    // -------------------------------------------------------------------------
    // Enums
    // -------------------------------------------------------------------------

    enum Alignment {
        Start,
        Center,
        End
    }

    enum Mode {
        Taskbar,
        OSD
    }

    enum Edge {
        Left,
        Right,
        Top,
        Bottom
    }

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    default property alias content: contentContainer.data

    property int mode: Surfaces.Popup.Mode.Taskbar
    property int alignment: Surfaces.Popup.Alignment.Center
    property int edge: Surfaces.Popup.Edge.Bottom

    property real freeX: (Screen.width - width) / 2
    property real freeY: (Screen.height - height) / 2

    property bool autoSizeWidth: true
    property bool autoSizeHeight: true

    property bool closeOnFocusLost: true
    property bool visibleRequested: false

    property real margin: Dimensions.spacingSm
    property real padding: Dimensions.spacingXs

    property real minimumWidth: 0 + 2 * Dimensions.spacingMd
    property real minimumHeight: 0 + 2 * Dimensions.spacingMd

    property real maximumWidth: Screen.width - (["right", "left"].includes(Settings.taskBarPosition) ? (Dimensions.taskBarHeight + padding * 2) : (padding * 2 + margin * 2))
    property real maximumHeight: Screen.height - (["top", "bottom"].includes(Settings.taskBarPosition) ? (Dimensions.taskBarHeight + padding * 2) : (padding * 2 + margin * 2))

    property real fixedWidth: Dimensions.popupMinWidth
    property real fixedHeight: Dimensions.popupMinWidth //TODO: minHeight

    // -------------------------------------------------------------------------
    // Calculations
    // -------------------------------------------------------------------------

    readonly property real contentWidth: contentContainer.childrenRect.width
    readonly property real contentHeight: contentContainer.childrenRect.height

    readonly property real calculatedWidth: Math.max(minimumWidth, Math.min(autoSizeWidth ? contentWidth : fixedWidth, maximumWidth))
    readonly property real calculatedHeight: Math.max(minimumHeight, Math.min(autoSizeHeight ? contentHeight : fixedHeight, maximumHeight))

    // -------------------------------------------------------------------------
    // OSD positioning
    // -------------------------------------------------------------------------

    readonly property bool osdSharesTaskbarEdge: {
        switch (edge) {
        case Surfaces.Popup.Edge.Left:
            return Settings.taskBarPosition === "left";
        case Surfaces.Popup.Edge.Right:
            return Settings.taskBarPosition === "right";
        case Surfaces.Popup.Edge.Top:
            return Settings.taskBarPosition === "top";
        case Surfaces.Popup.Edge.Bottom:
            return Settings.taskBarPosition === "bottom";
        default:
            return false;
        }
    }

    readonly property real osdEdgeMargin: Dimensions.spacingXl + (osdSharesTaskbarEdge ? Dimensions.taskBarHeight : 0)

    // -------------------------------------------------------------------------
    // Window configuration
    // -------------------------------------------------------------------------

    implicitHeight: popupBackground.implicitHeight + padding * 2
    implicitWidth: popupBackground.implicitWidth + padding * 2

    aboveWindows: true
    focusable: true
    exclusionMode: mode === Surfaces.Popup.Mode.OSD ? ExclusionMode.Ignore : ExclusionMode.Normal
    visible: false

    color: Colors.transparent

    // -------------------------------------------------------------------------
    // PanelWindow anchors
    // -------------------------------------------------------------------------

    // Taskbar: Original anchoring logic, unchanged.
    // OSD: Anchoring is controlled exclusively by edge.
    // Free / Anchor: No automatic anchoring.
    anchors.top: mode == Surfaces.Popup.Mode.Taskbar ? (Settings.taskBarPosition == "top" || (alignment == Surfaces.Popup.Alignment.Start && Settings.taskBarPosition != "bottom")) : mode == Surfaces.Popup.Mode.OSD ? edge == Surfaces.Popup.Edge.Top : false
    anchors.bottom: mode == Surfaces.Popup.Mode.Taskbar ? (Settings.taskBarPosition == "bottom" || (alignment == Surfaces.Popup.Alignment.End && Settings.taskBarPosition != "top")) : mode == Surfaces.Popup.Mode.OSD ? edge == Surfaces.Popup.Edge.Bottom : false
    anchors.left: mode == Surfaces.Popup.Mode.Taskbar ? (Settings.taskBarPosition == "left" || (alignment == Surfaces.Popup.Alignment.Start && Settings.taskBarPosition != "right")) : mode == Surfaces.Popup.Mode.OSD ? edge == Surfaces.Popup.Edge.Left : false
    anchors.right: mode == Surfaces.Popup.Mode.Taskbar ? (Settings.taskBarPosition == "right" || (alignment == Surfaces.Popup.Alignment.End && Settings.taskBarPosition != "left")) : mode == Surfaces.Popup.Mode.OSD ? edge == Surfaces.Popup.Edge.Right : false

    // OSD: Only the selected edge receives a margin.
    margins {
        left: mode == Surfaces.Popup.Mode.OSD && edge == Surfaces.Popup.Edge.Left ? osdEdgeMargin : 0
        right: mode == Surfaces.Popup.Mode.OSD && edge == Surfaces.Popup.Edge.Right ? osdEdgeMargin : 0
        top: mode == Surfaces.Popup.Mode.OSD && edge == Surfaces.Popup.Edge.Top ? osdEdgeMargin : 0
        bottom: mode == Surfaces.Popup.Mode.OSD && edge == Surfaces.Popup.Edge.Bottom ? osdEdgeMargin : 0
    }

    // -------------------------------------------------------------------------
    // Visual content
    // -------------------------------------------------------------------------

    Item {
        id: mask

        anchors.fill: parent
        anchors.centerIn: parent
        clip: true

        Item {
            id: animationContainer

            anchors.centerIn: parent

            implicitHeight: popupBackground.implicitHeight
            implicitWidth: popupBackground.implicitWidth

            property real animationProgress: 0.0
            property real animationOffset: 12

            scale: animationProgress
            opacity: animationProgress

            transformOrigin: {
                // OSD: Animate from the selected edge.
                if (popup.mode === Surfaces.Popup.Mode.OSD) {
                    switch (popup.edge) {
                    case Surfaces.Popup.Edge.Left:
                        return Item.Left;
                    case Surfaces.Popup.Edge.Right:
                        return Item.Right;
                    case Surfaces.Popup.Edge.Top:
                        return Item.Top;
                    case Surfaces.Popup.Edge.Bottom:
                        return Item.Bottom;
                    default:
                        return Item.Center;
                    }
                }

                // Taskbar: Original transform origin calculation.
                if (popup.mode === Surfaces.Popup.Mode.Taskbar) {
                    switch (Settings.taskBarPosition) {
                    case "top":
                        return popup.alignment == Surfaces.Popup.Alignment.Start ? Item.TopLeft : popup.alignment == Surfaces.Popup.Alignment.End ? Item.TopRight : Item.Top;
                    case "bottom":
                        return popup.alignment == Surfaces.Popup.Alignment.Start ? Item.BottomLeft : popup.alignment == Surfaces.Popup.Alignment.End ? Item.BottomRight : Item.Bottom;
                    case "left":
                        return popup.alignment == Surfaces.Popup.Alignment.Start ? Item.TopLeft : popup.alignment == Surfaces.Popup.Alignment.End ? Item.BottomLeft : Item.Left;
                    case "right":
                        return popup.alignment == Surfaces.Popup.Alignment.Start ? Item.TopRight : popup.alignment == Surfaces.Popup.Alignment.End ? Item.BottomRight : Item.Right;
                    default:
                        return Item.Center;
                    }
                }

                return Item.Center;
            }

            Behavior on animationProgress {
                NumberAnimation {
                    duration: Animations.animationNormal
                    easing.type: Animations.easingSmooth
                }
            }

            Surfaces.Card {
                id: popupBackground

                anchors.centerIn: parent

                implicitWidth: popup.calculatedWidth + popup.margin * 2
                implicitHeight: popup.calculatedHeight + popup.margin * 2

                cornerRadius: popup.mode === Surfaces.Popup.Mode.OSD ? Dimensions.radiusPill : Dimensions.radiusLg

                elevation: "flat"
            }

            Item {
                id: contentContainer

                anchors.centerIn: popupBackground

                implicitWidth: popup.calculatedWidth
                implicitHeight: popup.calculatedHeight

                clip: true
            }
        }
    }

    // -------------------------------------------------------------------------
    // Focus handling
    // -------------------------------------------------------------------------

    HyprlandFocusGrab {
        active: popup.closeOnFocusLost && popup.visible && popup.visibleRequested

        windows: [popup]

        onCleared: popup.hide()
    }

    // -------------------------------------------------------------------------
    // Popup controls
    // -------------------------------------------------------------------------

    function show() {
        closeDelayTimer.stop();

        visible = true;
        visibleRequested = true;

        animationContainer.animationProgress = 1.0;

        contentContainer.forceActiveFocus();
    }

    function hide() {
        if (!visibleRequested)
            return;

        visibleRequested = false;

        animationContainer.animationProgress = 0.0;

        closeDelayTimer.restart();
    }

    function toggle() {
        if (visibleRequested)
            hide();
        else
            show();
    }

    // -------------------------------------------------------------------------
    // Timers
    // -------------------------------------------------------------------------

    Timer {
        id: closeDelayTimer

        interval: Animations.animationNormal
        repeat: false

        onTriggered: {
            if (!popup.visibleRequested)
                popup.visible = false;
        }
    }
}
