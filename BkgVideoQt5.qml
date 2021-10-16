import QtQuick 2.0
import QtMultimedia 5.0

Image {
    anchors.fill: parent

    Video {
        source: "file://" + mpath
        anchors.fill: parent
        fillMode: VideoOutput.Stretch
        Component.onCompleted: play()
    }
}
