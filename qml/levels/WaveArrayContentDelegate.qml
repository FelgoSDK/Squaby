import VPlay 2.0
import QtQuick 2.0
import "WaveArrayDelegateScript.js" as ArrayDelegateScript
import "../"
Item {
  id: arrayContentDelegate

  width: parent.width
  height: flickableValueContent.height
  property alias repeater: column

  // some property meta data to control and style the delegate for the needs of the property.
  property variant propMetaData

  onPropMetaDataChanged: {
    //wavesText.text = (isDefined(propMetaData.label) ? propMetaData.label : arrayContentDelegate.parent.propName)
  }

  property Component elementDelegateComponent


  Flickable {
    id: flickableElements
    anchors.left: parent.left
    anchors.leftMargin: 10

    width: parent.width/3/2

    clip: true

    height: flickableValueContent.height/3*2

    contentWidth: column.width
    contentHeight: column.height
    flickableDirection: Flickable.VerticalFlick

    interactive: height < column.height


    // Own rebuilt column needs to be used because columns do not support swapping of children.
    Item {
      id: column

      height: (children[0] ? (children.length)*children[0].height+(children.length)*spacing : 0)
      width: (arrayContentDelegate.width/3/2)/3/2

      property int spacing: 6
      property bool defaultValueIsSet: false
      property bool writeData: false
      property variant model
      property int selectedItem: -1

      function removeCurrentSelectedelement() {
        ArrayDelegateScript.removeElement(repeater)
        highlightSelectedElement()
        alignElements()
      }

      onModelChanged:  {
        if(model) {
          var ii = 0
          // update or add array elements when the model changes
          while(ii<model.length) {
            if(model[ii]) {
              // Test if there are enough elements available, if not add one(happens e.g. when loading new array data from file)
              if(ii < ArrayDelegateScript.repeaterElements.length) {
                ArrayDelegateScript.repeaterElements[ii].currentModelData = model[ii]
              } else {
                ArrayDelegateScript.repeaterElements.push(addRepeaterModel(ii,model[ii]))
              }
            }
            ++ii
          }
          // remove elements which are not needed anymore (happens e.g. when loading new array data from file)
          while(ii < ArrayDelegateScript.repeaterElements.length) {
            ArrayDelegateScript.removeLastElement(repeater)
          }
        }
        // Do not write Data manually from the created list during model change, because it would lead to a binding loop! Better override the modelWrite directly with the given model so the binding loop prevention method of the BaseDelegate will catch the loop.
        //writeData = true
        arrayContentDelegate.parent.modelWrite = model
      }

      onVisibleChanged: {
        // Change the selectedItem to 0 when resuming from invisible to avoid problems when an old list had more elements and the new one less but the old count is used.
        selectedItem = 0
      }

      onSelectedItemChanged: {
        if(selectedItem != -1) {
          ArrayDelegateScript.setSelectedItem(selectedItem,repeater)
          selectedItem = -1
          // new selected item so highlight the correct item!
          highlightSelectedElement()
        }
      }

      function highlightSelectedElement() {
        // reset intermediate model so new data can be assigned if available
        valueContent.intermediateModel = 0
        valueContent.visible = true

        var highlightedItem = ArrayDelegateScript.selectedItem
        // security guard to ensure that correct data is loaded when waves editor opens
        if(highlightedItem <= 0 || highlightedItem >= ArrayDelegateScript.repeaterElements.length) {
          // seems nothing is selected
          highlightedItem = 0
        }

        if(ArrayDelegateScript.repeaterElements[highlightedItem] !== undefined) {
          var modelData = ArrayDelegateScript.repeaterElements[highlightedItem].currentModelData
          // If there is no current model data available it means, it was not assigned yet, can happen on first load of the wave data.
          if(modelData == undefined) {
            //console.debug("[WaveArrayContentDelegate] There is no current wave data available which could be set! Using model data!")
            modelData = ArrayDelegateScript.repeaterElements[highlightedItem].model
          }
          valueContent.intermediateModel = modelData
        } else {
          // when no wave data is available, don't show the sliders!
          valueContent.visible = false
          //console.debug("[WaveArrayContentDelegate] There is no wave data available which could be set!")
        }
      }

      onWriteDataChanged: {
        if(writeData) {
          var writeModelData = []
          for( var ii = 0; ii<ArrayDelegateScript.repeaterElements.length; ++ii) {
            if(ArrayDelegateScript.repeaterElements[ii] !== undefined) {
              var modelData = ArrayDelegateScript.repeaterElements[ii].writeModel
              // modelData can be undefined if the wave was not selected and therefore no change were made, so use the model which has the correct data instead of the writeModel
              if(modelData === undefined) {
                modelData = ArrayDelegateScript.repeaterElements[ii].model
              }
              writeModelData.push(modelData)
            }
          }
          arrayContentDelegate.parent.modelWrite = writeModelData

          writeData = false
        }
      }

      function addRepeaterModel(index,modelData) {
        var component = elementDelegateComponent
        if (component.status === Component.Ready) {
          var repeaterObject = component.createObject(repeater, {
                                                        "width": flickableElements.width,
                                                        "height": 40,
                                                        "spacing": repeater.spacing,
                                                        "model": modelData,
                                                        "defaultValueIsSet": repeater.defaultValueIsSet,
                                                        "waveIndex": index,
                                                        "repeater": repeater,
                                                        "propMetaData": propMetaData.elementsMetaData
                                                      });
          if (repeaterObject === null) {
            console.debug("[WaveArrayContentDelegate] ERROR: creating repeater object failed!")
            return 0
          } else {
            return repeaterObject
          }
        } else if(component.status === Component.Error) {
          console.debug("[WaveArrayContentDelegate] ERROR: loading repeater object failed:", component.errorString())
          return 0
        }
      }

      function alignElements() {
        if(children.length <= 1)
          return

        // adjust position of the flickable so that the focus objects are always in view
        var elementHeight = (children.length-2)*(children[1].height+spacing)
        if(elementHeight > flickableElements.height) {
          flickableElements.contentY = elementHeight-flickableElements.height+children[1].height
        } else {
          flickableElements.contentY = 0
        }
      }
    }
  }
  Item {
    width: 3
    height: flickableElements.height
    anchors.right: flickableElements.left
    clip: true
    // Scrollbar
    Rectangle {
      id: scrollbar
      y: flickableElements.visibleArea.yPosition * flickableElements.height
      width: 3
      height: flickableElements.visibleArea.heightRatio * flickableElements.height
      color: "white"
      visible: flickableElements.interactive
    }
  }
  // Visibility Node
  ButtonVPlay {
    id: addButton
    anchors.top: flickableElements.bottom
    anchors.left: flickableElements.left
    text: "Add Wave"
    onClicked: {
      ArrayDelegateScript.addElement(repeater,elementDelegate)
      repeater.alignElements()
      repeater.selectedItem = ArrayDelegateScript.repeaterElements.length-1
    }
  }

  Flickable {
    id: flickableValueContent
    anchors.left: flickableElements.right
    anchors.leftMargin: 10
    width: parent.width-parent.width/3/2

    clip: true

    height: window.activeScene.gameWindowAnchorItem.height-window.activeScene.gameWindowAnchorItem.width/10 // scene.width/10 is __headerheight of SquabycontentDelegate

    contentWidth: valueContent.width
    contentHeight: valueContent.height
    flickableDirection: Flickable.VerticalFlick

    interactive: height < valueContent.height

    Column {
      id: valueContent
      width: arrayContentDelegate.width-arrayContentDelegate.width/3/2


      property int elementHeight: 50
      property int itemWidth: valueContent.width
      property int itemHeight: 60

      property variant intermediateModel
      property variant intermediateWriteModel : {"amount": amountItem.value, "squabyDelay": delayItem.value, "pauseBetweenWaves": pauseBetweenWavesItem.value, "yellow": yellowItem.value, "orange": orangeItem.value, "red": redItem.value, "green": greenItem.value, "blue": blueItem.value, "grey": greyItem.value}

      onIntermediateWriteModelChanged: {
        if(ArrayDelegateScript.repeaterElements[ArrayDelegateScript.selectedItem] !== undefined) {
          var currentData = ArrayDelegateScript.repeaterElements[ArrayDelegateScript.selectedItem].currentModelData
          if(currentData == undefined || intermediateWriteModel.amount !== currentData.amount ||
              intermediateWriteModel.squabyDelay !== currentData.squabyDelay ||
              intermediateWriteModel.pauseBetweenWaves !== currentData.pauseBetweenWaves ||
              intermediateWriteModel.yellow !== currentData.yellow ||
              intermediateWriteModel.orange !== currentData.orange ||
              intermediateWriteModel.red !== currentData.red ||
              intermediateWriteModel.green !== currentData.green ||
              intermediateWriteModel.blue !== currentData.blue ||
              intermediateWriteModel.grey !== currentData.grey ) {
            ArrayDelegateScript.repeaterElements[ArrayDelegateScript.selectedItem].currentModelData = intermediateWriteModel
          }
          //else {
          //  console.debug("[WaveArrayContentDelegate] Skipp write, no new Data!")
          //}
        }
      }

      onIntermediateModelChanged: {
        if(!intermediateModel || typeof intermediateModel === "undefined")
          return

        amountItem.value = intermediateModel.amount
        delayItem.value = intermediateModel.squabyDelay
        pauseBetweenWavesItem.value = intermediateModel.pauseBetweenWaves
        yellowItem.value = intermediateModel.yellow
        orangeItem.value = intermediateModel.orange
        redItem.value = intermediateModel.red
        greenItem.value = intermediateModel.green
        blueItem.value = intermediateModel.blue
        greyItem.value = intermediateModel.grey
      }

      Item {
        width: parent.width
        height: parent.elementHeight

        Text {
          anchors.right: amountItem.left
          anchors.verticalCenter: amountItem.verticalCenter
          width: valueContent.width/6
          text: "Amount"
          font: currentItemEditor.itemEditorStyle.label.font
          color: currentItemEditor.itemEditorStyle.label.color
        }
        AccurateSlider {
          id: amountItem
          anchors.centerIn: parent
          width: valueContent.width/6*4
          minimumValue: 0
          maximumValue: 50
          stepSize: 1
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.amount
            return 0
          }
        }
        Text {
          anchors.left: amountItem.right
          anchors.leftMargin: 12
          anchors.verticalCenter: amountItem.verticalCenter
          width: valueContent.width/6*1
          text: amountItem.value.toFixed(utils.decimals(amountItem.stepSize))
          font: currentItemEditor.itemEditorStyle.label.font
          color: currentItemEditor.itemEditorStyle.label.color
        }
      }


      Item {
        width: parent.width
        height: parent.elementHeight

        Text {
          anchors.right: delayItem.left
          anchors.verticalCenter: delayItem.verticalCenter
          width: valueContent.width/6
          text: "Delay"
          font: currentItemEditor.itemEditorStyle.label.font
          color: currentItemEditor.itemEditorStyle.label.color
        }
        AccurateSlider {
          id: delayItem
          anchors.centerIn: parent
          width: valueContent.width/6*4
          minimumValue: 0
          maximumValue: 10000
          stepSize: 100
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.squabyDelay
            return 0
          }
        }

        Text {
          anchors.left: delayItem.right
          anchors.leftMargin: 12
          anchors.verticalCenter: delayItem.verticalCenter
          width: valueContent.width/6*1
          text: delayItem.value.toFixed(utils.decimals(delayItem.stepSize))
          font: currentItemEditor.itemEditorStyle.label.font
          color: currentItemEditor.itemEditorStyle.label.color
        }
      }

      Item {
        width: parent.width
        height: parent.elementHeight

        Text {
          anchors.right: pauseBetweenWavesItem.left
          anchors.verticalCenter: pauseBetweenWavesItem.verticalCenter
          width: valueContent.width/6
          text: "Pause"
          font: currentItemEditor.itemEditorStyle.label.font
          color: currentItemEditor.itemEditorStyle.label.color
        }
        AccurateSlider {
          id: pauseBetweenWavesItem
          anchors.centerIn: parent
          width: valueContent.width/6*4
          minimumValue: 0
          maximumValue: 10000
          stepSize: 100
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.pauseBetweenWaves
            return 0
          }
        }

        Text {
          anchors.left: pauseBetweenWavesItem.right
          anchors.leftMargin: 12
          anchors.verticalCenter: pauseBetweenWavesItem.verticalCenter
          width: valueContent.width/6*1
          text: pauseBetweenWavesItem.value.toFixed(utils.decimals(pauseBetweenWavesItem.stepSize))
          font: currentItemEditor.itemEditorStyle.label.font
          color: currentItemEditor.itemEditorStyle.label.color
        }
      }

      Item {
        width: parent.itemWidth
        height: parent.itemHeight

        SquabyImageIcon {
          id: yellowImage
          anchors.verticalCenter: parent.verticalCenter
          source: "../../assets/img/squabies/squ_yellow.png"
        }
        Item {
          id: yellowText
          anchors.left: yellowImage.right
          anchors.verticalCenter: parent.verticalCenter
          width: yellowImage.width

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: yellowItem.value.toFixed(utils.decimals(yellowItem.stepSize))
            font: currentItemEditor.itemEditorStyle.label.font
            color: currentItemEditor.itemEditorStyle.label.color
          }
        }
        AccurateSlider {
          id: yellowItem
          width: parent.width/2
          anchors.left: yellowText.right
          anchors.verticalCenter: parent.verticalCenter
          minimumValue: 0
          maximumValue: 1
          stepSize: 0.1
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.yellow
            return 0
          }
        }
      }

      Item {
        width: parent.itemWidth
        height: parent.itemHeight

        SquabyImageIcon {
          id: orangeImage
          anchors.verticalCenter: parent.verticalCenter
          source: "../../assets/img/squabies/squ_orange.png"
        }
        Item {
          id: orangeText
          anchors.left: orangeImage.right
          anchors.verticalCenter: parent.verticalCenter
          width: orangeImage.width

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: orangeItem.value.toFixed(utils.decimals(orangeItem.stepSize))
            font: currentItemEditor.itemEditorStyle.label.font
            color: currentItemEditor.itemEditorStyle.label.color
          }
        }
        AccurateSlider {
          id: orangeItem
          anchors.left: orangeText.right
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width/2
          minimumValue: 0
          maximumValue: 1
          stepSize: 0.1
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.orange
            return 0
          }
        }
      }

      Item {
        width: parent.itemWidth
        height: parent.itemHeight

        SquabyImageIcon {
          id: redImage
          anchors.verticalCenter: parent.verticalCenter
          source: "../../assets/img/squabies/squ_red.png"
        }
        Item {
          id: redText
          anchors.left: redImage.right
          anchors.verticalCenter: parent.verticalCenter
          width: redImage.width

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: redItem.value.toFixed(utils.decimals(redItem.stepSize))
            font: currentItemEditor.itemEditorStyle.label.font
            color: currentItemEditor.itemEditorStyle.label.color
          }
        }
        AccurateSlider {
          id: redItem
          anchors.left: redText.right
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width/2
          minimumValue: 0
          maximumValue: 1
          stepSize: 0.1
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.red
            return 0
          }
        }
      }



      Item {
        width: parent.itemWidth
        height: parent.itemHeight

        SquabyImageIcon {
          id: greenImage
          anchors.verticalCenter: parent.verticalCenter
          source: "../../assets/img/squabies/squ_green.png"
        }
        Item {
          id: greenText
          anchors.left: greenImage.right
          anchors.verticalCenter: parent.verticalCenter
          width: greenImage.width

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: greenItem.value.toFixed(utils.decimals(greenItem.stepSize))
            font: currentItemEditor.itemEditorStyle.label.font
            color: currentItemEditor.itemEditorStyle.label.color
          }
        }
        AccurateSlider {
          id: greenItem
          anchors.left: greenText.right
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width/2
          minimumValue: 0
          maximumValue: 1
          stepSize: 0.1
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.green
            return 0
          }
        }
      }

      Item {
        width: parent.itemWidth
        height: parent.itemHeight

        SquabyImageIcon {
          id: blueImage
          anchors.verticalCenter: parent.verticalCenter
          source: "../../assets/img/squabies/squ_blue.png"
        }
        Item {
          id: blueText
          anchors.left: blueImage.right
          anchors.verticalCenter: parent.verticalCenter
          width: blueImage.width

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: blueItem.value.toFixed(utils.decimals(blueItem.stepSize))
            font: currentItemEditor.itemEditorStyle.label.font
            color: currentItemEditor.itemEditorStyle.label.color
          }
        }
        AccurateSlider {
          id: blueItem
          anchors.left: blueText.right
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width/2
          minimumValue: 0
          maximumValue: 1
          stepSize: 0.1
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.blue
            return 0
          }
        }
      }

      Item {
        width: parent.itemWidth
        height: parent.itemHeight

        SquabyImageIcon {
          id: greyImage
          anchors.verticalCenter: parent.verticalCenter
          source: "../../assets/img/squabies/squ_grey.png"
        }
        Item {
          id: greyText
          anchors.left: greyImage.right
          anchors.verticalCenter: parent.verticalCenter
          width: greyImage.width

          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: greyItem.value.toFixed(utils.decimals(greyItem.stepSize))
            font: currentItemEditor.itemEditorStyle.label.font
            color: currentItemEditor.itemEditorStyle.label.color
          }
        }
        AccurateSlider {
          id: greyItem
          anchors.left: greyText.right
          anchors.verticalCenter: parent.verticalCenter
          width: parent.width/2
          minimumValue: 0
          maximumValue: 1
          stepSize: 0.1
          value: {
            if(typeof intermediateModel !== "undefined")
              return intermediateModel.grey
            return 0
          }
        }
      }
    }
  }
}
