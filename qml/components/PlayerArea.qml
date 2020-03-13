import Ergo 0.0
import QtQuick 2.4
import QtMultimedia 5.6
import QtQuick.Controls 2.2

Column {
    id: playerArea

    property var audioPlaybackState

    signal pause()
    signal previous()
    signal next()

    width: parent.width
    anchors {
        bottom: parent.bottom
        bottomMargin: app.gu(0.5)
    }

    Rectangle { 
        width: parent.width
        height: 1
        color: "grey"
    }
    Rectangle {
        width: parent.width
        height: app.gu(1) - 1
    }

    Row {
        id: playerUI
     
        width: parent.width - app.gu(2)
        x: app.gu(1)
        height: imageItem.height

        Icon {
            id: imageItem
            source: app.getPlayerPage().imageItemSource
            width: app.gu(10)
            height: width
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            id: meta
            width: parent.width - imageItem.width - playerButton.width
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: m1
                x: app.gu(1)
                width: parent.width - app.gu(1)
                font.bold: true
                font.pixelSize: app.fontPixelSizeLarge
                color: app.text1color
                wrapMode: Text.Wrap
                text: app.getPlayerPage().trackMetaText1
            }
            Text {
                id: m2
                x: app.gu(1)
                width: parent.width - app.gu(1)
                anchors.right: parent.right
                wrapMode: Text.Wrap
                font.pixelSize: app.fontPixelSizeLarge
                font.bold: true
                color: app.text2color
                text: app.getPlayerPage().trackMetaText2
            }

        }


        Icon {
            id: playerButton
            width: app.iconSizeLarge
            height: width
            anchors.verticalCenter: parent.verticalCenter
            name: audioPlaybackState == Audio.PlayingState
                        ? "media-preview-pause"
                        : "media-preview-start"
            MouseArea {
                anchors.fill: parent
                onClicked: app.playPause()
            }
        }
    }
}
