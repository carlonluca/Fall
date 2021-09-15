/**
 * GPLv3 License
 *
 * Copyright (c) 2021 Luca Carlon
 *
 * This file is part of Fall.
 *
 * Fall is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Fall is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Fall.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import com.luke 1.0

Item {
    id: rootWindow
    width: 1920
    height: 1080
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

    Rectangle {
        color: "orange"
        width: childrenRect.width
        height: childrenRect.height
        radius: 5
        scale: 2
        transformOrigin: Item.TopRight
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        opacity: 0.6

        Column {
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Property handler") }

            FpsItem {
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("frameSwapped()") }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("fps: ") + fpsmonitor.fps
            }

            Text { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("QQuickPaintedItem") }

            FPSText {
                id: fps_text
                x:0
                y: 0;
                width: 200
                height: 100
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    anchors.centerIn: parent
                    text: fps_text.fps.toFixed(2)
                }
            }
        }
    }
}
