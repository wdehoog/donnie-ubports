/*
 * Copyright (C) 2015-2017 kimmoli <kimmo.lindholm@eke.fi>
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
        title: title
        trailingActions: [
            Action {
                iconName: "toolkit_tick"
                text: i18n.tr("Ok")
                onTriggered: accepted()
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
            height: label.height

            property bool selected: indexes.indexOf(index) != -1

            Label {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width 
                wrapMode: Text.Wrap
                text: name
                background: Rectangle {
                    anchors.fill: parent
                    color: (delegateItem.highlighted || delegateItem.selected)
                           ? app.highlightBackgroundColor
                           : app.normalBackgroundColor
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

