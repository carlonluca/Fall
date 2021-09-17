/**
 * GPLv3 license
 *
 * Copyright (c) 2021 Luca Carlon
 *
 * This file is part of Fall
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
 * along with Fall.  If not, see <http://www.gnu.org/licenses/>.
 **/

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Item {
    property alias creationInterval: slider.value
    property int defaultSpacing: 10

    id: rootWindow
    anchors.fill: parent

    Image {
        source: "/beach1.jpg"
        anchors.fill: parent
        fillMode: Image.Stretch
    }

    Timer {
        repeat: true
        interval: creationInterval
        running: true
        onTriggered: bubbleComponent.createObject(rootWindow, {x: Math.random()*parent.width})
    }

    Component {
        id: bubbleComponent

        Item {
            id: bubble
            width: height
            height: rootWindow.height/10
            Component.onCompleted: bubbleAnim.start()

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

            SequentialAnimation {
                id: bubbleAnim

                NumberAnimation {
                    target: bubble
                    duration: 20000
                    property: "y"
                    from: -height
                    to: rootWindow.height + height
                }

                ScriptAction { script: bubble.destroy() }
            }

            Behavior on x { SmoothedAnimation { velocity: 10 } }
        }
    }

    Column {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: defaultSpacing

        Rectangle {
            color: "orange"
            width: fpsValue.width + 2*defaultSpacing
            height: fpsValue.height + 2*defaultSpacing
            radius: 5
            opacity: 0.6
            anchors.right: parent.right

            Text {
                id: fpsValue
                anchors.centerIn: parent
                text: qsTr("fps ≈ ") + fpsmonitor.fps + " @ int ≈ " + Math.round(creationInterval) + " ms"
                font.pointSize: 16
            }
        }

        Rectangle {
            color: "orange"
            width: slider.width + 2*defaultSpacing
            height: slider.height + 2*defaultSpacing
            radius: 5
            opacity: 0.6
            anchors.right: parent.right

            Slider {
                id: slider
                anchors.centerIn: parent
                from: 50
                to: 2000
                value: 500
            }
        }
    }
}
