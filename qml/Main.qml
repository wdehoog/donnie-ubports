import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import QtMultimedia 5.9
import QtQuick.Window 2.0

import "components"

Window {
    id: app
    objectName: 'mainView'
    //applicationName: 'donnie.wdehoog'
    //automaticOrientation: true

    // for desktop testing
    width: units.dp(480)
    height: units.dp(640)

    // Use these colors for the UI.
    //readonly property color bgColor: "#232323"
    //readonly property color fgColor: "#efefef"
    readonly property color fgColor: "#232323"
    readonly property color bgColor: "#efefef"

    property color text1color: "#E95420" // Ubuntu orange
    property color text2color: "#333333" // some dark grey 
    property color text3color: "#aea79f" // some light grey 

    property int fontPixelSizeLarge: units.dp(14)
    property int fontPixelSizeMedium: units.dp(12)
    property int fontPixelSizeSmall: units.dp(10)

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
            pageStack.push(mainPage)
            //showMessageDialog("Test", "Hello")
        }
    }

    Page {
        id: mainPage

        header: PageHeader {
            id: header
            title: 'Donnie'
            trailingActions: [
                Action {
                    iconName: "info"
                    //color: "white"
                    text: i18n.tr("About")
                    onTriggered: pageStack.push(Qt.resolvedUrl("pages/AboutPage.qml") )
                },
                Action {
                    iconName: "reload"
                    //color: app.fgColor
                    text: i18n.tr("Reload")
                    onTriggered: reload()
                }
            ]
        }

        Label {
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            text: i18n.tr('Hello World!')

            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
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
    
    function reload() {
        //channelsModel.reload()
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
}
