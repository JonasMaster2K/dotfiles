pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls

import "../../../style"
import "../../../config"
import "../surfaces" as Surfaces

Item {
    id: root

    // Steps are labels, e.g. ["Start", "Configure", "Finish"]
    property var steps: []
    property int currentStep: 0
    property bool interactive: true
    property string sizeVariant: "md"
    property color activeColor: Colors.accent
    property color textColor: Colors.textSecondary
    property color completedColor: Colors.accent
    property color surfaceColor: Colors.surface
    property real spacing: Dimensions.spacingSm
    signal stepSelected(int index)

    readonly property real stepDiameter: {
        switch (sizeVariant) {
        case "xs":
            return Dimensions.controlHeightXs;
        case "sm":
            return Dimensions.controlHeightSm;
        case "lg":
            return Dimensions.controlHeightLg;
        case "xl":
            return Dimensions.controlHeightXl;
        default:
            return Dimensions.controlHeightMd;
        }
    }
    readonly property real labelHeight: Typography.labelSize * 1.6

    implicitWidth: 400 * Settings.scale
    implicitHeight: stepDiameter + labelHeight + Dimensions.spacingMd

    Row {
        id: stepsRow
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.steps
            delegate: Item {
                id: stepCell
                required property int index
                required property var modelData
                readonly property bool selected: index === root.currentStep
                readonly property bool completed: index < root.currentStep

                width: root.steps.length > 0 ? stepsRow.width / root.steps.length : 0
                height: stepsRow.height

                Rectangle {
                    // Connecting line lives behind the round buttons.
                    visible: stepCell.index > 0
                    x: -stepCell.width / 2 + root.stepDiameter / 2
                    y: root.stepDiameter / 2 - height / 2
                    width: Math.max(0, stepCell.width - root.stepDiameter)
                    height: Math.max(1, 2 * Settings.scale)
                    radius: height / 2
                    color: stepCell.completed || stepCell.selected ? root.completedColor : Colors.textSecondary
                    opacity: stepCell.completed || stepCell.selected ? 0.9 : 0.25
                }

                Controls.AbstractButton {
                    id: stepButton
                    width: root.stepDiameter
                    height: root.stepDiameter
                    x: (stepCell.width - width) / 2
                    y: 0
                    enabled: root.interactive
                    hoverEnabled: true
                    focusPolicy: Qt.StrongFocus
                    Accessible.name: String(stepCell.modelData)

                    background: Surfaces.Surface {
                        elevation: stepButton.down ? "sunken" : stepCell.selected ? "raised" : (stepCell.completed ? "flat" : "sunken")
                        borderSize: 1 * Settings.scale
                        cornerRadius: width / 2
                        surfaceColor: root.surfaceColor
                        hovered: stepButton.hovered && !stepCell.selected
                    }
                    contentItem: Text {
                        text: stepCell.completed ? "✓" : String(stepCell.index + 1)
                        font.family: Typography.fontFamilyBody
                        font.pixelSize: Typography.labelSize
                        font.weight: Font.DemiBold
                        color: stepCell.selected ? root.activeColor : stepCell.completed ? root.completedColor : root.textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        root.currentStep = stepCell.index;
                        root.stepSelected(stepCell.index);
                    }
                }

                Text {
                    x: 0
                    y: root.stepDiameter + Dimensions.spacingSm
                    width: stepCell.width
                    text: String(stepCell.modelData)
                    color: stepCell.selected ? root.activeColor : root.textColor
                    font.family: Typography.fontFamilyBody
                    font.pixelSize: Typography.labelSize
                    font.weight: stepCell.selected ? Font.DemiBold : Font.Normal
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }
            }
        }
    }
}
