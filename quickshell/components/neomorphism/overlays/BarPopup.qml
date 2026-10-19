import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

PopupWindow {
    id: popup

    enum Alignment {
        Left,
        Center,
        Right,
        Anchor
    }

    required property Item targetItem
    property int alignment: BarPopup.Alignment.Anchor

    property bool autoSizeWidth: true
    property bool autoSizeHeight: true
    property real fixedWidth: 340 * Settings.scale
    property real fixedHeight: 360 * Settings.scale
    property real minimumWidth: 0
    property real minimumHeight: 0
    property real maximumWidth: Infinity
    property real maximumHeight: Infinity

    // Space between the popup surface and the PopupWindow edges.
    // Needed to keep raised shadows visible.
    property real margin: Dimensions.spacingLg
    property real padding: Dimensions.spacingLg
    property real anchorGap: Dimensions.spacingSm
    property real barHeight: targetWindow ? targetWindow.height : 0

    property string elevation: "raised"
    property color surfaceColor: Colors.surface
    property real cornerRadius: 16 * Settings.scale
    property real borderSize: 1 * Settings.scale
    property bool closeOnFocusLost: true
    property bool visibleRequested: false

    default property alias content: contentContainer.data

    readonly property var targetWindow: targetItem ? targetItem.QsWindow.window : null
    readonly property var targetScreen: targetWindow ? targetWindow.screen : null
    readonly property real availableWidth: targetScreen
        ? Math.max(0, targetScreen.width - 2 * anchorGap)
        : Infinity
    readonly property real availableHeight: targetScreen
        ? Math.max(0, targetScreen.height - barHeight - anchorGap)
        : Infinity

    readonly property real desiredSurfaceWidth: autoSizeWidth
        ? contentContainer.implicitWidth + 2 * padding
        : fixedWidth
    readonly property real desiredSurfaceHeight: autoSizeHeight
        ? contentContainer.implicitHeight + 2 * padding
        : fixedHeight

    readonly property real surfaceWidth: Math.max(0, implicitWidth - 2 * margin)
    readonly property real surfaceHeight: Math.max(0, implicitHeight - 2 * margin)

    implicitWidth: Math.min(
        Math.max(minimumWidth + 2 * margin, desiredSurfaceWidth + 2 * margin),
        Math.min(maximumWidth, availableWidth)
    )
    implicitHeight: Math.min(
        Math.max(minimumHeight + 2 * margin, desiredSurfaceHeight + 2 * margin),
        Math.min(maximumHeight, availableHeight)
    )

    anchor.window: targetWindow
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right

    color: "transparent"
    visible: false

    function alignmentOffset(rect) {
        if (!anchor.window)
            return 0;
        const windowWidth = anchor.window.width;
        switch (alignment) {
        case BarPopup.Alignment.Left:
            return -rect.x;
        case BarPopup.Alignment.Center:
            return windowWidth / 2 - popup.width / 2 - rect.x;
        case BarPopup.Alignment.Right:
            return windowWidth - popup.width - rect.x;
        case BarPopup.Alignment.Anchor:
            return rect.width / 2 - popup.width / 2;
        default:
            return 0;
        }
    }

    function show() {
        closeDelayTimer.stop();
        visible = true;
        visibleRequested = true;
    }

    function hide() {
        if (!visibleRequested)
            return;
        visibleRequested = false;
        closeDelayTimer.restart();
    }

    function toggle() {
        if (visibleRequested)
            hide();
        else
            show();
    }

    anchor.onAnchoring: {
        if (!popup.targetItem || !popup.targetWindow)
            return;
        const rect = popup.targetWindow.itemRect(popup.targetItem);
        popup.anchor.rect.x = rect.x + popup.alignmentOffset(rect);
        popup.anchor.rect.y = popup.anchorGap;
        popup.anchor.rect.width = rect.width;
        popup.anchor.rect.height = popup.barHeight;
    }

    HyprlandFocusGrab {
        active: popup.closeOnFocusLost && popup.visible && popup.visibleRequested
        windows: [popup]
        onCleared: popup.hide()
    }

    Item {
        id: animationContainer
        anchors.fill: parent
        clip: true

        Surfaces.Surface {
            id: popupSurface
            width: popup.surfaceWidth
            height: popup.surfaceHeight
            elevation: popup.elevation
            borderSize: popup.borderSize
            cornerRadius: popup.cornerRadius
            surfaceColor: popup.surfaceColor
            hoverColor: Colors.surfaceHover
            pressedColor: Colors.surfacePressed

            // Animate the entire surface, including its raised shadows.
            x: {
                if (popup.visibleRequested)
                    return popup.margin;
                if (popup.alignment === BarPopup.Alignment.Left)
                    return -width - popup.margin;
                if (popup.alignment === BarPopup.Alignment.Right)
                    return popup.width + popup.margin;
                return popup.margin;
            }
            y: {
                if (popup.visibleRequested)
                    return popup.margin;
                if (popup.alignment === BarPopup.Alignment.Center
                        || popup.alignment === BarPopup.Alignment.Anchor)
                    return -height - popup.margin;
                return popup.margin;
            }

            Behavior on x {
                NumberAnimation {
                    duration: Animations.animationFast
                    easing.type: Animations.easingSmooth
                }
            }
            Behavior on y {
                NumberAnimation {
                    duration: Animations.animationFast
                    easing.type: Animations.easingSmooth
                }
            }

            Item {
                id: contentViewport
                anchors.fill: parent
                anchors.margins: popup.padding
                clip: true

                ColumnLayout {
                    id: contentContainer
                    anchors.fill: parent
                }
            }
        }
    }

    Timer {
        id: closeDelayTimer
        interval: Animations.animationFast
        repeat: false
        onTriggered: {
            if (!popup.visibleRequested)
                popup.visible = false;
        }
    }
}
