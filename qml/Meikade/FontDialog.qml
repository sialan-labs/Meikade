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

Item {
    anchors.fill: parent

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
            height: txt.height + 30*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string font: fontName
            property alias press: marea.pressed

            Image {
                id: tik_img
                anchors.left: parent.left
                anchors.leftMargin: 10*physicalPlatformScale
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: 15*physicalPlatformScale
                source: "icons/tik.png"
                visible: Meikade.poemsFont == item.font
            }

            Text{
                id: txt
                anchors.left: tik_img.right
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                anchors.leftMargin: 10*physicalPlatformScale
                y: parent.height/2 - height/2
                font.pixelSize: 11*fontsScale
                font.family: SApp.globalFontFamily
                color: "#ffffff"
                text: item.font
                wrapMode: TextInput.WordWrap
            }

            MouseArea{
                id: marea
                anchors.fill: parent
                onClicked: {
                    Meikade.poemsFont = item.font
                }
            }
        }

        focus: true
        highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
        currentIndex: -1

        function refresh() {
            model.clear()

            var fonts = Meikade.availableFonts()
            for( var i=0; i<fonts.length; i++ )
                model.append({"fontName": fonts[i]})

            focus = true
        }

        Component.onCompleted: refresh()
    }

    ScrollBar {
        scrollArea: prefrences; height: prefrences.height
        anchors.right: prefrences.right; anchors.top: prefrences.top; color: "#ffffff"
    }
}
