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
    property alias trackListModel: trackListModel
    property alias trackListView: listView

    property string defaultImageSource : "image://theme/stock_music"
    property string imageItemSource : defaultImageSource
    property string playIconName : "media-preview-start"
    property int currentIndex: -1
    property var currentItem: UPnP.createNewListItem("Item")
    property bool metaShown : false
    property string trackClass
    property string durationText
    property string positionText

    property string trackMetaText1 : ""
    property string trackMetaText2 : ""

    property bool hasTracks : listView.model.count > 0
    property bool canNext: hasTracks && (currentIndex < (listView.model.count - 1))
    property bool canPrevious: hasTracks && (currentIndex > 0)
    property bool canPlay: hasTracks && (audio.playbackState != Audio.PlayingState)
    property bool canPause: audio.playbackState == Audio.PlayingState
    property int requestedAudioPosition : -1

    // 1 playing, 2 paused, the rest inactive
    property int transportState : -1

    header: PageHeader {
        title: i18n.tr("Built-In Player")
        trailingActions: [
            Action {
                iconName: "toolkit_input-clear"
                text: i18n.tr("Empty List")
                onTriggered: clearList()
                color: app.disableErgoActionColor
            }
        ]
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
        //console.log("RTS: count:" + listView.model.count+", currentIndex"+currentIndex+", hasTracks: "+hasTracks+", canNext: "+canNext)
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

            //if(audio.status == Audio.EndOfMedia) {
            //    next();
            //}
        }

        onPlaybackStateChanged: refreshTransportState()
        onSourceChanged: refreshTransportState()
        /*onBufferProgressChanged: {
            if(audio.bufferProgress == 1.0) {
                //play()
                updatePlayIcons()
            }
        }*/
    }

    Connections {
        target: app.audio.playlist
        onCurrentIndexChanged: {
            console.log("PlayList currentIndex changed: " + target.currentIndex)
            updateForTrack(audio.playlist.currentIndex)
        }
        onErrorChanged: {
            app.showErrorDialog(i18n.tr("Playlist") + ": " + audio.playlist.errorString)
        }
        onItemChanged: console.log("playlist.onItemChanged("+start+","+end+")")
        onItemInserted: console.log("playlist.onItemInserted("+start+","+end+")")
        onItemRemoved: console.log("playlist.onItemRemoved("+start+","+end+")")
    }

    function next() {
        console.log("PlayerPage.next() currentIndex=" + audio.playlist.currentIndex)
        if(audio.playlist.currentIndex >= (audio.playlist.itemCount-1))
            return;
        audio.playlist.next()
    }

    function prev() {
        console.log("PlayerPage.prev() currentIndex=" + audio.playlist.currentIndex)
        if(audio.playlist.currentIndex <= 0)
            return;
        audio.playlist.previous()
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

    function gotoTrack(track) {
        var i
        for(i=0;i<audio.playlist.itemCount;i++) {
            if(audio.playlist.itemSource(i) == track.uri) {
                audio.playlist.currentIndex = i
                break
            }
        }
    }

    function loadTrack(track) {
        //console.log("loadTrack: " + JSON.stringify(track))
        audio.playlist.clear()
        audio.playlist.addItem(track.uri)
        audio.play()
    }

    function updateForTrack(index) {
        currentIndex = index
        console.log("updateForTrack("+currentIndex+")")
        if(index < 0 || index >= trackListModel.count) {
            trackMetaText1 = ""
            trackMetaText2 = ""
            trackClass = ""
            durationText = ""
            positionText = ""
            imageItemSource = defaultImageSource
            currentItem = UPnP.createNewListItem("Item")
        } else {
            var track = trackListModel.get(index)
            //console.log("updateForTrack: " + JSON.stringify(track,null,2))
            currentItem = track
            updatePlayIcons()

            trackMetaText1 = track.titleText
            trackMetaText2 = track.metaText 
            trackClass = track.upnpclass
            durationText = track.durationText
            imageItemSource = track.albumArtURI ? track.albumArtURI : defaultImageSource

            //updateMprisForTrack(track)
            app.saveLastPlayingJSON(track, trackListModel)
        }
    }

    function clearList() {
        stop()
        //audio.source = "" causes Audio to throw error 'Resource cannot be ...'
        audio.playlist.clear()
        listView.model.clear()
        updateForTrack(-1)
    }

    function updatePlayIcons() {
        if(audio.playbackState == Audio.PlayingState) {
            playIconName = "media-preview-pause"
        } else {
            playIconName =  "media-preview-start"
        }
    }

    /*function updateMprisForTrackMetaData(track) {
        var meta = {};
        meta.Title = trackMetaText1;
        meta.Artist = trackMetaText2;
        meta.Album = track.album;
        meta.Length = 0;
        meta.ArtUrl = track.albumArtURI;
        meta.TrackNumber = currentIndex;
        app.updateMprisMetaData(meta);
    }

    function updateMprisForTrack(track) {
        var meta = {};
        meta.Title = trackMetaText1;
        meta.Artist = trackMetaText2;
        meta.Album = track.album;
        meta.Length = track.duration * 1000; // ms -> us
        meta.ArtUrl = track.albumArtURI;
        meta.TrackNumber = currentIndex;
        app.updateMprisMetaData(meta);
    }*/

    ListView {
        id: listView
        model: trackListModel
        width: parent.width
        anchors.fill: parent


        header: Column {
            x: app.paddingMedium
            width: parent.width - 2*x

            Rectangle {
                width: parent.width
                height:app.paddingLarge
                color: app.bgColor
                opacity: 1.0
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
                    width: parent.width * 2 / 3
                    height: width
                    fillMode: Image.PreserveAspectFit
                }

                Column {
                  id: playerButtons

                  anchors.verticalCenter: parent.verticalCenter
                  spacing: app.paddingMedium
                  width: parent.width - imageItem.width

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
                height: app.paddingMedium
                color: app.bgColor
                opacity: 1.0
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
                        audio.seek(value)
                    }
                    to: audio.duration
                    value: audio.position
                }

                Text {
                    id: durationLabel
                    font.pixelSize: app.fontSizeSmall
                    anchors.verticalCenter: parent.verticalCenter
                    text: positionText
                }
            }

            Rectangle {
                width: parent.width
                height: app.paddingMedium
                color: app.bgColor
                opacity: 1.0
            }

            PlaylistItem {
                id: stuff
                index: currentIndex
                title: trackMetaText1
                meta: trackMetaText2
                duration: durationText
            }

            Rectangle {
                width: parent.width
                height: app.paddingMedium
                color: app.bgColor
                opacity: 1.0
            }

            Rectangle {
                width: parent.width
                height: 1
                color: app.controlBorderColor
            }

            Rectangle {
                width: parent.width
                height: app.paddingMedium
                color: app.bgColor
                opacity: 1.0
            }

        }

        ListModel {
            id: trackListModel
            onCountChanged: refreshTransportState()
        }

        delegate: AdaptiveListItem {
            id: delegate
            x: app.paddingMedium
            width: parent.width - 2*x
            height: stuff.height + 2*app.paddingSmall

            PlaylistItem {
                id: stuff
                anchors.verticalCenter: parent.verticalCenter

                index: model.index
                title: titleText
                meta: metaText
                duration: durationText
            }

            function openActionMenu() {
                listItemMenu.show(index)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    currentIndex = index
                    gotoTrack(trackListModel.get(index))
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
                        + (trackListModel.count > 0 && listItemMenu.index >= 0 
                           ? " " + trackListModel.get(listItemMenu.index).titleText 
                           : "")
                onTriggered: {
                    trackListModel.remove(listItemMenu.index)
                    audio.playlist.removeItem(listItemMenu.index)
                    if(currentIndex === listItemMenu.index) {
                        currentIndex--
                        next()
                    } else if(currentIndex > listItemMenu.index)
                        currentIndex--
                }
            }
        ]
    }

    Timer {
        interval: 1000
        running: useBuiltInPlayer
                 && audio.hasAudio
                 && trackClass === UPnP.AudioItemType.MusicTrack
        repeat: true
        onTriggered: {
            positionText = UPnP.getDurationString(audio.position)
        }
    }

    // for internet radio the QT Audio object seems to support some metadata
    Timer {
        interval: 5000;
        running: useBuiltInPlayer
                 && audio.hasAudio
                 && trackClass === UPnP.AudioItemType.AudioBroadcast
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
            //updateMprisForTrackMetaData(getCurrentTrack())
            imageItemSource = logo ? logo : defaultImageSource
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
        var i
        var uris = []
        for(i=0;i<tracks.length;i++) {
            trackListModel.append(tracks[i])
            uris[i] = tracks[i].uri
        }
        audio.playlist.addItems(uris)
    }

    function openTrack(track) {
        addTracksNoStart([track])
        currentIndex = trackListModel.count - 1
        gotoTrack(trackListModel.get(currentIndex))
    }

    function addTracks(tracks) {
        addTracksNoStart(tracks)
        if(currentIndex == -1 && trackListModel.count>0) {
            if(arguments.length >= 2 && arguments[1] > -1) { // is index passed?
                audio.playlist.currentIndex = arguments[1]
                if(arguments.length >= 3) // is position passed?
                    requestedAudioPosition = arguments[2]
            }
        }
    }

    function replaceTracks(tracks) {
        var isPlaying = canPause
        clearList()
        addTracks(tracks)
        if(isPlaying)
            play()
    }

    function getCurrentTrack() {
        if(currentIndex < 0 || currentIndex >= trackListModel.count)
            return undefined
        return trackListModel.get(currentIndex)
    }

    // Format track duration to format like HH:mm:ss / m:ss / 0:ss
    function formatTrackDuration(trackDuration /* track duration in milliseconds */) {
        return UPnP.formatDuration(Math.round(parseInt(trackDuration) / 1000));
    }

}
