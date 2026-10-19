import QtQuick
import Qt5Compat.GraphicalEffects as Effects

import "../../../style"

Item {
    id: root

    // =========================================================================
    // SOURCE
    // =========================================================================

    required property url source

    // =========================================================================
    // APPEARANCE
    // =========================================================================

    property real coverSize: Dimensions.iconSize2Xl
    property real radius: Dimensions.radiusSm

    property color backgroundColor: Colors.surfaceSunken

    // =========================================================================
    // IMAGE STATE
    // =========================================================================

    readonly property int status: sourceImage.status
    readonly property bool loading: status === Image.Loading
    readonly property bool ready: status === Image.Ready
    readonly property bool failed: status === Image.Error

    // =========================================================================
    // LAYOUT
    // =========================================================================

    implicitWidth: coverSize
    implicitHeight: coverSize

    // =========================================================================
    // BACKGROUND
    // =========================================================================

    Rectangle {
        anchors.fill: parent

        radius: root.radius
        color: root.backgroundColor

        visible: !root.ready
    }

    // =========================================================================
    // SOURCE IMAGE
    // =========================================================================

    Image {
        id: sourceImage

        anchors.fill: parent

        source: root.source
        fillMode: Image.PreserveAspectCrop

        asynchronous: true
        cache: true
        smooth: true

        visible: false
    }

    // =========================================================================
    // ROUNDED MASK
    // =========================================================================

    Rectangle {
        id: imageMask

        anchors.fill: parent

        radius: root.radius
        color: "white"

        visible: false
    }

    // =========================================================================
    // RENDERED IMAGE
    // =========================================================================

    Effects.OpacityMask {
        anchors.fill: parent

        source: sourceImage
        maskSource: imageMask

        cached: true
        visible: root.ready
    }
}
