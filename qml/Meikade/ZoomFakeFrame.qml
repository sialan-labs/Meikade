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
    id: frame
    width: areaFrame.width
    height: areaFrame.height
    opacity: 0
    scale: itemSize/areaFrame.height

    property alias item: privates.item
    property real itemSize: 1

    onHeightChanged: refresh()
    onWidthChanged: refresh()
    onItemChanged: {
        if( privates.lastItem ) {
            privates.lastItem.destroy()
        }

        privates.lastItem = item
        if( !item )
            return

        item.parent = frame
        item.visible = true
        item.x = 0
        item.y = 0
        refresh()
    }

    Behavior on opacity {
        NumberAnimation { easing.type: Easing.InOutCubic; duration: globalZoomAnimDurations }
    }

    QtObject {
        id: privates

        property variant lastItem
        property variant item
    }

    function refresh(){
        if( !item )
            return

        item.width = width
        item.height = height
    }

    Component.onCompleted: refresh()
}
