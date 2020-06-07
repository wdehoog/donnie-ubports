/**
 * Donnie. Copyright (C) 2020 Willem-Jan de Hoog
 *
 * License: MIT
 */


import Ergo 0.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Column {
    id: control

    property int index
    property string title
    property string meta
    property string duration

    width: parent.width

    Item {
        width: parent.width
        height: tt.height

        Label {
            id: tt
            color: app.primaryColor
            font.pixelSize: app.fontPixelSizeMedium
            font.weight: currentIndex === index ? Font.Bold: Font.Normal
            textFormat: Text.StyledText
            elide: Text.ElideRight
            width: parent.width - dt.width
            text: title
        }

        Label {
            id: dt
            anchors.right: parent.right
            color: app.primaryColor
            font.weight: currentIndex === index ? Font.Bold: Font.Normal
            font.pixelSize: app.fontSizeSmall
            text: duration ? duration : ""
        }
    }

    Label {
        color: app.secondaryColor
        font.weight: currentIndex === index ? Font.Bold: Font.Normal
        font.pixelSize: app.fontSizeSmall
        textFormat: Text.StyledText
        elide: Text.ElideRight
        width: parent.width
        visible: meta ? meta.length > 0 : false
        text: meta
    }

}
