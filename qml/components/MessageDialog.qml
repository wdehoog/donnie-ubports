import Ergo 0.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

Rectangle {

    id: messageDialog

    property string msgTitle: "title"
    property string msgText: "text"
    property bool showCancel: false

    signal accepted()
    signal rejected()

    function open() {
        messageDialogPopup.open()
    }

    function close() {
        messageDialogPopup.close()
    }

    height: parent.height
    width: parent.width

    color: "#000000"
    opacity: 0.88
    visible: messageDialogPopup && messageDialogPopup.opened

    Popup {
        id: messageDialogPopup

        property QtObject account

        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2 - units.dp(35)

        width: parent.width - units.dp(24) * 2
        padding: units.dp(12)

        modal: true
        closePolicy: Popup.CloseOnEscape

        onClosed: {
            destroy();
        }

        background: Rectangle {
            color: "#111111"
            opacity: 0.99
            radius: units.dp(12)
        }

        ColumnLayout {
            width: parent.width
            spacing: units.dp(12)

            Text {
                Layout.fillWidth: true
                text: msgTitle
                color: "#efefef"
                font.pixelSize: app.fontPixelSizeLarge
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: msgText
                color: "#efefef"
                font.pixelSize: app.fontPixelSizeLarge
                wrapMode: Text.WordWrap
            }

            Item {
                Layout.fillWidth: true
                height: units.dp(16)
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: units.dp(24)

                Button {
                    Layout.fillWidth: true
                    font.pixelSize: units.dp(16)
                    text: i18n.tr("Cancel")
                    visible: showCancel
                    onClicked: {
                        rejected()
                        messageDialogPopup.close()
                    }
                }
                Button {
                    Layout.fillWidth: showCancel
                    font.pixelSize: units.dp(16)
                    text: i18n.tr("OK")
                    onClicked: {
                        accepted()
                        messageDialogPopup.close()
                    }
                    background: Rectangle {
                        color: "#ed3434"
                        radius: units.dp(10)
                    }
                }
            }
        }
    }
}

