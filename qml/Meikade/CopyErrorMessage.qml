import QtQuick 2.0
import SialanTools 1.0

Column {
    id: column
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right

    Text {
        width: main.width - 40*physicalPlatformScale
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.pixelSize: 9*fontsScale
        color: "#333333"
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("Error extracting database. There is no free space on your sd-card.\nMeikade need 150MB free space on your memory.")
    }

    Row {
        anchors.right: parent.right
        Button {
            textFont.family: SApp.globalFontFamily
            textFont.pixelSize: 10*fontsScale
            textColor: "#0d80ec"
            normalColor: "#00000000"
            highlightColor: "#660d80ec"
            text: qsTr("Dismiss")
            onClicked: {
                BackHandler.back()
                Meikade.close()
            }
        }
    }
}
