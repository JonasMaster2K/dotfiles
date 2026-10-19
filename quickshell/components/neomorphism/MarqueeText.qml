import QtQuick

import "../style"

Item {
    id: root

    property bool autoScroll: true
    property color color: Theme.foreground
    readonly property real contentWidth: textMetrics.advanceWidth
    property font font: Qt.font({
        family: Theme.fontFamily,
        pixelSize: Theme.fontSizeMd,
        weight: Theme.fontWeightMedium
    })
    property int interval: Theme.marqueeInterval
    property bool moving: false
    readonly property bool overflowing: contentWidth > width
    readonly property bool scrolling: moving
    property real spacing: Theme.marqueeSpacing
    property real speed: Theme.marqueeSpeed
    property int startDelay: Theme.marqueeStartDelay
    property string text: ""

    function restart(): void {
        stop();

        if (autoScroll && overflowing)
            marqueeAnimation.start();
    }
    function stop(): void {
        marqueeAnimation.stop();
        moving = false;
        marqueeContent.x = 0;
    }
    function trigger(): void {
        if (!overflowing)
            return;
        marqueeAnimation.stop();
        moving = false;
        marqueeContent.x = 0;
        marqueeAnimation.start();
    }

    clip: true
    implicitHeight: firstText.implicitHeight
    implicitWidth: contentWidth

    Component.onCompleted: restart()
    onAutoScrollChanged: restart()
    onTextChanged: restart()
    onWidthChanged: restart()

    TextMetrics {
        id: textMetrics

        font: root.font
        text: root.text
    }
    Text {
        anchors.fill: parent
        color: root.color
        elide: Text.ElideRight
        font: root.font
        text: root.text
        verticalAlignment: Text.AlignVCenter
        visible: !root.moving
        wrapMode: Text.NoWrap
    }
    Item {
        id: marqueeContent

        implicitHeight: Math.max(firstText.implicitHeight, secondText.implicitHeight)
        implicitWidth: firstText.implicitWidth + root.spacing + secondText.implicitWidth
        visible: root.moving
        x: 0

        Text {
            id: firstText

            anchors.verticalCenter: parent.verticalCenter
            color: root.color
            font: root.font
            text: root.text
            wrapMode: Text.NoWrap
            x: 0
        }
        Text {
            id: secondText

            anchors.verticalCenter: parent.verticalCenter
            color: root.color
            font: root.font
            text: root.text
            wrapMode: Text.NoWrap
            x: firstText.implicitWidth + root.spacing
        }
    }
    SequentialAnimation {
        id: marqueeAnimation

        loops: root.autoScroll ? Animation.Infinite : 1

        PauseAnimation {
            duration: root.startDelay
        }
        ScriptAction {
            script: {
                root.moving = true;
                marqueeContent.x = 0;
            }
        }
        NumberAnimation {
            duration: Math.max(1, (firstText.implicitWidth + root.spacing) / Math.max(1, root.speed) * 1000)
            easing.type: Easing.Linear
            from: 0
            property: "x"
            target: marqueeContent
            to: -(firstText.implicitWidth + root.spacing)
        }
        ScriptAction {
            script: {
                root.moving = false;
                marqueeContent.x = 0;
            }
        }
        PauseAnimation {
            duration: root.interval
        }
    }
}
