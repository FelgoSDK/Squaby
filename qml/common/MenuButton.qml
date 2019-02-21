import QtQuick 2.0
import Felgo 3.0

Item {
  property alias source: image.source

  signal clicked
  signal pressAndHold

  property bool active: false
  property bool clickable: true  

  width: image.width
  height: image.height


  MultiResolutionImage {
    id: image
    source: "../../assets/img/menu-downloaded.png"
    opacity: parent.clickable ? parent.active ? 0.4 : 1.0 : 0.1
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    enabled: parent.clickable
    onClicked: {
      parent.scale = 1.0
      parent.clicked()
    }
    onPressed: {
      parent.scale = 0.85
    }
    onReleased: {
      parent.scale = 1.0
    }
    onCanceled: {
      parent.scale = 1.0
    }
    onPressAndHold: parent.pressAndHold()
  }
}
