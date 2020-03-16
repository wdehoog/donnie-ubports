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
import "../controls"

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

                MyComboBox {
                    id: resumeModeSelector

                    anchors.right: parent.right
                    width: parent.width - resumeModeLabel.width - app.paddingMedium
                    height: app.comboBoxHeight
                    fontPixelSize: app.fontPixelSizeMedium

                    Component.onCompleted: currentIndex = app.settings.resume_saved_info

                    onActivated: app.settings.resume_saved_info = currentIndex

                    model: [
                        i18n.tr("Never"),
                        i18n.tr("Ask"),
                        i18n.tr("Always")
                    ]
                }
            }
                
            Item {
                width: parent.width
                height: childrenRect.height
                Label {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: app.fontPixelSizeMedium
                    text: i18n.tr("Show containers in search results")
                }
                Switch {
                    id: allowContainers
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    checked: settings.search_allow_containers
                    onCheckedChanged: settings.search_allow_containers = checked
                }
            }

        }

    }

}

