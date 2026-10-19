import QtQuick

QtObject {
    id: root

    required property var anchorWindow
    property var currentPopup: null
    readonly property bool hasOpenPopup: currentPopup !== null

    function open(popup): void {
        if (!popup)
            return

        if (currentPopup === popup) {
            if (!popup.visible)
                popup.show()

            return
        }

        closeCurrent()

        currentPopup = popup
        popup.show()
    }

    function close(popup): void {
        if (!popup)
            return

        popup.hide()

        if (currentPopup === popup)
            currentPopup = null
    }

    function toggle(popup): void {
        if (!popup)
            return

        if (currentPopup === popup && popup.visible) {
            close(popup)
            return
        }

        open(popup)
    }

    function closeCurrent(): void {
        if (!currentPopup)
            return

        const popup = currentPopup

        currentPopup = null
        popup.hide()
    }

    function release(popup): void {
        if (currentPopup === popup)
            currentPopup = null
    }
}