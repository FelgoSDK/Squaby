import Felgo 3.0
import QtQuick 2.0

Item {
  id: contentItem
  y: waveIndex*(height+spacing)

  property int waveIndex
  property int spacing: 0
  property variant propMetaData

  property variant currentModelData
  property variant writeModel
  property variant model
  property bool defaultValueIsSet
  property variant repeater
  property bool selected: false


  MultiResolutionImage {
    source: "../../assets/img/wave-item-selected.png"
    visible: selected
  }

  MultiResolutionImage {
    source: "../../assets/img/wave-item.png"
    visible: !selected
  }

  Text {
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 8
    text: waveIndex
    color: "white"
  }

  onWriteModelChanged: {
    if(typeof repeater === "undefined")
      return
    repeater.writeData = true
  }

  onCurrentModelDataChanged: {
    if(typeof currentModelData === "undefined")
      return

    writeModel = currentModelData
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      repeater.selectedItem = waveIndex
    }
    onPressAndHold: {
      repeater.selectedItem = waveIndex
      repeater.removeCurrentSelectedelement()
    }
  }
}
