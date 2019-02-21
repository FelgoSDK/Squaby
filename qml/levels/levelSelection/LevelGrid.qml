import QtQuick 2.0
import Felgo 3.0

Flickable {
  id: levelList

  contentWidth: grid.width
  contentHeight: grid.height+offset.height
  flickableDirection: Flickable.HorizontalFlick//Flickable.VerticalFlick
  interactive: grid.width > width
  boundsBehavior: Flickable.StopAtBounds
  property alias grid: grid

  /*!
    Connect this property with either LevelEditor::authorGeneratedLevels, LevelEditor::applicationJSONLevels or LevelEditor::applicationQMLLevels. The level array will then be displayed with the levelItemDelegate. See \l{Example Usage} for an example.
   */
  property variant levelMetaDataArray: levelScene.levelArrayFromState()

  /*!
    This alias property provides access to the \l Column element used for the level list. You can change the default spacing for example from 2 to any other value.

    For a reference how the LevelSelectionList is implemented see \l{LevelSelectionList Source Code}.
   */
  property alias levelColumn: grid

  /*!
    This property defines the delegate for a single level in the  LevelSelectionList. You can access all of the LevelData::levelMetaData like the \c levelName with \c modelData.levelName.

    By default, a SimpleButton is used for the delegate:
    \code
    SimpleButton {
      height: 20
      width: levelSelectionList.width
      text: modelData.levelName
      onClicked: {
        levelSelectionList.levelSelected(modelData)
      }
    }
    \endcode

    \note: It is required to set the height of the delegate so it can be displayed in the LevelSelectionList. The width of the delegate is set by default to the width you set for the LevelSelectionList.
   */
  property Component levelItemDelegate: LevelItem {}

  signal nextPageClicked
  signal prevPageClicked

  onLevelMetaDataArrayChanged: {
    updateList()
  }

  function updateList() {
    // display loading sign
    isLoading = true
    // delay rest to render the loading sign
    displayLoadingDelay.start()
  }

  // is used to only show the next and prev buttons when it is not loading
  property bool isLoading: false

  Timer {
    id: displayLoadingDelay
    interval: 50
    onTriggered: {
      // this removes the elements immediately to see an instant level loading screen
      // we could also leave the old data there!
      levelListRepeater.model = null

      if(levelMetaDataArray) {
        // display loading sign
        isLoading = true
        displayLoadingDelayReloading.start()
      } else {
        offIntervall.start()
      }
    }
  }
  Timer {
    id: displayLoadingDelayReloading
    interval: 50
    onTriggered: {
      levelListRepeater.model = levelMetaDataArray
    }
  }

  function nextPage() {
    if(page>=pageCount) return;
    page++
    // don't update the list immediately, but load first
    //updateList()

    nextPageClicked()
  }

  function prevPage() {
    if(page<=1) return;

    page--
    //updateList()

    prevPageClicked()
  }

  property int pageSize: -1
  property int page: 1
  property int pageCount: 1



  Grid {
    id: grid
    // the default spacing is 2 pixels
    //columns: 5
    rows: 2
    spacing: 6

    Repeater {
      id: levelListRepeater

      // delegate is the default property of Repeater
      delegate: levelItemDelegate

      onModelChanged: {
        console.debug("LevelList: listModel changed to", model, ", stringified:", JSON.stringify(model))
        // because the is so much asynchron that we can only estimate
        offIntervall.start()
      }
    }// end of Repeater
  }// end of Column

  Timer {
    id: offIntervall
    interval: 1000
    onTriggered: {
      isLoading = false
    }
  }

  Item {
    id: offset
    width: parent.width
    height: 100
  }
}// end of Flickable
