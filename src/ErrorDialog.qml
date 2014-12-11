import QtQuick 2.3
import QtQuick.Dialogs 1.2

Dialog {
    property string errorText: ""

    title: qsTr("Error")
    standardButtons: StandardButton.Ok

    Text {
        text: errorText
    }
}
