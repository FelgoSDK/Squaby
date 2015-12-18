import QtQuick 2.0
import VPlay 2.0
import "../../common"
Item {
  id: levelEditingHud
  signal menuBackButtonClicked()
  signal deleteButtonClicked()
  signal cloudUploadButtonClicked()

  state: ""

  states: [
    // the default state shows the weaponsRow, so the available towers that can be built
    State {
      name: ""
      StateChangeScript {
        script: {
          hud.changeToBuildMenu()
        }
      }
    },
    State {
      name: "baseState"
      PropertyChanges { target: settingsButton; visible: false}
      PropertyChanges { target: squabiesButton; visible: false}
      PropertyChanges { target: pathCreationButton; visible: false}
      PropertyChanges { target: obstaclesButton; visible: false}
      PropertyChanges { target: cloudUploadButton; visible: false}
    },
    State {
      name: "GameSettings"
      extend: "baseState"
      StateChangeScript {
        script: {
          hud.changeFromBuildMenu()
        }
      }
    },
    State {
      name: "SquabySettings"
      extend: "baseState"
      StateChangeScript {
        script: {
          hud.changeFromBuildMenu()
        }
      }
    },
    State {
      name: "WaveSettings"
      extend: "baseState"
      StateChangeScript {
        script: {
          hud.changeFromBuildMenu()
        }
      }
    },
    State {
      name: "PathCreation"
      extend: "baseState"
      PropertyChanges { target: pathCereationItem; visible: true}
      PropertyChanges { target: pathCreationOverlay; visible: true}
      StateChangeScript {
        script: {
          hud.changeToBuildMenu()
        }
      }
    },
    State {
      name: "ObstacleCreation"
      extend: "baseState"
      PropertyChanges { target: obstaclesRow; visible: true}
      StateChangeScript {
        script: {
          hud.changeToBuildMenu()
        }
      }
    }
  ]


  // can either be "enterLevelName", "enterLevelNameInPublishing" or "enterUserName"
  property string dialogState
  property bool publishLevelLocally: false

  // this may also be called after updating the username
  function publishLevel(publishLevelNow) {
    dialogState = ""
    levelEditingHud.messageBoxID = ""
    publishLevelLocally = publishLevelNow

    if(levelEditor.currentLevelNameString === qsTr("MyLevel")) {
      flurry.logEvent("LevelEditor.Publish","NoLevelName")
      // prevent publishing with levelName unnamed
      dialogState = "enterLevelNameInPublishing"
        nativeUtils.displayTextInput("Enter levelName", "Enter a level name before you can "+(publishLevelNow?"publish":"save")+" this level. Choose a name that expresses what makes your level special.", "", levelEditor.currentLevelNameString)
      return
    }

    if(!gameNetwork.isUserNameSet(gameNetwork.userName)) {
      flurry.logEvent("LevelEditor.Publish","NoAuthor")
      // prevent publishing if no authorName was set!
      dialogState = "enterUserName"
      nativeUtils.displayTextInput("Enter your name", "Before you can "+(publishLevelNow?"publish":"save")+" this level, enter your userName that will be shown to all other players.", "", gameNetwork.userName)
      return
    }

    // first save the level then export it
    saveCurrentLevel()

    if(publishLevelNow) {
      // use export funktion in developer mode here atm.
      // is only used during development
      if(developerBuild) {
        flurry.logEvent("LevelEditingMenu.ExportLevel")
        levelEditor.exportLevelAsFile("levels/" + levelEditor.currentLevelNameString )
      }

      flurry.logEvent("LevelEditor.Publish","Level",levelEditor.currentLevelNameString)
      levelEditor.publishLevel()
    } else {
      // not in editing state anymore (prevents spawning squabies)
      scene.state = ""
      // go back to the level selection scene
      window.state = "levels";
    }
  }

  Connections {
    target: itemEditor
    onBackButtonClicked: {
      menuBackButtonClicked()
    }
  }

  // the result of the messageBox is received with a connection to the signal messageBoxFinished
  Connections {
    target: nativeUtils

    // this signal has the parameter accepted, telling if the Ok button was clicked
    onMessageBoxFinished: {
      if(accepted) {
        if(levelEditingHud.messageBoxID === "save") {
          publishLevel(false)
        }
      }
      levelEditingHud.messageBoxID = ""
    }
    onTextInputFinished: {
      if(accepted) {

        if(dialogState === "enterLevelName" || dialogState === "enterLevelNameInPublishing") {

          if(enteredText.indexOf(' ') !== -1) {
            flurry.logEvent("LevelEditingMenu.Rename.Publish","White.Space")
            nativeUtils.displayMessageBox(qsTr("Invalid level name"), qsTr("No whitespaces allowed!"))
            return
          }

          if(enteredText.length > 20) {
            flurry.logEvent("LevelEditingMenu.Rename.Publish","Too.Long")
            nativeUtils.displayMessageBox(qsTr("Invalid level name"), qsTr("A maximum of 20 characters is allowed!"))
            return
          }

          if(gameNetwork.isValidUserInput(enteredText) && enteredText !== qsTr("MyLevel")) {
            levelEditor.saveCurrentLevel( {levelMetaData: {levelName: enteredText}} )

            if(dialogState ==="enterLevelNameInPublishing") {
              // if the level name was changed in the publishing process, continue with publishing
              publishLevel(publishLevelLocally)
            }
          } else {
            flurry.logEvent("LevelEditingMenu.Rename.Publish","Invalid.Name")
            nativeUtils.displayMessageBox(qsTr("Invalid level name"), qsTr("You entered an invalid level name. Please do not use any swear words for your level name."))
          }
        } else if(dialogState === "enterUserName") {

          var validName = gameNetwork.updateUserName(enteredText)
          if(!validName) {
            flurry.logEvent("LevelEditingMenu.Author.Publish","Invalid.UserName")
            // maybe open another textInput here - this would then loop until a valid username is entered
            nativeUtils.displayMessageBox(qsTr(""), qsTr("You entered an invalid username, please try a different one. The username must not start with a number or contain any swearwords."))
          } else {
            //continue publishing the level - no the check for valid userName will pass and the level gets published
            publishLevel(publishLevelLocally)
          }

        }
      }
      dialogState = ""
    }
  }

  property string messageBoxID: ""

  onMenuBackButtonClicked: {
    if(levelEditingHud.state !== "" || scene.cameFromLevelEditing || itemEditor.currentEditableType === "Performance Settings") { // scene.cameFromLevelEditing when using performance menu ingame in levelEditing mode
      levelEditingHud.state = ""
    } else {
      saveDialog.opacity = 1
    }
  }

  onCloudUploadButtonClicked: {
    if(!scene.level.pathEntity.waypoints.length && !scene.level.waves.length) {
      flurry.logEvent("LevelEditor.Publish","NoPath.NoWaves")
      levelEditingHud.messageBoxID = "upload"
      nativeUtils.displayMessageBox(qsTr("Upload Level"), qsTr("No path and waves are set!"),0)
    } else if(!scene.level.pathEntity.waypoints.length) {
        flurry.logEvent("LevelEditor.Publish","NoPath")
      levelEditingHud.messageBoxID = "upload"
      nativeUtils.displayMessageBox(qsTr("Upload Level"), qsTr("No path is set!"),0)
    } else if(!scene.level.waves.length) {
      flurry.logEvent("LevelEditor.Publish","NoWaves")
      levelEditingHud.messageBoxID = "upload"
      nativeUtils.displayMessageBox(qsTr("Upload Level"), qsTr("No waves are set!"),0)
    } else {
      publishDialog.opacity = 1
    }
  }

  function saveCurrentLevel() {
    flurry.logEvent("LevelEditingMenu.SaveLevel")

    levelEditor.saveCurrentLevel({ levelMetaData: { levelName: levelEditor.currentLevelNameString } })
  }

  SingleSquabySpriteButton {
    id: menuBackButtonItem
    anchors.verticalCenter: parent.verticalCenter
    spriteInSpriteSheetSource: "editor-back.png"

    onClicked: {
      menuBackButtonClicked()
    }
  }
  Item {
    width: parent.width-menuBackButtonItem.width
    height: parent.height
    anchors.left: menuBackButtonItem.right

    Row {
      anchors.centerIn: parent
      spacing: 4
      SingleSquabySpriteButton {
        id: settingsButton
        spriteInSpriteSheetSource: "editor-settings.png"

        onClicked: {
          levelEditingHud.state = "GameSettings"
          itemEditor.currentEditableType = "GameSettings"
          itemEditor.searchAndDisplayHeaderGroup("environment")
        }
      }

      SingleSquabySpriteButton {
        id: squabiesButton
        spriteInSpriteSheetSource: "editor-waves.png"

        onClicked: {
          levelEditingHud.state = "WaveSettings"
          itemEditor.currentEditableType = "WaveSettings"
          itemEditor.searchAndDisplayHeaderGroup("waves")
        }
      }

      SingleSquabySpriteButton {
        id: pathCreationButton
        spriteInSpriteSheetSource: "editor-path.png"

        onClicked: {
          levelEditingHud.state = "PathCreation"
        }
      }

      SingleSquabySpriteButton {
        id: obstaclesButton
        spriteInSpriteSheetSource: "editor-decoration.png"

        onClicked: {
          levelEditingHud.state = "ObstacleCreation"
        }
      }

      SingleSquabySpriteButton {
        id: cloudUploadButton
        spriteInSpriteSheetSource: "editor-upload.png"

        onClicked: {
          cloudUploadButtonClicked()
        }
      }

    }
  }

  Item {
    width: parent.width-menuBackButtonItem.width
    height: parent.height
    anchors.left: menuBackButtonItem.right

    Text {
      id: pathCereationItem
      text: qsTr("Drag your path from the green to the red spot!")
      font.family: hudFont.name
      font.pixelSize: 10
      color: "white"
      anchors.centerIn: parent
      visible: false
    }
  }

  Item {
    width: parent.width-menuBackButtonItem.width
    height: parent.height
    anchors.left: menuBackButtonItem.right

    Row {
      id: obstaclesRow

      anchors.centerIn: parent

      visible: false

      BuildObstacleButton {
        toCreateEntityType: "../../entities/Obstacle.qml"
        variationType: "teddy"
        source: "../../../assets/img/backgrounds/teddy.png"
      }
      BuildObstacleButton {
        toCreateEntityType: "../../entities/Obstacle.qml"
        variationType: "choco"
        source: "../../../assets/img/backgrounds/choco-right.png"
      }
      BuildObstacleButton {
        toCreateEntityType: "../../entities/Obstacle.qml"
        variationType: "pillow"
        source: "../../../assets/img/backgrounds/pillow.png"
      }
      BuildObstacleButton {
        toCreateEntityType: "../../entities/Obstacle.qml"
        variationType: "soccerball"
        source: "../../../assets/img/backgrounds/soccerball-left.png"
      }
      BuildObstacleButton {
        toCreateEntityType: "../../entities/Obstacle.qml"
        variationType: "toyblocks"
        source: "../../../assets/img/backgrounds/toyblocks-left.png"
      }
      BuildObstacleButton {
        toCreateEntityType: "../../entities/Obstacle.qml"
        variationType: "../../../assets/img/backgrounds/book"
        source: "../../../assets/img/backgrounds/book-left.png"
      }
    } // end of obstacles row*/
  }
}
