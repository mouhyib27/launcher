/*
 * Copyright (C) 2021 CutefishOS.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import Cutefish.Launcher 1.0
import Cutefish.System 1.0 as System
import FishUI 1.0 as FishUI

Item {
    id: root

    width: launcher.screenRect.width
    height: launcher.screenRect.height

    property real horizontalSpacing: launcher.screenRect.width * 0.01
    property real verticalSpacing: launcher.screenRect.height * 0.01
    property real maxSpacing: horizontalSpacing > verticalSpacing ? horizontalSpacing : verticalSpacing
    property bool showed: launcher.showed
    property int iconSize: root.height < 960 ? 96 : 128

    onShowedChanged: {
        if (showed)
            searchFieldAni.start()
    }

    NumberAnimation {
        id: searchFieldAni
        from: 0.0
        to: 1.0
        target: textField
        property: "opacity"
        easing.type: Easing.InQuad
        duration: 250
    }

//    onShowedChanged: {
//        appViewOpacityAni.restart()
//        blurAnimation.restart()
//    }

//    NumberAnimation {
//        id: rootOpacityAni
//        from: root.showed ? 1 : 0
//        to: root.showed ? 0 : 1
//        target: root
//        property: "opacity"
//        duration: 200
//    }

//    NumberAnimation {
//        id: blurAnimation
//        target: wallpaperBlur
//        property: "radius"
//        duration: 300
//        from: root.showed ? 72 : 0
//        to: root.showed ? 0 : 72
//    }

//    NumberAnimation {
//        id: wallpaperColorAni
//        target: wallpaperColor
//        property: "opacity"
//        from: root.showed ? 0.4 : 0.0
//        to: root.showed ? 0.0 : 0.4
//        duration: 250
//    }

//    NumberAnimation {
//        id: appViewScaleAni
//        target: appView
//        property: "scale"
//        easing.type: Easing.OutCubic
//        from: root.showed ? 1.0 : 1.2
//        to: root.showed ? 1.2 : 1.0
//        duration: 180
//    }

//    NumberAnimation {
//        id: appViewOpacityAni
//        target: appView
//        property: "opacity"
//        easing.type: Easing.OutCubic
//        from: root.showed ? 1.0 : 0.0
//        to: root.showed ? 0.0 : 1.0
//        duration: 250
//    }

    System.Wallpaper {
        id: backend
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: "file://" + backend.path
        sourceSize: Qt.size(launcher.screenRect.width,
                            launcher.screenRect.height)
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: false
        smooth: true
    }

    FastBlur {
        id: wallpaperBlur
        anchors.fill: parent
        radius: 72
        source: wallpaper
        cached: true
        visible: true
    }

    ColorOverlay {
        id: wallpaperColor
        anchors.fill: parent
        source: wallpaperBlur
        color: "#000000"
        opacity: backend.dimsWallpaper ? 0.5 : 0.4
        visible: true
    }

    LauncherModel {
        id: launcherModel
    }

    Connections {
        target: launcherModel

        function onApplicationLaunched() {
            launcher.hideWindow()
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.topMargin: 28
        anchors.leftMargin: launcher.leftMargin
        anchors.rightMargin: launcher.rightMargin
        anchors.bottomMargin: launcher.bottomMargin + 28
        spacing: 0

        Item {
            id: searchItem
            Layout.fillWidth: true
            height: fontMetrics.height + FishUI.Units.largeSpacing

            TextMetrics {
                id: fontMetrics
                text: _placeLabel.text
            }

            TextField {
                id: textField
                anchors.centerIn: parent
                width: searchItem.width * 0.2
                height: parent.height

                leftPadding: textField.activeFocus ? _placeImage.width + FishUI.Units.largeSpacing : FishUI.Units.largeSpacing
                rightPadding: FishUI.Units.largeSpacing

                selectByMouse: true

                // placeholderText: qsTr("Search")
                wrapMode: Text.NoWrap

                color: "white"

                Item {
                    id: placeHolderItem
                    height: textField.height
                    width: _placeHolderLayout.implicitWidth
                    opacity: 0.6
                    x: textField.activeFocus ? FishUI.Units.smallSpacing : (textField.width - placeHolderItem.width) / 2
                    y: 0

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                        }
                    }

                    RowLayout {
                        id: _placeHolderLayout
                        anchors.fill: parent

                        Image {
                            id: _placeImage
                            height: placeHolderItem.height - FishUI.Units.largeSpacing
                            width: height
                            sourceSize: Qt.size(width, height)
                            source: "qrc:/images/system-search-symbolic.svg"
                        }

                        Label {
                            id: _placeLabel
                            color: "white"
                            text: qsTr("Search")
                            visible: !textField.length && !textField.preeditText && (!textField.activeFocus || textField.horizontalAlignment !== Qt.AlignHCenter)
                        }
                    }
                }

                background: Rectangle {
                    opacity: 0.2
                    radius: textField.height * 0.2
                    color: "white"
                    border.width: 0
                }

                Timer {
                    id: searchTimer
                    interval: 500
                    repeat: false
                    onTriggered: launcherModel.search(textField.text)
                }

                onTextChanged: {
                    if (textField.text === "") {
                        // Switch directly to normal mode
                        launcherModel.search("")
                    } else {
                        searchTimer.start()
                    }
                }
                Keys.onEscapePressed: launcher.hideWindow()
            }
        }

        Item {
            height: 14
        }

        Item {
            id: gridItem
            Layout.fillHeight: true
            Layout.fillWidth: true

            Keys.enabled: true
            Keys.forwardTo: appView

            AllAppsView {
                id: appView
                anchors.fill: parent
                anchors.leftMargin: gridItem.width * 0.1
                anchors.rightMargin: gridItem.width * 0.1
                Layout.alignment: Qt.AlignHCenter
                searchMode: textField.text
                focus: true

                Keys.enabled: true
                Keys.onPressed: {
                    if (event.key === Qt.Key_Escape)
                        launcher.hideWindow()

                    if (event.key === Qt.Key_Left ||
                            event.key === Qt.Key_Right ||
                            event.key === Qt.Key_Up ||
                            event.key === Qt.Key_Down) {
                        return
                    }

                    // First input text
                    if ((event.key >= Qt.Key_A && event.key <= Qt.Key_Z) ||
                            event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                        textField.forceActiveFocus()
                        textField.text = event.text
                    }
                }

                Label {
                    anchors.centerIn: parent
                    text: qsTr("Not found")
                    font.pointSize: 30
                    color: "white"
                    visible: appView.count === 0
                }
            }
        }

        PageIndicator {
            id: pageIndicator
            count: appView.count
            currentIndex: appView.currentIndex
            onCurrentIndexChanged: appView.currentIndex = currentIndex
            interactive: true
            spacing: FishUI.Units.largeSpacing
            Layout.alignment: Qt.AlignHCenter

            delegate: Rectangle {
                width: 10
                height: width
                radius: width / 2
                color: index === pageIndicator.currentIndex ? "white" : Qt.darker("white", 1.8)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1

        onClicked: {
            launcher.hideWindow()
        }
    }

    Timer {
        id: clearSearchTimer
        interval: 100
        onTriggered: textField.text = ""
    }

    Connections {
        target: launcher

        function onVisibleChanged(visible) {
            if (visible) {
                textField.focus = false
                appView.focus = true
                appView.forceActiveFocus()
            } else {
                clearSearchTimer.restart()
            }
        }
    }
}
