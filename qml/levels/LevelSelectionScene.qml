import QtQuick 1.1
import VPlay 1.0
import "../otherScenes" // for MainMenuButton and SquabySceneBase

SquabySceneBase {
  id: levelSelectionScene

  // gets set from the MainMenuScene, depending which mainmenu button was clicked (application levels, author levels, etc.)
  // is used to disable the new level button for application levels
  // currently only user levels are used, so set this initally
  property string storageLocation: levelEditor.applicationJSONLevelsLocation

  // gets set from the levelEditor, once it has finished loading
  // instead, use the below function, which sets a binding and thus the model is always in sync with levelEditor
  //property alias levelModel: levelListRepeater.model

  // this is used as a binding for the levelListRepeater.model property
  // every time the storageLocation changes, the model will also update
  // if the model in levelEditor then changes afterwards (e.g. authorGeneratedLevels change because a new level was added), the change will be forwarded to the model as it is a binding
  function storageFromLocation() {
    console.debug("LevelSelectionScene: storageLocation changed to", storageLocation)
    if(storageLocation === levelEditor.authorGeneratedLevelsLocation) {
      return levelEditor.authorGeneratedLevels
    } else if(storageLocation === levelEditor.applicationQMLLevelsLocation) {
      return levelEditor.applicationQMLLevels
    } else if(storageLocation === levelEditor.applicationJSONLevelsLocation) {
      return levelEditor.applicationJSONLevels
    } else {
      console.debug("ERROR: LevelSelectionScene: unknown storageLocation:", storageLocation)
      return null
    }
  }

  state: "exited"

  onBackPressed: {
    levelSelectionScene.state = "exited"
    // make this with a timer, otherwise the animation wouldnt be played to the end!
    sceneChangeTimer.start()
  }

  // is not used at the moment, but could be used to modify the curren titem
  property variant currentlySelectedLevelItem

  // holds the levelMetaData of the selected level
  property variant currentlySelectedLevelData

  MultiResolutionImage {
    source: "../img/bgSubmenu-sd.png"
    anchors.centerIn: parent
    property int pixelFormat: 3
  }

  Text {
    text: qsTr("Select Level")
    font.family: jellyFont.name
    color: "white"
    font.pixelSize: 60
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 20
  }


  Flickable {
    id: flickable
    //anchors.fill: parent
    anchors.centerIn: parent
    // never make the flickable bigger than the parent, if the columns is smaller (so less items), the flickable should not be as big as the item!
    width: (parent.width < grid.width) ? parent.width : grid.width
    height: grid.height

    contentWidth: grid.width
    contentHeight: grid.height
    flickableDirection: Flickable.HorizontalFlick

    Row {
      id: grid

      spacing: 20

      anchors.centerIn: parent

      // Just a placeholder item for positioning cause row can't set an inner padding?
      Item {
        width: levelSelectionScene.width / 2 - 97 / 2 - grid.spacing / 2
        height: 97
      }

      // We use this for creating a new level
      SingleLevelItem {
        itemLevelName: qsTr("New Level")

        rating: -1
        maxScoreInLevel: -1

        // only display the new button for author levels
        visible: storageLocation === levelEditor.authorGeneratedLevelsLocation

        onClicked: {
          console.debug("New level clicked...");
          // to track how often the players select the new level selection
          flurry.logEvent("LevelSelection.NewLevels.clicked")
          twoPhaseLevelLoader.startLoadingLevel(true, { levelMetaData: { levelName: "newLevelName", levelBaseName: "DynamicLevel01" } })
        }
      }

      Repeater {
        id: levelListRepeater

        // this gets changed from the outside, based on which levels should be displayed
        // no default value is needed - must be set from the outside with the levelModel alias anyway
        //model: levelEditor.applicationQMLLevels
        model: storageFromLocation()

        onModelChanged: {
          console.debug("LevelSelectionScene: levelModel for to display levels changed")
          console.debug("new model value:", JSON.stringify(model))
          loadItemWithCocos(levelListRepeater.parent)
        }

        delegate: levelItemDelegate
      }

      Item {
        // just a placeholder item
        width: levelSelectionScene.width / 2 - 97 / 2 - grid.spacing / 2
        height: 97
      }
    }
  }

  Component {
    id: levelItemDelegate
    SingleLevelItem {
      // the id is needed, so w e can copy a reference to it as currentlySelectedLevelItem!
      id: singleLevelItem

      // NOTE: it is not allowed to use the same name for the property of the SingleLevelItem, and for the item from the model data object!
      // so this does NOT work: levelName: levelName - instead, use another name for the key for the SingleItem!
      itemLevelName: modelData.levelName

      itemLevelId: modelData.levelId

      onClicked: {
        currentlySelectedLevelItem = singleLevelItem
        singleLevelSelected(modelData)
      }
    }
  }

  MainMenuButton {
    id: backButton

    text: qsTr("Back")

    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10

    onClicked: {
      console.debug(text, " button clicked")

      levelSelectionScene.state = "exited"
      // make this with a timer, otherwise the animation wouldnt be played to the end!
      sceneChangeTimer.start()
    }

    Timer {
      id: sceneChangeTimer
      interval: backButton.slideDuration
      onTriggered: window.state = "main"
    }
  }

  MainMenuButton {
    id: shareButton

    text: qsTr("Share Levels!")

    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10

    textItem.anchors.left: shareButton.left
    textItem.anchors.leftMargin: 15

    x: 260

    onClicked: {
      console.debug(text, " button clicked")
      flurry.logEvent("LevelSelectionScene.SharePressed")

      nativeUtils.displayMessageBox("Coming soon!", "You will soon be able to share your levels with your friends and the whole Squaby community! So stay tuned and always update to the latest version :)")
    }
  }


  // Called when scene is displayed
  function enterScene() {
    state = "entered"
  }

  function singleLevelSelected(levelData) {
    console.debug("LevelSelectionScene: single level selected, switch to state game and load the level with LevelEditor")
    flurry.logEvent("LevelSelection.LoadLevel.clicked")
    twoPhaseLevelLoader.startLoadingLevel(false, levelData)
  }

  states: [
    State {
      name: "entered"
      PropertyChanges { target: grid; opacity: 1 }
      StateChangeScript {
        script: {
          backButton.slideIn()
        }
      }
    },
    State {
      name: "exited"
      StateChangeScript {
        script: {
          backButton.slideOut()
        }
      }
    }
  ]

  transitions: Transition {
    NumberAnimation {
      duration: 900
      property: "opacity"
      easing.type: Easing.InOutQuad
    }
  }
}
