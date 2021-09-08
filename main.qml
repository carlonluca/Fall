import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: rootWindow
    width: 1920
    height: 1080
    title: "Fall"
    visible: true

    Image {
        source: "/beach1.jpg"
    }

    Timer {
        interval: 0
        running: true
        repeat: false
        onTriggered: {
            var ball = ballComponent.createObject(rootWindow, {x: Math.random()*parent.width})
            ball.y = rootWindow.height + height
            restart()
        }

        function restart() {
            interval = Math.random()*500
            start()
        }
    }

    Component {
        id: ballComponent
        Item {
            width: height
            height: rootWindow.height/10
            y: -height

            onYChanged: {
                if (y >= rootWindow.height + height)
                    destroy()
            }

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

            Timer {
                interval: 0
                running: true
                repeat: false
                onTriggered: {
                    parent.x = parent.x + Math.random()*rootWindow.width/5 - rootWindow.width/10
                    restart()
                }

                function restart() {
                    interval = Math.random()*3000
                    start()
                }
            }

            Behavior on y { NumberAnimation { duration: 20000 } }
            Behavior on x { SmoothedAnimation { velocity: 10 } }
        }


    }
}
