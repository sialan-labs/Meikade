import QtQuick 2.0
import SialanTools 1.0

Column {
    anchors.verticalCenter: parent.verticalCenter

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: SApp.globalFontFamily
        font.pixelSize: 9*fontsScale
        color: "#333333"
        text: qsTr("Thank you for choosing Meikade.\nIf you are like this app, please rate us on Google play or Bazaar.\nThank you.")
    }

    Row {
        anchors.right: parent.right
        Button {
            textFont.family: SApp.globalFontFamily
            textFont.pixelSize: 10*fontsScale
            textColor: "#0d80ec"
            normalColor: "#00000000"
            highlightColor: "#660d80ec"
            text: qsTr("Cancel")
            onClicked: {
                BackHandler.back()
            }
        }

        Button {
            textFont.family: SApp.globalFontFamily
            textFont.pixelSize: 10*fontsScale
            textColor: "#0d80ec"
            normalColor: "#00000000"
            highlightColor: "#660d80ec"
            text: qsTr("OK")
            onClicked: {
                Qt.openUrlExternally("market://details?id=org.sialan.meikade")
                BackHandler.back()
            }
        }
    }
}
