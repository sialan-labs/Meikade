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
    id: notes
    width: 100
    height: 62
    color: "#ffffff"
    viewMode: false

    QtObject {
        id: privates
        property int favoritesId
        property int notesId
    }

    Connections {
        target: UserData
        onFavorited: notes.refresh()
        onUnfavorited: notes.refresh()
        onNoteChanged: notes.refresh()
    }

    PoemView {
        id: poem
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: backButton? headerHeight+View.statusBarHeight : 0
        width: parent.width
        topFrame: false
        clip: true
        x: notes.viewMode? 0 : -width

        Behavior on x {
            NumberAnimation { easing.type: Easing.OutCubic; duration: animations*400 }
        }
    }

    Rectangle {
        id: bookmark_frame
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: backButton? headerHeight+View.statusBarHeight : View.statusBarHeight
        width: parent.width
        x: notes.viewMode? width : 0
        color: "#ffffff"

        Behavior on x {
            NumberAnimation { easing.type: Easing.OutCubic; duration: animations*400 }
        }

        PoemView {
            id: poem_view
            anchors.fill: parent
            color: "#00000000"
            header: Item {}
            clip: true
            editable: false
            topFrame: false
            headerVisible: false
            onItemSelected: {
                poem.poemId = pid
                poem.goTo(vid)
                poem.highlightItem(vid)
                notes.viewMode = true
            }
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: bookmark_frame.right
        anchors.bottom: back_btn.bottom
        height: 1*physicalPlatformScale
        color: "#444444"
        visible: backButton
    }

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

        Behavior on textColor {
            ColorAnimation { easing.type: Easing.OutCubic; duration: animations*400 }
        }
    }

    function refresh() {
        var verses_str = UserData.notes()

        poem_view.clear()
        for( var i=0; i<verses_str.length; i++ ) {
            var sid = verses_str[i]
            var pid = UserData.extractPoemIdFromStringId(sid)
            var vid = UserData.extractVerseIdFromStringId(sid)

            poem_view.add( pid, vid )
        }
    }

    Component.onCompleted: {
        refresh()
    }
}
