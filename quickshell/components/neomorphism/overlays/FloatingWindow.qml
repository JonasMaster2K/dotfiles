import QtQuick
import QtQuick.Layouts

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

// A draggable, contained panel. This is a Qt Quick Item, not a native OS window.
// Set windowZone to the Item which defines the permitted drag area.
Item {
    id: control

    property Item windowZone: null
    property string title: "Window"
    property bool collapsed: false
    property bool closable: true
    property bool minimizable: true
    property bool draggable: true
    property string elevation: "raised"
    property color surfaceColor: Colors.surface
    property color titleColor: Colors.textPrimary
    property real borderSize: 1 * Settings.scale
    property real cornerRadius: 18 * Settings.scale
    property real headerHeight: 44 * Settings.scale
    property real expandedWidth: 370 * Settings.scale
    property real expandedHeight: 280 * Settings.scale
    property real collapsedWidth: 190 * Settings.scale
    property real contentPadding: Dimensions.spacingLg
    property real shadowMargin: 0

    // Children declared inside FloatingWindow become window content.
    default property alias content: contentContainer.data

    signal closeRequested()
    signal minimizeRequested()
    signal restoreRequested()

    function close() {
        closeRequested();
        visible = false;
    }

    function show() {
        visible = true;
        clampToZone();
    }

    function toggleCollapsed() {
        collapsed = !collapsed;
    }

    function clampToZone() {
        if (!windowZone)
            return;
        x = Math.max(0, Math.min(x, Math.max(0, windowZone.width - width)));
        y = Math.max(0, Math.min(y, Math.max(0, windowZone.height - height)));
    }

    parent: windowZone
    width: collapsed ? Math.min(collapsedWidth, windowZone ? windowZone.width : collapsedWidth)
                     : Math.min(expandedWidth, windowZone ? windowZone.width : expandedWidth)
    height: collapsed ? Math.min(headerHeight, windowZone ? windowZone.height : headerHeight)
                      : Math.min(expandedHeight, windowZone ? windowZone.height : expandedHeight)
    z: 100

    onWidthChanged: Qt.callLater(clampToZone)
    onHeightChanged: Qt.callLater(clampToZone)
    onWindowZoneChanged: Qt.callLater(clampToZone)

    Behavior on width {
        NumberAnimation { duration: Animations.animationFast; easing.type: Animations.easingSmooth }
    }
    Behavior on height {
        NumberAnimation { duration: Animations.animationFast; easing.type: Animations.easingSmooth }
    }

    Surfaces.Surface {
        id: windowSurface
        anchors.fill: parent
        elevation: control.elevation
        surfaceColor: control.surfaceColor
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius
    }

    // Only the content is clipped when the window shrinks; shadow stays visible.
    Item {
        anchors.fill: parent
        clip: true

        Item {
            id: header
            x: 0
            y: 0
            width: parent.width
            height: Math.min(control.headerHeight, parent.height)

            // Dragging the header moves the entire window, clamped to its zone.
            MouseArea {
                id: dragArea
                anchors.fill: parent
                enabled: control.draggable
                acceptedButtons: Qt.LeftButton
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                drag.target: control
                drag.axis: Drag.XAndYAxis
                drag.minimumX: 0
                drag.minimumY: 0
                drag.maximumX: Math.max(0, control.windowZone ? control.windowZone.width - control.width : 0)
                drag.maximumY: Math.max(0, control.windowZone ? control.windowZone.height - control.height : 0)
                onReleased: control.clampToZone()
                onDoubleClicked: {
                    if (control.minimizable) {
                        control.toggleCollapsed();
                        if (control.collapsed) control.minimizeRequested();
                        else control.restoreRequested();
                    }
                }
            }

            Row {
                id: windowActions
                anchors.left: parent.left
                anchors.leftMargin: Dimensions.spacingLg
                anchors.verticalCenter: parent.verticalCenter
                spacing: Dimensions.spacingSm

                // Red: close window.
                Rectangle {
                    width: 13 * Settings.scale
                    height: width
                    radius: width / 2
                    color: control.closable ? "#ff5f57" : Colors.textSecondary
                    opacity: control.closable ? 1 : 0.35
                    MouseArea {
                        anchors.fill: parent
                        enabled: control.closable
                        cursorShape: Qt.PointingHandCursor
                        onClicked: control.close()
                    }
                }

                // Yellow: collapse to a compact title bar.
                Rectangle {
                    width: 13 * Settings.scale
                    height: width
                    radius: width / 2
                    color: control.minimizable ? "#febc2e" : Colors.textSecondary
                    opacity: control.minimizable ? 1 : 0.35
                    MouseArea {
                        anchors.fill: parent
                        enabled: control.minimizable
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            control.toggleCollapsed();
                            if (control.collapsed)
                                control.minimizeRequested();
                            else
                                control.restoreRequested();
                        }
                    }
                }

                // Green: restore when minimized; double click on header also works.
                Rectangle {
                    width: 13 * Settings.scale
                    height: width
                    radius: width / 2
                    color: "#28c840"
                    opacity: control.collapsed ? 1 : 0.5
                    MouseArea {
                        anchors.fill: parent
                        enabled: control.collapsed
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            control.collapsed = false;
                            control.restoreRequested();
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 0
                width: Math.max(0, parent.width - 155 * Settings.scale)
                text: control.title
                color: control.titleColor
                font.family: Typography.fontFamilyHeading
                font.pixelSize: Typography.labelSize
                font.weight: Typography.weightSemibold
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }


        }

        Item {
            id: contentViewport
            x: 0
            y: control.headerHeight
            width: parent.width
            height: Math.max(0, parent.height - y)
            visible: height > 0
            clip: true

            Item {
                id: contentContainer
                anchors.fill: parent
                anchors.margins: control.contentPadding
            }
        }
    }
}
