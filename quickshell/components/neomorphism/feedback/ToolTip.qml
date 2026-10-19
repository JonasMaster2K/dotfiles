import QtQuick
import Quickshell
import "../../../style"
import "../surfaces" as Surfaces
import "../../../config"

PopupWindow {
    id: control

    property string elevation: "flat"
    property real borderSize: 1 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton

    property string text: ""
    property Item targetItem: null

    property int xOff: 0
    property int yOff: 0

    implicitWidth: background.implicitWidth + Dimensions.shadowCardOffset * 6
    implicitHeight: background.implicitHeight + Dimensions.shadowCardOffset * 6

    visible: targetItem !== null && text !== ""

    color: "transparent"

    anchor.window: targetItem ? targetItem.QsWindow.window : null

    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right

    anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide

    anchor.onAnchoring: {
        if (!targetItem)
            return;
        const rect = targetItem.QsWindow.window.itemRect(targetItem);

        anchor.rect.x = rect.x + xOff;
        anchor.rect.y = rect.y + yOff;
        anchor.rect.height = rect.height;
        anchor.rect.width = rect.width;
    }

    Surfaces.Surface {
        id: background
        anchors.centerIn: parent
        implicitWidth: tooltipText.width + Dimensions.spacingMd * 2
        implicitHeight: tooltipText.height + Dimensions.spacingMd * 2
        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius
        surfaceColor: Colors.surface

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: control.text
            color: Colors.textPrimary
            font.family: Typography.fontFamilyBody
            font.pixelSize: Typography.labelSize
            wrapMode: Text.Wrap
        }
    }
}
