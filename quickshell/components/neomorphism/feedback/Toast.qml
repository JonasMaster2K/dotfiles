import QtQuick
import QtQuick.Controls as Controls
import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.Popup {
    id: toast

    property string message: ""
    property string elevation: "raised"
    property string sizeVariant: "md"
    property int displayDuration: 3000
    property color messageColor: Colors.textPrimary
    property color surfaceColor: Colors.surface
    property real borderSize: 1 * Settings.scale

    function show(text, duration) {
        message = text;
        dismissTimer.interval = duration === undefined ? displayDuration : duration;
        open();
        dismissTimer.restart();
    }

    modal: false
    focus: false
    closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside
    padding: Dimensions.spacingLg
    x: parent ? Math.round((parent.width - width) / 2) : 0
    y: parent ? Math.max(0, parent.height - height - Dimensions.spacing2Xl) : 0
    implicitWidth: Math.max(180 * Settings.scale, Math.min(360 * Settings.scale, messageLabel.implicitWidth + leftPadding + rightPadding))
    implicitHeight: messageLabel.implicitHeight + topPadding + bottomPadding

    background: Surfaces.Surface {
        elevation: toast.elevation
        borderSize: toast.borderSize
        cornerRadius: Dimensions.radiusButton
        surfaceColor: toast.surfaceColor
    }
    contentItem: Text {
        id: messageLabel
        text: toast.message
        color: toast.messageColor
        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.bodySize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }

    Timer {
        id: dismissTimer
        interval: toast.displayDuration
        repeat: false
        onTriggered: toast.close()
    }
    onClosed: dismissTimer.stop()
}
