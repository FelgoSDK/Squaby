import QtQuick 2.0
import Felgo 3.0

Item {
  property alias text: label.text

  signal clicked
  signal pressAndHold

  property bool active: false
  property bool clickable: true  

  width: label.width
  height: parent.height

  Text {
    id: label
    anchors.verticalCenter: parent.verticalCenter
    // grey if it is not clickable, green if it is active, black by default
    color: "white"
    opacity: parent.clickable ? parent.active ? 0.5 : 1.0 : 0.2
    font.family: hudFont.name
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
