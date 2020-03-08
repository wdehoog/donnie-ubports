/**
 * Copyright (C) 2019 Willem-Jan de Hoog
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
    property int selectedMenuItem: -1
    property int _currentIndex: -1
    property bool _started: false

    anchors.fill: parent

    header: PageHeader {
        title: i18n.tr("Donnie") 
        //flickable: listView

        trailingActions: [
            //Action {
            //    iconName: "help"
            //    text: i18n.tr("Help")
            //    onTriggered: Qt.openUrlExternally("https://wdehoog.github.io/hutspot-ubports")
            //},
            Action {
                iconName: "info"
                text: i18n.tr("About")
                //onTriggered: app.doSelectedMenuItem(Util.HutspotMenuItem.ShowAboutPage)
            } //,
            //Action {
            //    iconName: "settings"
            //    text: i18n.tr("Settings")
            //   onTriggered: app.doSelectedMenuItem(Util.HutspotMenuItem.ShowSettingsPage)
            //}
        ]
    }

    ListModel {
        id: menuModel
    }

    Component.onCompleted: {
        menuModel.append({hutspotMenuItem: "UPnP Browser",
                          name: ("Browser"),
                          icon: "image://theme/view-list-symbolic"
                         })
        /*menuModel.append({hutspotMenuItem: Util.HutspotMenuItem.ShowLibraryPage,
                          name: ("Library"),
                          icon: "image://theme/view-list-symbolic"
                         })
        menuModel.append({hutspotMenuItem: Util.HutspotMenuItem.ShowTopStuffPage,
                          name: i18n.tr("Top"),
                          icon: "image://theme/unlike"
                         })
        menuModel.append({hutspotMenuItem: Util.HutspotMenuItem.ShowGenreMoodPage,
                          name: i18n.tr("Genre & Mood"),
                          icon: "image://theme/weather-app-symbolic",
                         })
        menuModel.append({hutspotMenuItem: Util.HutspotMenuItem.ShowSearchPage,
                          name: i18n.tr("Search"),
                          icon: "image://theme/toolkit_input-search"
                         })
        menuModel.append({hutspotMenuItem: Util.HutspotMenuItem.ShowHistoryPage,
                          name: i18n.tr("History"),
                          icon: "image://theme/history"
                         })
        menuModel.append({hutspotMenuItem: Util.HutspotMenuItem.ShowDevicesPage,
                          name: i18n.tr("Devices"),
                          icon: "image://theme/audio-speakers-symbolic",
                          name: "devices"
                                //"image://theme/audio-volume-muted-blocking-panel"
                         })*/
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

            Colorize {
                visible: name == "devices" && !app.controller.hasCurrentDevice
                anchors.fill: image
                source: image
                hue: 0.0
                saturation: 1.0
                lightness: -0.2
            }

            Text {
                anchors.left: image.right
                anchors.leftMargin: app.paddingLarge
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                //color: _currentIndex === index ? Theme.highlightColor : Theme.primaryColor
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
