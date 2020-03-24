import QtQuick 2.7
import QtQuick.Controls 2.2

CheckBox {
    id: control
    text: qsTr("CheckBox")
    checked: true

    indicator: Rectangle {
        id: ind
        width: control.width * 0.9
        implicitHeight: width
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: app.controlRadius
        border.color: app.controlBorderColor

        Rectangle {
            width: ind.width * 0.6
            height: width
            x: y
            y: ind.height / 2 - height / 2
            radius: app.controlRadius
            color: app.controlBorderColor
            visible: control.checked
        }
    }

    /*contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: control.down ? "#17a81a" : "#21be2b"
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }*/
}
