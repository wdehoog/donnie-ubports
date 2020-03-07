import Ergo 0.0
import QtQuick 2.4
import QtMultimedia 5.6
import QtQuick.Controls 2.2

Column {
    property alias audioPlaybackState: playerUI.audioPlaybackState

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
     
        property int audioPlaybackState


        width: parent.width - app.gu(2)
        x: app.gu(1)
        height: imageItem.height

        Icon {
            id: imageItem
            source: channelImageUrl.length > 0 ? channelImageUrl : Qt.resolvedUrl("../resources/somafm-logo.svg")
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
                text: streamMetaText1
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
                text: streamMetaText2
            }

        }


        Icon {
            id: playerButton
            width: app.gu(4)
            height: width
            anchors.verticalCenter: parent.verticalCenter
            source: audioPlaybackState == Audio.PlayingState
                        ? Qt.resolvedUrl("../resources/pause.svg")
                        : Qt.resolvedUrl("../resources/play.svg")
            MouseArea {
                anchors.fill: parent
                onClicked: playPause()
            }
        }
    }
}
