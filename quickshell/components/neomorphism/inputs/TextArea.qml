import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Controls.TextArea {
    id: control

    // Same appearance API as TextField.qml.
    property string elevation: "sunken"  // "flat", "raised", "sunken"
    property string sizeVariant: "md"     // "xs", "sm", "md", "lg", "xl"

    property real borderSize: Dimensions.borderWidth * 3
    property real cornerRadius: Dimensions.radiusButton
    property int minimumVisibleLines: 4

    property color surfaceColor: Colors.surface
    property color hoverSurfaceColor: Colors.surfaceHover
    property color pressedSurfaceColor: Colors.surfacePressed
    property color textColor: Colors.textPrimary

    readonly property real variantHeight: {
        switch (sizeVariant) {
        case "xs": return Dimensions.controlHeightXs
        case "sm": return Dimensions.controlHeightSm
        case "lg": return Dimensions.controlHeightLg
        case "xl": return Dimensions.controlHeightXl
        default:   return Dimensions.controlHeightMd
        }
    }

    readonly property real contentInset: Math.max(
        Dimensions.spacingLg,
        elevation === "sunken" ? borderSize + Dimensions.spacingSm : 0
    )

    implicitWidth: 280 * Settings.scale
    implicitHeight: Math.max(
        variantHeight * 2,
        minimumVisibleLines * font.pixelSize * 1.5 + topPadding + bottomPadding
    )

    leftPadding: contentInset
    rightPadding: contentInset
    topPadding: contentInset
    bottomPadding: contentInset

    font.family: Typography.fontFamilyBody
    font.pixelSize: Typography.bodySize

    color: enabled ? textColor : Colors.textSecondary
    placeholderTextColor: Colors.textSecondary
    selectionColor: Colors.accent
    selectedTextColor: Colors.textPrimary

    wrapMode: TextEdit.Wrap
    selectByMouse: true
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    opacity: enabled ? 1 : 0.48

    background: Surfaces.Surface {
        elevation: control.elevation
        borderSize: control.borderSize
        cornerRadius: control.cornerRadius
        surfaceColor: control.surfaceColor
        hoverColor: control.hoverSurfaceColor
        pressedColor: control.pressedSurfaceColor
        hovered: control.hovered && control.enabled && !control.activeFocus
    }
}
