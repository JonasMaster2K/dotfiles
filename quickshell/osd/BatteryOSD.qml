import QtQuick

import "../config"
import "../style"
import "../services"
import "../components/neomorphism/feedback" as Indicator

OSDPanel {
    id: osd

    position: Settings.batteryOsdPosition
    connectionTarget: BatteryService

    Row {
        padding: Dimensions.spacingSm
        spacing: Dimensions.spacingMd

        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: "Battery"
            color: Colors.textPrimary

            font {
                family: Typography.fontFamilyBody
                pixelSize: Typography.labelSize
                weight: Font.DemiBold
            }
        }

        Indicator.Badge {
            anchors.verticalCenter: parent.verticalCenter

            text: {
                switch (BatteryService.osdSignal) {
                case 1:
                    return "CHARGING";
                case 2:
                    return "20%";
                case 3:
                    return "10%";
                default:
                    return `${BatteryService.level}%`;
                }
            }

            sizeVariant: "sm"
            accented: BatteryService.osdSignal >= 2
        }
    }
}
