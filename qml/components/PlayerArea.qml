import Ergo 0.0
import QtQuick 2.4
import QtMultimedia 5.6
import QtQuick.Controls 2.2

Column {
    id: playerArea

    property var audio
    property string trackMetaText1
    property string trackMetaText2
    property string imageSource

    signal playPause()
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
        color: "darkgrey"
        width: audio.playbackState == Audio.PlayingState
               ? (parent.width * (audio.position / audio.duration)) : 0
        height: app.paddingSmall
    }

    Row {
        id: playerUI
     
        width: parent.width - app.gu(2)
        x: app.gu(1)
        height: imageItem.height

        Icon {
            id: imageItem
            source: imageSource
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
                text: trackMetaText1
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
                text: trackMetaText2
            }

        }


        Icon {
            id: playerButton
            width: app.iconSizeLarge
            height: width
            anchors.verticalCenter: parent.verticalCenter
            name: audio.playbackState == Audio.PlayingState
                        ? "media-preview-pause"
                        : "media-preview-start"
            MouseArea {
                anchors.fill: parent
                onClicked: playPause()
            }
        }
    }

    /*Timer {
        running: audioPlaybackState == Audio.PlayingState
        interval: 1000
        repeat: true

        onTriggered: {
            timeSlider.to = audio.duration
            timeSlider.value = audio.position
        }
    }*/
}
