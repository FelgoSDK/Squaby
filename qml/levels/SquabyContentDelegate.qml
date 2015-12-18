import QtQuick 2.0
import VPlay 2.0
import "../common"

Item {
  id: contentDelegate
  objectName: "contentDelegate"

  width: parent.width
  height: parent.height

  // === public properties ===
  // needed by item editor to use the content delegate correctly.

  property alias groupContainer: contentArea

  /*!
    The property prevButtonVisible defines if the previous group button is visible or not. The default values is true.
    */
  property bool prevButtonVisible: false
  /*!
    The property nextButtonVisible defines if the next group button is visible or not. The default values is true.
    */
  property bool nextButtonVisible: false
  /*!
    The signal headerPrev forwards a button press to display the previous group. The signal is used by the ItemEditor to change the active group to the previous one in the editor storage.
    */
  signal headerPrev;
  /*!
    The signal headerNext forwards a button press to display the next group. The signal is used by the ItemEditor to change the active group to the next one in the editor storage.
    */
  signal headerNext;

  property real __headerHeight: parent.width/10

  property variant currentItemEditor: parent
  property variant editableTypeList

  // Background
  Loader {
    width: parent.width
    height: contentDelegate.height
    sourceComponent: currentItemEditor.itemEditorStyle.contentDelegateBackground
  }

  onVisibleChanged: {
    // to avoid problems with settings of squabies which get changed but are not applied to pooled entites we have to remove all of them here. The problem is that the gamesettings are asign during creation, but the binding does not seem to work so it needs to be reasigned/created. See SquabyTypes.qml where this transaction is used.
    if(!visible && currentItemEditor && currentItemEditor.currentEditableType === "SquabySettings") {
      entityManager.removeAllPooledEntities()
    }
  }

  Column {
    width: parent.width

    Item {
      id: headerBackgroundItem

      width: parent.width
      height: __headerHeight

      visible: !(currentItemEditor.currentEditableType === "Performance Settings")


      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -buttonSettings.height*2/4

        /*MenuButton {
          source: "../../assets/img/level-base.png"
          active: currentItemEditor.currentGroup === "settings"
          Text {
            text: qsTr("Local")
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            font.family: jellyFont.name
            font.pixelSize: 18
          }
          onClicked: {
            currentItemEditor.currentEditableType = "GameSettings"
            currentItemEditor.searchAndDisplayHeaderGroup("settings")
          }
        }
        MenuButton {
          source: "../../assets/img/level-base.png"
          active: currentItemEditor.currentGroup === "waveData"
          Text {
            text: qsTr("Wave")
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            font.family: jellyFont.name
            font.pixelSize: 18
          }
          onClicked: {
            currentItemEditor.currentEditableType = "GameSettings"
            currentItemEditor.searchAndDisplayHeaderGroup("waveData")
          }
        }*/
        MenuButton {
          id: buttonSettings
          source: "../../assets/img/level-base.png"
          active: currentItemEditor.currentGroup === "environment"

          MultiResolutionImage {
            source: "../../assets/img/menu-settings.png"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
          }

          onClicked: {
            currentItemEditor.currentEditableType = "GameSettings"
            currentItemEditor.searchAndDisplayHeaderGroup("environment")
          }
        }
        MenuButton {
          source: "../../assets/img/level-base.png"
          active: currentItemEditor.currentGroup === "waves"

          MultiResolutionImage {
            source: "../../assets/img/menu-waves.png"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
          }

          onClicked: {
            currentItemEditor.currentEditableType = "WaveSettings"
            currentItemEditor.searchAndDisplayHeaderGroup("waves")
          }
        }
        MenuButton {
          source: "../../assets/img/level-base.png"
          active: currentItemEditor.currentEditableType === "SquabySettings"

          MultiResolutionImage {
            source: "../../assets/img/menu-squabys.png"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
          }

          onClicked: {
            currentItemEditor.currentEditableType = "SquabySettings"
            currentItemEditor.searchAndDisplayHeaderGroup("squabyYellow")
          }
        }

        /*MenuButton {
            source: "../../assets/img/level-base.png"
            //active:
            Text {
              text: qsTr("Towers")
              anchors.bottom: parent.bottom
              anchors.bottomMargin: 10
              anchors.horizontalCenter: parent.horizontalCenter
              color: "white"
              font.family: jellyFont.name
              font.pixelSize: 18
            }
            onClicked: {
              currentItemEditor.currentEditableType = "TowerSettings"
              currentItemEditor.searchAndDisplayHeaderGroup("nailgun")
            }
          }*/
      }
    }
    Item {
      id: contentBackground

      width: parent.width
      height: currentItemEditor.currentEditableType === "Performance Settings" ? contentDelegate.height : contentDelegate.height-__headerHeight

      Item {
        id: topRect
        width: parent.width
        height: contentDelegate.height-__headerHeight-scene.hudHeight
      }
      Item {
        id: hudBackground
        anchors.top: topRect.bottom
        x: parent.width/3/2
        width: parent.width-parent.width/3+parent.width/3/2
        height: scene.hudHeight
      }

      Item {
        id: contentArea
        anchors.horizontalCenter: parent.horizontalCenter
        // alias is neccessary that the GroupDelegate is able to access the editor
        property alias currentItemEditor: contentDelegate.currentItemEditor
        width: parent.width
        height: contentDelegate.height-__headerHeight-((currentItemEditor.currentEditableType === "TowerSettings" || currentItemEditor.currentEditableType === "SquabySettings") ? (menuBackButtonItem.height+10+20) : 0)
      }

      MenuButton {
        id: menuBackButtonItem
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        source: "../../assets/img/menu-back.png"
        onClicked: {
          currentItemEditor.backButtonClicked()
          hud.changeToBuildMenu()
        }
      }

      /*Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: hudBackground.y-20
        visible: currentItemEditor.currentEditableType === "TowerSettings"
        spacing: 5

        SquabyImageIcon {
          source: "../../assets/img/squabies/nailgun.png"
          onClicked: {
            currentItemEditor.searchAndDisplayHeaderGroup("nailgun")
          }
          opacity: currentItemEditor.currentGroup === "nailgun" ? 1.0 : 0.5
        }
        SquabyImageIcon {
          source: "../../assets/img/squabies/flamethrower.png"
          onClicked: {
            currentItemEditor.searchAndDisplayHeaderGroup("flamethrower")
          }
          opacity: currentItemEditor.currentGroup === "flamethrower" ? 1.0 : 0.5
        }
        SquabyImageIcon {
          source: "../../assets/img/squabies/taser.png"
          onClicked: {
            currentItemEditor.searchAndDisplayHeaderGroup("taser")
          }
          opacity: currentItemEditor.currentGroup === "taser" ? 1.0 : 0.5
        }
        SquabyImageIcon {
          source: "../../assets/img/squabies/tesla.png"
          onClicked: {
            currentItemEditor.searchAndDisplayHeaderGroup("tesla")
          }
          opacity: currentItemEditor.currentGroup === "tesla" ? 1.0 : 0.5
        }
        SquabyImageIcon {
          source: "../../assets/img/squabies/turbine.png"
          onClicked: {
            currentItemEditor.searchAndDisplayHeaderGroup("turbine")
          }
          opacity: currentItemEditor.currentGroup === "turbine" ? 1.0 : 0.5
        }
      }*/

      Item {
        id: texts
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: parent.width - menuBackButtonItem.width - 10
        height: hud.height
        visible: currentItemEditor.currentEditableType === "GameSettings"
        Column {
          anchors.verticalCenter: parent.verticalCenter
          x: parent.width/4
          width: texts.width
          Text {
            width: parent.width
            text: "ID (Devmode only)"+levelEditor.currentLevelId
            color: "white"
            visible: developerBuild
            font.pixelSize: 12
          }
          Item {
            width: parent.width/2
            height: nameOfLevel.height

            Text {
              id: nameOfLevel
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              text: "Level Name: "
              color: "white"
            }
            Item {
              anchors.left: nameOfLevel.right
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width-nameOfLevel.width
              height: parent.height
              ResponsiveText {
                id: levelName
                text: levelEditor.currentLevelNameString
                color: "white"
              }
            }
            MouseArea {
              anchors.fill: parent
              onClicked:  {
                dialogState = "renameLevel"
                flurry.logEvent("LevelEditor.Settings","LevelName",levelEditor.currentLevelNameString)
                nativeUtils.displayTextInput("Enter levelName", "Enter the level name. Choose a name that expresses what makes your level special.", "", levelEditor.currentLevelNameString)
              }
            }
          }
        }

        Row {
          anchors.right: parent.right
          anchors.rightMargin: 10
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 10

          MenuButton {
            source: "../../assets/img/editor-smaller-restore.png"
            onClicked: {
              dialogState = "resetLevel"
              nativeUtils.displayMessageBox("Reset Level", "Do you want to reset the level to the last saved state?", 2)
            }
          }
          MenuButton {
            source: "../../assets/img/editor-smaller-trash.png"
            onClicked: {
              dialogState = "deleteLevel"
              nativeUtils.displayMessageBox("Delete Level", "Do you really want to delete this level?", 2)
            }
          }
        }
      }

      Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        width: parent.width - menuBackButtonItem.width - 10
        height: squabyRow.height
        visible: currentItemEditor.currentEditableType === "SquabySettings"

        Row {
          id: squabyRow
          anchors.centerIn: parent
          spacing: 5

          SquabyImageIcon {
            source: "../../assets/img/squabies/squ_yellow.png"
            onClicked: {
              currentItemEditor.searchAndDisplayHeaderGroup("squabyYellow")
            }
            opacity: currentItemEditor.currentGroup === "squabyYellow" ? 1.0 : 0.5
          }
          SquabyImageIcon {
            source: "../../assets/img/squabies/squ_orange.png"
            onClicked: {
              currentItemEditor.searchAndDisplayHeaderGroup("squabyOrange")
            }
            opacity: currentItemEditor.currentGroup === "squabyOrange" ? 1.0 : 0.5
          }
          SquabyImageIcon {
            source: "../../assets/img/squabies/squ_red.png"
            onClicked: {
              currentItemEditor.searchAndDisplayHeaderGroup("squabyRed")
            }
            opacity: currentItemEditor.currentGroup === "squabyRed" ? 1.0 : 0.5
          }
          SquabyImageIcon {
            source: "../../assets/img/squabies/squ_green.png"
            onClicked: {
              currentItemEditor.searchAndDisplayHeaderGroup("squabyGreen")
            }
            opacity: currentItemEditor.currentGroup === "squabyGreen" ? 1.0 : 0.5
          }
          SquabyImageIcon {
            source: "../../assets/img/squabies/squ_blue.png"
            onClicked: {
              currentItemEditor.searchAndDisplayHeaderGroup("squabyBlue")
            }
            opacity: currentItemEditor.currentGroup === "squabyBlue" ? 1.0 : 0.5
          }
          SquabyImageIcon {
            source: "../../assets/img/squabies/squ_grey.png"
            onClicked: {
              currentItemEditor.searchAndDisplayHeaderGroup("squabyGrey")
            }
            opacity: currentItemEditor.currentGroup === "squabyGrey" ? 1.0 : 0.5
          }
        }
      }
    }
  }

  property string dialogState

  // the result of the messageBox is received with a connection to the signal messageBoxFinished
  Connections {
    target: nativeUtils

    onMessageBoxFinished: {
      if(accepted) {
        if(dialogState === "resetLevel") {
          for(var ii = 0; ii < levelEditor.authorGeneratedLevels.length; ++ii) {
            if(levelEditor.authorGeneratedLevels[ii].levelId == levelEditor.currentLevelId) {
              flurry.logEvent("LevelEditor.ResetLevel")
              reloadLevel = true
              editAuthorLevel = true
              twoPhaseLevelLoader.startLoadingLevel(false,levelEditor.authorGeneratedLevels[ii])
              break
            }
          }
        } else if(dialogState === "deleteLevel") {
          // first save it, so it is ensured that there is also a level present which can be deleted!
          flurry.logEvent("LevelEditor.DeleteLevel")

          levelEditor.saveCurrentLevel({ levelMetaData: { levelName: levelEditor.currentLevelNameString } })

          flurry.logEvent("LevelEditingMenu.RemoveLevel")
          // TODO: we could open a messageBox so the user has to confirm the removal
          levelEditor.removeCurrentLevel();
          // not in editing state anymore (prevents spawning squabies
          scene.state = ""
          // go back to the level selection scene
          window.state = "levels";
        }
      }
      // reset the dialogState, no matter if accepted or not
      dialogState = ""
    }

    onTextInputFinished: {
        if(accepted && dialogState == "renameLevel") {


        if(enteredText.indexOf(' ') !== -1) {
          flurry.logEvent("LevelEditingMenu.Rename","White.Space")
          nativeUtils.displayMessageBox("Invalid level name", "No whitespaces allowed!")
          return
        }

        if(enteredText.length > 20) {
          flurry.logEvent("LevelEditingMenu.Rename","Too.Long")
          nativeUtils.displayMessageBox("Invalid level name", "A maximum of 20 characters is allowed!")
          return
        }

        if(gameNetwork.isValidUserInput(enteredText) && enteredText !== qsTr("MyLevel")) {
          levelEditor.saveCurrentLevel( {levelMetaData: {levelName: enteredText}} )
        } else {
          flurry.logEvent("LevelEditingMenu.Rename","Invalid.Name")
          nativeUtils.displayMessageBox("Invalid level name", "You entered an invalid level name. Please do not use any swear words for your level name.")
        }
      }
      // reset the dialogState, no matter if accepted or not
      dialogState = ""
    }
  }

}
