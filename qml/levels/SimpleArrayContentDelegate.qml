import Felgo 3.0
import QtQuick 2.0
import "SimpleArrayDelegateScript.js" as ArrayDelegateScript
import "../"
Item {
  id: arrayContentDelegate

  width: parent.width
  height: flickableElements.height
  property alias repeater: column

  // some property meta data to control and style the delegate for the needs of the property.
  property variant propMetaData

  onPropMetaDataChanged: {
    //arrayText.text = (isDefined(propMetaData.label) ? propMetaData.label : arrayContentDelegate.parent.propName)
  }

  property Component elementDelegateComponent

//  Text {
//    id: arrayText
//    width: parent.width
//    // initial text in white waves
//    text: arrayContentDelegate.parent.propName
//    color: "White"
//  }
  Flickable {
    id: flickableElements
    width: parent.width

    clip: true

    height: 80//valueContent.height/3*2

    contentWidth: column.width
    contentHeight: column.height
    flickableDirection: Flickable.HorizontalFlick

    interactive: parent.width < column.width


    // Own rebuilt column needs to be used because columns do not support swapping of children.
    Item {
      id: column

      height: parent.height
      width: (children[0] ? (children.length-1)*children[0].width+(children.length-1)*spacing : 0)

      property int spacing: 6
      property bool defaultValueIsSet: false
      property bool writeData: false
      property variant model
      property int selectedItem: -1

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
        writeData = true
        //arrayContentDelegate.parent.modelWrite = model
      }


      onSelectedItemChanged: {
        if(selectedItem != -1) {
          ArrayDelegateScript.setSelectedItem(selectedItem,repeater)
          selectedItem = -1
        }
      }

      onWriteDataChanged: {
        if(writeData) {
          var writeModelData = []
          for( var ii = 0; ii<ArrayDelegateScript.repeaterElements.length; ++ii) {
            if(ArrayDelegateScript.repeaterElements[ii] !== undefined) {
              writeModelData.push(ArrayDelegateScript.repeaterElements[ii].writeModel)
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
                                                        "width": 80,
                                                        "height": 80,
                                                        "spacing": repeater.spacing,
                                                        "model": modelData,
                                                        "currentModelData": modelData,
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
    }
  }
}
