
var repeaterElements = new Array();

var selectedItem = -1

function setSelectedItem(selItem,repeater) {
  selectedItem = selItem
  updateSelectedColor(repeater)
}

function updateSelectedColor(repeater) {
  for( var ii = 0; ii<repeaterElements.length; ++ii) {
    if(repeaterElements[ii])
      repeaterElements[ii].selected = false
  }
  if(selectedItem >= 0 && repeaterElements.length > 0) {
    if(repeaterElements[selectedItem])
      repeaterElements[selectedItem].selected = true
  }

  // update write data because otherwise the save contant would not be correct.
  repeater.writeData = true
}

function addElement(repeater, elementDelegate) {
  // use default model data, might be empty because the delegates writeModel is not set yet
  var modelData = repeater.model[0]

  if(repeaterElements.length>0 && selectedItem !== -1) {
    // use the model data from the currently selected item
     modelData = repeaterElements[selectedItem].writeModel
  }



  repeaterElements.push(repeater.addRepeaterModel(repeaterElements.length, modelData))

  if(selectedItem == -1 && repeaterElements.length==1) {
    selectedItem = 0
  }

  updateSelectedColor(repeater)
}

function removeAllElements() {
  for( var ii = 0; ii<repeaterElements.length; ++ii) {
    if(repeaterElements[ii]) {
      repeaterElements[ii].destroy()
    }
  }
  repeaterElements.splice(0,repeaterElements.length-1)
}

function removeLastElement(repeater) {
  if(repeaterElements.length <= 0)
    return

  repeaterElements[repeaterElements.length-1].destroy()
  repeaterElements.splice(repeaterElements.length-1,1)

  updateRepeaterElementsOrdering()

  if(repeaterElements.length<=0) {
    selectedItem = -1
  }
  updateSelectedColor(repeater)
}

function removeElement(repeater){
  if(repeaterElements.length <= 0 || selectedItem == -1)
    return

  for( var ii = 0; ii<repeaterElements.length; ++ii) {
    if(selectedItem == ii && repeaterElements[ii]) {
      repeaterElements[ii].destroy()
      repeaterElements.splice(ii,1)
    }
  }

  updateRepeaterElementsOrdering()

  if(selectedItem>=1)
    selectedItem--

  if(repeaterElements.length<=0) {
    selectedItem = -1
  }

  updateSelectedColor(repeater)
}

function updateRepeaterElementsOrdering() {
  for( var ii = 0; ii<repeaterElements.length; ++ii) {
    if(repeaterElements[ii]) {
      repeaterElements[ii].waveIndex = ii
    }
  }
}

function moveDown(repeater) {
  if(!(selectedItem < repeaterElements.length-1) || selectedItem == -1 || selectedItem>=repeaterElements.length)
    return

  // remove item from list and store the element temporary
  var item = 0
  if(repeaterElements[selectedItem]) {
    item = repeaterElements[selectedItem]
    repeaterElements.splice(selectedItem,1)
  }

  // Insert below
  selectedItem++
  repeaterElements.splice(selectedItem, 0, item);

  updateRepeaterElementsOrdering()

  if(repeaterElements.length<=0) {
    selectedItem = -1
  }
  updateSelectedColor(repeater)
}

function moveUp(repeater) {
  if(selectedItem <= 0 || selectedItem == -1)
    return

  // remove item from list and store the element temporary
  var item = 0
  if(repeaterElements[selectedItem]) {
    item = repeaterElements[selectedItem]
    repeaterElements.splice(selectedItem,1)
  }

  // Insert below
  selectedItem--
  repeaterElements.splice(selectedItem, 0, item);

  updateRepeaterElementsOrdering()

  if(repeaterElements.length<=0) {
    selectedItem = -1
  }
  updateSelectedColor(repeater)
}
