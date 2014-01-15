import VPlay 1.0
import QtQuick 1.1

MultiResolutionImage {
  id: button
  // setting the width is not supported directly, as it must be multiplied by the scale factor!
  width: 64
  height: 64

  source: "../../img/menuSquare-sd.png"

  signal clicked

  property alias text: textItem.text

  property alias pressed: mouseArea.pressed

  Text {
    id: textItem
    text: "Game\nMode"
    anchors.centerIn: parent
    font.family: hudFont.name
    font.pixelSize: 10
    color: "white"
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    onClicked: {
      button.clicked()
    }
  }
}
