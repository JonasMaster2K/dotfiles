import QtQuick

import "../config"
import "../services"
import "../components/neomorphism/feedback" as Feedback

OSDPanel {
    id: osd

    position: Settings.keyboardOsdPosition
    connectionTarget: KeyboardService

    readonly property real barLength: 400 * Settings.scale
    readonly property real barThickness: 20 * Settings.scale

    Feedback.SegmentedProgressBar {

        anchors {
            horizontalCenter: osd.vertical ? parent.horizontalCenter : undefined
            verticalCenter: osd.vertical ? undefined : parent.verticalCenter
        }

        orientation: osd.vertical ? "vertical" : "horizontal"

        length: osd.barLength
        thickness: osd.barThickness

        from: 0
        to: 3
        value: KeyboardService.backlight
    }
}
