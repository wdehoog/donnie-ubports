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
    }

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

        ListView {
            id: meta
            width: parent.width - imageItem.width - playerButton.width
            height: parent.height
            orientation: ListView.Horizontal
            clip: true

            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange 
            highlightFollowsCurrentItem: true

            model: getPlayerPage().trackListModel

            property bool _fromPlayer: false // no navigation when we follow the player 
            property int _fromPlayerIndex: -1

            onCurrentIndexChanged: {
                var idx = getPlayerPage().currentItem
                var idx2 = getPlayerPage().trackListView.currentIndex
                var idx3 = app.audio.playlist.currentIndex
                console.log("PlayerArea: currentIndex changed: " + meta.currentIndex + ", currentItem=" + idx + ", view.currentIndex=" + idx2 + ", playlist.currentIndex=" + idx3 + ", " + _fromPlayer)

                if(meta._fromPlayer && meta.currentIndex == meta._fromPlayerIndex) {
                    // update was caused by PlayerPage ListView
                    meta._fromPlayer = false
                    return
                } else if(meta._fromPlayer) {
                    // PlayerPage ListView is updating as well so don't interfere
                    return
                }

                if(meta.currentIndex > idx)
                    app.getPlayerPage().next()
                else if(meta.currentIndex < idx) 
                    app.getPlayerPage().prev()
            }

            /*Connections { why is this not triggered?
                target: getPlayerPage().trackListView
                onCurrentIndexChanged: {
                    var idx = getPlayerPage().currentItem
                    console.log("PlayerPage currentIndex changed: " + target.currentIndex + ":" + idx)
                }
            }*/

            Connections {
                target: getPlayerPage()
                onCurrentItemChanged: {
                  var idx = getPlayerPage().currentItem
                  var idx2 = getPlayerPage().trackListView.currentIndex
                  var idx3 = app.audio.playlist.currentIndex
                  console.log("PlayerArea: PlayerPage.currentItem changed: " + meta.currentIndex + ", currentItem=" + idx + ", view.currentIndex=" + idx2 + ", playlist.currentIndex=" + idx3)

                    if(meta.currentIndex != target.currentItem) {
                        // scroll, hopefully without animation, and causes currentIndex to be updated
                        meta._fromPlayer = true
                        meta._fromPlayerIndex = target.currentItem
                        meta.positionViewAtIndex(target.currentItem, ListView.Beginning) 
                    }
                }
            }

            delegate: Item {
                width: meta.width
                height: meta.height
                Column {
                    id: stuff
                    width: meta.width
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: m1
                        x: app.gu(1)
                        width: parent.width - app.gu(1)
                        font.bold: true
                        font.pixelSize: app.fontPixelSizeMedium
                        color: app.text1color
                        wrapMode: Text.Wrap
                        text: titleText
                    }
                    Text {
                        id: m2
                        x: app.gu(1)
                        width: parent.width - app.gu(1)
                        anchors.right: parent.right
                        wrapMode: Text.Wrap
                        font.pixelSize: app.fontPixelSizeMedium
                        font.bold: true
                        color: app.text2color
                        text: metaText
                    }

                }
            }
        }
        /*SwipeArea {
            id: meta
            width: parent.width - imageItem.width - playerButton.width
            height: parent.height
            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: m1
                    x: app.gu(1)
                    width: parent.width - app.gu(1)
                    font.bold: true
                    font.pixelSize: app.fontPixelSizeMedium
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
                    font.pixelSize: app.fontPixelSizeMedium
                    font.bold: true
                    color: app.text2color
                    text: trackMetaText2
                }

            }
            onSwipe: {
                switch(direction) {
                    case "left":
                        app.getPlayerPage().next()
                        break
                    case "right":
                        app.getPlayerPage().prev()
                        break
                }
            }
        }*/

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
        }
    }

}
