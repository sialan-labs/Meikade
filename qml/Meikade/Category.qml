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
    id: category
    width: 100
    height: 62

    property int catId: -1
    property alias header: category_list.header
    property alias footer: category_list.footer
    property alias contentY: category_list.contentY
    property alias itemHeight: category_list.cellWidth

    onCatIdChanged: category_list.refresh()

    Component {
        id: itemComponent

        Item {
            id: item
            width: category_list.cellWidth
            height: width

            property int identifier: -1
            property int cid: identifier
            property bool fakeItem: cid == -1
            property bool hafezOmen: cid == 10001
            property bool middlest: false

            Rectangle {
                id: back
                anchors.centerIn: parent
                width: (item.width+2)/1.414213562
                height: width
                transformOrigin: Item.Center
                rotation: 45
                color: marea.pressed? "#FFE9DD" : "#ffffff"
                border.width: 1
                border.color: "#33333333"
                visible: item.middlest || marea.pressed
            }

            Item {
                width: back.width*1.414213562 - txt.paintedHeight
                height: maxHeight
                anchors.centerIn: parent
                visible: !item.fakeItem
                clip: true

                property real maxHeight: back.height/1.414213562

                Text{
                    id: txt
                    anchors.fill: parent
                    text: Database.catName(item.cid)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Devices.isMobile? 9*fontsScale : 11*fontsScale
                    font.family: SApp.globalFontFamily
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }

            ZoomItem{
                id: zoom_item
                file: item.hafezOmen? "HafezOmen.qml" : "CategoryPage.qml"
                itemSize: areaFrame.width>areaFrame.height? (item.width*areaFrame.height/areaFrame.width)/2 : item.height/2
                height: itemSize
                width: height*areaFrame.width/areaFrame.height
                anchors.centerIn: parent
                visible: !item.fakeItem
                onZoomedChanged: {
                    category_list.interactive = !zoomed
                }
            }

            MouseArea{
                id: marea
                transformOrigin: back.transformOrigin
                rotation: back.rotation
                width: back.width
                height: back.height
                anchors.centerIn: back
                visible: !zoom_item.zoomed && !item.fakeItem
                onClicked: {
                    var childs = Database.childsOf(item.cid)
                    if( childs.length === 0 && !item.hafezOmen )
                        zoom_item.file = "PoemsPage.qml"

                    zoom_item.zoom()
                    if( zoom_item.item )
                        zoom_item.item.catId = item.cid
                }
            }
        }
    }

    ListView {
        id: category_list
        anchors.fill: parent
        bottomMargin: View.navigationBarHeight

        property real cellWidth: areaFrame.width/cellCount
        property int cellCount: Math.floor(areaFrame.width/(150*physicalPlatformScale))
        property variant list: new Array

        onCellCountChanged: if( zoomedStack.isEmpty() ) refresh()

        model: ListModel {}
        delegate: Item {
            width: category_list.width
            height: category_list.cellWidth/2

            property bool middlest: index%2 == 0
            property int cellCount: category_list.cellCount
            property int indexMid: Math.floor(index/2)
            property int length: middlest? cellCount : cellCount-1
            property int startIdx: middlest? indexMid*(cellCount)+indexMid*(cellCount-1) :
                                                 indexMid*(cellCount-1)+(indexMid+1)*(cellCount)

            Row {
                id: row
                anchors.centerIn: parent
                layoutDirection: Qt.RightToLeft
                height: category_list.cellWidth
            }

            Component.onCompleted: {
                for( var i=startIdx; i<startIdx+length; i++ ) {
                    itemComponent.createObject(row,{"identifier":category_list.list[i],"middlest":middlest})
                }
            }
        }

        function refresh() {
            model.clear()

            list = Database.childsOf(category.catId)

            var sumCount = cellCount+cellCount-1
            var length = Math.floor(list.length/sumCount)*2
            var round = list.length%sumCount
            if( round != 0 ) {
                length++
                if( round > cellCount )
                    length++
            }

            for( var i=0; i<length; i++ ) {
                model.append({"rowIdx":i})
            }

            focus = true
        }
    }

    ScrollBar {
        scrollArea: category_list; height: category_list.height; width: 8
        anchors.left: category_list.left; anchors.top: category_list.top
    }
}
