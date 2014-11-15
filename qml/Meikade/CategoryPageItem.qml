import QtQuick 2.0
import SialanTools 1.0

Rectangle {
    id: cat_item
    width: parent.width
    x: outside? parent.width : 0
    y: startInit? 0 : startY
    height: startInit? parent.height : startHeight
    clip: true
    color: "#dddddd"

    property alias catId: category.catId
    property alias root: cat_title.root

    property bool outside: false
    property bool startInit: false

    property real startY: 0
    property real startHeight: 0

    property Component categoryComponent
    property variant baseFrame

    Behavior on x {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
    }
    Behavior on y {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
    }
    Behavior on height {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
    }

    Timer {
        id: destroy_timer
        interval: 400
        onTriggered: cat_item.destroy()
    }

    Timer {
        id: start_timer
        interval: 400
        onTriggered: cat_item.startInit = true
    }

    Category {
        id: category
        topMargin: item.visible? item.height : 0
        height: cat_item.parent.height
        width: cat_item.parent.width
        header: root? desc_component : footer

        onCategorySelected: {
            var item = categoryComponent.createObject(baseFrame, {"catId": cid, "startY": rect.y, "startHeight": rect.height})
            item.root = (cat_item.catId == 0)
            item.start()

            if( list.count != 0 )
                list.last().outside = true

            list.append(item)
        }
    }

    Rectangle {
        id: item
        x: category.itemsSpacing
        width: category.width - 2*x
        height: 55*physicalPlatformScale
        border.width: 1*physicalPlatformScale
        border.color: "#cccccc"
        opacity: startInit? 0 : 1
        visible: cat_title.cid != 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
        }
    }

    Rectangle {
        height: item.height
        width: parent.width
        color: "#e0ffffff"
        opacity: startInit? 1 : 0
        visible: cat_title.cid != 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: destroy_timer.interval }
        }
    }

    CategoryItem {
        id: cat_title
        anchors.fill: item
        cid: category.catId
    }

    Component {
        id: desc_component
        Rectangle {
            x: category.itemsSpacing
            width: category.width - 2*x
            height: 55*physicalPlatformScale
            border.width: 1*physicalPlatformScale
            border.color: "#cccccc"
        }
    }

    function start() {
        start_timer.start()
    }

    function end() {
        startInit = false
        destroy_timer.start()
    }
}
