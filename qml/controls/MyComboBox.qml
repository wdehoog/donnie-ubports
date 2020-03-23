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

ComboBox {
    id: control

    property int fontPixelSize
    property color backgroundColor: app.controlBackgroundColor

    font.pixelSize: fontPixelSize
    indicator.width: height
    background: Rectangle {
        color: control.backgroundColor
        border.width: 1
        border.color: app.controlBorderColor
        radius: app.controlRadius
    }

    // override only to set font.pixelSize
    delegate: ItemDelegate { 
        width: control.width
        //height: resumeModeSelector.height
        contentItem: Text {
            text: modelData
            font.pixelSize: control.fontPixelSize
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            font.weight: control.currentIndex === index ? Font.DemiBold : Font.Normal
        }
    }

    Component.onCompleted: {
        popup.background.color = control.backgroundColor
    }

    // setting a custom indicator results in: 'Cannot assign a value directly to a grouped property'

    /*indicator: Image {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        source: "image://theme/toolkit_arrow-down/" + (!control.editable && control.visualFocus ? Default.focusColor : Default.textColor)
        sourceSize.width: width
        sourceSize.height: height
        opacity: enabled ? 1 : 0.3
    }*/

    /*indicator: Canvas {
        id: canvas
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: control
            onPressedChanged: canvas.requestPaint()
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            //context.fillStyle = control.pressed ? "#17a81a" : "#21be2b";
            context.fill();
        }
    }*/
}
