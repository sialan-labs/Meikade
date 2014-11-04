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

Rectangle {
    id: page
    width: 100
    height: 62

    property alias catId: category.catId
    property real titleBarHeight: 320*physicalPlatformScale

    onCatIdChanged: {
        var fileName = catId
        var filePath = "banners/" + fileName + ".jpg"
        while( !Meikade.fileExists(filePath) ) {
            fileName = Database.parentOf(fileName)
            filePath = "banners/" + fileName + ".jpg"
        }

        console.debug("Category switched:",catId)
        image.source = filePath
    }

    Image{
        id: image
        anchors.left: parent.left
        anchors.right: parent.right
        height: page.titleBarHeight + category.itemHeight/4
        y: catTop
        fillMode: Image.PreserveAspectCrop
        smooth: true
        sourceSize: Qt.size(width,height)
        scale: catTop>0? 1+2*catTop/page.titleBarHeight : 1
        visible: false

        property real catTop: -category.contentY/2 -page.titleBarHeight/2
    }

    FastBlur {
        anchors.fill: image
        source: image
        radius: (image.scale - 1)*35*physicalPlatformScale
        scale: image.scale
    }

    Rectangle{
        id: back
        y: (category.contentY-category.itemHeight/4>0? -category.itemHeight/4 : -category.contentY) + category.itemHeight/4
        height: parent.height-y
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#ffffff"
    }

    Category{
        id: category
        anchors.fill: parent
        header: Item{
            height: page.titleBarHeight
        }
    }
}
