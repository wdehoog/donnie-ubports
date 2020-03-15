/**
 * Donnie. Copyright (C) 2020 Willem-Jan de Hoog
 *
 * License: MIT
 */

import Ergo 0.0

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../components"

import "../UPnP.js" as UPnP


Page {
    id: searchPage

    property bool keepSearchFieldFocus: true
    property bool showBusy: false;
    property string searchString: ""
    property int startIndex: 0
    property int maxCount: app.settings.max_number_of_results
    property int totalCount
    property bool allowContainers : app.settings.search_allow_containers
    property var searchResults
    property var searchCapabilities: []
    property int selectedSearchCapabilitiesMask: app.settings.selected_search_capabilities
    property var scMap: []
    //property string groupByField: app.settings.groupby_search_results

    header: PageHeader {
        title: i18n.tr("Search")
    }

    BusyIndicator {
        id: busyThingy
        anchors.centerIn: parent
        width: itemSizeLarge
        height: width
        running: showBusy;
    }

    ListModel {
        id: searchModel
    }

    ListView {
        id: listView
        model: searchModel
        anchors.fill: parent
        anchors {
            topMargin: 0
            bottomMargin: 0
        }

        header: Column {
            id: lvColumn

            width: parent.width - 2*x
            x: app.paddingMedium
            anchors.bottomMargin: app.paddingLarge
            spacing: app.paddingLarge

            /*PullDownMenu {
               MenuItem {
                    text: i18n.tr("Load Previous Set")
                    enabled: searchString.length >= 1
                             && selectedSearchCapabilitiesMask > 0
                             && startIndex >= maxCount
                    onClicked: {
                        searchModel.clear();
                        searchMore(startIndex-maxCount);
                    }
                }
                MenuItem {
                    text: i18n.tr("Load Next Set")
                    enabled: searchString.length >= 1
                             && selectedSearchCapabilitiesMask > 0
                             && (startIndex + searchModel.count) < totalCount
                    onClicked: {
                        searchModel.clear();
                        searchMore(startIndex+maxCount);
                    }
                }
                MenuItem {
                    text: i18n.tr("Load More")
                    enabled: searchString.length >= 1
                             && selectedSearchCapabilitiesMask > 0
                             && searchModel.count < totalCount
                    onClicked: searchMore(startIndex+maxCount);
                }
            }

            PushUpMenu {
                MenuItem {
                    text: i18n.tr("Load More")
                    enabled: searchString.length >= 1
                             && selectedSearchCapabilitiesMask > 0
                             && searchModel.count < totalCount
                    onClicked: searchMore(startIndex+maxCount);
                }
                MenuItem {
                    text: i18n.tr("Load Next Set")
                    enabled: searchString.length >= 1
                             && selectedSearchCapabilitiesMask > 0
                             && (startIndex + searchModel.count) < totalCount
                    onClicked: {
                        searchModel.clear();
                        searchMore(startIndex+maxCount);
                    }
                }
                MenuItem {
                     text: i18n.tr("Load Previous Set")
                     enabled: searchString.length >= 1
                              && selectedSearchCapabilitiesMask > 0
                              && startIndex >= maxCount
                     onClicked: {
                         searchModel.clear();
                         searchMore(startIndex-maxCount);
                     }
                 }
            }*/

            Rectangle { height: units.dp(4); width: parent.width; opacity: 1.0 }
            Row {
                width: parent.width
                Icon {
                    id: sfIcon
                    height: searchField.height
                    width: height
                    name: "find"
                }
                TextField {
                    id: searchField
                    width: parent.width - sfIcon.width
                    placeholderText: i18n.tr("Search for")
                    inputMethodHints: Qt.ImhNoPredictiveText

                    Binding {
                        target: searchPage
                        property: "searchString"
                        value: searchField.text.toLowerCase().trim()
                    }
                    Keys.onReturnPressed: refresh()
                }
            }

            /* Which fields to search in */
            Button {
                property var indexes: []
                property string value: ""

                width: parent.width

                text: i18n.tr("Search In")

                ListModel {
                    id: items
                }

                Component.onCompleted: {
                    var c = 0;
                    value = i18n.tr("None")
                    indexes = []
                    items.clear()

                    // load capabilities
                    for (var u=0;u<searchCapabilities.length;u++) {
                        var scapLabel = UPnP.geSearchCapabilityDisplayString(searchCapabilities[u])
                        if(scapLabel === undefined)
                            continue

                        items.append( {id: c, name: scapLabel })
                        scMap[c] = u

                        c++
                    }

                    // the selected
                    value = ""
                    for(var i=0;i<scMap.length;i++) {
                        if(selectedSearchCapabilitiesMask & (0x01 << scMap[i])) {
                            var first = value.length == 0;
                            value = value + (first ? "" : ", ") + items.get(i).name
                            indexes.push(i)
                        }
                    }
                }

                onClicked: {
                    var ms = app.pushPage("components/MultiItemPicker.qml", { items: items, title: text, indexes: indexes })
                    ms.accepted.connect(function() {
                        indexes = ms.indexes.sort(function (a, b) { return a - b })
                        selectedSearchCapabilitiesMask = 0
                        if (indexes.length == 0) {
                            value = i18n.tr("None")
                        } else {
                            value = ""
                            var tmp = []
                            selectedSearchCapabilitiesMask = 0
                            for(var i=0;i<indexes.length;i++) {
                                value = value + ((i>0) ? ", " : "") + items.get(indexes[i]).name
                                selectedSearchCapabilitiesMask |= (0x01 << scMap[indexes[i]])
                            }
                        }
                        app.settings.selected_search_capabilities = selectedSearchCapabilitiesMask
                    })
                }

            }

            /* Group by */
            /*ComboBox {
                id: groupBy
                width: parent.width
                label: i18n.tr("Group By")
                currentIndex: {
                    if(groupby_search_results === "album")
                        return 0;
                    if(groupby_search_results === "artist")
                        return 1;
                    if(groupby_search_results === "title")
                        return 2;
                    return -1;
                }
                menu: ContextMenu {
                    MenuItem {
                        text: i18n.tr("Album")
                        onClicked: {
                            groupby_search_results = "album";
                        }
                    }
                    MenuItem {
                        text: i18n.tr("Artist")
                        onClicked: {
                            groupby_search_results = "artist";
                        }
                    }
                    MenuItem {
                        text: i18n.tr("Title")
                        onClicked: {
                            groupby_search_results.value = "title";
                            groupby_search_results.sync();
                        }
                    }
                }
            }*/
        }

        /*section.property : groupByField
        section.delegate : Component {
            id: sectionHeading
            Item {
                width: parent.width - 2*app.paddingMedium
                x: app.paddingMedium
                height: childrenRect.height

                Text {
                    text: section
                    font.bold: true
                    font.pixelSize: app.fontSizeMedium
                    color: app.highlightColor
                }
            }
        }*/

        delegate: AdaptiveListItem {
            id: delegate
            width: parent.width - 2*x
            x: app.paddingMedium
            height: stuff.height

            Row {
                id: stuff
                spacing: app.paddingMedium
                width: parent.width

                Column {
                    width: parent.width

                    Item {
                        width: parent.width
                        height: tt.height

                        Label {
                            id: tt
                            color: app.primaryColor
                            textFormat: Text.StyledText
                            //truncationMode: TruncationMode.Fade
                            width: parent.width - dt.width
                            text: titleText
                        }
                        Label {
                            id: dt
                            anchors.right: parent.right
                            color: app.secondaryColor
                            font.pixelSize: app.fontSizeExtraSmall
                            text: durationText
                        }
                    }

                    Label {
                        color: app.secondaryColor
                        font.pixelSize: app.fontSizeExtraSmall
                        text: metaText
                        textFormat: Text.StyledText
                        //truncationMode: TruncationMode.Fade
                        width: parent.width
                    }
                }

            }

            /*menu: contextMenu

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: i18n.tr("Add To Player")
                        visible: listView.model.get(index).type === "Item"
                        onClicked: addToPlayer(listView.model.get(index));
                    }
                    MenuItem {
                        text: i18n.tr("Add Group To Player")
                        visible: listView.model.get(index).type === "Item"
                        onClicked: addGroupToPlayer(groupByField, listView.model.get(index)[groupByField]);
                    }
                    MenuItem {
                        text: i18n.tr("Add All To Player")
                        visible: listView.model.get(index).type === "Item"
                        onClicked: addAllToPlayer();
                    }
                    // minidlna and minimserver give complete collection as parent
                    // so browsing that is useless (and for some reason does not work)
                    //MenuItem {
                    //    text: "Browse (experimental)"
                    //    onClicked: openBrowseOn(listView.model.get(index).pid);
                    //}
                }
            }*/
        }

        ScrollBar.vertical: ScrollBar {}

    }

    onSearchStringChanged: {
        typeDelay.restart()
    }

    Timer {
        id: typeDelay
        interval: 1000
        running: false
        repeat: false
        onTriggered: refresh()
    }

    onSelectedSearchCapabilitiesMaskChanged: refresh()

    function refresh() {
        if(searchString.length >= 1 && selectedSearchCapabilitiesMask > 0) {
            var searchQuery = UPnP.createUPnPQuery(searchString, searchCapabilities, selectedSearchCapabilitiesMask, allowContainers);
            showBusy = true;
            upnp.search(searchQuery, 0, maxCount);
            //console.log("search start="+startIndex);
        }
        searchModel.clear();
    }

    function searchMore(start) {
        if(searchString.length < 1 || selectedSearchCapabilitiesMask == 0)
            return;
        var searchQuery = UPnP.createUPnPQuery(searchString, searchCapabilities, selectedSearchCapabilitiesMask, allowContainers);
        showBusy = true;
        startIndex = start;
        upnp.search(searchQuery, start, maxCount);
        //console.log("search start="+startIndex);
    }

    Connections {
        target: upnp
        onSearchDone: {
            var i;

            try {
                searchResults = JSON.parse(searchResultsJson);

                // containers
                for(i=0;i<searchResults.containers.length;i++) {
                    var container = searchResults.containers[i];
                    searchModel.append(UPnP.createListContainer(container));
                }

                // items
                for(i=0;i<searchResults.items.length;i++) {
                    var item = searchResults.items[i];
                    if(UPnP.startsWith(item.properties["upnp:class"], "object.item.audioItem")) {
                        searchModel.append(UPnP.createListItem(item));
                    } else
                        console.log("onSearchDone: skipped loading of an object of class " + item.properties["upnp:class"]);
                }

                totalCount = searchResults["totalCount"];

            } catch( err ) {
                app.error("Exception in onSearchDone: " + err);
                app.error("json: " + searchResultsJson);
            }

            showBusy = false;
        }

        onError: {
            console.log("Search::onError: " + msg);
            //app.errorLog.push(msg);
            showBusy = false;
        }
    }
    function addToPlayer(track) {
        getPlayerPage().addTracks([track]);
    }

    function replaceInPlayer(track) {
        getPlayerPage().clearList();
        getPlayerPage().addTracks([track]);
    }

    function getAllTracks() {
        var tracks = [];
        for(var i=0;i<listView.model.count;i++) {
            if(listView.model.get(i).type === "Item")
                tracks.push(listView.model.get(i));
        }
        return tracks;
    }

    function addAllToPlayer() {
        var tracks = getAllTracks();
        getPlayerPage().addTracks(tracks);
    }

    function replaceAllInPlayer() {
        var tracks = getAllTracks();
        getPlayerPage().clearList();
        getPlayerPage().addTracks(tracks);
    }

    function addGroupToPlayer(field, value) {
        var tracks = [];
        for(var i=0;i<listView.model.count;i++) {
            if(listView.model.get(i).type === "Item") {
                var track = listView.model.get(i);
                if(track[field] === value)
                    tracks.push(track);
            }
        }
        getPlayerPage().addTracks(tracks);
    }

    function openBrowseOn(id) {
        pageStack.pop();
        mainPage.openBrowsePage(id);
    }

}
