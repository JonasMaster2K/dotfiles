pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../../components/neomorphism/buttons" as Buttons
import "../../components/neomorphism/icons" as Icons

import "../../style"
import "../../services"
import "../../config"

RowLayout {
    id: root

    // =========================================================================
    // MODULE API
    // =========================================================================

    property string displayMode: "icon"
    property var taskBarWindow: null

    property string sizeVariant: "md"
    property real itemSpacing: Dimensions.spacingXs
    property real contentSpacing: Dimensions.spacingSm

    property color activeColor: Colors.textPrimary
    property color inactiveColor: Colors.textSecondary

    property real inactiveOpacity: 0.35
    property bool showAppIcons: true

    signal workspaceSelected(var workspace)

    spacing: itemSpacing

    // =========================================================================
    // WORKSPACES
    // =========================================================================

    Repeater {
        model: WorkspaceService.workspaces

        delegate: Buttons.Button {
            id: workspaceButton

            required property var modelData

            readonly property var workspace: modelData.workspace
            readonly property string workspaceName: modelData.name
            readonly property bool active: WorkspaceService.isActive(workspace)

            Layout.alignment: Qt.AlignVCenter

            buttonHeight: Dimensions.taskBarWidgetSizeMd
            elevation: Settings.taskBarWidgetStyle
            text: ""
            iconName: ""

            implicitWidth: Math.max(variantHeight, workspaceContent.implicitWidth + paddingHorizontal * 2)

            opacity: enabled ? 1 : 0.6

            Row {
                id: workspaceContent

                anchors.centerIn: parent

                spacing: root.contentSpacing

                opacity: workspaceButton.active ? 1.0 : root.inactiveOpacity

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.animationFast
                        easing.type: Easing.InOutQuad
                    }
                }

                Text {
                    id: workspaceLabel

                    anchors.verticalCenter: parent.verticalCenter
                    text: workspaceButton.workspaceName
                    color: workspaceButton.active ? root.activeColor : root.inactiveColor
                    font.family: Typography.fontFamilyBody
                    font.pixelSize: Typography.labelSize
                    font.weight: Typography.weightBold
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -Dimensions.spacingMd
                    visible: root.displayMode === "icon" && root.showAppIcons

                    Repeater {
                        model: workspaceButton.workspace ? workspaceButton.workspace.toplevels : []

                        delegate: Icons.Icon {
                            required property var modelData
                            required property var index

                            anchors.verticalCenter: parent.verticalCenter
                            iconName: WorkspaceService.appId(modelData)
                            size: Dimensions.taskBarIconSizeLg
                            colorize: false
                            visible: iconName !== ""
                            z: -index
                        }
                    }
                }
            }

            onClicked: {
                WorkspaceService.activate(workspace);
                root.workspaceSelected(workspace);
            }
        }
    }
}
