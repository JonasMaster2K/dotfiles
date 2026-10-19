import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.Dialog {
    id: control

    // Standard Controls.Dialog properties remain available:
    // title, standardButtons, modal, accepted/rejected, open()/close().
    property string elevation: "raised"
    property real borderSize: 1 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton
    property real dialogPadding: Dimensions.spacingXl
    property color surfaceColor: Colors.surface

    modal: true
    focus: true
    closePolicy: Controls.Popup.CloseOnEscape
                 | Controls.Popup.CloseOnPressOutside

    width: Math.min(420 * Settings.scale,
                    parent ? Math.max(0, parent.width - 2 * Dimensions.spacingXl)
                           : 420 * Settings.scale)
    padding: dialogPadding
    spacing: Dimensions.spacingLg

    // Center the popup in the host window, not inside the triggering button.
    anchors.centerIn: Controls.Overlay.overlay

    background: Surfaces.Surface {
        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius
        surfaceColor: control.surfaceColor
    }

    header: Item {
        implicitHeight: control.title.length > 0
                        ? titleText.implicitHeight + control.dialogPadding
                        : 0
        visible: control.title.length > 0

        Text {
            id: titleText
            x: control.dialogPadding
            y: control.dialogPadding
            width: Math.max(0, parent.width - 2 * control.dialogPadding)
            text: control.title
            color: Colors.textPrimary
            font.family: Typography.fontFamilyHeading
            font.pixelSize: Typography.titleSize
            font.weight: Typography.weightSemibold
            wrapMode: Text.Wrap
        }
    }

    footer: Controls.DialogButtonBox {
        visible: control.standardButtons !== Controls.Dialog.NoButton
        standardButtons: control.standardButtons
        onAccepted: control.accept()
        onRejected: control.reject()

        background: Item {}
        leftPadding: control.dialogPadding
        rightPadding: control.dialogPadding
        bottomPadding: control.dialogPadding
        topPadding: Dimensions.spacingMd
    }
}
