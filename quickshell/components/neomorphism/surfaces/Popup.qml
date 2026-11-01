import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

//TODO: Reveal-Animation, zweiter Modus endweder als island oder an der taskbar dran mit rundungen dann

PanelWindow {
    id: popup

    enum Alignment {
        Start,
        Center,
        End
    }

    enum Mode {
        Floating,
        Attached,
        Island
    }

    default property alias content: contentContainer.data

    property int alignment: Surfaces.Popup.Alignment.Center
    property int mode: Surfaces.Popup.Mode.Floating //TODO

    property bool autoSizeWidth: false
    property bool autoSizeHeight: false

    property bool closeOnFocusLost: true
    property bool visibleRequested: false

    property real margin: Dimensions.spacingMd
    property real padding: Dimensions.spacingXs

    property real minimumWidth: 0 + 2 * Dimensions.spacingMd
    property real minimumHeight: 0 + 2 * Dimensions.spacingMd
    property real maximumWidth: Screen.width - (["right", "left"].includes(Settings.taskBarPosition) ? (Dimensions.taskBarHeight + padding * 2) : (padding * 2 + margin * 2))
    property real maximumHeight: Screen.height - (["top", "bottom"].includes(Settings.taskBarPosition) ? (Dimensions.taskBarHeight + padding * 2) : (padding * 2 + margin * 2))

    property real fixedWidth: 600
    property real fixedHeight: 1000

    readonly property real calculatedWidth: Math.max(minimumWidth, Math.min((autoSizeWidth ? contentContainer.childrenRect.width : fixedWidth), maximumWidth))
    readonly property real calculatedHeight: Math.max(minimumHeight, Math.min((autoSizeHeight ? contentContainer.childrenRect.height : fixedHeight), maximumHeight))

    implicitHeight: popupBackground.implicitHeight + padding * 2
    implicitWidth: popupBackground.implicitWidth + padding * 2

    aboveWindows: true
    focusable: true
    exclusionMode: ExclusionMode.Normal
    visible: false

    anchors.top: (Settings.taskBarPosition == "top" || (alignment == Surfaces.Popup.Alignment.Start && Settings.taskBarPosition != "bottom"))
    anchors.bottom: (Settings.taskBarPosition == "bottom" || (alignment == Surfaces.Popup.Alignment.End && Settings.taskBarPosition != "top"))
    anchors.left: (Settings.taskBarPosition == "left" || (alignment == Surfaces.Popup.Alignment.Start && Settings.taskBarPosition != "right"))
    anchors.right: (Settings.taskBarPosition == "right" || (alignment == Surfaces.Popup.Alignment.End && Settings.taskBarPosition != "left"))

    color: Colors.transparent

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

            Behavior on animationProgress {
                NumberAnimation {
                    duration: Animations.animationNormal
                    easing.type: Animations.easingSmooth
                }
            }

            Surfaces.Card {
                id: popupBackground

                anchors.centerIn: mask

                implicitHeight: popup.calculatedHeight + popup.margin * 2
                implicitWidth: popup.calculatedWidth + popup.margin * 2

                cornerRadius: Dimensions.radiusLg

                elevation: "flat"
            }

            Item {
                id: contentContainer

                anchors.centerIn: popupBackground

                implicitHeight: popup.calculatedHeight
                implicitWidth: popup.calculatedWidth

                clip: true
            }
        }
    }

    HyprlandFocusGrab {
        active: popup.closeOnFocusLost && popup.visible && popup.visibleRequested

        windows: [popup]

        onCleared: popup.hide()
    }

    function show() {
        closeDelayTimer.stop();

        visible = true;
        visibleRequested = true;

        animationContainer.animationProgress = 1.0;
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
