import Felgo 3.0
import QtQuick 2.0
import QtQuick.Controls 1.1
import "../common"

ItemEditorBaseDelegate {
  width: parent.width
  height: sliderItem.height

  Item {
    id: numberTextItem
    anchors.verticalCenter: sliderItem.verticalCenter
    width: parent.parent.width/6*1.5
    height: parent.height

    ResponsiveText {
      id: numberText
      anchors.centerIn: parent
      text: propName
      font: currentItemEditor.itemEditorStyle.label.font
      color: currentItemEditor.itemEditorStyle.label.color
    }
  }
  AccurateSlider {
    id: sliderItem
    anchors.left: numberTextItem.right
    anchors.leftMargin: 12
    width: parent.parent.width/6*3.5
    minimumValue: 0
    maximumValue: 100
    stepSize: 1
    style: currentItemEditor.sliderStyle
    onValueChanged: {
      if(modelWrite == value)
        return

      modelWrite = value
      updateText(value)
    }
  }
  Text {
    id: valueText
    anchors.left: sliderItem.right
    anchors.leftMargin: 12
    anchors.verticalCenter: sliderItem.verticalCenter
    width: parent.parent.width/6*1
    font: currentItemEditor.itemEditorStyle.label.font
    color: currentItemEditor.itemEditorStyle.label.color
  }

  onPropMetaDataChanged: {
    if(isDefined(propMetaData.min))
      sliderItem.minimumValue = propMetaData.min
    if(isDefined(propMetaData.max))
      sliderItem.maximumValue = propMetaData.max
    if(isDefined(propMetaData.stepsize))
      sliderItem.stepSize = propMetaData.stepsize
    if(isDefined(propMetaData.color))
      numberText.color = propMetaData.color
  }

  // Set default value for Slider Reset function
  onInitialValueChanged: {
    sliderItem.value = initialValue
    updateText(initialValue)
  }

  onModelChanged: {
    if(!isDefined(model) || !bindingActive)
      return

    modelWrite = model
    sliderItem.value = model
    updateText(model)
  }

  function updateText(value) {
    numberText.text = (isDefined(propMetaData.label) ? propMetaData.label : propName)
    valueText.text = value.toFixed(utils.decimals(sliderItem.stepSize))
  }
}

