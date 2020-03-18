/**
 * Copyright (C) 2020 Willem-Jan de Hoog
 *
 * License: MIT
 */

import Ergo 0.0

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.impl 2.2
import QtQuick.Templates 2.2 as T

Button {
    id: control

    contentItem: Text {
        text: control.text
        font.pixelSize: app.fontPixelSizeMedium
        //color: rejectButton.down ? "#17a81a" : "#21be2b"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        border.color: app.controlBorderColor
        border.width: 1
        radius: app.controlRadius
        color: app.controlBackgroundColor
    }
}
