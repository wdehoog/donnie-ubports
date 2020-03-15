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

Page {
    id: page
    property bool showBusy : false

    //allowedOrientations: Orientation.All

    header: PageHeader {
        id: pHeader
        title: qsTr("UPnP Devices")
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

        /*
        section {
            property: "type"
            criteria: ViewSection.FullString
            delegate: SectionHeader {
                text: {
                    switch(section) {
                    case "Renderer": return qsTr("Renderer")
                    case "Content Server": return qsTr("Content Server")
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

            Switch {
                id: checkbox
                checked: selected
                //automaticCheck: false
                anchors {
                    right: parent.right;
                    rightMargin: app.horizontalPageMargin
                    //verticalCenter: listItem.verticalCenter
                }

                onClicked: {
                    var device = devicesModel.get(index);

                    // clear current choice
                    for(var i=0;i<devicesModel.count;i++) {
                        if(devicesModel.get(i).type === device.type)
                            devicesModel.set(i, { "selected": false })
                    }

                    // update for new choice
                    devicesModel.set(index, { "selected": true })
                    if(device.type === "Content Server") {
                        app.setCurrentServer(app.discoveredServers[device.discoveryIndex]);
                        storeSelectedServer(device);
                    } else {
                        if(device.UDN === "donnie-player-udn") {
                            app.useBuiltInPlayer = true;
                            app.setCurrentRenderer(undefined);
                        } else {
                            app.useBuiltInPlayer = false;
                            app.setCurrentRenderer(app.discoveredRenderers[device.discoveryIndex]);
                        }
                        storeSelectedRenderer(device);
                    }

                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
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
                    friendlyName: qsTr("Built-in Player"),
                    manufacturer: "donnie",
                    modelName: qsTr("QTAudio Player"),
                    UDN: "donnie-player-udn",
                    URLBase: "",
                    deviceType: qsTr("a page with audio player controls and list of tracks"),
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
                    var server = app.discoveredServers[i];
                    selected = server["UDN"] === app.settings.server_udn;
                    if(selected) {
                        app.setCurrentServer(server);
                        updateSelectedServer(server["friendlyName"]);
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
                        deviceType: server["deviceType"],
                        selected: selected
                    });
                }
                if(!hasSelected && app.discoveredServers.length>0) {
                    // if no server is selected select the first one
                    app.setCurrentServer(app.discoveredServers[0]);
                    var firstIndex = app.discoveredRenderers?app.discoveredRenderers.length+1:1;
                    devicesModel.set(firstIndex, { "selected": true });
                    storeSelectedServer(devicesModel.get(firstIndex));
                }
            } catch(err) {
                app.error("Exception in Discovery: "+err);
                app.error("json: " + devicesJson);
            }
            showBusy = false;
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


