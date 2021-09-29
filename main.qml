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
        id: bkgImage
        source: "/beach1.jpg"
        anchors.fill: parent
        fillMode: Image.Stretch
    }

    ShaderEffect {
        id: wiggleEffect

        property real strength: 8.0
        property real time: 50.0
        property variant source: bkgImage

        anchors.centerIn: parent
        width: bkgImage.width
        height: bkgImage.height
        visible: checkBoxShader.checked

        mesh: GridMesh {
            resolution: Qt.size(20, 20)
        }

        UniformAnimator on time {
            from: 0
            to:  100
            duration: 2000
            loops: -1
            running: true
        }

        vertexShader: "qrc:/wiggle.vert"
        fragmentShader: "qrc:/wiggle.frag"

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
            property int stateIndex: 0

            id: bubble
            width: height
            height: rootWindow.height/10
            Component.onCompleted: bubbleAnim.start()
            state: "regular"

            transform: Scale {
                id: scaleTransform
                origin.x: width/2
                origin.y: height/2
            }

            states: [
                State {
                    name: "thin"
                    PropertyChanges {
                        target: scaleTransform
                        xScale: 0.9
                    }
                    PropertyChanges {
                        target: scaleTransform
                        yScale: 1.1
                    }
                },
                State {
                    name: "thick"
                    PropertyChanges {
                        target: scaleTransform
                        xScale: 1.1
                    }
                    PropertyChanges {
                        target: scaleTransform
                        yScale: 0.9
                    }
                },
                State {
                    name: "regular"
                    PropertyChanges {
                        target: scaleTransform
                        xScale: 1
                    }
                    PropertyChanges {
                        target: scaleTransform
                        yScale: 1
                    }
                }
            ]

            transitions: Transition {
                NumberAnimation { properties: "xScale,yScale"; easing.type: Easing.InOutQuad; duration: 1000 }
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

            RandomTimer {
                onTriggered: {
                    parent.x = parent.x + Math.random()*rootWindow.width/5 - rootWindow.width/10
                    restart(3000)
                }
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    bubble.stateIndex = (bubble.stateIndex + 1)%2
                    if (checkBox.checked)
                        bubble.state = (bubble.stateIndex === 0 ? "thick" : "thin")
                    else
                        bubble.state = "regular"
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
                font.pointSize: 17
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

        Rectangle {
            color: "orange"
            width: checkBox.width + 2*defaultSpacing
            height: checkBox.height + 2*defaultSpacing
            radius: 5
            opacity: 0.6
            anchors.right: parent.right

            CheckBox {
                id: checkBox
                text: qsTr("Scale bubbles")
                font.pointSize: 17
                anchors.centerIn: parent
                contentItem: Text {
                    text: checkBox.text
                    font.pointSize: 13
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: checkBox.indicator.width + checkBox.spacing
                }
            }
        }

        Rectangle {
            color: "orange"
            width: checkBoxShader.width + 2*defaultSpacing
            height: checkBoxShader.height + 2*defaultSpacing
            radius: 5
            opacity: 0.6
            anchors.right: parent.right

            CheckBox {
                id: checkBoxShader
                text: qsTr("Shader")
                font.pointSize: 17
                anchors.centerIn: parent
                contentItem: Text {
                    text: checkBoxShader.text
                    font.pointSize: 13
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: checkBoxShader.indicator.width + checkBoxShader.spacing
                }
            }
        }
    }
}
