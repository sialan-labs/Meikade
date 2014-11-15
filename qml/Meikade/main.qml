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

SialanMain {
    id: main
    width: 500
    height: 680
    color: "#333333"
    mainFrame: main_scene

    property string globalPoemFontFamily: Devices.isIOS? "Droid Arabic Naskh" : poem_texts_font.name
    property real globalZoomAnimDurations: animations? 500 : 0

    property alias headerHeight: header.height
    property bool backButton: !Devices.isAndroid
    property bool flatDesign: true

    property alias catPage: cat_page

    property bool blockBack: false

    property bool animations: Meikade.animations

    property variant areaFrame: area_frame
    property variant mainDialog

    property variant menuItem
    property variant init_wait

    onMenuItemChanged: {
        if( menuItem )
            BackHandler.pushHandler( main, main.hideMenuItem )
        else
            BackHandler.removeHandler(main)
    }

    QtObject {
        id: privates
        property bool animations: true
    }

    Timer {
        id: main_dialog_destroyer
        interval: 400
        repeat: false
        onTriggered: if(item) item.destroy()
        property variant item
    }

    Component.onCompleted: {
        if( !Database.initialized() ) {
            var initWaitComponent = Qt.createComponent("InitializeWait.qml")
            init_wait = initWaitComponent.createObject(main)
        }
    }

    Connections{
        target: Meikade
        onCloseRequest: {
            if( !main.back() )
                Meikade.close()
        }
    }

    Connections {
        target: SApp
        onBackRequest: main.back()
    }

    Connections {
        target: Database
        onInitializeFinished: {
            if( init_wait ) {
                init_wait.visible = false
                init_wait.destroy()
            }
        }
    }

    Connections {
        target: Backuper
        onActiveChanged: {
            if( Backuper.active ) {
                showWaitDialog()
                UserData.disconnect()
                main.blockBack = true
            } else {
                hideMainDialog()
                UserData.reconnect()
                main.blockBack = false
            }
        }
    }

    FontLoader{
        id: poem_texts_font
        source: Meikade.resourcePath + "/fonts/" + Meikade.poemsFont + ".ttf"
        onStatusChanged: if(status == FontLoader.Ready) SApp.globalFontFamily = name
    }

    FontLoader{
        id: normal_fonts
        source: Meikade.resourcePath + "/fonts/DroidNaskh-Regular.ttf"
    }

    MainMenu {
        id: menu
        width: main_scene.menuSize
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        onSelected: {
            if( main.menuItem )
                main.menuItem.close()
            if( !search_bar.hide ) {
                if( search_bar.viewMode )
                    if( BackHandler )
                        BackHandler.back()

                search_bar.hide = true
            }

            if( fileName.length == 0 )
                ;
            else
            if( fileName.slice(0,4) == "cmd:" ) {
                var cmd = fileName.slice(4)
                if( cmd == "search" )
                    Meikade.timer(400,search_bar,"show")
            }
            else {
                var component = Qt.createComponent("MainMenuItem.qml")
                var item = component.createObject(frame)
                item.anchors.fill = frame
                item.z = 1000

                var ocomponent = Qt.createComponent(fileName)
                var object = ocomponent.createObject(item)
                item.item = object

                menuItem = item
            }

            hideMenu()
        }
    }

    SearchBar {
        id: search_bar
        anchors.left: main_scene.left
        anchors.right: main_scene.right
        onHideChanged: {
            if( !hide ) {
                if( main.menuItem )
                    main.menuItem.close()
            }
            if( !hide )
                BackHandler.pushHandler( search_bar, function hide(){search_bar.hide = true} )
            else
                BackHandler.removeHandler(search_bar)
        }
    }

    Item {
        id: main_scene
        anchors.top: search_bar.bottom
        width: parent.width
        height: parent.height
        clip: true
        transformOrigin: Item.Center

        property real menuSize: 237*physicalPlatformScale
        property bool menu: false

        onMenuChanged: {
            if( main_scene.menu ) {
                main_scene.x = -main_scene.menuSize
                BackHandler.pushHandler(main_scene, main_scene.hideMenu)
            } else {
                main_scene.x = 0
                BackHandler.removeHandler(main_scene)
            }
        }

        Behavior on x {
            NumberAnimation { easing.type: Easing.OutCubic; duration: frame.anim?400:0 }
        }

        Item {
            id: frame
            y: 0
            x: 0
            width: main.width
            height: main.height
            clip: true

            property bool anim: false

            Behavior on y {
                NumberAnimation { easing.type: Easing.OutCubic; duration: frame.anim?animations*400:0 }
            }

            Item {
                id: area_item
                y: padY
                height: parent.height
                anchors.left: parent.left
                anchors.right: parent.right

                property real padY: header.about? parent.height/3 : 0

                Behavior on padY {
                    NumberAnimation { easing.type: Easing.OutCubic; duration: animations*400 }
                }

                Item {
                    id: area_frame
                    width: parent.width
                    height: parent.height

                    Behavior on scale {
                        NumberAnimation { easing.type: Easing.InOutCubic; duration: animations*globalZoomAnimDurations }
                    }
                    Behavior on x {
                        NumberAnimation { easing.type: Easing.InOutCubic; duration: animations*globalZoomAnimDurations }
                    }
                    Behavior on y {
                        NumberAnimation { easing.type: Easing.InOutCubic; duration: animations*globalZoomAnimDurations }
                    }

                    CategoryPage {
                        id: cat_page
                        anchors.fill: parent
                    }
                }
            }

            Item {
                id: header_frame
                y: header.about? parent.height : 0
                anchors.left: parent.left
                anchors.right: parent.right
                height: Devices.standardTitleBarHeight+View.statusBarHeight

                Behavior on y {
                    NumberAnimation { easing.type: Easing.OutCubic; duration: animations*400 }
                }

                Header {
                    id: header
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: Devices.standardTitleBarHeight
                    titleFont.pixelSize: 13*fontsScale
                    light: true
                    visible: false
                }
            }
        }

        Button {
            id: menu_btn
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: View.statusBarHeight
            height: Devices.standardTitleBarHeight
            width: height
            radius: 0
            normalColor: "#00000000"
            highlightColor: "#00000000"
            textColor: "#ffffff"
            icon: press? "icons/menu_hover_64.png" : "icons/menu_64.png"
            iconHeight: 24*physicalPlatformScale
            onClicked: {
                frame.anim = true
                if( main_scene.menu )
                    main_scene.x = 0
                else
                    main_scene.x = -main_scene.menuSize

                main_scene.menu = !main_scene.menu
            }
        }

        MouseArea {
            anchors.fill: parent
            visible: !search_bar.hide
            z: 10000
            onClicked: {
                main.back()
                Devices.hideKeyboard()
            }
        }

        function hideMenu() {
            main_scene.menu = false
        }
    }

    MouseArea {
        id: marea
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: main_scene.right
        anchors.topMargin: menu_btn.height+menu_btn.y
        width: main_scene.menu? main_scene.width : 10*physicalPlatformScale

        onPressed: {
            pinX = mouseX
            movedX = false
        }

        onMouseXChanged: {
            var sizeX = main_scene.x + mouseX-pinX
            if( Math.abs(mouseX-pinX)>10*physicalPlatformScale )
                movedX = true

            if( -sizeX > main_scene.menuSize )
                sizeX = -main_scene.menuSize
            else
            if( -sizeX < 0 )
                sizeX = 0

            frame.anim = false
            main_scene.x = sizeX
            frame.anim = true
        }

        onReleased: {
            if( !movedX ) {
                main_scene.menu = false
                main_scene.x = 0
                return
            }

            var sizeX = -main_scene.x
            if( main_scene.menu ) {
                if( sizeX > 2*main_scene.menuSize/3 )
                    main_scene.x = -main_scene.menuSize
                else
                    main_scene.menu = false
            } else {
                if( sizeX < main_scene.menuSize/3 )
                    main_scene.x = 0
                else
                    main_scene.menu = true
            }
        }

        property real pinX
        property bool movedX: false
    }

    FastBlur {
        anchors.fill: main_scene
        source: main_scene
        radius: 32*physicalPlatformScale
        opacity: main_dialog_frame.opacity
        visible: main_dialog_frame.visible
    }

    Rectangle {
        id: main_dialog_frame
        anchors.fill: parent
        transformOrigin: Item.Center
        opacity: main.mainDialog? 1 : 0
        visible: opacity != 0
        color: "#aa000000"

        MouseArea {
            anchors.fill: parent
        }

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: animations*400 }
        }
    }

    Keys.onEscapePressed: back()

    function hideMenuItem() {
        main.menuItem.close()
    }

    function hideMenu() {
        main_scene.menu = false
    }

    function setCurrentChapter( id ){
        quran_frame.chapterViewer.chapter = id
    }

    function showMainDialog( item ){
        hideMainDialog()
        item.parent = main_dialog_frame
        mainDialog = item
    }

    function hideMainDialog(){
        if( !mainDialog )
            return
        if( main_dialog_destroyer.item )
            main_dialog_destroyer.item.destroy()

        main_dialog_destroyer.item = mainDialog
        main_dialog_destroyer.restart()
        mainDialog = 0
    }

    function showWaitDialog(){
        var component = Qt.createComponent("WaitDialog.qml")
        var item = component.createObject(main_dialog_frame)
        showMainDialog(item)
        return item
    }

    function back(){
        return BackHandler.back()
    }
}
