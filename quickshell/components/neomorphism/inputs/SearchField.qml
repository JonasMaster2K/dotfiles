import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../icons" as Icons

// Extends the project's themed TextField.qml in the same directory.
TextField {
    id: control

    // Public API
    signal searchRequested(string query)

    property bool showClearButton: true
    property bool trimSearchQuery: true
    property string searchIconName: "search-symbolic"
    property string clearIconName: "window-close-symbolic"
    property color clearIconColor: Colors.textSecondary

    // Visual defaults; elevation / borderSize / sizeVariant remain inherited.
    elevation: "sunken"
    leadingIcon: searchIconName
    placeholderText: "Search..."

    readonly property bool canClear: showClearButton && text.length > 0 && enabled && !readOnly
    readonly property real clearButtonSize: Math.min(variantHeight, iconSize + Dimensions.spacingSm * 2)

    // Reserve space for the clear action without interfering with TextField's text.
    rightPadding: horizontalInset + (canClear ? clearButtonSize + iconGap : (trailingIcon.length > 0 ? iconSize + iconGap : 0))

    onAccepted: {
        const query = trimSearchQuery ? text.trim() : text;
        searchRequested(query);
    }

    Controls.AbstractButton {
        id: clearButton
        visible: control.canClear
        enabled: control.canClear
        focusPolicy: Qt.NoFocus
        hoverEnabled: true

        width: control.clearButtonSize
        height: control.clearButtonSize
        x: control.width - control.horizontalInset - width
        y: (control.height - height) / 2

        background: Item {}

        contentItem: Icons.Icon {
            iconName: control.clearIconName
            iconColor: control.clearIconColor
            colorize: true
            size: control.iconSize
            opacity: clearButton.down ? 0.55 : clearButton.hovered ? 1 : 0.72
            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.animationFast
                }
            }
        }

        onClicked: {
            control.clear();
            control.forceActiveFocus();
        }

        Accessible.name: "Clear search"
    }
}
