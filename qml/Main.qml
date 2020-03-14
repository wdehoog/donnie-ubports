import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtMultimedia 5.9
import QtQuick.Window 2.0
import Qt.labs.settings 1.0 as QLS

import "components"
import "pages"

import "UPnP.js" as UPnP

Window {
    id: app
    objectName: 'mainView'

    property alias settings: settings
    property alias audio: audio

    // for desktop testing
    width: units.dp(480)
    height: units.dp(640)

    // Use these colors for the UI.
    readonly property color fgColor: "#232323"
    readonly property color bgColor: "#efefef"

    property color text1color: "#E95420" // Ubuntu orange
    property color text2color: "#333333" // some dark grey 
    property color text3color: "#aea79f" // some light grey 

    property color primaryColor: text1color
    property color secondaryColor: text2color

    property int fontPixelSizeLarge: units.dp(14)
    property int fontPixelSizeMedium: units.dp(12)
    property int fontPixelSizeSmall: units.dp(10)
    property int fontPixelSizeExtraSmall: units.dp(8)

    property int fontSizeLarge: fontPixelSizeLarge
    property int fontSizeMedium: fontPixelSizeMedium 
    property int fontSizeSmall: fontPixelSizeSmall
    property int fontSizeExtraSmall: fontPixelSizeExtraSmall

    //
    // UI stuff
    //
    property double paddingSmall: units.dp(4)
    property double paddingMedium: units.dp(8)
    property double paddingLarge: units.dp(16)

    property double iconSizeSmall: units.dp(16)
    property double iconSizeMedium: units.dp(32)
    property double iconSizeLarge: units.dp(80)

    property double itemSizeMedium: units.dp(32)
    property double itemSizeLarge: units.dp(80)

    property color normalBackgroundColor: "white" // theme.palette.normal.base
    property color highlightBackgroundColor: "#CDCDCD" // theme.palette.highlited.base

    property var fontPrimaryWeight: Font.Light
    property var fontHighlightWeight: Font.Bold

    property color popupBackgroundColor: "#111111"
    property double popupBackgroundOpacity: 0.1
    property double popupRadius: units.dp(8)

    title: i18n.tr("Donnie")
    visible: true

    StackView {
        id: pageStack
        anchors {
            bottom: playerArea.top
            fill: undefined
            left: parent.left
            right: parent.right
            top: parent.top
        }
        clip: true

        Component.onCompleted: {
            pageStack.push(Qt.resolvedUrl("pages/Menu.qml"))
            showConfirmDialog("test confirm title", "test confirm text", function() {console.log("confirmed!")})
        }
    }

    PlayerArea {
        id: playerArea
        height: visible ? childrenRect.height : 0
        audio: audio
        visible: pageStack.currentItem.objectName != "PlayerPage"
        trackMetaText1: getPlayerPage().trackMetaText1
        trackMetaText2: getPlayerPage().trackMetaText2
        imageSource: app.getPlayerPage().imageItemSource
        onPlayPause: app.playPause()
    }

    signal previous()
    signal next()

    signal audioBufferFull()
    onAudioBufferFull: play()

    Audio {
        id: audio

        autoLoad: true
        autoPlay: false
        //source: channelStreamUrl

        onError: {
            console.log("Audio Player error:" + errorString)
            console.log("source: " + source)
            showErrorDialog(i18n.tr("Audio Player:") + "\n\n" + errorString)
        }
    }

    function playPause() {
        console.log("pause() audio.source:" + audio.source)
        if(audio.playbackState === Audio.PlayingState)
            audio.pause()
        else
          audio.play()
    }
    
    function doSelectedMenuItem(id) {
        switch(id) {
            case "upnp-discovery": 
                pageStack.push(Qt.resolvedUrl("pages/Discovery.qml"))
                break
            case "upnp-browse": 
                pageStack.push(Qt.resolvedUrl("pages/Browse.qml"), {cid: "0"})
                break
            case "builtin-player": 
                pageStack.push(playerpage)
                break
        }
    }

    // trial and error and interweb
    function gu(value) {
        return units.dp(8) * value
    }

    function error(msg) {
        console.log("error: " + msg)
        //errorLog.push(msg);
    }

    PlayerPage {
        id: playerpage
        visible: false
        audio: audio
    }

    function getPlayerPage() {
        return playerpage
    }

    property var discoveredRenderers : []
    property var discoveredServers : []
    property var currentBrowseStack : new UPnP.dataStructures.Stack()
    property var currentServer
    property var currentRenderer
    property var currentServerSearchCapabilities
    property bool useBuiltInPlayer: true

    function hasCurrentServer() {
        return app.currentServer ? true : false
    }

    function setCurrentServer(server) {
        app.currentServer = server;
        console.log("setCurrentServer to: "+ currentServer["friendlyName"]);
        var res = upnp.setCurrentServer(currentServer["friendlyName"], true);
        currentServerSearchCapabilities = [];
        if(res) {
            try {
                var i
                var scapJson = upnp.getSearchCapabilitiesJson();
                console.log(scapJson);
                var allSearchCaps = JSON.parse(scapJson);
                // minidlna worked well but minimserver returned some search capabilities that
                // when used the query made it return an error
                // things like: @refID, upnp:class, upnp:artist[@role="AlbumArtist"]
                for(i=0;i<allSearchCaps.length;i++) {
                    if(allSearchCaps[i] !== "upnp:class"
                       && allSearchCaps[i].indexOf('@') < 0)
                        currentServerSearchCapabilities.push(allSearchCaps[i]);
                }
            } catch( err ) {
                app.error("Exception while getting Search Capabilities: " + err);
                app.error("json: " + scapJson);
            }
        } else {
            error("Failed to set Current Server to: "+ currentServer["friendlyName"]);
        }
        return res;
    }

    function hasCurrentRenderer() {
        return app.currentRenderer ? true : false;
    }

    function setCurrentRenderer(renderer) {
        app.currentRenderer = renderer;

        if(renderer === undefined) {
            rendererPage.reset();
            return;
        }

        console.log("setCurrentRenderer to: "+ currentRenderer["friendlyName"]);
        var res = upnp.setCurrentRenderer(currentRenderer["friendlyName"], true);
        if(!res) {
            rendererPage.reset();
            error("Failed to set Current Renderer to: "+ currentRenderer["friendlyName"]);
        }
        return res;
    }

    function searchForRendererAndServer() {
        var started = false
        // check if configured renderer and server can be reached
        if(settings.renderer_friendlyname && settings.renderer_udn !== "donnie-player-udn") {
            upnp.getRendererJson(settings.renderer_friendlyname, settings.search_window)
            started = true
        }
        else if(settings.renderer_friendlyname && settings.renderer_udn === "donnie-player-udn")
            app.useBuiltInPlayer = true
        if(settings.server_friendlyname) {
            upnp.getServerJson(settings.server_friendlyname, settings.search_window)
            started = true
        }
        //showBusy = started
    }
    
    Component.onCompleted: searchForRendererAndServer()

    Connections {
        target: upnp

        onGetRendererDone: {
            var i;

            try {
                var devices = JSON.parse(rendererJson);

                if(devices["renderer"] && devices["renderer"].length>0)
                    app.setCurrentRenderer(devices["renderer"][0]);
            } catch(err) {
                app.error("Exception in onGetRendererDone: "+err);
                app.error("json: " + rendererJson);

            }

            //showBusy = false; // VISIT both should be done
        }

        onGetServerDone: {
            var i;

            try {
                var devices = JSON.parse(serverJson);

                if(devices["server"] && devices["server"].length>0)
                    app.setCurrentServer(devices["server"][0]);
            } catch(err) {
                app.error("Exception in onGetServerDone: "+err);
                app.error("json: " + serverJson);
            }

            //showBusy = false; // VISIT both should be done

            if(app.hasCurrentServer()) {
                if(settings.resume_saved_info === 1) // 0: never, 1: ask, 2:always
                    app.showConfirmDialog(i18n.tr("Load previously saved queue?"), i18n.tr("Load"), function() {
                        loadResumeMetaData()
                    })
                else if(settings.resume_saved_info === 2)
                    loadResumeMetaData()
            }
        }

        onError: {
            console.log("Main::onError: " + msg);
            app.error(msg);
            //showBusy = false; // VISIT only one could fail
        }
    }

    function saveLastBrowsingJSON() {
        var i
        var browseStackIds = []
        for(i=1;i<currentBrowseStack.length();i++)
            browseStackIds.push(currentBrowseStack.elements()[i].id)
        settings.last_browsing_info = JSON.stringify(browseStackIds)
    }

    function saveLastPlayingJSON(currentTrack, trackListModel) {
        /*
          info.currentTrackId
          info.queueTrackIds[]
         */
        var i
        var lastPlayingInfo = {}
        lastPlayingInfo.currentTrackId = currentTrack.id
        lastPlayingInfo.queueTrackIds = []
        for(i=0;i<trackListModel.count;i++) {
            var item = trackListModel.get(i)
            var info
            if(item.dtype === UPnP.DonnieItemType.ContentServer)
                info = { dtype: "cs", data: item.id}
            else
                info = { dtype: "ud", data: { title: item.title, uri: item.uri, streamType: item.upnpclass}}
            lastPlayingInfo.queueTrackIds.push(info)
        }
        settings.last_playing_info = JSON.stringify(lastPlayingInfo)
    }

    //
    // Dialogs
    //

    Component {
        id: dialogFactory

        Dialog {
            id: dialog

            property string messageTitle: ""
            property string messageText: ""
            property bool confirmation: false
            property var acceptedCallback: null

            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            title: messageTitle
            standardButtons: confirmation ? Dialog.Yes | Dialog.No : Dialog.Ok
            modal: true
           
            Label {
                text: dialog.messageText
            }

            onAccepted: {
                if(acceptedCallback != null)
                    acceptedCallback()
            }
        }
    }

    function showConfirmDialog(title, text, callback) {
        var dialog = dialogFactory.createObject(app, { 
            messageTitle: title, 
            messageText: text, 
            confirmation: true, 
            acceptedCallback: callback
        })
        dialog.open()
    }

    function showMessageDialog(title, text) {
        var dialog = dialogFactory.createObject(app, { 
            messageTitle: title, 
            messageText: text, 
            confirmation: false, 
        })
        dialog.open()
    }

    function showErrorDialog(text) {
        showMessageDialog(i18n.tr("Error"), text)
    }

    //
    // Settings
    //
    QLS.Settings {
        id: settings

        property int search_window: 5
        property int max_number_of_results: 200
        property string server_udn : ""
        property string server_friendlyname : ""
        property string server_use_nexturi : ""
        property string renderer_udn : ""
        property string renderer_friendlyname : ""
        property string last_browsing_info: ""
        property string last_playing_info: ""
        property int last_playing_position: 0
        property int resume_saved_info: 0
    }
}
