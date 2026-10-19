pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../icons" as Icons

Item {
    id: root

    // ========================================================================
    // PUBLIC API
    // ========================================================================

    property string mode: "static" // static | wheel

    property int count: 0
    property int currentIndex: 0
    property int visibleCount: 5
    property int orientation: Qt.Horizontal

    property bool reversed: false
    property bool interactive: true

    // Grab / drag
    property bool draggable: true
    property real dragThreshold: 0.3

    // Optional navigation arrows
    property bool showNavigationArrows: false
    property bool showArrowsOnHover: true
    property real arrowSize: Dimensions.hitTargetMin
    property real arrowGap: Dimensions.spacingSm
    property real arrowIconSize: Dimensions.iconSizeSm

    // Dots
    property real dotSize: Dimensions.spacingSm
    property real activeSize: Dimensions.spacingLg
    property real hitSize: Dimensions.hitTargetMin
    property real spacing: Dimensions.spacingXs

    property color activeColor: Colors.accent
    property color inactiveColor: Colors.surfaceSunken
    property color hoverColor: Colors.surfaceHover

    // Animation
    property int slideDuration: 280

    // Wheel
    property int wheelCooldown: 380
    property real wheelStepThreshold: 120
    property real touchpadStepThreshold: 90

    property bool fadeEdges: true

    signal pageSelected(int index)

    // ========================================================================
    // CALCULATED PROPERTIES
    // ========================================================================

    readonly property bool wheelMode: mode === "wheel"
    readonly property bool horizontal: orientation === Qt.Horizontal

    readonly property int safeCount: Math.max(0, count)

    readonly property int slotCount: wheelMode ? Math.min(safeCount, Math.max(1, visibleCount)) : safeCount

    readonly property int centerSlot: Math.floor(slotCount / 2)

    readonly property real slotExtent: Math.max(hitSize, dotSize, activeSize)

    readonly property real slotStep: slotExtent + spacing

    readonly property int guards: wheelMode && safeCount > 1 ? 1 : 0

    readonly property int renderedCount: slotCount + 2 * guards

    readonly property real dotsExtent: slotCount * slotExtent + Math.max(0, slotCount - 1) * spacing

    readonly property real arrowExtent: showNavigationArrows ? arrowSize + arrowGap : 0

    readonly property bool canPrevious: interactive && safeCount > 1 && (wheelMode || currentIndex > 0)

    readonly property bool canNext: interactive && safeCount > 1 && (wheelMode || currentIndex < safeCount - 1)

    readonly property bool arrowsVisible: showNavigationArrows && (!showArrowsOnHover || hoverHandler.hovered)

    // ========================================================================
    // INTERNAL STATE
    // ========================================================================

    property int visualIndex: 0
    property real slideOffset: 0
    property real dragOffset: 0
    property real wheelAccumulation: 0
    property bool initialized: false

    // ========================================================================
    // HELPERS
    // ========================================================================

    function wrap(i) {
        return safeCount > 0 ? ((i % safeCount) + safeCount) % safeCount : 0;
    }

    function pageAtSlot(slot) {
        if (!wheelMode)
            return reversed ? safeCount - 1 - slot : slot;

        return wrap(visualIndex + (slot - guards - centerSlot) * (reversed ? -1 : 1));
    }

    function selectPage(index) {
        if (!interactive || safeCount < 1)
            return;

        const next = wheelMode ? wrap(index) : Math.max(0, Math.min(safeCount - 1, index));

        if (next !== currentIndex)
            pageSelected(next);
    }

    function step(sign) {
        if (!interactive || safeCount < 2 || slideAnimation.running || dragHandler.active)
            return;

        selectPage(currentIndex + sign * (reversed ? -1 : 1));
    }

    function resetVisual() {
        slideAnimation.stop();

        slideOffset = 0;
        dragOffset = 0;

        visualIndex = wrap(currentIndex);
    }

    function currentChanged() {
        if (!initialized)
            return;

        if (!wheelMode || safeCount < 2 || slideDuration <= 0) {
            resetVisual();
            return;
        }

        if (slideAnimation.running) {
            resetVisual();
            return;
        }

        const direction = reversed ? -1 : 1;

        const forward = wrap(visualIndex + direction) === wrap(currentIndex);

        const backward = wrap(visualIndex - direction) === wrap(currentIndex);

        if (!forward && !backward) {
            resetVisual();
            return;
        }

        const sign = forward ? 1 : -1;

        slideAnimation.from = slideOffset;
        slideAnimation.to = -sign * slotStep;

        slideAnimation.start();
    }

    function finishDrag() {
        if (!wheelMode || !interactive || safeCount < 2) {
            dragOffset = 0;
            return;
        }

        const releasedOffset = dragOffset;

        // Die Animation startet an der losgelassenen Position.
        slideOffset = releasedOffset;
        dragOffset = 0;

        const threshold = slotStep * Math.max(0, dragThreshold);

        if (Math.abs(releasedOffset) >= threshold) {
            const sign = releasedOffset < 0 ? 1 : -1;

            // Die Seite wird vom Besitzer über pageSelected
            // geändert. currentChanged animiert anschließend.
            const previousIndex = currentIndex;

            selectPage(previousIndex + sign * (reversed ? -1 : 1));

            // Falls der Besitzer currentIndex nicht verändert,
            // fährt der Track wieder in seine Ausgangslage.
            if (currentIndex === previousIndex)
                animateBack();

            return;
        }

        animateBack();
    }

    function animateBack() {
        if (slideDuration <= 0) {
            slideOffset = 0;
            return;
        }

        slideAnimation.from = slideOffset;
        slideAnimation.to = 0;
        slideAnimation.start();
    }

    // ========================================================================
    // STATE CHANGES
    // ========================================================================

    onCurrentIndexChanged: currentChanged()

    onCountChanged: {
        if (initialized)
            resetVisual();
    }

    onModeChanged: {
        if (initialized)
            resetVisual();
    }

    onOrientationChanged: {
        if (initialized)
            resetVisual();
    }

    onReversedChanged: {
        if (initialized)
            resetVisual();
    }

    Component.onCompleted: {
        visualIndex = wrap(currentIndex);
        initialized = true;
    }

    // ========================================================================
    // ANIMATION
    // ========================================================================

    NumberAnimation {
        id: slideAnimation

        target: root
        property: "slideOffset"

        duration: root.slideDuration
        easing.type: Easing.InOutCubic

        onFinished: {
            root.visualIndex = root.wrap(root.currentIndex);
            root.slideOffset = 0;
        }
    }

    Timer {
        id: wheelLock

        interval: root.wheelCooldown
        repeat: false
    }

    // ========================================================================
    // LAYOUT
    // ========================================================================

    implicitWidth: horizontal ? dotsExtent + 2 * arrowExtent : Math.max(slotExtent, showNavigationArrows ? arrowSize : 0)

    implicitHeight: horizontal ? Math.max(slotExtent, showNavigationArrows ? arrowSize : 0) : dotsExtent + 2 * arrowExtent

    // Wichtig: Die Pfeile dürfen nicht abgeschnitten werden.
    // Nur der innere Viewport clippt die animierten Dots.
    clip: false

    HoverHandler {
        id: hoverHandler
    }

    // ========================================================================
    // DOT VIEWPORT
    // ========================================================================

    Item {
        id: dotViewport

        width: root.horizontal ? root.dotsExtent : root.slotExtent

        height: root.horizontal ? root.slotExtent : root.dotsExtent

        x: root.horizontal ? root.arrowExtent : (root.width - width) / 2

        y: root.horizontal ? (root.height - height) / 2 : root.arrowExtent

        clip: true

        // ====================================================================
        // WHEEL HANDLING
        // ====================================================================

        MouseArea {
            anchors.fill: parent

            enabled: root.wheelMode && root.interactive
            acceptedButtons: Qt.NoButton

            onWheel: function (e) {
                e.accepted = true;

                if (root.safeCount < 2 || wheelLock.running || slideAnimation.running || dragHandler.active)
                    return;

                const angle = root.horizontal && e.angleDelta.x !== 0 ? e.angleDelta.x : e.angleDelta.y;

                const pixels = root.horizontal && e.pixelDelta.x !== 0 ? e.pixelDelta.x : e.pixelDelta.y;

                const usingPixels = angle === 0 && pixels !== 0;

                const delta = usingPixels ? pixels : angle;

                if (delta === 0)
                    return;

                if (root.wheelAccumulation !== 0 && Math.sign(root.wheelAccumulation) !== Math.sign(delta)) {
                    root.wheelAccumulation = 0;
                }

                root.wheelAccumulation += delta;

                const threshold = usingPixels ? root.touchpadStepThreshold : root.wheelStepThreshold;

                if (Math.abs(root.wheelAccumulation) < Math.max(1, threshold))
                    return;

                const sign = root.wheelAccumulation < 0 ? 1 : -1;

                root.wheelAccumulation = 0;

                wheelLock.start();
                root.step(sign);
            }
        }

        // ====================================================================
        // GRAB / DRAG
        // ====================================================================

        DragHandler {
            id: dragHandler

            enabled: root.wheelMode && root.draggable && root.interactive && root.safeCount > 1 && !slideAnimation.running

            target: null

            xAxis.enabled: root.horizontal
            yAxis.enabled: !root.horizontal

            onTranslationChanged: {
                if (!active)
                    return;

                const delta = root.horizontal ? translation.x : translation.y;

                // Nur eine Seite pro Drag-Geste.
                root.dragOffset = Math.max(-root.slotStep, Math.min(root.slotStep, delta));
            }

            onActiveChanged: {
                if (!active)
                    root.finishDrag();
            }
        }

        // ====================================================================
        // DOT TRACK
        // ====================================================================

        Item {
            id: track

            width: root.horizontal ? root.renderedCount * root.slotExtent + Math.max(0, root.renderedCount - 1) * root.spacing : root.slotExtent

            height: root.horizontal ? root.slotExtent : root.renderedCount * root.slotExtent + Math.max(0, root.renderedCount - 1) * root.spacing

            x: root.horizontal ? -root.guards * root.slotStep + root.slideOffset + root.dragOffset : 0

            y: root.horizontal ? 0 : -root.guards * root.slotStep + root.slideOffset + root.dragOffset

            Repeater {
                model: root.renderedCount

                delegate: PaginationDot {
                    required property int index

                    readonly property int pageIndex: root.pageAtSlot(index)

                    readonly property real distance: Math.abs(index - root.guards - root.centerSlot + (root.slideOffset + root.dragOffset) / root.slotStep)

                    readonly property real highlight: root.wheelMode ? Math.max(0, 1 - distance) : (pageIndex === root.currentIndex ? 1 : 0)

                    x: root.horizontal ? index * root.slotStep : (root.slotExtent - width) / 2

                    y: root.horizontal ? (root.slotExtent - height) / 2 : index * root.slotStep

                    opacity: !root.wheelMode || !root.fadeEdges ? 1 : Math.max(0.5, 1 - 0.12 * distance)

                    active: highlight >= 0.999
                    emphasis: highlight

                    enabled: root.interactive

                    dotSize: root.dotSize
                    activeSize: root.activeSize
                    hitSize: root.hitSize

                    activeColor: root.activeColor
                    inactiveColor: root.inactiveColor
                    hoverColor: root.hoverColor

                    onClicked: root.selectPage(pageIndex)
                }
            }
        }
    }

    // ========================================================================
    // PREVIOUS ARROW
    // ========================================================================

    Controls.AbstractButton {
        id: previousButton

        visible: root.showNavigationArrows
        enabled: root.canPrevious

        hoverEnabled: true
        focusPolicy: Qt.NoFocus

        width: root.arrowSize
        height: root.arrowSize

        x: root.horizontal ? 0 : (root.width - width) / 2

        y: root.horizontal ? (root.height - height) / 2 : 0

        opacity: root.arrowsVisible ? (enabled ? 1 : 0.35) : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.animationFast
            }
        }

        background: Rectangle {
            radius: height / 2

            color: previousButton.down ? Colors.surfacePressed : previousButton.hovered ? Colors.surfaceHover : "transparent"
        }

        contentItem: Icons.Icon {
            iconName: root.horizontal ? "arrow-left-symbolic" : "arrow-up-symbolic"

            size: root.arrowIconSize

            iconColor: Colors.textSecondary
            colorize: true
        }

        onClicked: root.step(-1)
    }

    // ========================================================================
    // NEXT ARROW
    // ========================================================================

    Controls.AbstractButton {
        id: nextButton

        visible: root.showNavigationArrows
        enabled: root.canNext

        hoverEnabled: true
        focusPolicy: Qt.NoFocus

        width: root.arrowSize
        height: root.arrowSize

        x: root.horizontal ? root.width - width : (root.width - width) / 2

        y: root.horizontal ? (root.height - height) / 2 : root.height - height

        opacity: root.arrowsVisible ? (enabled ? 1 : 0.35) : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.animationFast
            }
        }

        background: Rectangle {
            radius: height / 2

            color: nextButton.down ? Colors.surfacePressed : nextButton.hovered ? Colors.surfaceHover : "transparent"
        }

        contentItem: Icons.Icon {
            iconName: root.horizontal ? "arrow-right-symbolic" : "arrow-down-symbolic"

            size: root.arrowIconSize

            iconColor: Colors.textSecondary
            colorize: true
        }

        onClicked: root.step(1)
    }
}
