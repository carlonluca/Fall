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
    property alias bkgImage: bkgLoader.item
    property int defaultSpacing: 5
    property int i: 2147483647
    property var ii: 4294967295

    id: rootWindow
    anchors.fill: parent

    Component.onCompleted: {
        console.log("Android insets:", lqtUtils.safeAreaTopInset(), lqtUtils.safeAreaBottomInset())
    }

    Loader {
        id: bkgLoader
        source: {
            if (btype === "image")
                return "BkgImage.qml"
            else if (btype === "qtvideo" && qt_major > 5)
                return "BkgVideoQt6.qml"
            else if (btype === "qtvideo" && qt_major <= 5)
                return "BkgVideoQt5.qml"
            else if (btype === "potvl")
                return "BkgVideoPOTVL.qml"
            else
                return "BkgImage.qml"
        }

        anchors.fill: parent
        active: true
    }

    ShaderEffect {
        id: wiggleEffect

        property real strength: 9.0
        property real time: 50.0
        property variant source: bkgImage

        anchors.centerIn: parent
        width: bkgImage ? bkgImage.width : 0
        height: bkgImage ? bkgImage.height : 0
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

        vertexShader: qt_major < 6 ? "qrc:/wiggle.vert" : "qrc:/wiggle.vert.qsb"
        fragmentShader: qt_major < 6 ? "qrc:/wiggle.frag" : "qrc:/wiggle.frag.qsb"
    }

    Timer {
        repeat: true
        interval: creationInterval
        running: !checkBoxBubbles.checked
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
                opacity: 0.4
                anchors.fill: parent
                color: "orange"

                SequentialAnimation on color {
                    loops: Animation.Infinite
                    running: checkBoxColor.checked
                    ColorAnimation { to: "yellow"; duration: 1000 }
                    ColorAnimation { to: "green"; duration: 1000 }
                    ColorAnimation { to: "blue"; duration: 1000 }
                    ColorAnimation { to: "red"; duration: 1000 }
                    ColorAnimation { to: "orange"; duration: 1000 }
                }
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

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: defaultSpacing
        anchors.topMargin: lqtUtils.safeAreaTopInset() + defaultSpacing
        radius: 5
        width: column.width + 2*defaultSpacing
        height: column.height + 2*defaultSpacing
        color: "orange"
        opacity: 0.8
        z: 1

        Column {
            id: column
            anchors.centerIn: parent
            spacing: defaultSpacing

            Text {
                id: fpsValue
                anchors.right: parent.right
                text: qsTr("fps ≈ ") + fpsmonitor.freq + " @ int ≈ " + Math.round(creationInterval) + " ms"
                font.family: monospaceFont
                font.pointSize: 13
                width: 220
            }

            Slider {
                id: slider
                anchors.right: parent.right
                from: 50
                to: 2000
                value: 500
                enabled: !checkBoxBubbles.checked
            }

            CheckBox {
                id: checkBoxBubbles
                text: qsTr("Disable bubbles")
                font.pointSize: 17
                anchors.left: parent.left
                contentItem: Text {
                    text: checkBoxBubbles.text
                    font.pointSize: 13
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: checkBoxBubbles.indicator.width + checkBoxBubbles.spacing
                }
            }

            CheckBox {
                id: checkBox
                text: qsTr("Scale bubbles")
                font.pointSize: 17
                anchors.left: parent.left
                enabled: !checkBoxBubbles.checked
                contentItem: Text {
                    text: checkBox.text
                    font.pointSize: 13
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: checkBox.indicator.width + checkBox.spacing
                }
            }

            CheckBox {
                id: checkBoxColor
                text: qsTr("Color animation")
                font.pointSize: 17
                anchors.left: parent.left
                enabled: !checkBoxBubbles.checked
                contentItem: Text {
                    text: checkBoxColor.text
                    font.pointSize: 13
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: checkBoxColor.indicator.width + checkBoxColor.spacing
                }
            }

            CheckBox {
                id: checkBoxShader
                text: qsTr("Shader")
                font.pointSize: 17
                anchors.left: parent.left
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
