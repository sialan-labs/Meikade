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
    id: bhandler_item
    width: 100
    height: 62

    property bool viewMode: false
    property variant fallBackHandler

    onViewModeChanged: {
        if( viewMode ) {
            if( backHandler )
                fallBackHandler = backHandler

            backHandler = bhandler_item
        }
        else {
            if( fallBackHandler )
                backHandler = fallBackHandler
            else
                backHandler = 0
        }

        main.focus = true
    }

    function back() {
        if( viewMode ) {
            viewMode = false
            return true
        } else {
            return false
        }
    }

    Component.onDestruction: if( fallBackHandler && backHandler == bhandler_item ) backHandler = fallBackHandler
}
