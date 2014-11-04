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
    id: hafez_omen
    width: 100
    height: 62

    property alias catId: omen_frame.catId
    property alias cellulSize: omen_frame.cellulSize
    property bool viewMode: false

    property int duration: 400
    property int easingType: Easing.OutQuad

    onViewModeChanged: {
        if( !viewMode )
            omen_frame.refresh()
    }

    OmenFrame {
        id: omen_frame
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        scale: hafez_omen.viewMode && portrait? 0.8 : 1
        onItemSelected: {
            if( !hafez_omen.viewMode )
                hafez_omen.switchPages()
            view.poemId = pid
            view.goToBegin()
        }

        Behavior on scale {
            NumberAnimation { easing.type: hafez_omen.easingType; duration: animations*hafez_omen.duration }
        }
    }

    Rectangle {
        id: black
        anchors.fill: parent
        color: "#000000"
        opacity: (1 - omen_frame.scale)*3
    }

    PoemView {
        id: view
        width: portrait? parent.width : parent.width*2/3
        height: parent.height
        x: hafez_omen.viewMode? 0 : -width - shadow.width

        Behavior on x {
            NumberAnimation { easing.type: hafez_omen.easingType; duration: animations*hafez_omen.duration }
        }

        Rectangle{
            id: shadow
            x: parent.width
            y: -height
            width: parent.height
            height: 10*physicalPlatformScale
            rotation: 90
            transformOrigin: Item.BottomLeft
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 1.0; color: "#33000000" }
            }
        }
    }

    function switchPages() {
        hafez_omen.viewMode = !hafez_omen.viewMode
    }

    function back() {
        if( hafez_omen.viewMode ) {
            switchPages()
            return true
        } else {
            return false
        }
    }

    Component.onCompleted: main.backHandler = hafez_omen
}
