import QtQuick

import "../config"
import "../style"
import "../services"
import "../components/neomorphism/feedback" as Indicator

OSDPanel {
    id: osd

    position: Settings.capslockOsdPosition
    connectionTarget: Capslock

    Row {
        padding: Dimensions.spacingSm
        spacing: Dimensions.spacingMd

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: "Caps Lock"
            color: Colors.textPrimary

            font {
                family: Typography.fontFamilyBody
                pixelSize: Typography.labelSize
                weight: Font.DemiBold
            }
        }

        Indicator.Badge {
            anchors.verticalCenter: parent.verticalCenter

            text: Capslock.active ? "ON" : "OFF"
            sizeVariant: "sm"
            accented: Capslock.active
        }
    }
}
