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
    font.weight: Font.DemiBold

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

    // transparent drop down looks cool but the control on the line below
    // shines through
    /*Component.onCompleted: {
        popup.background.color = control.backgroundColor
    }*/

    Component {
        id: indicatorFactory
        /*Image {
            width: height
            height: control.height * 0.5
            x: control.mirrored ? width : control.width - 1.5 * width
            y: control.topPadding + (control.availableHeight - height) / 2
            source: "image://theme/toolkit_arrow-down"
            sourceSize.width: width
            sourceSize.height: height
        }*/
        Canvas {
            id: canvas
            x: control.width - width - control.rightPadding
            y: control.topPadding + (control.availableHeight - height) / 2
            width: height * 1.5
            height: control.height * 0.25
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
                context.fillStyle = app.controlBorderColor
                context.fill();
            }
        }
    }

    Component.onCompleted: {
        indicator = indicatorFactory.createObject(control)
    }

}
