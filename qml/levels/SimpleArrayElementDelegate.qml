import VPlay 2.0
import QtQuick 2.0

Image {
  id: contentItem
  x: waveIndex*(width+spacing)

  property int waveIndex
  property int spacing: 0
  property variant propMetaData

  property variant currentModelData
  property variant writeModel: {"checked": contentItem.checked, "name": model.name}
  property variant model
  property bool defaultValueIsSet
  property variant repeater
  property bool checked
  property bool selected

  source: "../../assets/img/squabies/"+model.name+".png"

  opacity: checked ? 1.0 : 0.5

  onPropMetaDataChanged: {
    if(typeof propMetaData === undefined)
      return
  }

  onWriteModelChanged: {
    if(typeof repeater === "undefined")
      return
    repeater.writeData = true
  }

  onDefaultValueIsSetChanged: {
   if(typeof model === "undefined")
     return

   contentItem.checked = model.checked
 }

  onCurrentModelDataChanged: {
    if(typeof currentModelData === "undefined")
      return

    contentItem.checked = currentModelData.checked
  }


  MouseArea {
    anchors.fill: parent
    onClicked: {
      repeater.selectedItem = waveIndex
      contentItem.checked^=1
    }
  }
}
