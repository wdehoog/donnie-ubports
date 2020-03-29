/**
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */


import Ergo 0.0

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../components"
import "../controls"

Page {
    id: page
    property bool showBusy : false

    //allowedOrientations: Orientation.All

    header: PageHeader {
        id: pHeader
        title: i18n.tr("UPnP Devices")
        trailingActions: [
            Action {
                iconName: "reload"
                text: i18n.tr("Reload")
                onTriggered: discover()
            }
        ]
    }


    ListModel {
      id: devicesModel;
    }

    ListView {
        id: devicesList
        model: devicesModel;

        anchors.fill: parent
        interactive: contentHeight > height
        spacing: units.dp(8)

        header: Rectangle {
            width: parent.width
            height: app.paddingMedium
            opacity: 1.0
        }
        /*
        section {
            property: "type"
            criteria: ViewSection.FullString
            delegate: SectionHeader {
                text: {
                    switch(section) {
                    case "Renderer": return i18n.tr("Renderer")
                    case "Content Server": return i18n.tr("Content Server")
                    default: return section
                    }
                }
            }
        }*/

        delegate: AdaptiveListItem {
            id: listItem
            height: icolumn.height

            anchors {
                left: parent.left
                right: parent.right
                margins: app.paddingLarge
            }

            Column {
                id: icolumn
                anchors {
                    left: parent.left
                    right: checkbox.left
                }

                Text {
                    id: fName

                    font.pixelSize: app.fontSizeMedium
                    color: app.primaryColor
                    wrapMode: Text.Wrap
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    text: friendlyName
                }

                Text {
                    id: mName

                    //anchors.top: fName.bottom
                    font.pixelSize: app.fontSizeSmall
                    color: app.secondaryColor
                    wrapMode: Text.Wrap
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    text: modelName
                }
            }

            MyCheckBox {
                id: checkbox
                width: height
                height: app.checkBoxHeight
                anchors {
                    right: parent.right
                    rightMargin: app.horizontalPageMargin
                }
                enabled: app.discoveredServers.length > 1   
                checked: UDN == app.settings.server_udn
                onClicked: {
                    //console.log("onClicked")
                    var device = devicesModel.get(index)

                    // clear current choice
                    for(var i=0;i<devicesModel.count;i++) {
                        if(devicesModel.get(i).type === device.type)
                            devicesModel.set(i, { "selected": false })
                    }

                    // update for new choice
                    if(device.type === "Content Server") {
                        app.setCurrentServer(app.discoveredServers[device.discoveryIndex])
                        storeSelectedServer(device)
                    /*} else {
                        if(device.UDN === "donnie-player-udn") {
                            app.useBuiltInPlayer = true
                            app.setCurrentRenderer(undefined)
                        } else {
                            app.useBuiltInPlayer = false
                            app.setCurrentRenderer(app.discoveredRenderers[device.discoveryIndex])
                        }
                        storeSelectedRenderer(device)*/
                    }

                }
            }

            // I am getting crazy. For some reason the mouse events on the checkbox 
            // are never triggered. So I use this mousearea to mimic them.
            MouseArea {
                width: parent.width// - checkbox.width
                height: parent.height
                x:0
                y:0
                onClicked: {
                    if(mouse.x > (parent.width - checkbox.width)) {
                        checkbox.clicked()
                    } else {  
                        var item = devicesList.model.get(index)
                        app.showMessageDialog(i18n.tr("Device Details"),
                            "Type: " + item.type +
                            "\nName: " + item.friendlyName +
                            "\nMan.: " + item.manufacturer +
                            "\nModel: " + item.modelName +
                            "\nUDN: " + item.UDN +
                            "\nURL: " + item.URLBase +
                            "\nDev.Type: " + item.deviceType)
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}

    }

    Component.onCompleted: {
        discover();
    }

    Connections {
        target: upnp
        onDiscoveryDone: {
            var i;

            try {
                var devices = JSON.parse(devicesJson);

                app.discoveredRenderers = devices["renderers"];
                app.discoveredServers = devices["servers"];

                devicesModel.clear();
                var selected;
                var hasSelected = false;

                /* currently there is no support for renderers
                for(i=0;i<app.discoveredRenderers.length;i++) {
                    var renderer = app.discoveredRenderers[i];
                    selected = renderer["UDN"] === app.settings.renderer_udn;
                    if(selected) {
                        app.setCurrentRenderer(renderer);
                        updateSelectedRenderer(renderer["friendlyName"]);
                        hasSelected = true;
                    }
                    devicesModel.append({
                        type: "Renderer",
                        discoveryIndex: i,
                        friendlyName: renderer["friendlyName"],
                        manufacturer: renderer["manufacturer"],
                        modelName: renderer["modelName"],
                        UDN: renderer["UDN"],
                        URLBase: renderer["URLBase"],
                        deviceType: renderer["deviceType"],
                        selected: selected
                    });
                }

                // add local player
                selected = "donnie-player-udn" === app.settings.renderer_udn;
                if(selected)
                    hasSelected = true;
                devicesModel.append({
                    type: "Renderer",
                    discoveryIndex: app.discoveredRenderers.length,
                    friendlyName: i18n.tr("Built-in Player"),
                    manufacturer: "donnie",
                    modelName: i18n.tr("QTAudio Player"),
                    UDN: "donnie-player-udn",
                    URLBase: "",
                    deviceType: i18n.tr("a page with audio player controls and list of tracks"),
                    selected: selected
                });

                // make sure one player is selected
                if(!hasSelected) {
                    // if no renderer is selected select the first one
                    devicesModel.set(0, { "selected": true });
                    storeSelectedRenderer(devicesModel.get(0));
                    if(app.discoveredRenderers.length>0)
                        app.setCurrentRenderer(app.discoveredRenderers[0]);
                    else
                        app.useBuiltInPlayer = true;
                }*/

                hasSelected = false;
                for(i=0;i<app.discoveredServers.length;i++) {
                    var server = app.discoveredServers[i]
                    selected = server["UDN"] === app.settings.server_udn
                    //console.log("UDN:"+server.UDN +", app:"+app.settings.server_udn)
                    if(selected) {
                        app.setCurrentServer(server)
                        updateSelectedServer(server["friendlyName"])
                        hasSelected = true;
                    }
                    devicesModel.append({
                        type: "Content Server",
                        discoveryIndex: i,
                        friendlyName: server["friendlyName"],
                        manufacturer: server["manufacturer"],
                        modelName: server["modelName"],
                        UDN: server["UDN"],
                        URLBase: server["URLBase"],
                        deviceType: server["deviceType"]
                    })
                }
                if(!hasSelected && app.discoveredServers.length>0) {
                    // if no server is selected select the first one
                    app.setCurrentServer(app.discoveredServers[0])
                    storeSelectedServer(devicesModel.get(firstIndex))
                }
            } catch(err) {
                app.error("Exception in Discovery: "+err)
                app.error("json: " + devicesJson)
            }
            showBusy = false
        }
    }

    function discover() {
        showBusy = true;
        upnp.discover(app.settings.search_window);
    }

    function storeSelectedRenderer(device) {
        app.settings.renderer_udn = device.UDN;
        app.settings.renderer_friendlyname = device.friendlyName;
    }

    function updateSelectedRenderer(friendlyName) {
        app.settings.renderer_friendlyname = friendlyName;
    }

    function storeSelectedServer(device) {
        app.settings.server_udn = device.UDN;
        app.settings.server_friendlyname = device.friendlyName;
    }

    function updateSelectedServer(friendlyName) {
        app.settings.server_friendlyname = friendlyName;
    }

}


