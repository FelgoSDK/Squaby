import QtQuick 2.0
import VPlay 2.0
import "../levels" // contains the LevelLoader
import "../balancing"
import "hud"
import "../otherScenes" // for SquabySceneBase
import "../common"
SquabySceneBase {
    id: scene

    property alias level: level
    property alias hud: hud // needs to be accessed from the towers when they are clicked to update the upgrade menu

    // set it as the level, because there the obstacles are defined!
    property alias entityContainer: level
    property alias itemEditor: itemEditor
    property alias tutorials: tutorials

    // the "logical" height of the scene is 320-64 = 256!
    property int hudHeight: 64


    // this gets set from LevelEditingMenu, when the user clicks on Game Mode to test the level
    // it is reset in exitScene()
    property bool cameFromLevelEditing: false

    // this is set by the scene when a wave was defeated if endless game is allowed or not so it can be used in the defeatedScene to show or hide the endless game button.
    property bool endlessGameAllowed: false

    // signal sent from SquabyCreatorLogic if the last wave was sent
    signal lastWaveSend
    // signal sent from SquabyCreator if last wave was sent, no looping gameplay is used and all squabies are killed
    signal changeToNextLevel

    onLastWaveSend: {
      endlessGameAllowed = true
      showWaveDefeatedScene()
    }

    onChangeToNextLevel: {
      endlessGameAllowed = false
      showWaveDefeatedScene()
    }

    function loadNextLevel() {
      for(var ii = 0; ii < levelEditor.applicationJSONLevels.length; ++ii) {
        if(levelEditor.applicationJSONLevels[ii].levelId == level.nextLevelId) {
          twoPhaseLevelLoader.startLoadingLevel(false,levelEditor.applicationJSONLevels[ii])
          break
        }
      }
    }

    onBackButtonPressed: {
      if(scene.state !== "levelEditing") {
        showPauseScene();
      } else {
        if(saveDialog.opacity == 1) {
          saveDialog.opacity = 0
        } else if(publishDialog.opacity == 1) {
          publishDialog.opacity = 0
        } else {
          hud.levelEditingHud.menuBackButtonClicked()
        }
      }
    }

    // uncomment the following line for quick testing of different states
//    state: "levelEditing"

    // creates the squbies
    SquabyCreator {
        id: squabyCreator

        // NOTE: set this to true, when you want to test the real level creation with the final waves
        // do not enable it by default for testing logic of towers&squabies, but for balancing and the final game it should be enabled of course
        enabled: true
    }

    // if clicked in an empty area (so not on a tower), the upgradeMenu will disappear
    MouseArea {
        anchors.fill: parent        
        onClicked: {

            if(scene.state === "levelEditing") {
                // this forces the hud to disable a possibly selected obstacle and to show the obstacleBuildMenu again
                hud.state = "levelEditing";
                return;
            }

            // don't set scene state to "" in that case!
//            if(scene.state === "testLevelInLevelMode") {
//              hud.state = "buildTowers";
//              return;
//            }

            console.debug("SquabyScene: resetting the hud to default state because no tower was selected, so set upgrade menu to invisible");
            // also disable the ingame menu when clicked outside the ingame menu button area!
            scene.state = ""
            hud.state = "buildTowers"
        }
    }

    // use a BackgroundImage for performance improvements involving blending function and pixelFormat, especially important for Android!
    BackgroundImage {
        id:levelBackground
        source: "../../assets/img/floor-merged.png"

        // use this if the image should be centered, which is the most common case
        // if the image should be aligned at the bottom, probably the whole scene should be aligned at the bottom, and the image should be shited up by the delta between the imagesSize and the scene.y!
        anchors.centerIn: parent
    }


    // TODO: put the image to a sprite sheet and use a MultiResolutionImage for it
    // the raster is displayed when in levelEditing mode, where it is useful to see the grid
    Image {
        id: raster
        // in level editing mode, it is very useful!
        visible: scene.state === "levelEditing"
        opacity: 0.5
        source: "../../assets/img/raster.png"
    }

    SquabyLevelContainer {
        id: level
        width: scene.width
        // the height is only the remaining one excluding the HUD - this is important for the correct values at snapping at DragWeapon!
        height: scene.height-hudHeight // (64 is the HUD height), but the HUD may also be slightly bigger

        Component.onCompleted: console.debug("SquabyLevelContainer.onCompleted()")
    }

    // this may be defined before or after the entity creations (in level), the physics module is robust enough to detect both
    PhysicsWorld {
        debugDraw.opacity: 0.2 // this is less disturbing
        id: physicsWorld
        debugDrawVisible: false // otherwise it would be enabled in debug builds by default
        // the logical world is smaller, not containing the hud!
        height: parent.height-hudHeight
        // instead of setting z, it would be better to place it after the level-item because then it is drawn on top of the squabies and obstacles, but below HUD and SquabyPerformanceTestOptions!
    }

    HUD {
      id: hud
      width: scene.width
      height: scene.hudHeight

      // this always positions it on the bottom of the window (but the scaling of the scene is still applied, which is what is desired!
      anchors.bottom: scene.gameWindowAnchorItem.bottom

      onMenuButtonClicked: {
        console.debug("SquabyScene: menu button clicked")
        showPauseScene();
      }
    }

    Tutorials {
      id: tutorials
      //anchors.fill: parent
      currentLevel: (scene.state !== "levelEditing") ? (level.levelLoader.loadedLevel ? level.levelLoader.loadedLevel.levelData.levelMetaData.levelName ? level.levelLoader.loadedLevel.levelData.levelMetaData.levelName : "" : "") : ""
    }

    ItemEditor {
      id: itemEditor
      anchors.fill: scene.gameWindowAnchorItem

      signal backButtonClicked()
      currentEditableType: "GameSettings"

      opacity: 0

      // using a different content delegate which displays the content at the top
      contentDelegate: SquabyContentDelegate{ }
      numberDelegate: SquabyNumberDelegate{ }
      boolDelegate: SquabyBoolDelegate{ }

      customTypes: { "waveArrayDelegate" : Qt.resolvedUrl("../levels/WaveArrayDelegate.qml"),
                     "simpleArrayDelegate" : Qt.resolvedUrl("../levels/SimpleArrayDelegate.qml")}

      Component.onCompleted: {
        // Notify level editor where to find the item editor
        levelEditor.itemEditorItem = itemEditor
      }

      visible: opacity > 0

      function slideIn() {
        itemEditor.opacity = 1
      }

      function slideOut() {
        itemEditor.opacity = 0
      }


      /*Behavior on opacity {
        PropertyAnimation {
          duration: 600
        }
      }*/
    }

    DialogField {
      id: saveDialog

      width: scene.gameWindowAnchorItem.width
      height: scene.gameWindowAnchorItem.height

      descriptionText: qsTr("You leave the level, do you want to ")
      options1Text: qsTr("Save Changes and Exit")
      options2Text: qsTr("Discard Changes and Exit")
      //options3Text: qsTr("Cancel")

      opacity: 0
      z: 100

      onOption1Pressed: {
        if(!scene.level.pathEntity.waypoints.length && !scene.level.waves.length) {
          flurry.logEvent("LevelEditor.Save","NoPath.NoWaves")
          hud.levelEditingHud.messageBoxID = "save"
          nativeUtils.displayMessageBox(qsTr("Save Level"), qsTr("No path and waves are set! Save and leave the level anyway?"),2)
        } else if(!scene.level.pathEntity.waypoints.length) {
          flurry.logEvent("LevelEditor.Save","NoPath")
          hud.levelEditingHud.messageBoxID = "save"
          nativeUtils.displayMessageBox(qsTr("Save Level"), qsTr("No path is set! Save and leave the level anyway?"),2)
        } else if(!scene.level.waves.length) {
          flurry.logEvent("LevelEditor.Save","NoWaves")
          hud.levelEditingHud.messageBoxID = "save"
          nativeUtils.displayMessageBox(qsTr("Save Level"), qsTr("No waves are set! Save and leave the level anyway?"),2)
        } else {
          hud.levelEditingHud.publishLevel(false)
        }
      }

      onOption2Pressed: {
        // not in editing state anymore (prevents spawning squabies)
        scene.state = ""
        // go back to the level selection scene
        window.state = "levels";
      }

      property variant levelData
    }

    DialogField {
      id: publishDialog

      width: scene.gameWindowAnchorItem.width
      height: scene.gameWindowAnchorItem.height

      descriptionText: levelEditor.currentLevelData.levelMetaData && levelEditor.currentLevelData.levelMetaData.publishedLevelId ?
                       qsTr("You are about to update a level. It'll keep ratings and downloads! Remove rating and download statistics by unpublishing the level.") :
                       qsTr("You are about to publish a level. It can be edited afterwards but it'll keep ratings and downloads! Remove rating and download statistics by unpublishing the level.")
      options1Text: qsTr("Publish Level")
      options2Text: qsTr("Change Level Name")
      //options3Text: qsTr("Cancel")

      opacity: 0
      z: 100

      onOption1Pressed: {
        hud.levelEditingHud.publishLevel(true)
      }

      onOption2Pressed: {
        nativeUtils.displayTextInput("Enter levelName", "Enter the level name. Choose a name that expresses what makes your level special.", "", levelEditor.currentLevelNameString)
        opacity = 1
      }
    }

    // this is called when the menu button is clicked, and when the back button was clicked
    function showPauseScene() {
      // do not reset game when: in level editing mode (game was running, user switches back to editing and presses back button in same moment)
      if(!scene.cameFromLevelEditing && scene.state === "levelEditing" || resetGame || startClock.waitsForStart)
        return

      console.debug("HUD: menuButton clicked, current scene state:", scene.state);

      if(scene.state === "levelEditing") {
        console.debug("ERROR: This state should not be possible!")
      } else {
        // that is the normal use case, when the game is played by users when they are not editing a level
        scene.state = "ingameMenuReleaseVersion"
        pauseScene()
        window.state = "pause"
      }
      console.debug("HUD: new scene state:", scene.state);
    }

    // this is called when user defeated a scene.
    function showWaveDefeatedScene() {
      // do not reset game when: in level editing mode (game was running, user switches back to editing and presses back button in same moment)
      if(!scene.cameFromLevelEditing && scene.state === "levelEditing" && window.state !== "gameover" || resetGame || player.lives<=0)
        return

      scene.state = "ingameMenuReleaseVersion"
      pauseScene()
      window.state = "waveDefeated"
    }


    property int marginLabelElemements: 5
    Row {
        id: scoreRow
        anchors.left: scene.gameWindowAnchorItem.left
        anchors.leftMargin: marginLabelElemements
        // position it on the window top, not on the scene top!
        anchors.top: scene.gameWindowAnchorItem.top
        //anchors.top: parent.top

        visible: scene.state !== "levelEditing"

        spacing: marginLabelElemements

        SingleSquabySprite {
            id: scoreImage
            source: "../../assets/img/menu_labels/labelScore.png"
        }
        Text {
            anchors.verticalCenter: scoreImage.verticalCenter
            anchors.verticalCenterOffset: -2

            text: player.score
            font.family: hudFont.name
            font.pixelSize: 18
            color: "white"
        }
    }

    // Button to change between level editing mode and game mode
    Item {
      id: levelEditorChangeButton
      width: sprite.width
      height: sprite.height
      anchors.top: gameWindowAnchorItem.top
      anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
      // Bed alignment
      //anchors.bottom: scene.gameWindowAnchorItem.bottom
      //anchors.bottomMargin: hud.height*1.3
      //anchors.right: scene.gameWindowAnchorItem.right
      //anchors.rightMargin: -10
      scale: 0.7
      visible: (scene.cameFromLevelEditing || scene.state === "levelEditing") && !itemEditor.visible
      opacity: scene.cameFromLevelEditing ? 0.4 : 0.8
      SingleSquabySprite {
        id: sprite        
        source: "../../assets/img/button.png"
      }

      SingleSquabySprite {
       // id: sprite
        source: scene.cameFromLevelEditing ? "../../assets/img/button-pause.png" : "../../assets/img/button-play.png"
        anchors.centerIn: parent
      }

      MouseArea {
        id: mouseArea
        anchors.fill: parent

        onClicked: {
          parent.scale = 0.7
          // start playing the game
          if(cameFromLevelEditing) {
            scene.leaveGameToLevelEditingMode()
          } else {
            scene.startGameFromLevelEditingMode()
          }
        }
        onPressed: {
          parent.scale = 0.58
        }
        onReleased: {
          parent.scale = 0.7
        }
        onCanceled: {
          parent.scale = 0.7
        }
      }
    }



    Row {
        id: livesRow
        anchors.right: scene.gameWindowAnchorItem.right
        anchors.rightMargin: marginLabelElemements
        // position it on the window top, not on the scene top!
        anchors.top: scene.gameWindowAnchorItem.top
        //anchors.top: parent.top

        visible: scene.state !== "levelEditing"

        spacing: marginLabelElemements

        SingleSquabySprite {
            id: livesImage
            source: "../../assets/img/menu_labels/labelLives.png"
        }
        Text {
            id: livesText
            // if a width is assigned here, the re-allocation of space for each letter would be prevented!
            // if the text changes the number of digits, also the x position of this whole row would change!
            //width: 20

            anchors.verticalCenter: livesImage.verticalCenter
            anchors.verticalCenterOffset: -2

            text: player.lives
            font.family: hudFont.name
            font.pixelSize: 18
            color: "white"
        }

    }

    Loader {
      id: pathCreationOverlay
      source: "../levels/PathCreationOverlay.qml"
      // set active by the LevelEditingHUD
      visible: false
      // limit it to the playfield (not including the HUD!)
      width: parent.width
      height: parent.height-hudHeight
    }


    states: [
        State {
            // this is the default state
            name: ""
        },

        State {
            name: "ingameMenuReleaseVersion"
        },

        State {
            name: "levelEditing"

            // the hud also has a state with the same name, to show the available obstacles to drop into the game field
            PropertyChanges { target: hud; state: "levelEditing"}
            // pause the squaby creation
            StateChangeScript {
                script: {
                  startClock.stop()
                  squabyCreator.stop()
                  removeAllSquabiesAndTowers()
                }
            }
        }
    ]

    function startGameFromLevelEditingMode() {
      // this messes up everything! just set a bool flag, which gets reset in exitScene there!
      // especially, the handling with pauseScene, isnt working if this is an own state!
      console.debug("Start Game from Level Editing Mode!")
      scene.cameFromLevelEditing = true;

      // this resets the score, waves, label and gold
      player.initializeProperties()
      // this resets the wave property!
      startClock.restart()

      // this starts the squaby creation!
      scene.state = ""
    }

    function leaveGameToLevelEditingMode() {

      // otherwise, they would show up during level editing, which is not intended!
      removeAllSquabiesAndTowers();

      // to avoid problems with settings of squabies which get changed but are not applied to pooled entites we have to remove all of them here. The problem is that the gamesettings are asign during creation, but the binding does not seem to work so it needs to be reasigned/created. See SquabyTypes.qml where this transaction is used.
      entityManager.removeAllPooledEntities()


      // NOTE: this must be set BEFORE the scene is changed to state levelEditing, otherwise the hud state would be overwritten!
      // reset the hud menu (so the build tower buttons should be displayed)
      // also, if a tower was selected the towerRange wont be visible any more by resetting this state
      hud.state = "buildTowers"

      // it must be disabled here, otherwise it would still be visible in the levelEditing state!
      scene.cameFromLevelEditing = false;
      scene.state = "levelEditing"
      // without it could cause problems when entering the game mode again. (showing "defeated screen")
      squabyCreator.reset()
    }

    // Called when scene is displayed - is called when it is resumed from the pause, and when entered from main menu!
    function enterScene() {
      console.debug("SquabyScene: onEntered")
      console.debug("wasInPauseBefore:", wasInPauseBefore)

      system.resumeGameForObject(level);

      // if the level is an application level, set the game state
      // if the level is an author level, set the game state if cameFromLevelEditing is true (i.e. the game was started by pressing the game mode button)
      // if the level is an author level, set the levelEditing state if cameFromLevelEditing is false (i.e. the game was started when previously an application level was loaded)

      // if the loaded level has storage authorGeneratedLevelsLocation, then editing should be possible
      // for applicationLevels or userGeneratedLevelsLocation it should not be possible
      console.debug("SquabyScene: storageLocation of current loaded level:", levelEditor.currentLevelData.levelMetaData.storageLocation)
      console.debug("SquabyScene: currentLevelData:", JSON.stringify(levelEditor.currentLevelData))
      // comment this, if you also want to allow modification of static QML levels and then storing them to the authorGeneratedStorage
      if(editAuthorLevel || createdNewLevel) {

        // new level was created and needs to be duplicated so it can be saves accordingly.
        if(createdNewLevel) {
          createdNewLevel = false
          editAuthorLevel = true
          levelEditor.duplicateCurrentLevel({ levelMetaData: { levelName: levelEditor.currentLevelNameString } })
        }

        // if cameFromLevelEditing is true, this means the scene state was "" before, and the level mode menu should be displayed
        if(cameFromLevelEditing) {
          scene.state = ""
          if(resetGame) {
             // coming from pause menu (also when in editor mode)
             player.initializeProperties()
             startClock.restart()
             resetGame = false
          } else {
            squabyCreator.start()
          }
        } else {
          // if it was false and the current level is an authorLevel, this means the previous state was levelEditing
          // however, this can never happen, because no restart option is clickable when in levelEditing state!
          // but this will happen, when an author level is loaded, and previously an applicaiton level was loaded

          console.debug("SquabyScene: the level is an authorGenerated one - switch scene to state levelEditing")
          // the scene state must be switched to levelEditing AFTER the window state was changed to game above, because in enterScene of SquabyScene the default state is set
          scene.state = "levelEditing"
        }

      } else {
        // this must be set to false for static levels, otherwise the level mode button would appear
        cameFromLevelEditing = false
        scene.state = ""
        console.debug("SquabyScene: no authorGeneratedLevel, so either an applicationLevel or a userGeneratedLevel was loaded")

        if(wasInPauseBefore) {
          // only start squaby creation when not in tutorial mode, otherwise the tutorial itself handles the creation process.
          if(!tutorials.running) {
            squabyCreator.start()
          }
          tutorials.resume()
        } else {
          // this resets the score, waves, label and gold
          player.initializeProperties()
          tutorials.reset()
          startClock.restart()
        }
      }
      if(!levelStore.noAdsGood.purchased)
        chartboostView.doNotShowAdvert()

      wasInPauseBefore = false
      resetGame = false

      if(scene.state !== "levelEditing") {
          var sum = 0;
          for (var i in scene.level.waves) {
            sum += scene.level.waves[i].amount
          }

          infinario.track('level_start', {level_id: levelEditor.currentLevelData.levelMetaData.levelId, level_name: levelEditor.currentLevelData.levelMetaData.levelName, monsters: sum})
      }

      console.debug("SquabyScene: end of enterScene()")

    }

    function exitScene() {
      console.debug("SquabyScene: onExited")

      // resume all objects (when paused) so that it can be deleted correctly. So when pooled it is activated again.
      system.resumeGameForObject(level);

      // this must be set to false, because pauseScene() was not called before
      startClock.stop()
      squabyCreator.stop()
      tutorials.reset()
      // reset endless game flag so the new level can be scored up.
      endlessGameAllowed = false

      // do NOT remove all! only the created entities should be removed, but not the obstacles, entitybuttons, etc.
      //entityManager.removeAllEntities();

      // remove all squabies and towers at a restart
      removeAllSquabiesAndTowers()

      // old: this is needed atm, because delayedRemoval is set to true, and otherwise the pooled entities would never be removed
      // do NOT remove the pooled squabies, they can be reused for the next game!
      //entityManager.removeAllPooledEntities();

      wasInPauseBefore = false

      // reset the hud menu (so the build tower buttons should be displayed)
      // also, if a tower was selected the towerRange wont be visible any more by resetting this state
      hud.state = "buildTowers"

      // this gets set explicitly when entered from the level editing menu!
      // NOTE: this must not be set to false here, otherwise a restart when in gameoverscene would not move back to the levelEditing menu!
      // also see the new logic added to enterScene to decide on the state based on the currentLevel data
      //cameFromLevelEditing = false;
      resetGame = false
    }

    // not used at the moment - distinguish by wasInPauseBefore set to true or false
//    function resumeScene() {
//    }
    function nextLevel() {
      exitScene()
      loadNextLevel()
    }

    function continueGame() {
      // do not reset game when: in level editing mode (game was running, user switches back to editing and presses back button in same moment)
      if(!scene.cameFromLevelEditing && scene.state === "levelEditing")
        return

      squabyCreator.continueEndless()
    }

    // gets called from SquabyMain, when restart was pressed
    function restartGame() {

      console.debug("Restart level with scene.state:", scene.state  )

      // do not reset game when: in level editing mode (game was running, user switches back to editing and presses back button in same moment)
      if(!scene.cameFromLevelEditing && scene.state === "levelEditing")
        return

      // this is interesting, to find out at which state in the game restart was pressed!
      // when the gameOver state is entered, the game is lost and the reached score, waves, etc. should be sent for analytics
      //var objectWithPlayerProperties = {};
      // here all player properties are set as properties, e.g. waves, score, gold, number nailguns built, etc.
      //player.addPlayerPropertiesToAnalyticsObject(objectWithPlayerProperties);
      //flurry.logEvent("Game.RestartPressed", objectWithPlayerProperties);

      exitScene()
      resetGame = true
      // NOTE: do NOT call enterScene() here, it is called anyway when the game state is entered from the main menu state!!!
      // and in exitScene, wasInPauseBefore gets set to false anyway, so in the next call of enterScene(), the game will be restarted
      //enterScene()
    }

    // this is called from exitScene(), and when the user changes to the levelEditing mode
    function removeAllSquabiesAndTowers() {
        var toRemoveEntityTypes = ["squaby", "nailgun", "flamethrower", "taser", "tesla", "turbine"];
      entityManager.removeEntitiesByFilter(toRemoveEntityTypes)
    }

    property bool shouldRestart: false
    property bool wasInPauseBefore: false
    property bool resetGame: false
    function pauseScene() {
      wasInPauseBefore = true

      // do NOT set running to false directly here, otherwise a new squaby would be created when the counter is resumed again
      //running = false
      startClock.pause()
      tutorials.pause()


      // required steps:
      // pause squaby movement, whichever state it is currently in (path movement, whirled, dying, the spriteSequence must be paused!)
      // pause tower animations & movement
      // pause particle system


      console.debug("SquabyScene: calling System.pauseGameForObject() with scene.state: ",scene.state)
      // NOTE: do not pause all qt timers, animations and QML Timers from the whole scene (there might be animations going on), but only from the level, i.e. from the entities!
      //system.pauseGameForObject(scene);
      system.pauseGameForObject(level);

      // this is paused automatically
      //physicsWorld.running = false
    }

    Rectangle {
      id: loadMessage
      z:1001
      x: scene.gameWindowAnchorItem.x
      y: scene.gameWindowAnchorItem.y
      width: scene.gameWindowAnchorItem.width
      height: scene.gameWindowAnchorItem.height
      color: "black"
      opacity: 0.5
      visible: itemEditor.state === "loading"

      Text {
        anchors.centerIn: parent
        text: "loading..."
        color: "white"
      }
    }

    StartClock {
      id: startClock
      anchors.fill: parent
    }
}
