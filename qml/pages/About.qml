import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2

import "../components"

Page {
    id: aboutPage
    objectName: "AboutPage"


    header: PageHeader  {
        id: header
        title: i18n.tr("About") 
    }

    ScrollView  {
        id: flick
        anchors.fill: parent

        Column {
            id: column
            width: flick.width - 2*app.gu(1)
            x: app.gu(1)
            y: x
            spacing: app.gu(5)

            Item {
                width: parent.width
                height: childrenRect.height

                Icon {
                    id: icon
                    width: app.gu(10)
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Qt.resolvedUrl("../../assets/logo.svg")
                }

                Column {
                    id: appTitleColumn

                    anchors {
                        left: parent.left
                        leftMargin: app.paddingMedium
                        right: parent.right
                        rightMargin: app.paddingMedium
                        top: icon.bottom
                        topMargin: app.paddingMedium
                    }

                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: app.fontPixelSizeLarge
                        text: "Donnie 0.2"
                    }

                    Label {
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: app.fontPixelSizeLarge
                        text: i18n.tr("UPnP player for UBPorts")
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        horizontalAlignment: implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: app.fontPixelSizeSmall
                        text: "Copyright (C) 2020 Willem-Jan de Hoog"
                        width: parent.width
                    }
                    /*Label {
                        horizontalAlignment: implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: app.fontPixelSizeMedium
                        text: i18n.tr("sources: https://github.com/wdehoog/somafm-ubports")
                        width: parent.width
                    }*/
                    Label {
                        horizontalAlignment: implicitWidth > width ? Text.AlignLeft : Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: app.fontPixelSizeMedium
                        text: i18n.tr("License: MIT")
                        width: parent.width
                    }
                }

            }

            Column {
                width: parent.width

                Label {
                    text: i18n.tr("Translations")
                    font.pixelSize: app.fontPixelSizeLarge
                }

                Label {
                    anchors {
                        left: parent.left
                        leftMargin: app.gu(2)
                        right: parent.right
                        rightMargin: app.gu(2)
                    }
                    font.pixelSize: app.fontPixelSizeLarge
                    wrapMode: Text.WordWrap
                    text: "fr: Anne017"
                    }
            }

            Column {
                width: parent.width

                Label {
                    text: i18n.tr("Thanks to")
                    font.pixelSize: app.fontPixelSizeLarge
                }

                Label {
                    anchors {
                        left: parent.left
                        leftMargin: app.gu(2)
                        right: parent.right
                        rightMargin: app.gu(2)
                    }
                    font.pixelSize: app.fontPixelSizeLarge
                    wrapMode: Text.WordWrap
                    text:
"
J.F.Dockes for amazing UPnP libs
Rodney: https://gitlab.com/calm-os/ergo
UBPorts Team: UBPorts
"
                }
            }
        }
    }
}
