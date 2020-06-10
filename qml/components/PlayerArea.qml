import Ergo 0.0
import QtQuick 2.4
import QtMultimedia 5.6
import QtQuick.Controls 2.2

Rectangle {
    id: playerArea

    property var audio
    property var track
    property string imageSource

    signal playPause()
    signal previous()
    signal next()

    color: app.bgColor
    width: parent.width
    anchors {
        bottom: parent.bottom
    }

    Column {

        width: parent.width

        Rectangle { 
            width: parent.width
            height: 1
            color: "grey"
        }

        Rectangle {
            id: progress
            color: "darkgrey"
            height: app.paddingExtraSmall
        }

        // Using binding on width results in binding loop (why?)
        // so use a timer.
        Timer { 
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                progress.width = audio.playbackState == Audio.PlayingState
                   ? (parent.width * (audio.position / audio.duration)) : 0
            }
        }

        Row {
            id: playerUI
         
            width: parent.width - 2*x
            x: app.gu(1)
            height: imageItem.height

            Icon {
                id: imageItem
                source: imageSource
                width: app.gu(10)
                height: width
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                     anchors.fill: parent
                     onClicked: {
                         app.doSelectedMenuItem("builtin-player")
                     }
                }
            }

            SwipeArea {
                id: meta
                width: parent.width - imageItem.width - playerButton.width
                height: parent.height
                clip: true

                property int swipeX: 0
                property bool backAnimationEnabled: false
                property var flashButton

                Column {
                    id: info
                    x: meta.swipeX 
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        x: app.paddingSmall
                        width: parent.width - 2*x
                        wrapMode: Text.Wrap
                        color: app.primaryHighlightColor
                        text: track.title ? track.title : ""
                    }
                    Label {
                        x: app.paddingSmall
                        width: parent.width - 2*x
                        wrapMode: Text.Wrap
                        color: app.secondaryHighlightColor
                        text: getLabelText(track.artist, track.album)
                    }
                    Label {
                        x: app.paddingSmall
                        width: parent.width - 2*x
                        wrapMode: Text.Wrap
                        color: app.tertiaryHighlightColor
                        text: getLabelText(track.durationText, track.audioType)
                    }

                }
                onSwipe: {
                    switch(direction) {
                        case "left":
                            meta.flashButton = nextButton
                            meta.swipeX = meta.width
                            app.getPlayerPage().next()
                            break
                        case "right":
                            meta.flashButton = previousButton
                            meta.swipeX = -meta.width
                            app.getPlayerPage().prev()
                            break
                    }
                    meta.backAnimationEnabled = true
                }
                onMove: {
                    meta.backAnimationEnabled = false
                    meta.swipeX = x
                }
                NumberAnimation on swipeX {
                    id: backToZero
                    running: meta.backAnimationEnabled
                    to: 0
                }
            }

            Item {
                width: app.iconSizeLarge
                height: width

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
                        onClicked: app.playPause()
                    }
                    opacity: 1
                }
                Icon {
                    id: nextButton
                    width: playerButton.width
                    height: width
                    x: playerButton.x
                    y: playerButton.y
                    name: "media-skip-forward"
                    opacity: 0
                }
                Icon {
                    id: previousButton
                    width: playerButton.width
                    height: width
                    x: playerButton.x
                    y: playerButton.y
                    name: "media-skip-backward"
                    opacity: 0
                }
            }
        }

    }

    function getLabelText(l0, l1) {
      var l = ""
      if(l0)
        l += l0
      if(l1) {
        if(l)
          l += " - "
        l += l1    
      }
      return l
    }
}
