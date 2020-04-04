/**
 * Code based on Ergo/AdaptiveListItem.qml
 */

import Ergo 0.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

Popup {
    id: actionMenu
    modal: true

    property list<Action> actions

    property int index

    function show(idx) {
        index = idx
        open()
    }

    padding: units.dp(8)
    // FIXME: need to move this closer to mouse/tap
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    //height: childrenRect.height
    width: parent.width - units.dp(8)
    background: Rectangle {
        color: "#111111"
        opacity: 0.93
        radius: 9
    }

    ColumnLayout {
        width: parent.width
        //anchors.fill: parent
        spacing: units.dp(12)

        Repeater {
            model: actionMenu.actions
            delegate: Item {
                width: actionMenu.width
                height: childrenRect.height

                Label {
                    topPadding: app.paddingMedium
                    bottomPadding: topPadding
                    font.pixelSize: app.fontSizeLarge
                    text: modelData.text
                    color: "#efefef"
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    onClicked: {
                        actionMenu.close();
                        modelData.trigger();
                    }
                }
            }
        }
    }
}
