import QtQuick
import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Item {
    id: root

    property string text: "New"
    property string sizeVariant: "md"
    property string elevation: "raised"
    property bool accented: false
    property color textColor: accented ? Colors.accent : Colors.textPrimary
    property color surfaceColor: Colors.surface
    property real horizontalPadding: Dimensions.spacingMd
    property real verticalPadding: Dimensions.spacingSm

    readonly property real textSize: Typography.labelSize * (
        sizeVariant === "xs" ? 0.8 :
        sizeVariant === "sm" ? 0.9 :
        sizeVariant === "lg" ? 1.1 :
        sizeVariant === "xl" ? 1.2 : 1
    )
    implicitWidth: badgeText.implicitWidth + 2 * horizontalPadding
    implicitHeight: badgeText.implicitHeight + 2 * verticalPadding

    Surfaces.Surface {
        anchors.fill: parent
        elevation: root.elevation
        borderSize: 1 * Settings.scale
        cornerRadius: height / 2
        surfaceColor: root.surfaceColor
    }

    Text {
        id: badgeText
        anchors.centerIn: parent
        text: root.text
        color: root.textColor
        font.family: Typography.fontFamilyBody
        font.pixelSize: root.textSize
        font.weight: Font.DemiBold
    }
}
