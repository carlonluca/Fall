import QtQuick
import com.luke

Rectangle {
    anchors.fill: parent
    color: "transparent"

    Kms {
        anchors.fill: parent
        Component.onCompleted: play()
    }
}
