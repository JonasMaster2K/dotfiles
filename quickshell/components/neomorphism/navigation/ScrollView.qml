import QtQuick
import QtQuick.Controls as Controls

Controls.ScrollView {
    id: control

    // ---------------------------------------------------------------------
    // Public API
    // ---------------------------------------------------------------------

    property alias verticalPolicy: verticalBar.policy
    property alias horizontalPolicy: horizontalBar.policy

    property alias verticalScrollBar: verticalBar
    property alias horizontalScrollBar: horizontalBar

    property string scrollBarSizeVariant: "sm"

    property bool scrollBarAutoHide: true
    property bool showScrollBarTrack: false

    // ---------------------------------------------------------------------
    // Layout
    // ---------------------------------------------------------------------

    padding: 0
    clip: true

    hoverEnabled: true

    background: Item {}

    // Hover über den gesamten Bereich, nicht nur über die Scrollbar.
    HoverHandler {
        id: viewHover
    }

    // ---------------------------------------------------------------------
    // Vertical Scrollbar
    // ---------------------------------------------------------------------

    Controls.ScrollBar.vertical: ScrollBar {
        id: verticalBar

        parent: control

        x: control.mirrored ? 0 : control.width - width

        y: 0
        height: control.height

        sizeVariant: control.scrollBarSizeVariant
        autoHide: control.scrollBarAutoHide
        showTrack: control.showScrollBarTrack

        viewHovered: viewHover.hovered

        policy: Controls.ScrollBar.AsNeeded
    }

    // ---------------------------------------------------------------------
    // Horizontal Scrollbar
    // ---------------------------------------------------------------------

    Controls.ScrollBar.horizontal: ScrollBar {
        id: horizontalBar

        parent: control

        x: 0
        y: control.height - height

        width: control.width

        sizeVariant: control.scrollBarSizeVariant
        autoHide: control.scrollBarAutoHide
        showTrack: control.showScrollBarTrack

        viewHovered: viewHover.hovered

        policy: Controls.ScrollBar.AsNeeded
    }
}
