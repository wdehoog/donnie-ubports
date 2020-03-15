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
    id: settingsPage
    objectName: "SettingsPage"

    header: PageHeader {
        title: i18n.tr("Settings")
    }

    Flickable {
        id: flick
        anchors.fill: parent

        Column {
            id: column
            width: parent.width - 2*app.paddingMedium
            y: app.paddingLarge
            x: app.paddingMedium
            spacing: app.paddingLarge

            Item {
                width: parent.width
                height: childrenRect.height 
                Label {
                    id: resumeModeLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 2 / 3
                    font.pixelSize: app.fontPixelSizeMedium
                    wrapMode: Label.WordWrap
                    text: i18n.tr("Load saved queue at startup and resume playing")
                }

                ComboBox {
                    id: resumeModeSelector
                    anchors.right: parent.right
                    width: parent.width - resumeModeLabel.width - app.paddingMedium
                    height: app.comboBoxHeight

                    font.pixelSize: app.fontPixelSizeMedium
                    indicator.width: height
                    background: Rectangle {
                        color: app.normalBackgroundColor
                        border.width: 1
                        border.color: "grey"
                        radius: 7
                    }

                    delegate: ItemDelegate { // override only to set font.pixelSize
                        width: resumeModeSelector.width
                        //height: resumeModeSelector.height
                        contentItem: Text {
                            text: modelData
                            font.pixelSize: app.fontPixelSizeMedium
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Component.onCompleted: currentIndex = app.settings.resume_saved_info

                    onActivated: {
                        app.settings.resume_saved_info = currentIndex
                    }

                    model: [
                        i18n.tr("Never"),
                        i18n.tr("Ask"),
                        i18n.tr("Always")
                    ]
                }
            }
                
            Row {
                width: parent.width
                height: childrenRect.height
                Label {
                    text: i18n.tr("Show containers in search results")
                }
                Switch {
                    id: allowContainers
                    anchors.right: parent.right
                    checked: settings.search_allow_containers
                    onCheckedChanged: settings.search_allow_containers = checked
                }
            }

        }

    }

}

