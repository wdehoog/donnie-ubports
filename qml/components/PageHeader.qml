import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2

Rectangle  {

    property alias trailingActions: toolbar.trailingActions
    property alias leadingActions: toolbar.leadingActions
    property string title: "PageHeader"

    width: parent.width
    height: app.pageHeaderSize
    //color: app.bgColor

    AdaptiveToolbar {
        id: toolbar
        width: parent.width
        height: parent.height - 1
        anchors.top: parent.top
        leadingActions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: pageStack.pop()
            }
        ]

        Label { 
            text: title
            font.pixelSize: app.fontPixelSizeLarge
            font.bold: true
            //color: app.fgColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    Rectangle { 
        width: parent.width
        height: 1
        anchors.bottom: parent.bottom
        color: "grey"
    }
}
