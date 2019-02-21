import Felgo 3.0
import QtQuick 2.0
import QtQuick.Controls 1.1

ItemEditorBaseDelegate {
  width: parent.width
  height: switchItem.height

  Item {
    id: boolTextItem
    anchors.verticalCenter: parent.verticalCenter
    width: parent.parent.width/6*1.5
    height: parent.height

    Text {
      id: boolText
      anchors.centerIn: parent
      text: propName
      font: currentItemEditor.itemEditorStyle.label.font
      color: currentItemEditor.itemEditorStyle.label.color
    }
  }
  Switch {
    id: switchItem
    anchors.left: boolTextItem.right
    width: parent.parent.width/6*3.5
    style: currentItemEditor.switchStyle
    onCheckedChanged: {
      if(modelWrite == checked)
        return

      modelWrite = checked
      updateText(checked)
    }
  }

  Text {
    id: boolValue
    anchors.left: switchItem.right
    anchors.verticalCenter: parent.verticalCenter
    width: parent.parent.width/6*1
    text: "-"
    font: currentItemEditor.itemEditorStyle.label.font
    color: currentItemEditor.itemEditorStyle.label.color
  }

  onPropMetaDataChanged: {
    if(isDefined(propMetaData.color))
      boolText.color = propMetaData.color
  }

  // Set default value for textur delegate
  onInitialValueChanged: {
    switchItem.checked = initialValue
    updateText(initialValue)
  }

  onModelChanged: {
    if(!isDefined(model) || !bindingActive)
      return

    modelWrite = model
    switchItem.checked = model
    updateText(model)
  }
  function updateText(value) {
    boolText.text = (isDefined(propMetaData.label) ? propMetaData.label : propName)
    boolValue.text = value
  }
}
