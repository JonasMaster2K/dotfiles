import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces
import "../icons" as Icons

Controls.SpinBox {
    id: control

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------
    property string sizeVariant: "md" // xs, sm, md, lg, xl
    property string elevation: "sunken" // flat, raised, sunken (value field)
    property real borderSize: 4 * Settings.scale
    property real cornerRadius: Dimensions.radiusButton
    property string valueSuffix: ""
    property string incrementIcon: "list-add-symbolic"
    property string decrementIcon: "list-remove-symbolic"

    property color surfaceColor: Colors.surface
    property color hoverSurfaceColor: Colors.surfaceHover
    property color pressedSurfaceColor: Colors.surfacePressed
    property color textColor: Colors.textPrimary
    property color iconColor: Colors.textPrimary

    readonly property real variantHeight: {
        switch (sizeVariant) {
        case "xs": return Dimensions.controlHeightXs
        case "sm": return Dimensions.controlHeightSm
        case "lg": return Dimensions.controlHeightLg
        case "xl": return Dimensions.controlHeightXl
        default:   return Dimensions.controlHeightMd
        }
    }
    readonly property real buttonSize: variantHeight
    readonly property real iconSize: Math.min(variantHeight * 0.48, Dimensions.iconSizeLg)
    readonly property real buttonGap: Dimensions.spacingSm

    // -------------------------------------------------------------------------
    // SpinBox behaviour
    // -------------------------------------------------------------------------
    from: 0
    to: 100
    value: 50
    stepSize: 1
    editable: true
    wrap: false

    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    padding: 0

    leftPadding: buttonSize + buttonGap + Dimensions.spacingMd
    rightPadding: buttonSize + buttonGap + Dimensions.spacingMd

    implicitWidth: Math.max(190 * Settings.scale,
                            2 * buttonSize + 2 * buttonGap + 75 * Settings.scale)
    implicitHeight: variantHeight

    opacity: enabled ? 1 : 0.48

    textFromValue: function(value, locale) {
        return Number(value).toLocaleString(locale, 'f', 0) + control.valueSuffix
    }

    valueFromText: function(text, locale) {
        let numberText = String(text)
        if (control.valueSuffix.length > 0 && numberText.endsWith(control.valueSuffix))
            numberText = numberText.slice(0, -control.valueSuffix.length)
        const value = Number.fromLocaleString(locale, numberText.trim())
        return isNaN(value) ? control.value : Math.round(value)
    }

    // Suffixes are parsed by valueFromText; an IntValidator would reject them.
    validator: control.valueSuffix.length > 0 ? null : integerValidator

    IntValidator {
        id: integerValidator
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    // -------------------------------------------------------------------------
    // Center: themed sunken/raised/flat field
    // -------------------------------------------------------------------------
    background: Item {
        Surfaces.Surface {
            x: control.buttonSize + control.buttonGap
            y: 0
            width: Math.max(0, parent.width - 2 * (control.buttonSize + control.buttonGap))
            height: parent.height

            elevation: control.elevation
            borderSize: control.borderSize
            cornerRadius: control.cornerRadius
            surfaceColor: control.surfaceColor
            hoverColor: control.hoverSurfaceColor
            pressedColor: control.pressedSurfaceColor
            hovered: control.hovered && control.enabled
        }
    }

    contentItem: TextInput {
        text: control.displayText
        font.family: Typography.fontFamilyBody
        font.pixelSize: Typography.bodySize
        font.weight: Font.Medium
        color: control.textColor
        selectionColor: Colors.accent
        selectedTextColor: Colors.textPrimary

        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        readOnly: !control.editable
        selectByMouse: true
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        clip: true

        onEditingFinished: {
            if (control.editable)
                control.value = Math.max(Math.min(control.valueFromText(text, control.locale),
                                                   Math.max(control.from, control.to)),
                                         Math.min(control.from, control.to))
        }
    }

    // -------------------------------------------------------------------------
    // Minus: raised at rest, sunken when pressed
    // -------------------------------------------------------------------------
    down.indicator: Item {
        x: 0
        y: (control.height - height) / 2
        implicitWidth: control.buttonSize
        implicitHeight: control.buttonSize
        width: implicitWidth
        height: implicitHeight

        Surfaces.Surface {
            anchors.fill: parent
            elevation: control.down.pressed ? "sunken" : "raised"
            borderSize: 1 * Settings.scale
            cornerRadius: control.cornerRadius
            surfaceColor: control.surfaceColor
            hoverColor: control.hoverSurfaceColor
            pressedColor: control.pressedSurfaceColor
            hovered: control.hovered && !control.down.pressed
        }

        Icons.Icon {
            anchors.centerIn: parent
            iconName: control.decrementIcon
            size: control.iconSize
            iconColor: control.iconColor
            colorize: true
            opacity: control.value <= Math.min(control.from, control.to) && !control.wrap ? 0.35 : 1
        }
    }

    // -------------------------------------------------------------------------
    // Plus
    // -------------------------------------------------------------------------
    up.indicator: Item {
        x: control.width - width
        y: (control.height - height) / 2
        implicitWidth: control.buttonSize
        implicitHeight: control.buttonSize
        width: implicitWidth
        height: implicitHeight

        Surfaces.Surface {
            anchors.fill: parent
            elevation: control.up.pressed ? "sunken" : "raised"
            borderSize: 1 * Settings.scale
            cornerRadius: control.cornerRadius
            surfaceColor: control.surfaceColor
            hoverColor: control.hoverSurfaceColor
            pressedColor: control.pressedSurfaceColor
            hovered: control.hovered && !control.up.pressed
        }

        Icons.Icon {
            anchors.centerIn: parent
            iconName: control.incrementIcon
            size: control.iconSize
            iconColor: control.iconColor
            colorize: true
            opacity: control.value >= Math.max(control.from, control.to) && !control.wrap ? 0.35 : 1
        }
    }
}
