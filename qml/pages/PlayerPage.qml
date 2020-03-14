/**
 * Donnie. Copyright (C) 2020 Willem-Jan de Hoog
 *
 * License: MIT
 */


import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtMultimedia 5.9
import QtQuick.Window 2.0

import "../components"

import "../UPnP.js" as UPnP

Page {
    id: playerPage
    objectName: "PlayerPage"

    property var audio
    property string defaultImageSource : "image://theme/stock_music"
    property string imageItemSource : defaultImageSource
    property string playIconName : "media-preview-start"
    property int currentItem: -1
    property bool metaShown : false
    property string trackClass

    property string trackMetaText1 : ""
    property string trackMetaText2 : ""

    property bool hasTracks : listView.model.count > 0
    property bool canNext: hasTracks && (currentItem < (listView.model.count - 1))
    property bool canPrevious: hasTracks && (currentItem > 0)
    property bool canPlay: hasTracks && (audio.playbackState != audio.PlayingState)
    property bool canPause: audio.playbackState == audio.PlayingState
    property int requestedAudioPosition : -1

    // 1 playing, 2 paused, the rest inactive
    property int transportState : -1

    header: PageHeader {
        title: i18n.tr("Built-In Player")
    }

    function refreshTransportState() {
        var newState;
        if(audio.playbackState == Audio.PlayingState)
            newState = 1;
        else if(audio.playbackState == Audio.PausedState)
            newState = 2;
        else
            newState = -1;
        transportState = newState;
        //console.log("RTS: count:" + listView.model.count+", currentItem"+currentItem+", hasTracks: "+hasTracks+", canNext: "+canNext)
        //app.notifyTransportState(transportState);
    }

    Connections {
        target: app.audio

        onStatusChanged: {
            if((audio.status == Audio.Loading
                || audio.status == Audio.Loaded)
               && requestedAudioPosition != -1) {
                 audio.seek(requestedAudioPosition)
                requestedAudioPosition = -1
            }

            if(audio.status == Audio.EndOfMedia) {
                next();
            }            
        }

        onPlaybackStateChanged: refreshTransportState()
        onSourceChanged: refreshTransportState()
        onBufferProgressChanged: {
            if(audio.bufferProgress == 1.0) {
                play()
                updatePlayIcons()
            }
        }
    }

    function next() {
        if(currentItem >= (trackListModel.count-1))
            return;
        currentItem++;
        loadTrack(trackListModel.get(currentItem));
    }

    function prev() {
        if(currentItem <= 0)
            return;
        currentItem--;
        loadTrack(trackListModel.get(currentItem));
    }

    function pause() {
        if(audio.playbackState == Audio.PlayingState) {
            audio.pause()
            updatePlayIcons()
            app.settings.last_playing_position = audio.position
        } else {
            play()
        }
    }

    function play() {
        audio.play()
        updatePlayIcons()
    }

    function stop() {
        audio.stop()
        updatePlayIcons()
        app.settings.last_playing_position = audio.position
    }

    function loadTrack(track) {
        //audio.stop();
        audio.source = track.uri
        imageItemSource = track.albumArtURI ? track.albumArtURI : defaultImageSource
        updatePlayIcons()

        trackMetaText1 = track.titleText
        trackMetaText2 = track.metaText
        trackClass = track.upnpclass;

        updateMprisForTrack(track);
        app.saveLastPlayingJSON(track, trackListModel)
    }

    function clearList() {
        stop()
        audio.source = ""
        listView.model.clear()
        trackMetaText1 = ""
        trackMetaText2 = ""
        trackClass = ""
        currentItem = -1
        imageItemSource = defaultImageSource
    }

    function updatePlayIcons() {
        if(audio.playbackState == Audio.PlayingState) {
            playIconName = "media-preview-pause"
        } else {
            playIconName =  "media-preview-start"
        }
    }

    function updateMprisForTrackMetaData(track) {
        var meta = {};
        meta.Title = trackMetaText1;
        meta.Artist = trackMetaText2;
        meta.Album = track.album;
        meta.Length = 0;
        meta.ArtUrl = track.albumArtURI;
        meta.TrackNumber = currentItem;
        //app.updateMprisMetaData(meta);
    }

    function updateMprisForTrack(track) {
        var meta = {};
        meta.Title = trackMetaText1;
        meta.Artist = trackMetaText2;
        meta.Album = track.album;
        meta.Length = track.duration * 1000; // ms -> us
        meta.ArtUrl = track.albumArtURI;
        meta.TrackNumber = currentItem;
        //app.updateMprisMetaData(meta);
    }

    ListView {
        id: listView
        model: trackListModel
        width: parent.width
        anchors.fill: parent

        /*PullDownMenu {
            MenuItem {
                text: qsTr("Add Stream")
                //visible: false
                onClicked: {
                    app.showEditURIDialog(qsTr("Add Stream"), "", "", UPnP.AudioItemType.AudioBroadcast, function(title, uri, streamType) {
                        if(uri === "")
                            return
                        var track = UPnP.createUserAddedTrack(uri, title, streamType)
                        if(track !== null) {
                            trackListModel.append(track)
                            currentItem = trackListModel.count-1
                            loadTrack(track)
                        }
                    })
                }
            }
            MenuItem {
                text: qsTr("Empty List")
                onClicked: clearList()
            }
        }*/

        header: Column {
            width: parent.width - 2*app.paddingMedium
            x: app.paddingMedium

            anchors {
                topMargin: 0
                bottomMargin: app.paddingLarge
            }

            Rectangle {
                width: parent.width
                height:app.paddingLarge
                opacity: 0
            }

            Row {

                width: parent.width

                /*Rectangle {
                    width: app.paddingLarge
                    height: parent.height
                    opacity: 0
                }*/

                Image {
                    id: imageItem
                    source: imageItemSource ? imageItemSource : defaultImageSource
                    width: parent.width / 2
                    height: width
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                  id: playerButtons
                  //property int currentPlayerState: Audio.Pl

                  anchors.verticalCenter: parent.verticalCenter
                  spacing: app.paddingMedium
                  width: parent.width / 2
                  //height: playIcon.height

                  Icon {
                      anchors.horizontalCenter: parent.horizontalCenter
                      name: "media-skip-backward"
                      enabled: canPrevious
                      width: app.iconSizeMedium
                      height: width
                      MouseArea {
                          anchors.fill: parent
                          onClicked: prev()
                      }
                  }

                  Icon {
                      anchors.horizontalCenter: parent.horizontalCenter
                      id: playIcon
                      name: playIconName
                      width: app.iconSizeLarge
                      height: width
                      MouseArea {
                          anchors.fill: parent
                          onClicked: pause()
                      }
                  }

                  Icon {
                      anchors.horizontalCenter: parent.horizontalCenter
                      name: "media-skip-forward"
                      enabled: canNext
                      width: app.iconSizeMedium
                      height: width
                      MouseArea {
                          anchors.fill: parent
                          onClicked: next()
                      }
                  }
                }
            }

            Rectangle {
                width: parent.width
                height:app.paddingMedium
                opacity: 0
            }

            Row {
                width: parent.width
                /*Text {
                    id: progressLabel
                    //font.pixelSize: Theme.fontSizeSmall
                    anchors.verticalCenter: parent.verticalCenter
                    text: Util.getDurationString(app.controller.playbackState.progress_ms)
                }*/
                Slider { // for tracks
                    id: timeSlider
                    enabled: !UPnP.isBroadcast(getCurrentTrack())

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - durationLabel.width //- progressLabel.width
                    //anchors.left: parent.left
                    //anchors.right: parent.right

                    onPressedChanged: {
                        if(pressed) // only act on release
                            return
                        audio.seek(value);
                    }
                    to: audio.playbackState == Audio.PlayingState
                           ? audio.duration : 0
                    value: audio.playbackState == Audio.PlayingState
                           ? audio.position : 0
                }

                Text {
                    id: durationLabel
                    font.pixelSize: app.fontSizeSmall
                    anchors.verticalCenter: parent.verticalCenter
                    text: UPnP.getDurationString(audio.duration)
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    width: parent.width
                    font.pixelSize: app.fontSizeMedium
                    color:  app.primaryColor
                    font.weight: Font.Bold
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    text: trackMetaText1
                }
                Text {
                    width: parent.width
                    font.pixelSize: app.fontSizeMedium
                    color: app.secondaryColor
                    font.weight: Font.Bold
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    text: trackMetaText2
                }
            }

            Rectangle { 
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "black"
            }

            Rectangle { 
                anchors.left: parent.left
                anchors.right: parent.right
                height: 4
                opacity: 1.0
            }

        }

        ListModel {
            id: trackListModel
            onCountChanged: refreshTransportState()
        }

        delegate: AdaptiveListItem {
            id: delegate
            width: parent.width - 2*app.paddingMedium
            x: app.paddingMedium
            height: stuff.height

            Column {
                id: stuff
                width: parent.width

                Item {
                    width: parent.width
                    height: tt.height

                    Label {
                        id: tt
                        color: app.primaryColor
                        font.pixelSize: app.fontPixelSizeMedium
                        font.weight: currentItem === index ? Font.Bold: Font.Normal
                        textFormat: Text.StyledText
                        //truncationMode: TruncationMode.Fade
                        width: parent.width - dt.width
                        text: titleText
                    }

                    Label {
                        id: dt
                        anchors.right: parent.right
                        color: app.primaryColor
                        font.weight: currentItem === index ? Font.Bold: Font.Normal
                        font.pixelSize: app.fontSizeSmall
                        text: durationText ? durationText : ""
                    }
                }

                Label {
                    color: app.secondaryColor
                    font.weight: currentItem === index ? Font.Bold: Font.Normal
                    font.pixelSize: app.fontSizeSmall
                    textFormat: Text.StyledText
                    //truncationMode: TruncationMode.Fade
                    width: parent.width
                    visible: metaText ? metaText.length > 0 : false
                    text: metaText
                }

            }

            function openActionMenu() {
                listItemMenu.show(index)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentItem = index
                    loadTrack(trackListModel.get(index))
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }

    ListItemMenu {
        id: listItemMenu

        property ListView listView: listView

        actions: [
            Action {
                text: i18n.tr("Remove")
                onTriggered: {
                    var saveIndex = index
                    trackListModel.remove(index)
                    if(currentItem === saveIndex) {
                        currentItem--
                        next();
                    } else if(currentItem > saveIndex)
                        currentItem--
                }
            }
        ]
    }

    // for internet radio the QT Audio object seems to support some metadata
    Timer {
        interval: 5000;
        running: useBuiltInPlayer && audio.hasAudio && trackClass === UPnP.AudioItemType.AudioBroadcast
        repeat: true
        onTriggered: {
            var title = audio.metaData.title
            var publisher = audio.metaData.publisher
            var logo = audio.metaData.coverArtUrlLarge
            if(!logo)
                logo = audio.metaData.coverArtUrlSmall

            /*if(title !== undefined)
                albumText = title;
            if(publisher !== undefined)
                trackText = publisher;*/

            trackMetaText1 = title ? title : ""
            trackMetaText2 = publisher ? publisher : ""
            updateMprisForTrackMetaData(getCurrentTrack())
            imageItemSource = logo ? logo : defaultImageSource
            cover.updateDisplayData(logo, publisher, trackClass)
        }
    }

    /*Component.onDestruction: {
        console.debug("Destruction of PlayerPage")
        safeLastPlayingInfo()
    }

    function safeLastPlayingInfo() {
        console.debug("PlayerPage safeLastPlayingInfo")
        //mainPage.saveLastPlayingJSON(getCurrentTrack(), audio.position, trackListModel)
    }*/

    function addTracksNoStart(tracks) {
        var i;
        for(i=0;i<tracks.length;i++)
            trackListModel.append(tracks[i])
    }

    function openTrack(track) {
        addTracksNoStart([track])
        currentItem = trackListModel.count - 1
        loadTrack(trackListModel.get(currentItem))
    }

    function addTracks(tracks) {
        addTracksNoStart(tracks)
        if(currentItem == -1 && trackListModel.count>0) {
            if(arguments.length >= 2 && arguments[1] > -1) // is index passed?
                currentItem = arguments[1] - 1 // next will do +1
            if(arguments.length >= 3) // is positiom passed?
                requestedAudioPosition = arguments[2]
            next();
        }
    }

    function getCurrentTrack() {
        if(currentItem < 0 || currentItem >= trackListModel.count)
            return undefined
        return trackListModel.get(currentItem)
    }

    // Format track duration to format like HH:mm:ss / m:ss / 0:ss
    function formatTrackDuration(trackDuration /* track duration in milliseconds */) {
        return UPnP.formatDuration(Math.round(parseInt(trackDuration) / 1000));
    }

}
