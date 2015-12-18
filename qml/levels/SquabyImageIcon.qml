import QtQuick 2.0
import VPlay 2.0

Image {
  id: imageIcon
  source: "../../assets/img/squabies/squ_yellow.png"
  height: 60
  width: 60
  signal clicked()
  MouseArea {
    anchors.fill: parent
    onClicked: {
      imageIcon.clicked()
    }
  }
}
