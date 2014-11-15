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
    id: search_list
    width: 100
    height: 62

    property string keyword

    signal itemSelected( int poem_id, int vid )

    onKeywordChanged: {
        view_list.clear()
        search_timer.restart()
    }

    Timer {
        id: search_timer
        interval: 300
        repeat: false
        onTriggered: view_list.find(search_list.keyword)
    }

    Item {
        anchors.fill: parent

        ListView {
            id: view_list
            anchors.fill: parent
            highlightMoveDuration: 250
            maximumFlickVelocity: flickVelocity
            bottomMargin: View.navigationBarHeight

            Connections {
                target: ThreadedDatabase
                onFound: {
                    view_list.add(poem_id,vorder)
                }
            }

            model: ListModel {}
            delegate: Rectangle {
                id: item
                width: view_list.width
                height: poem.height + txt_frame.height
                color: press? "#11000000" : "#00000000"

                property alias press: marea.pressed

                PoemItem {
                    id: poem
                    width: parent.width
                    color: "#00000000"
                    textColor: "#333333"
                    vid: identifier
                    pid: poem_id

                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 25*physicalPlatformScale
                        color: "#EC4334"
                        visible: item.press

                        Text {
                            anchors.centerIn: parent
                            text: Meikade.numberToArabicString(index+1)
                            color: "#ffffff"
                            font.pixelSize: 10*fontsScale
                            font.family: SApp.globalFontFamily
                        }
                    }
                }

                Rectangle {
                    id: txt_frame
                    height: poet.height
                    width: parent.width
                    anchors.bottom: parent.bottom
                    color: "#EC4334"

                    Text {
                        id: poet
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 8*physicalPlatformScale
                        font.pixelSize: 9*fontsScale
                        font.family: SApp.globalFontFamily
                        color: "#ffffff"

                        Component.onCompleted: {
                            var cat = Database.poemCat(poem.pid)
                            var str
                            str = Database.catName(cat) + ", "
                            str += Database.poemName(poem.pid)

                            var poet
                            var book
                            while( cat ) {
                                book = poet
                                poet = cat
                                cat = Database.parentOf(cat)
                            }

                            str = Database.catName(poet) + ", " + Database.catName(book) + ", " + str
                            text = str
                        }
                    }
                }

                MouseArea{
                    id: marea
                    anchors.fill: parent
                    onClicked: {
                        search_list.itemSelected(poem.pid,poem.masterVid)
                    }
                }
            }

            footer: Button {
                width: view_list.width
                height: 42*physicalPlatformScale
                color: "#333333"
                highlightColor: "#222222"
                text: qsTr("More")
                onClicked: ThreadedDatabase.next(50)
            }

            currentIndex: -1

            function add( poem_id, vorder ) {
                if( search_list.keyword.length == 0 )
                    return
                model.append({"poem_id": poem_id, "identifier": vorder})
            }

            function clear() {
                model.clear()
            }

            function find( keyword ) {
                clear()
                if( keyword.length === 0 )
                    return

                ThreadedDatabase.find(keyword)
                ThreadedDatabase.next(50)
            }
        }

        ScrollBar {
            scrollArea: view_list; height: view_list.height
            anchors.left: view_list.left; anchors.top: view_list.top
        }
    }
}
