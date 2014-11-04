/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Meikade is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Meikade is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import SialanTools 1.0

BackHandlerView {
    id: configure
    width: 100
    height: 62
    color: "#555555"

    viewMode: false

    Button{
        id: back_btn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: View.statusBarHeight
        height: headerHeight
        radius: 0
        normalColor: "#00000000"
        highlightColor: "#666666"
        textColor: "#ffffff"
        icon: "icons/back_light_64.png"
        iconHeight: 16*physicalPlatformScale
        fontSize: 11*fontsScale
        textFont.bold: false
        visible: backButton
        onClicked: {
            main.back()
            Devices.hideKeyboard()
        }
    }

    Row {
        id: logo
        anchors.top: parent.top
        anchors.margins: 12*physicalPlatformScale
        anchors.topMargin: View.statusBarHeight
        x: backButton? parent.width/2 - width/2 : (Meikade.languageDirection == Qt.RightToLeft? configure.width - width - 12*physicalPlatformScale : 12*physicalPlatformScale)
        height: headerHeight
        spacing: 6*physicalPlatformScale
        layoutDirection: Meikade.languageDirection

        Image {
            anchors.top: logo.top
            anchors.bottom: logo.bottom
            anchors.margins: 6
            width: height
            source: height>48? "icons/light_config_64.png" : "icons/light_config_32.png"
            sourceSize.width: width
            sourceSize.height: height
            visible: !backButton
        }

        Text {
            id: configure_txt
            anchors.verticalCenter: logo.verticalCenter
            font.pixelSize: 12*fontsScale
            font.family: SApp.globalFontFamily
            color: "#ffffff"
        }
    }

    Rectangle {
        id: frame
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logo.bottom
        anchors.bottom: parent.bottom
        color: "#333333"
        clip: true

        Rectangle {
            id: perf_frame
            width: parent.width
            height: parent.height
            color: configure.color
            transformOrigin: Item.Center
            scale: configure.viewMode? 0.85 : 1.0

            Behavior on scale {
                NumberAnimation { easing.type: Easing.OutCubic; duration: animations*300 }
            }

            ListView {
                id: prefrences
                anchors.fill: parent
                anchors.topMargin: 4*physicalPlatformScale
                anchors.bottomMargin: 4*physicalPlatformScale
                highlightMoveDuration: 250
                maximumFlickVelocity: flickVelocity
                clip: true

                model: ListModel {}
                delegate: Rectangle {
                    id: item
                    width: prefrences.width
                    height: txt.height + 20*physicalPlatformScale
                    color: press? "#3B97EC" : "#00000000"

                    property string dstFile: file
                    property alias press: marea.pressed
                    property bool checkable: check

                    property string prprt: pr

                    Text{
                        id: txt
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 30*physicalPlatformScale
                        y: parent.height/2 - height/2
                        font.pixelSize: 11*fontsScale
                        font.family: SApp.globalFontFamily
                        color: "#ffffff"
                        text: name
                        wrapMode: TextInput.WordWrap
                    }

                    MouseArea{
                        id: marea
                        anchors.fill: parent
                        onClicked: {
                            if( !item.checkable ) {
                                var component = Qt.createComponent(item.dstFile)
                                var citem = component.createObject(sub_frame)
                                sub_frame.item = citem
                                configure.viewMode = true
                            } else {
                                checkbox.checked = !checkbox.checked
                            }
                        }
                    }

                    CheckBox {
                        id: checkbox
                        x: Meikade.languageDirection == Qt.RightToLeft? 20 : item.width - width - 20
                        anchors.verticalCenter: parent.verticalCenter
                        visible: item.checkable
                        checked: item.prprt.length==0? false : Meikade.property(Meikade,item.prprt)
                        onCheckedChanged: Meikade.setProperty(Meikade,item.prprt,checked)
                    }
                }

                highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
                currentIndex: -1

                function refresh() {
                    model.clear()

                    model.append({ "name": qsTr("Backup & Restore"), "file": "BackupDialog.qml", "check": false, "pr":""})
                    model.append({ "name": qsTr("Fonts"), "file": "FontDialog.qml", "check": false, "pr":""})
                    model.append({ "name": qsTr("Animations"), "file": "", "check": true, "pr":"animations"})
                    model.append({ "name": qsTr("Languages"), "file": "LanguageSelector.qml", "check": false, "pr":""})
                }
            }

            ScrollBar {
                scrollArea: prefrences; height: prefrences.height; width: 8
                anchors.right: prefrences.right; anchors.top: prefrences.top; color: "#ffffff"
            }
        }

        Rectangle {
            id: black
            anchors.fill: parent
            color: "#000000"
            opacity: (1 - perf_frame.scale)*3
        }

        Rectangle {
            id: sub_frame
            width: parent.width
            height: parent.height
            x: configure.viewMode? 0 : parent.width
            color: configure.color
            visible: x != parent.width

            property variant item

            onVisibleChanged: {
                if( visible )
                    return
                if( !item )
                    return

                item.destroy()
            }

            Behavior on x {
                NumberAnimation { easing.type: Easing.OutCubic; duration: animations*300 }
            }
            Behavior on scale {
                NumberAnimation { easing.type: Easing.OutCubic; duration: animations*300 }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logo.bottom
        height: 1*physicalPlatformScale
        color: "#888888"
        visible: backButton
    }

    Connections{
        target: Meikade
        onCurrentLanguageChanged: initTranslations()
    }

    function initTranslations(){
        prefrences.refresh()
        configure_txt.text = qsTr("Configure")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
