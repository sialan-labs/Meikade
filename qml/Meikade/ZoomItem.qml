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
    id: zoom_item

    property string file
    property real itemSize: 10
    property bool zoomed: false

    property variant baseItem: main.areaFrame
    property variant item

    onItemSizeChanged: if( privates.frame ) privates.frame.itemSize = itemSize

    QtObject {
        id: privates
        property variant frame
    }

    function zoom(){
        if( privates.frame )
            return
        if( blockBack )
            return

        var component = Qt.createComponent(file)
        var item = component.createObject(zoom_item)

        var frameComponent = Qt.createComponent("ZoomFakeFrame.qml")
        var frameItem = frameComponent.createObject(zoom_item)
        frameItem.transformOrigin = Item.TopLeft
        frameItem.itemSize = itemSize
        frameItem.opacity = 1
        frameItem.item = item

        privates.frame = frameItem
        zoom_item.item = item

        var mainScale = baseItem.height/itemSize
        var newScale = baseItem.scale*mainScale
        baseItem.transformOrigin = Item.TopLeft
        baseItem.scale = newScale
        moveToFrame(newScale)

        zoomed = true
        blockBack = true
        zoomedStack.append(zoom_item)
        zoom_finished_tmr.restart()
    }

    function unzoom(){
        if( !privates.frame )
            return
        if( blockBack )
            return

        var mainScale = baseItem.height/itemSize
        var newScale = baseItem.scale/mainScale

        baseItem.transformOrigin = Item.TopLeft
        baseItem.scale = newScale
        zoomedStack.takeLast()

        if( zoomedStack.isEmpty() ) {
            baseItem.x = 0
            baseItem.y = 0
        } else {
            zoomedStack.last().moveToFrame(newScale)
        }

        privates.frame.opacity = 0
        zoomed = false
        blockBack = true
        kill_timer.restart()
    }

    function moveToFrame( newScale ){
        baseItem.x = -privates.frame.mapToItem(baseItem,0,0).x * newScale
        baseItem.y = -privates.frame.mapToItem(baseItem,0,0).y * newScale
    }

    function onAnim(){
        return kill_timer.running
    }

    Timer {
        id: zoom_finished_tmr
        repeat: false
        interval: globalZoomAnimDurations
        onTriggered: {
            blockBack = false
        }
    }

    Timer {
        id: kill_timer
        repeat: false
        interval: globalZoomAnimDurations
        onTriggered: {
            blockBack = false
            if( zoom_item.item )
                zoom_item.item.destroy()
            if( privates.frame )
                privates.frame.destroy()
        }
    }
}
