pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import "../components/neomorphism/surfaces" as Surfaces
import "../style"
import "../services"
import "../config"

// import "./taskbarWidgets"

Scope {
    id: scope

    property var windowController: null

    Variants {
        id: variant

        model: Quickshell.screens

        delegate: PanelWindow {
            id: taskBar

            required property var modelData
            property var windowController: scope.windowController

            anchors.left: ["top", "left", "bottom"].includes(Settings.taskBarPosition) ? true : false
            anchors.right: ["top", "bottom", "right"].includes(Settings.taskBarPosition) ? true : false
            anchors.top: ["top", "left", "right"].includes(Settings.taskBarPosition) ? true : false
            anchors.bottom: ["bottom", "left", "right"].includes(Settings.taskBarPosition) ? true : false

            screen: modelData

            color: "transparent"

            implicitHeight: taskBarBackground.implicitHeight + Dimensions.taskBarOuterMargin

            Surfaces.Card {
                id: taskBarBackground

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom

                implicitWidth: parent.width - Dimensions.taskBarOuterMargin * 2
                implicitHeight: Dimensions.taskBarHeight
                cornerRadius: Dimensions.taskBarRadius

                elevation: "flat"
            }

            Item {
                id: taskBarContent

                anchors.fill: taskBarBackground
                anchors.leftMargin: Dimensions.taskBarInnerMargin
                anchors.rightMargin: Dimensions.taskBarInnerMargin

                TaskBarSection {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    modules: Settings.taskBarLeftModules
                }

                TaskBarSection {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    modules: Settings.taskBarCenterModules
                }

                TaskBarSection {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    modules: Settings.taskBarRightModules
                }

                /* LeftBarSection {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    popupController: taskBarController
                }

                WorkspaceSwitcher {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                RightBarSection {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    popupController: taskBarController
                } */
            }

            //TODO (überarbeiten?)
            PopupController {
                id: taskBarController

                anchorWindow: taskBar
            }

            Component.onCompleted: {
                NotificationService.targetWindow = taskBar;
            }

            /*
            // TODO ???
            BackgroundEffect.blurRegion: Region {
                item: taskBarBackground
                radius: Dimensions.taskBarRadius
            }
            */
        }
    }
}
