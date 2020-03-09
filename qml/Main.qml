import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtMultimedia 5.9
import QtQuick.Window 2.0
import Qt.labs.settings 1.0 as QLS

import "components"

Window {
    id: app
    objectName: 'mainView'

    property alias settings: settings

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

    property int fontSizeLarge: fontPixelSizeLarge
    property int fontSizeMedium: fontPixelSizeMedium 
    property int fontSizeSmall:  fontPixelSizeSmall

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
            //showMessageDialog("Test", "Hello")
        }
    }

    PlayerArea {
        id: playerArea
        height: visible ? childrenRect.height : 0
    }

    signal previous()
    signal next()

    signal audioBufferFull()
    onAudioBufferFull: play()

    Audio {
        id: audio

        autoLoad: true
        autoPlay: true
        //source: channelStreamUrl

        onPlaybackStateChanged: playerArea.audioPlaybackState = playbackState

        onError: {
            console.log("Audio Player error:" + errorString)
            console.log("source: " + source)
            showErrorDialog(qsTr("Audio Player:") + "\n\n" + errorString)
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
            case "upnp-browser": 
                pageStack.push(Qt.resolvedUrl("pages/Browser.qml"))
                break
        }
    }

    function showMessageDialog(title, text) {
        var component = Qt.createComponent("components/MessageDialog.qml")
        var msgDialog = component.createObject(app, {})
        msgDialog.msgTitle = title
        msgDialog.msgText = text
        msgDialog.accepted.connect(function() { msgDialog.destroy() })
        msgDialog.open()
    }

    function showErrorDialog(text) {
        showMessageDialog(i18n.tr("Error"), text)
    }

    // trial and error and interweb
    function gu(value) {
        return units.dp(8) * value
    }

    function error(msg) {
        console.log("error: " + msg);
        //errorLog.push(msg);
    }

    property var discoveredRenderers : [];
    property var discoveredServers : [];
    property var currentServer
    property var currentRenderer
    property var currentServerSearchCapabilities
    property bool useBuiltInPlayer: true;
    function hasCurrentServer() {
        return app.currentServer ? true : false;
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
                if(resume_saved_info.value === 1) // 0: never, 1: ask, 2:always
                    app.showConfirmDialog(qsTr("Load previously saved queue?"), qsTr("Load"), function() {
                        loadResumeMetaData()
                    })
                else if(resume_saved_info.value === 2)
                    loadResumeMetaData()
            }
        }

        onError: {
            console.log("Main::onError: " + msg);
            app.error(msg);
            //showBusy = false; // VISIT only one could fail
        }
    }

    //
    //
    //
    QLS.Settings {
        id: settings

        property int search_window: 5
        property string server_udn : ""
        property string server_friendlyname : ""
        property string server_use_nexturi : ""
        property string renderer_udn : ""
        property string renderer_friendlyname : ""
    }
}
