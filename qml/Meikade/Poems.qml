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
import QtGraphicalEffects 1.0
import SialanTools 1.0

Rectangle {
    id: poems

    property int catId: -1

    onCatIdChanged: {
        poems_list.refresh()

        var fileName = catId
        var filePath = "banners/" + fileName + ".jpg"
        while( !Meikade.fileExists(filePath) ) {
            fileName = Database.parentOf(fileName)
            filePath = "banners/" + fileName + ".jpg"
        }

        var result = filePath
        img.source = result
    }

    signal itemSelected( int pid )

    Item {
        id: header_back
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: View.statusBarHeight+42*physicalPlatformScale
        clip: true

        Image {
            id: img
            anchors.left: parent.left
            anchors.right: parent.right
            y: 0
            height: sourceSize.height*width/sourceSize.width
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        FastBlur {
            id: blur
            anchors.fill: img
            source: img
            radius: 64
            Component.onDestruction: radius = 0
        }

        Rectangle {
            anchors.fill: blur
            color: "#000000"
            opacity: 0.4
        }
    }

    ListView {
        id: poems_list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header_back.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4*physicalPlatformScale
        highlightMoveDuration: 250
        maximumFlickVelocity: flickVelocity
        bottomMargin: View.navigationBarHeight
        clip: true

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: poems_list.width
            height: txt.height + 30*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property int pid: identifier
            property alias press: marea.pressed
            property bool hasFavorite: false
            property bool hasNote: false

            onPidChanged: {
                txt.text = Database.poemName(pid)
            }

            Text{
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                font.pixelSize: Devices.isMobile? 10*fontsScale : 11*fontsScale
                font.family: SApp.globalFontFamily
                color: item.press? "#ffffff" : "#333333"
                text: Database.poemName(pid)
                wrapMode: TextInput.WordWrap
            }

            MouseArea{
                id: marea
                anchors.fill: parent
                onClicked: {
                    poems.itemSelected(item.pid)
                }
            }
        }

        focus: true
        highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
        currentIndex: -1

        function refresh() {
            model.clear()

            var poems = Database.catPoems(catId)
            for( var i=0; i<poems.length; i++ )
                model.append({"identifier": poems[i]})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: poems_list; height: poems_list.height; width: 8
        anchors.left: poems_list.left; anchors.top: poems_list.top
        color: "#333333"
    }
}
