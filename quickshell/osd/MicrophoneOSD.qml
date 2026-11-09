import QtQuick

import "../config"
import "../style"
import "../services"
import "../components/neomorphism/feedback" as Indicator

OSDPanel {
    id: osd

    position: Settings.microphoneOsdPosition
    connectionTarget: MicrophoneService

    Row {
        padding: Dimensions.spacingSm
        spacing: Dimensions.spacingMd

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: "Mic"
            color: Colors.textPrimary

            font {
                family: Typography.fontFamilyBody
                pixelSize: Typography.labelSize
                weight: Font.DemiBold
            }
        }

        Indicator.Badge {
            anchors.verticalCenter: parent.verticalCenter

            text: MicrophoneService.muted ? "OFF" : "ON"
            sizeVariant: "sm"
            accented: MicrophoneService.muted
        }
    }
}
