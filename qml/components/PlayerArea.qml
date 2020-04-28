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

        /* Using a horizontal ListView looks and works nice. 
           Except that media-hub does not go to the previous track on prev() 
           but restarts the current one. Impossible to reflect with these sliding tracks. 
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

            //Connections { why is this not triggered?
            //    target: getPlayerPage().trackListView
            //    onCurrentIndexChanged: {
            //        var idx = getPlayerPage().currentItem
            //        console.log("PlayerPage currentIndex changed: " + target.currentIndex + ":" + idx)
            //    }
            //}

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
        }*/

        SwipeArea {
            id: meta
            width: parent.width - imageItem.width - playerButton.width
            height: parent.height
            clip: true

            property int swipeX: 0
            property bool backAnimationEnabled: false
            property bool flashButtonEnabled: false
            property var flashButton

            Column {
                id: info
                x: meta.swipeX 
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
                meta.backAnimationEnabled = true
                switch(direction) {
                    case "left":
                        meta.flashButton = nextButton
                        meta.flashButtonEnabled = true
                        app.getPlayerPage().next()
                        break
                    case "right":
                        meta.flashButton = previousButton
                        meta.flashButtonEnabled = true
                        app.getPlayerPage().prev()
                        break
                }
            }
            onMove: {
                meta.backAnimationEnabled = false
                meta.flashButtonEnabled = false
                meta.swipeX = x
            }
            NumberAnimation on swipeX {
                id: backToZero
                running: meta.backAnimationEnabled
                to: 0
            }
            ParallelAnimation {
                running: meta.flashButtonEnabled
                SequentialAnimation {
                    NumberAnimation { target: playerButton; property: "opacity";
                                      to: 0; } 
                    PauseAnimation { duration: 300; }
                    NumberAnimation { target: playerButton; property: "opacity";
                                      to: 1; duration: 300;} 
                }
                SequentialAnimation {
                    NumberAnimation { target: meta.flashButton; property: "opacity";
                                      to: 1; }
                    PauseAnimation { duration: 300 }
                    NumberAnimation { target: meta.flashButton; property: "opacity";
                                      to: 0; duration: 300; }
                }
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
