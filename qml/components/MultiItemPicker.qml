/*
 * Copyright (C) 2020 Willem-Jan de Hoog
 *
 *
 * You may use this file under the terms of BSD license
 */

import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0

Page {
    id: itemPicker

    property ListModel items
    property var indexes: []

    signal accepted()

    header: PageHeader {
        title: itemPicker.title
        trailingActions: [
            Action {
                iconName: "toolkit_tick"
                text: i18n.tr("Ok")
                onTriggered: {
                    pageStack.pop()
                    accepted()
                }
                color: app.disableErgoActionColor
            }
        ]
    }

    ListView {
        id: view

        anchors.fill: parent
        model: items

        delegate: AdaptiveListItem {
            id: delegateItem
            x: app.paddingMedium
            width: parent.width - 2*x
            height: stuff.height + 2*app.paddingSmall 

            property bool selected: indexes.indexOf(index) != -1

            Row {
                id: stuff
                width: parent.width
                height: Math.max(cb.height, label.height)
                spacing: app.paddingMedium
                anchors.verticalCenter: parent.verticalCenter

                CheckBox {
                    id: cb
                    height: label.height
                    width: height
                    Component.onCompleted: { 
                        // set indicator sizes 
                        indicator.height = cb.height * 0.8
                        indicator.width = indicator.height
                        // Qt really hates to give access to usefull properties
                        indicator.children[0].width = indicator.width
                        indicator.children[0].height = indicator.height
                    }
                    checked: selected
                }

                Label {
                    id: label
                    height: app.labelHeight
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.Wrap
                    font.pixelSize: app.fontSizeLarge
                    text: name
                    /*background: Rectangle {
                        anchors.fill: parent
                        color: (delegateItem.highlighted || delegateItem.selected)
                               ? app.highlightBackgroundColor
                               : app.normalBackgroundColor
                    }*/
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var indexOfIndex = indexes.indexOf(index)
                    selected = (indexOfIndex == -1)
                    if (selected)
                        indexes.push(index)
                    else
                        indexes.splice(indexOfIndex, 1)
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }
}

