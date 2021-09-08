import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    id: rootWindow
    width: 1920
    height: 1080
    title: "Fall"
    visible: true

    Image {
        source: "/beach1.jpg"
        anchors.fill: parent
        fillMode: Image.Stretch
    }

    RandomTimer {
        onTriggered: {
            var ball = ballComponent.createObject(rootWindow, {x: Math.random()*parent.width})
            ball.y = rootWindow.height + height
            restart(500)
        }
    }

    Component {
        id: ballComponent
        Item {
            width: height
            height: rootWindow.height/10
            y: -height

            onYChanged:
                if (y >= rootWindow.height + height)
                    destroy()

            Rectangle {
                radius: width/2
                color: "orange"
                opacity: 0.4
                anchors.fill: parent
            }

            Image {
                sourceSize.width: parent.width + 20
                sourceSize.height: parent.height + 20
                anchors.centerIn: parent
                source: "/soap.svg"
            }

            RandomTimer {
                onTriggered: {
                    parent.x = parent.x + Math.random()*rootWindow.width/5 - rootWindow.width/10
                    restart(3000)
                }
            }

            Behavior on y { NumberAnimation { duration: 20000 } }
            Behavior on x { SmoothedAnimation { velocity: 10 } }
        }
    }
}
