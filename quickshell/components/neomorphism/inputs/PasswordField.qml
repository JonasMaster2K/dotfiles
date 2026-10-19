import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../icons" as Icons

// Extends the themed TextField.qml in the same directory.
TextField {
    id: control

    // Public API
    property bool showVisibilityButton: true
    property bool passwordVisible: false
    property string lockIconName: "changes-prevent-symbolic"
    property string showPasswordIconName: "view-reveal-symbolic"
    property string hidePasswordIconName: "view-conceal-symbolic"
    property color visibilityIconColor: Colors.textSecondary

    // Inherited appearance: elevation / borderSize / sizeVariant.
    elevation: "sunken"
    leadingIcon: lockIconName
    placeholderText: "Password..."

    echoMode: passwordVisible ? TextInput.Normal : TextInput.Password

    readonly property bool canToggleVisibility: showVisibilityButton && enabled
    readonly property real visibilityButtonSize: Math.min(variantHeight, iconSize + Dimensions.spacingSm * 2)

    // Space for the eye button, or for an inherited trailing icon.
    rightPadding: horizontalInset + (canToggleVisibility ? visibilityButtonSize + iconGap : (trailingIcon.length > 0 ? iconSize + iconGap : 0))

    Controls.AbstractButton {
        id: visibilityButton

        visible: control.canToggleVisibility
        enabled: control.canToggleVisibility
        focusPolicy: Qt.NoFocus
        hoverEnabled: true

        width: control.visibilityButtonSize
        height: control.visibilityButtonSize
        x: control.width - control.horizontalInset - width
        y: (control.height - height) / 2

        background: Item {}

        contentItem: Icons.Icon {
            iconName: control.passwordVisible ? control.hidePasswordIconName : control.showPasswordIconName
            iconColor: control.visibilityIconColor
            colorize: true
            size: control.iconSize
            opacity: visibilityButton.down ? 0.55 : visibilityButton.hovered ? 1 : 0.72

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.animationFast
                }
            }
        }

        onClicked: {
            control.passwordVisible = !control.passwordVisible;
            control.forceActiveFocus();
        }

        Accessible.name: control.passwordVisible ? "Hide password" : "Show password"
    }
}
