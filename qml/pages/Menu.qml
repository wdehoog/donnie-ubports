/**
 * Copyright (C) 2020 Willem-Jan de Hoog
 *
 * License: MIT
 */

import Ergo 0.0

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../components"

Page {

    objectName: "MenuPage"

    property bool popOnExit: true
    property string selectedMenuItem: ""
    property int _currentIndex: -1
    property bool _started: false

    anchors.fill: parent

    header: PageHeader {
        title: i18n.tr("Donnie") 
        //flickable: listView

        leadingActions: [] // disable Back button

        trailingActions: [
            //Action {
            //    iconName: "help"
            //    text: i18n.tr("Help")
            //    onTriggered: Qt.openUrlExternally("https://wdehoog.github.io/hutspot-ubports")
            //},
            Action {
                iconName: "info"
                text: i18n.tr("About")
                onTriggered: app.doSelectedMenuItem("about")
            },
            Action {
                iconName: "settings"
                text: i18n.tr("Settings")
                onTriggered: app.doSelectedMenuItem("settings")
            }
        ]
    }

    ListModel {
        id: menuModel
    }

    Component.onCompleted: {
        menuModel.append({menuItem: "upnp-discovery",
                          name: i18n.tr("UPnP Discovery"),
                          icon: "image://theme/network-server-symbolic"
                         })
        menuModel.append({menuItem: "upnp-browse",
                          name: i18n.tr("Browse"),
                          icon: "image://theme/view-list-symbolic"
                         })
        menuModel.append({menuItem: "upnp-search",
                          name: i18n.tr("Search"),
                          icon: "image://theme/toolkit_input-search"
                         })
        menuModel.append({menuItem: "builtin-player",
                          name: i18n.tr("Player"),
                          icon: "image://theme/stock_music"
                         })
    }

    ListView {
        id: listView
        model: menuModel

        anchors.fill: parent
        interactive: contentHeight > height
        spacing: units.dp(8)

        delegate: AdaptiveListItem {
            width: parent.width - 2 * app.paddingLarge
            x: app.paddingLarge
            height: units.dp(56)

            Image {
                id: image
                width: app.iconSizeMedium
                height: width
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: model.icon
            }

            /*Colorize {
                id: colorize
                visible: menuItem === ""
                anchors.fill: image
                source: image
                hue: 0.0
                saturation: 1.0
                lightness: -0.2
            }*/

            Text {
                anchors.left: image.right
                anchors.leftMargin: app.paddingLarge
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                //color: _currentIndex === index ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: app.fontPixelSizeLarge
                text: model.name
            }

            MouseArea {
                anchors.fill: parent
                onPressed: _currentIndex = index
                onReleased:  _currentIndex = 0
                onClicked: {
                    selectedMenuItem = model.menuItem
                    closeIt()
                }
            }

        }
    }
    
    function closeIt() {
        app.doSelectedMenuItem(selectedMenuItem)
    }
}
