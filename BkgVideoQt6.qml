import QtQuick
import QtMultimedia

Image {
    anchors.fill: parent

    Video {
        source: "file://" + mpath
        anchors.fill: parent
        fillMode: VideoOutput.Stretch
        Component.onCompleted: play()
    }
}
