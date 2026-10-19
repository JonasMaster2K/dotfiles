import QtQuick

// Uses the same styling and keyboard behavior as Menu.
// Set parent to the target Item, then openAt() with target-local coordinates.
Menu {
    id: control

    function openAt(target, localX, localY) {
        if (!target || !control.parent)
            return;
        const position = target.mapToItem(control.parent, localX, localY);
        control.x = position.x;
        control.y = position.y;
        control.open();
    }
}
