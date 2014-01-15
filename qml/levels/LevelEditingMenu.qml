import QtQuick 1.1


Item {
    id: levelEditingMenu

    // it fills the whole scene
    anchors.fill: parent

    // this will be used for the initial text of TextEdit for saving the level
    // DONE: maybe connect this with dynamicLevelLoader.currentLevelName!? this is only used for displaying the name with a Text item, so the visual representation of the loaded level!
    property string currentLevelName: levelEditor.currentLevelNameString

    // will either be set to "saveLevel", or "duplicateLevel" depending on which button was clicked
    // the corresponding function is then called for levelEditor
    property string textInputMode: ""

    // the level name should always be presented to the user
    Text {
        // the cocos label position is too much left!        
        anchors.horizontalCenter: levelEditingMenu.horizontalCenter
        y: 10

        // uncomment the below for debugging
        text: qsTr("Current level: " + currentLevelName) // + ", id:" + currentLevelId + ", state:" + levelEditingMenu.state
        color: "white"
        //font.pixelSize: 10
    }

    Column {
        id: menuItems
        spacing: 2
        anchors.centerIn: parent
        // this is added in LevelEditingMenuButton now, as it should get darker when pressed which fits better to LevelEditingMenuButton than handling it here
//        opacity: 0.9 // make it opaque so the obstacles are still visible when the menu is enabled

        LevelEditingMenuButton {
            id: saveLevelButton
            text: "Save Level"
            onClicked: {
                console.debug("saveLevelButton was clicked! current state:", levelEditingMenu.state);
                flurry.logEvent("LevelEditingMenu.SaveLevel")

                textInputMode = "saveLevel"

                // avoid multiple calls to displayMessageBox
                if(levelEditingMenu.state === "enteringLevelName")
                    return;

                levelEditingMenu.state = "enteringLevelName";
                nativeUtils.displayTextInput(qsTr("Level name:"), "", currentLevelName);

            }
        }

        LevelEditingMenuButton {
            text: "Duplicate Level"
            onClicked: {
                console.debug("duplicateLevelButton was clicked! current state:", levelEditingMenu.state);
              flurry.logEvent("LevelEditingMenu.DuplicateLevel")

                textInputMode = "duplicateLevel"

                // avoid multiple calls to displayMessageBox
                if(levelEditingMenu.state === "enteringLevelName")
                    return;

                levelEditingMenu.state = "enteringLevelName";
                nativeUtils.displayTextInput(qsTr("Level name:"), "", currentLevelName);

            }
        }

        LevelEditingMenuButton {
            text: "Reset Level"
            onClicked: {
              flurry.logEvent("LevelEditingMenu.ResetLevel")
              // all dynamic entities are removed
              entityManager.removeAllEntities()
              //entityManager.removeEntitiesByFilter(dynamicLevelLoader.filteredEntityTypes);
            }
        }
        LevelEditingMenuButton {
            text: "Remove Level"
            onClicked: {
              flurry.logEvent("LevelEditingMenu.RemoveLevel")
              // TODO: we could open a messageBox so the user has to confirm the removal
              levelEditor.removeCurrentLevel();
            }
        }
        LevelEditingMenuButton {
            text: "Clear All Levels"
            visible: developerBuild
            onClicked: {
              // this wouldnt be needed, as it is only used during development
              flurry.logEvent("LevelEditingMenu.ClearAllLevels")
              levelEditor.clearAllLevels()
            }
        }
        LevelEditingMenuButton {
          text: "Export Level"
          // only make this visible for the developer of Squaby, will not be available for end users (which can save it locally)
          // the export functionality is used to store levels as json files, and then pack them with the application binary
          visible: developerBuild
          onClicked: {
            // this wouldnt be needed, as it is only used during development
            flurry.logEvent("LevelEditingMenu.ExportLevel")
            levelEditor.exportLevelAsFile("levels/" + currentLevelName)
          }
        }

        LevelEditingMenuButton {
            text: "Back to Levels"
            onClicked: {

              // TODO: is this problematic?

              // go back to the level selection scene
              window.state = "levels";
            }
        }
    } // end of Column

    Connections {
        target: nativeUtils
        onTextInputFinished: {
            console.debug("messageBox finished with OK", accepted, " and entered name:", enteredText);

            // check if in state enteringLevelName, because a textInput could also be created from other states in the future
            if(accepted && levelEditingMenu.state === "enteringLevelName") {
              // save the level + the waypoints!
              //dynamicLevelLoader.saveLevel("ChriLevel01", {waypoints: level.pathEntity.waypoints})
              //dynamicLevelLoader.saveLevelWithCustomData(enteredText, {waypoints: level.pathEntity.waypoints})

              // if the name is not the same, a new level could be created - but rather allow changing the levelName here

              // the waypoints are stored in SquabyLevelBase now as customData!
              if(textInputMode === "saveLevel") {
                levelEditor.saveCurrentLevel({ levelMetaData: { levelName: enteredText }/*, customData: {waypoints: level.pathEntity.waypoints}*/ })
              } else {
                // here the textInputMode must be "duplicateLevel"
                levelEditor.duplicateCurrentLevel({ levelMetaData: { levelName: enteredText }/*, customData: {waypoints: level.pathEntity.waypoints}*/ })
              }

                console.debug("after saveLevel in textInputFinished");
            }

            levelEditingMenu.state  = "";
        }
    }

    states: [
        State {
            name: "levelSelection"
            PropertyChanges { target: levelSelection; visible: true}
            PropertyChanges { target: menuItems; visible: false}
        },
        State {
            name: "enteringLevelName"
            //PropertyChanges { target: menuItems; visible: false}
            //PropertyChanges { target: levelNameInput; visible: true}

        },
        State {
            name: "removeLevel"
        }

    ]

} // end of item
