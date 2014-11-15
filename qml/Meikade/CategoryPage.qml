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

Rectangle {
    id: page
    width: 100
    height: 62
    color: "#dddddd"

    ListObject {
        id: list
        onCountChanged: {
            if( count <= 1 )
                BackHandler.removeHandler(page)
            else
            if( count == 2 )
                BackHandler.pushHandler(page, page.back)
        }
    }

    Connections {
        target: Database
        onInitializeFinished: {
            var item = category_component.createObject(base_frame, {"catId": 0, "startY": 0, "startHeight": base_frame.height})
            item.startInit = true
            list.append(item)
        }
    }

    Rectangle {
        id: title_bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Devices.standardTitleBarHeight + View.statusBarHeight
        color: "#880000"
    }

    Item {
        id: base_frame
        anchors.top: title_bar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Component {
        id: category_component

        CategoryPageItem {
            categoryComponent: category_component
            baseFrame: base_frame
        }
    }

    function back() {
        var item = list.takeLast()
        item.end()
        if( list.count != 0 )
            list.last().outside = false

        main.focus = true
        if( list.count == 1 )
            BackHandler.removeHandler(page)
        else
            return false
    }
}
