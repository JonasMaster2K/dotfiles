import QtQuick

import "../config"
import "../style"
import "../services"
import "../components/neomorphism/feedback" as Indicator

OSDPanel {
    id: osd

    position: Settings.numlockOsdPosition
    connectionTarget: Numlock

    Row {
        padding: Dimensions.spacingSm
        spacing: Dimensions.spacingMd

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: "Num-Lock"
            color: Colors.textPrimary

            font {
                family: Typography.fontFamilyBody
                pixelSize: Typography.labelSize
                weight: Font.DemiBold
            }
        }

        Indicator.Badge {
            anchors.verticalCenter: parent.verticalCenter

            text: Numlock.active ? "ON" : "OFF"
            sizeVariant: "sm"
            accented: Numlock.active
        }
    }
}
