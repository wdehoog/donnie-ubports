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
import QtQuick.Controls.Suru 2.2

import "../components"

import "../UPnP.js" as UPnP


Page {
    id: searchPage

    property bool keepSearchFieldFocus: true
    property bool showBusy: false
    property string searchString: ""
    property int startIndex: 0
    property int maxCount: app.settings.max_number_of_results
    property int totalCount
    property bool allowContainers : app.settings.search_allow_containers
    property var searchResults
    property var searchCapabilities: []
    property int selectedSearchCapabilitiesMask: app.settings.selected_search_capabilities
    property var scMap: []
    property string groupByField: app.settings.groupby_search_results

    header: PageHeader {
        title: i18n.tr("Search")
    }

    BusyIndicator {
        id: busyThingy
        anchors.centerIn: parent
        width: itemSizeLarge
        height: width
        running: showBusy
    }

    SortedListModel {
        id: searchModel
        //sortKey: groupByField

        // sort by group field and track number
        comparator: function(a, b) {
            return a[groupByField].localeCompare(b[groupByField])
                || (groupByField == "album" ? (a.trackNumber - b.trackNumber) : 0)
        }
    }

    ListModel {
        id: searchHistoryModel
        Component.onCompleted: reloadSearchHistoryModel()
    }

    function reloadSearchHistoryModel() {
        searchHistoryModel.clear()
        var data = JSON.parse(app.settings.searchHistory)
        for(var i=0;i<data.length;i++) {
            searchHistoryModel.append({query: data[i]})
        }
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
                        searchModel.clear()
                        searchMore(startIndex-maxCount)
                    }
                }
                MenuItem {
                    text: i18n.tr("Load Next Set")
                    enabled: searchString.length >= 1
                             && selectedSearchCapabilitiesMask > 0
                             && (startIndex + searchModel.count) < totalCount
                    onClicked: {
                        searchModel.clear()
                        searchMore(startIndex+maxCount)
                    }
                }
                MenuItem {
                    text: i18n.tr("Load More")
                    enabled: searchString.length >= 1
                             && selectedSearchCapabilitiesMask > 0
                             && searchModel.count < totalCount
                    onClicked: searchMore(startIndex+maxCount)
                }
            }

            }*/

            Rectangle { height: units.dp(4); width: parent.width; color: app.bgColor; opacity: 1.0 }

            // Suru styled ComboBox is not editable so combine with a TextField
            Item {
                width: parent.width
                height: searchCombo.height
                ComboBox {
                    id: searchCombo
                    width: parent.width
                    //font.pixelSize: app.fontPixelSizeLarge
                    model: searchHistoryModel
                    onAccepted: {
                        searchString = editText.toLowerCase().trim()
                        refresh()
                        app.settings.searchHistory =
                            updateSearchHistory(editText,
                                                app.settings.searchHistory,
                                                app.settings.searchHistoryMaxSize)
                        reloadSearchHistoryModel()
                    }
                    onActivated: {
                        var selectedText = model.get(index).query
                        editText = selectedText
                        accepted()
                        searchField.text = selectedText
                    }
                }
                TextField {
                    id: searchField
                    width: parent.width - searchCombo.indicator.width - searchCombo.leftPadding - searchCombo.rightPadding
                    height: searchCombo.height
                    anchors.verticalCenter: parent.verticalCenter
                    //font.pixelSize: app.fontPixelSizeLarge
                    placeholderText: i18n.tr("Search for")
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

                    Binding {
                        target: searchPage
                        property: "searchString"
                        value: searchField.text.toLowerCase().trim()
                    }

                    Component.onCompleted: {
                        // for unknown reason Suru styled Textfield border remains too small
                        background.width = width
                    }

                    Keys.onReturnPressed: {
                        searchCombo.editText = searchField.text
                        searchCombo.accepted()
                    }
                }
            }

            /* Which fields to search in */
            Button {
                id: searchInButton
                property var indexes: []
                property string value: ""

                width: parent.width
                height: app.buttonHeight
                //font.pixelSize: app.fontPixelSizeMedium

                text: i18n.tr("Search In") + ": " + value

                ListModel {
                    id: items
                }

                Component.onCompleted: {
                    var c = 0
                    value = i18n.tr("None")
                    indexes = []
                    items.clear()

                    // load capabilities
                    for (var u=0;u<searchCapabilities.length;u++) {
                        var scapLabel = getSearchCapabilityDisplayString(searchCapabilities[u])
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
                            var first = value.length == 0
                            value = value + (first ? "" : ", ") + items.get(i).name
                            indexes.push(i)
                        }
                    }
                }

                onClicked: {
                    var ms = app.pushPage("components/MultiItemPicker.qml", { items: items, title: text, indexes: JSON.parse(JSON.stringify(indexes)) })
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

            Item {
                width: parent.width
                height: childrenRect.height 

                Label {
                    id: groupByLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 2 / 3
                    //font.pixelSize: app.fontPixelSizeMedium
                    wrapMode: Label.WordWrap
                    text: i18n.tr("Group By")
                }

                ComboBox {
                    id: groupByCombo

                    anchors.right: parent.right
                    width: parent.width - groupByLabel.width - app.paddingMedium
                    height: app.comboBoxHeight
                    //fontPixelSize: app.fontPixelSizeMedium

                    Component.onCompleted: {
                        console.log("onCompleted: " + app.settings.groupby_search_results)
                        if(app.settings.groupby_search_results === "album")
                            currentIndex = 0
                        else if(app.settings.groupby_search_results === "artist")
                            currentIndex = 1
                        else if(app.settings.groupby_search_results === "title")
                            currentIndex = 2
                        else
                            currentIndex = -1
                        console.log("model["+currentIndex+"]="+model[currentIndex])
                    }

                    onActivated: app.settings.groupby_search_results = model[currentIndex].toLowerCase()

                    model: [
                        i18n.tr("Album"),
                        i18n.tr("Artist"),
                        i18n.tr("Title")
                    ]
                }
            }
            Rectangle { height: units.dp(4); width: parent.width; color: app.bgColor; opacity: 1.0 }
        }

        section.property : groupByField
        section.delegate : Component {
            id: sectionHeading
            Item {
                width: parent.width - 2*x
                x: app.paddingMedium
                height: childrenRect.height

                Label {
                    anchors.right: parent.right
                    text: section
                    font.weight: Font.Bold
                    //font.pixelSize: app.fontSizeMedium
                    color: app.primaryColor
                }
            }
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
                if(listView.model.get(index).type === "Item")
                    listItemMenu.show(index)
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }

    ListItemMenu {
        id: listItemMenu

        property ListView listView: listView

        actions: [
            Action {
                text: i18n.tr("Add To Player")
                onTriggered: getPlayerPage().addTracks([listView.model.get(listItemMenu.index)])
            },
            Action {
                text: i18n.tr("Replace in Player")
                onTriggered: getPlayerPage().replaceTracks([listView.model.get(listItemMenu.index)])
            },
            Action {
                text: i18n.tr("Add Group To Player")
                onTriggered: getPlayerPage().addTracks(getGroupTracks(groupByField, listView.model.get(listItemMenu.index)[groupByField]))
            },
            Action {
                text: i18n.tr("Replace Group in Player")
                onTriggered: getPlayerPage().replaceTracks(getGroupTracks(groupByField, listView.model.get(listItemMenu.index)[groupByField]))

            },
            Action {
                text: i18n.tr("Add All To Player")
                onTriggered: getPlayerPage().addTracks(getAllTracks())
            },
            Action {
                text: i18n.tr("Replace All in Player")
                onTriggered: getPlayerPage().replaceTracks(getAllTracks())
            }
        ]
    }

    // minidlna and minimserver give complete collection as parent
    // so browsing that is useless (and for some reason does not work)
    //MenuItem {
    //    text: "Browse (experimental)"
    //    onClicked: openBrowseOn(listView.model.get(index).pid)
    //}

    /*onSearchStringChanged: {
        typeDelay.restart()
    }

    Timer {
        id: typeDelay
        interval: 1000
        running: false
        repeat: false
        onTriggered: refresh()
    }*/

    onSelectedSearchCapabilitiesMaskChanged: refresh()

    function refresh() {
        if(searchString.length >= 1 && selectedSearchCapabilitiesMask > 0) {
            var searchQuery = UPnP.createUPnPQuery(searchString, searchCapabilities, selectedSearchCapabilitiesMask, allowContainers)
            showBusy = true
            console.log("query: " + searchQuery)
            upnp.search(searchQuery, 0, maxCount)
            //console.log("search start="+startIndex)
        }
        searchModel.clear()
    }

    function searchMore(start) {
        if(searchString.length < 1 || selectedSearchCapabilitiesMask == 0)
            return
        var searchQuery = UPnP.createUPnPQuery(searchString, searchCapabilities, selectedSearchCapabilitiesMask, allowContainers)
        showBusy = true
        startIndex = start
        upnp.search(searchQuery, start, maxCount)
        //console.log("search start="+startIndex)
    }

    Connections {
        target: upnp
        onSearchDone: {
            var i

            try {
                searchResults = JSON.parse(searchResultsJson)
                console.log("onSearchDone: " + searchResults.containers.length +":"+ searchResults.items.length)

                // containers
                for(i=0;i<searchResults.containers.length;i++) {
                    var container = searchResults.containers[i]
                    searchModel.add(UPnP.createListContainer(container))
                }

                // items
                for(i=0;i<searchResults.items.length;i++) {
                    var item = searchResults.items[i]
                    if(UPnP.startsWith(item.properties["upnp:class"], "object.item.audioItem")) {
                        var li = UPnP.createListItem(item)
                        //console.log("adding: " + li.title + ":" + li.trackNumber)
                        searchModel.add(li)
                    } else
                        console.log("onSearchDone: skipped loading of an object of class " + item.properties["upnp:class"])
                }

                totalCount = searchResults["totalCount"]

            } catch( err ) {
                app.error("Exception in onSearchDone: " + err)
                app.error("json: " + searchResultsJson)
            }

            showBusy = false
        }

        onError: {
            console.log("Search::onError: " + msg)
            //app.errorLog.push(msg)
            showBusy = false
        }
    }

    function replaceInPlayer(track) {
        getPlayerPage().clearList()
        getPlayerPage().addTracks([track])
    }

    function getAllTracks() {
        var tracks = []
        for(var i=0;i<listView.model.count;i++) {
            if(listView.model.get(i).type === "Item")
                tracks.push(listView.model.get(i))
        }
        return tracks
    }

    function replaceAllInPlayer() {
        var tracks = getAllTracks()
        getPlayerPage().clearList()
        getPlayerPage().addTracks(tracks)
    }

    function getGroupTracks(field, value) {
        var tracks = []
        for(var i=0;i<listView.model.count;i++) {
            if(listView.model.get(i).type === "Item") {
                var track = listView.model.get(i)
                if(track[field] === value)
                    tracks.push(track)
            }
        }
        return tracks
    }

    function replaceGroupInPlayer(field, value) {
        getPlayerPage().clearList()
        getPlayerPage().addTracks(getGroupTracks(field, value))
    }

    function openBrowseOn(id) {
        pageStack.pop()
        mainPage.openBrowsePage(id)
    }

    function getSearchCapabilityDisplayString(searchCapability) {
        if(searchCapability === "upnp:artist")
            return i18n.tr("Artist");
        if(searchCapability === "dc:title")
            return i18n.tr("Title");
        if(searchCapability === "upnp:album")
            return i18n.tr("Album");
        if(searchCapability === "upnp:genre")
            return i18n.tr("Genre");
        if(searchCapability === "dc:creator")
            return i18n.tr("Creator");
        if(searchCapability === "dc:publisher")
            return i18n.tr("Publisher");
        if(searchCapability === "dc:description")
            return i18n.tr("Description");
        if(searchCapability === "upnp:userAnnotation")
            return i18n.tr("User Annotation");
        if(searchCapability === "upnp:longDescription")
            return i18n.tr("Long Description");

        return undefined;
    }

    function updateSearchHistory(searchString, search_history, maxSize) {
        if(!searchString || searchString.length === 0)
            return

        var sh = JSON.parse(search_history)
        var pos = sh.indexOf(searchString)
        console.log("updateSearchHistory " + searchString + ": maxSize=" + maxSize + ", pos=" + pos)
        if(pos > -1) {
            // already in the list so reorder
            for(var i=pos;i>0;i--)
                sh[i] = sh[i-1]
            sh[0] = searchString
        } else
            // a new item
            sh.unshift(searchString)

        while(sh.length > maxSize)
            sh.pop()

        return JSON.stringify(sh)
    }

}
