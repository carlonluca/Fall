import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 640
    visible: true
    title: qsTr("Hello World")
    color: "purple"

    Image {
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        source: "/soap.svg"
        anchors.centerIn: parent
    }
}
