import QtQuick 1.1
import VPlay 1.0
import "../levels" // contains the LevelLoader
import "../balancing"
import "hud"
import "../otherScenes" // for SquabySceneBase

SquabySceneBase {
    id: scene

    property alias level: level
    property alias hud: hud // needs to be accessed from the towers when they are clicked to update the upgrade menu

    // set it as the level, because there the obstacles are defined!
    property alias entityContainer: level

    // the "logical" height of the scene is 320-64 = 256!
    property int hudHeight: 64

    // this is not really an own state, but it gets set from the level editor when path creation should be done
    // when it is set to true, the mouseArea over the whole playfield is enabled
    // it gets set to true from the LevelEditingHUD
    property bool pathCreationMode: false

    // this gets set from LevelEditingMenu, when the user clicks on Game Mode to test the level
    // it is reset in exitScene()
    property bool cameFromLevelEditing: false

    // maybe connect this property with the developerBuild property!? but the PerfMenu is not very good at the moment, because it has no restart/resume/main menu functionality
    property bool enablePerformanceTestingMenu: false//developerBuild

    onBackPressed: {
      showPauseScene();
    }

    // uncomment the following line for quick testing of different states
//    state: "levelEditing"

    // creates the squbies
    SquabyCreator {
        id: squabyCreator

        // NOTE: set this to true, when you want to test the real level creation with the final waves
        // do not enable it by default for testing logic of towers&squabies, but for balancing and the final game it should be enabled of course
        enabled: true
        // put it on top, just for debugging the output values of SquabyCreator with the Text element in it
        z:20
        property real vertexZ: 20
    }

    // if clicked in an empty area (so not on a tower), the upgradeMenu will disappear
    MouseArea {
        anchors.fill: parent        
        onClicked: {

            // this is necessary for performance testing, when the HUD is disabled, because then the menu must be enabled again otherwise the menu could not be enabled again!
            if(scene.state === "hideHUD") {
                scene.state = "ingameMenuPerformanceTesting";
                return;
            }

            if(scene.state === "levelEditing" || scene.state === "levelEditingMenu") {
                scene.state = "levelEditing";
                // this forces the hud to disable a possibly selected obstacle and to show the obstacleBuildMenu again
                hud.state = "levelEditing";
                return;
            }

            // dont set scene state to "" in that case!
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
        source: "../img/floor-merged-sd.png"

        // use this if the image should be centered, which is the most common case
        // if the image should be aligned at the bottom, probably the whole scene should be aligned at the bottom, and the image should be shited up by the delta between the imagesSize and the scene.y!
        anchors.centerIn: parent
    }


    // TODO: put the image to a sprite sheet and use a MultiResolutionImage for it
    // the raster is displayed when in levelEditing mode, where it is useful to see the grid
    Image {
        id: raster
        // in level editing mode, it is very useful!
        visible: scene.state=="levelEditing" || scene.state=="levelEditingMenu"
        opacity: 0.5
        source: "../img/raster.png"
    }

    // when the spriteBatchContainer is placed here, at its update the sprites still have the old position!
    // thus use the function entity.updateItemPositionAndRotationImmediately() to not have a flicker when it is reused from pooling! (see Squaby.qml and BuildEntityButton.qml)
    // another issue with this approach, is that the particles will always be drawn on top of the entity batched sprites (so also the blood from squaby)!
    // the reason for that is, that this draw is called first, followed by a draw of Rectangle and Particle children of the entities
    //  however, placing the SpriteBatchContainer AFTER the level with the entities also is not good, because then all particles would be drawn below (not good for turbine), and also the Towers are not rendered because of a vertexZ issue!?
    SpriteBatchContainer {
    }

    SquabyLevelContainer {
        id: level
        width: scene.width
        // the height is only the remaining one excluding the HUD - this is important for the correct values at snapping at DragWeapon!
        height: scene.height-hudHeight // (64 is the HUD height), but the HUD may also be slightly bigger

        Component.onCompleted: console.debug("SquabyLevelContainer.onCompleted()")
    }

    // if put here, there is an issue with drawing the towers, see comments at above SpriteBatchContainer
//    SpriteBatchContainer {
//      //property real vertexZ: 20
//      //z:2 // setting a z is not good here, because then it gets mixed up with the vertexZ settings
//    }

    // this may be defined before or after the entity creations (in level), the physics module is robust enough to detect both
    PhysicsWorld {
      z: 0 // z=0 would be the default anyway, so not really needed
      debugDraw.opacity: 0.2 // this is less disturbing
        id: physicsWorld
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

    }// end of HUD

    // this is called when the menu button is clicked, and when the back button was clicked
    function showPauseScene() {
      console.debug("HUD: menuButton clicked, current scene state:", scene.state);
      if(enablePerformanceTestingMenu) {
        // this displays the ingame menu for performance testing, the SquabyPerformanceTestOptions.qml
        scene.state = "ingameMenuPerformanceTesting"
        return;
      }

      if(scene.state === "levelEditing") {
        // this displays the ingame menu for level editing, the LevelEddtingingMenu.qml
        scene.state = "levelEditingMenu"
      } else if(scene.state === "levelEditingMenu") {
        // switch back to the levelEditing mode, when in levelEditingMenu before
        scene.state = "levelEditing"
      } else {
        // that is the normal use case, when the game is played by users when they are not editing a level
        window.state = "pause"

        scene.state = "ingameMenuReleaseVersion"
      }
      console.debug("HUD: new scene state:", scene.state);
    }

    property int marginLabelElemements: 5
    Row {
        id: scoreRow
        anchors.left: scene.gameWindowAnchorItem.left
        anchors.leftMargin: marginLabelElemements
        // position it on the window top, not on the scene top!
        anchors.top: scene.gameWindowAnchorItem.top
        //anchors.top: parent.top

        spacing: marginLabelElemements

        // make sure the sprite & text is on top of the closet (vertexZ=2) and HUD with the dragged tower (vertexZ=3)
        property real vertexZ: 4

        SingleSquabySprite {
            id: scoreImage
            source: "labelScore.png"
            //source: "img/iMenuIconScore.png" // old, for Image use
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

    Row {
        id: livesRow
        anchors.right: scene.gameWindowAnchorItem.right
        anchors.rightMargin: marginLabelElemements
        // position it on the window top, not on the scene top!
        anchors.top: scene.gameWindowAnchorItem.top
        //anchors.top: parent.top

        spacing: marginLabelElemements

        // make sure the sprite & text is on top of the closet (vertexZ=2) and HUD with the dragged tower (vertexZ=3)
        // -> no need to set the vertexZ here, because there is no closet on the right side! also no issue with sprite being on top of draggedTower, because z-ordering of sprites within the spritesheet works as expected!
        //property real vertexZ: 4

        SingleSquabySprite {
            id: livesImage
            source: "labelLives.png"
            //source: "img/iMenuIconLives.png" // old, for Image use
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

            // set it here, because z-ordering for the sprite from the spritesheet works as expected, but not for this text item!
            property real vertexZ: 4
        }

    }

    // comment the real SquabyPerformanceTestOptions component at the moment as a performance improvement to speed up loading time
    Item {
//    SquabyPerformanceTestOptions {
        id: performanceTestOverlay
        visible: false // make invisible by default, gets set to visible when pressing at the menu bar below
        property real vertexZ: 10 // this is needed for cocos, otherwise it would not be drawn on top of the spritesheet! the hud has vertexZ of 3, the labels in the hud 4, so set this highest
    }

    Loader {
    //LevelEditingMenu {
        id: levelEditingMenu
        source: allowMultipleLevels ? "../levels/LevelEditingMenu.qml" : ""
        visible: false // make invisible by default, gets set to visible when pressing at the menu bar below
        property real vertexZ: 10 // this is needed for cocos, otherwise it would not be drawn on top of the spritesheet! the hud has vertexZ of 3, the labels in the hud 4, so set this highest

        anchors.fill: parent // this is required, because a anchors.fill: parent is used in the LevelEditingMenu, and parent size would be undefined otherwise
    }

    Loader {
//    PathCreationOverlay {
      source: allowMultipleLevels ? "../levels/PathCreationOverlay.qml" : ""
      visible: scene.pathCreationMode
      // limit it to the playfield (not including the HUD!)
      width: parent.width
      height: parent.height-hudHeight
      property real vertexZ: 10
    }


    // this should only be added for testing different squaby types manually for balancing
    // in the retail version, do not include this!
    /*
    BalancingTestingOverlay {
      // only make visible in debug builds
      visible: system.debugBuild
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      // move a bit to the left,otherwise the nailgun is covered
      anchors.horizontalCenterOffset: -30

      property real vertexZ: 15
    }
    */

    // with this, squaby balancing settings could be changed at runtime - commented at the moment as it is in active development
    /*ItemEditor {
      id: itemEditor
      opacity: 0.7 // this is just for testing anyway
      width: 200
      height: parent.height
      anchors.right: parent.right

      //defaultGroupName: "squabyYellow"

      // TODO: if no editableTypes is set, all should be visible!
//      editableTypes: [
//        "SquabySettings"
//      ]

      // TODO: if no currentEditableType is set, the first one should be displayed
      //currentEditableType: "SquabySettings"
    }
    */

    states: [
        State {
            // this is the default state
            name: ""
            StateChangeScript {
                script: {
                  console.debug("SquabyScene: entering default state")
                  // do not call start() twice!
                    // if squabyCreator was enabled before and its running property was set to false in the ingameMenu, set running to true again
//                    if(squabyCreator.enabled) {
//                      squabyCreator.start()
//                      //squabyCreator.running = true;
//                    }
                    // it is not guaranteed that the scene is resumed here, may also be started initially!
                    //resumeScene()
                }
            }
        },

        // this is too confusing to make an own state - only set the property cameFromLevelEditing to true when the user should get displayed the back button to the level menu!
//        State {
//            // this is similar to the default state, but it is entered from the levelEditingMenu!
//            // so when the user came here from level editing, display a button on the bottom that he can go back to levelEditingMenu quickly
//            // this state is used in the HUD, for the button to show the entry back to the level editing mode
//            name: "testLevelInLevelMode"
//            extend: ""
//        },

        State {
            name: "ingameMenuPerformanceTesting"

            //PropertyChanges { target: ingameMenu; visible: true} // this should be used in the end, instead of the performanceOverlay for debugging
            PropertyChanges { target: performanceTestOverlay; visible: true}
            // pause the squaby creation
            // ATTENTION: dont use the next here, otherwise the running-property will be reset to false again when leaving the ingameMenu!
            // thus make this change in the StateChangeScript below!
            //PropertyChanges { target: squabyCreator; running: false}

            // dont pause yet when toggling the menu! somehow the animations would need to be stopped! as well as all timers!
            StateChangeScript {
                script: {
                    // for pausing animations and timer, application.active could be set to false!
                    //squabyCreator.running = false;
                  pauseScene()
                }
            }
        },

        State {
            name: "ingameMenuReleaseVersion"
            StateChangeScript {
                script: {
                    // for pausing animations and timer, application.active could be set to false!
                    // pause the squaby creation from the waves                    
                    pauseScene()
                }
            }
        },

        State {
            name: "levelEditing"

            // the hud also has a state with the same name, to show the available obstacles to drop into the game field
            PropertyChanges { target: hud; state: "levelEditing"}
            // pause the squaby creation
            StateChangeScript {
                script: {
                    // for pausing animations and timer, application.active could be set to false!
                    //squabyCreator.running = false;
                  squabyCreator.stop()
                }
            }
        },

        State {
            name: "levelEditingMenu"
            extend: "levelEditing"

            // the hud also has a state with the same name, to show the available obstacles to drop into the game field
            PropertyChanges { target: levelEditingMenu; visible: true}
        },


        // the following states are for performance-testing only

        State {
            name: "hideObstacles"
            extend: "ingameMenuPerformanceTesting"
            PropertyChanges { target: level; state: "hideObstacles"}
        },
        State {
            name: "hideHUD"
            extend: "ingameMenuPerformanceTesting"
            PropertyChanges { target: hud; visible: false}
        },
        State {
            name: "hideHUDAndObstacles"
            extend: "ingameMenuPerformanceTesting"
            PropertyChanges { target: hud; visible: false}
            PropertyChanges { target: level; state: "hideObstacles"}
        },
        State {
            name: "hideAll"
            extend: "ingameMenuPerformanceTesting"
            PropertyChanges { target: level; state: "hideObstacles"}
            PropertyChanges { target: hud; visible: false}
            PropertyChanges { target: scoreRow; visible: false}
            PropertyChanges { target: livesRow; visible: false}
            PropertyChanges { target: levelBackground; visible: false}
        }
    ]

    function startGameFromLevelEditingMode() {
      //scene.state = "testLevelInLevelMode"
      // this messes up everything! just set a bool flag, which gets reset in exitScene there!
      // especially, the handling with pauseScene, isnt working if this is an own state!
      scene.cameFromLevelEditing = true;

      // when testing the game, this mode should be left, so also the button isnt displayed!
      // also disable this in enterScene() - otherwise it would be visible when a new game is started not from levelEditingMode
      scene.pathCreationMode = false;

      // this resets the score, waves, label and gold
      player.initializeProperties()
      // this resets the wave property!
      if(squabyCreator.enabled) {
        squabyCreator.restart()
        // the timer is restarted in restart()
      }

      // this starts the squaby creation!
      scene.state = ""
    }

    function leaveGameToLevelEditingMode() {

      // otherwise, they would show up during level editing, which is not intended!
      removeAllSquabiesAndTowers();


      // NOTE: this must be set BEFORE the scene is changed to state levelEditing, otherwise the hud state would be overwritten!
      // reset the hud menu (so the build tower buttons should be displayed)
      // also, if a tower was selected the towerRange wont be visible any more by resetting this state
      hud.state = "buildTowers"

      // it must be disabled here, otherwise it would still be visible in the levelEditing state!
      scene.cameFromLevelEditing = false;
      scene.state = "levelEditing"
    }

    // Called when scene is displayed - is called when it is resumed from the pause, and when entered from main menu!
    function enterScene() {
      console.debug("SquabyScene: onEntered")
      console.debug("wasInPauseBefore:", wasInPauseBefore)

      system.resumeGameForObject(scene);

      if(wasInPauseBefore) {

        // only set running to true, do not restart
        // when running is set to true here, the next squaby is created immediately!
        if(squabyCreator.enabled)
          squabyCreator.start()
          //squabyCreator.running = true;

      } else {
        // this resets the score, waves, label and gold
        player.initializeProperties()

        if(squabyCreator.enabled) {
          squabyCreator.restart()
          // the timer is restarted in restart()
        }
      }

      // this is important, otherwise at loading a new level the path overlay is still shown
      scene.pathCreationMode = false;

      wasInPauseBefore = false


      // if the level is an application level, set the game state
      // if the level is an author level, set the game state if cameFromLevelEditing is true (i.e. the game was started by pressing the game mode button)
      // if the level is an author level, set the levelEditing state if cameFromLevelEditing is false (i.e. the game was started when previously an application level was loaded)

      // if the loaded level has storage authorGeneratedLevelsLocation, then editing should be possible
      // for applicationLevels or userGeneratedLevelsLocation it should not be possible
      console.debug("SquabyScene: storageLocation of current loaded level:", levelEditor.currentLevelData.levelMetaData.storageLocation)
      console.debug("SquabyScene: currentLevelData:", JSON.stringify(levelEditor.currentLevelData))
      // comment this, if you also want to allow modification of static QML levels and then storing them to the authorGeneratedStorage
      if(levelEditor.currentLevelData.levelMetaData.storageLocation === levelEditor.authorGeneratedLevelsLocation) {

        // if cameFromLevelEditing is true, this means the scene state was "" before, and the level mode menu should be displayed
        if(cameFromLevelEditing) {
          scene.state = ""
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
      }


      console.debug("SquabyScene: end of enterScene()")

    }

    function exitScene() {
      console.debug("SquabyScene: onExited")

      // this must be set to false, because pauseScene() was not called before
      //squabyCreator.running = false
      squabyCreator.pause()

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
    }

    // not used at the moment - distinguish by wasInPauseBefore set to true or false
//    function resumeScene() {
//    }

    // gets called from SquabyMain, when restart was pressed
    function restartGame() {

      // this is interesting, to find out at which state in the game restart was pressed!
      // when the gameOver state is entered, the game is lost and the reached score, waves, etc. should be sent for analytics
      var objectWithPlayerProperties = {};
      // here all player properties are set as properties, e.g. waves, score, gold, number nailguns built, etc.
      player.addPlayerPropertiesToAnalyticsObject(objectWithPlayerProperties);
      flurry.logEvent("Game.RestartPressed", objectWithPlayerProperties);

      exitScene()
      // NOTE: do NOT call enterScene() here, it is called anyway when the game state is entered from the main menu state!!!
      // and in exitScene, wasInPauseBefore gets set to false anyway, so in the next call of enterScene(), the game will be restarted
      //enterScene()
    }

    // this is called from exitScene(), and when the user changes to the levelEditing mode
    function removeAllSquabiesAndTowers() {
      var toRemoveEntityTypes = ["squaby", "nailgun", "flamethrower", "turbine"];
      entityManager.removeEntitiesByFilter(toRemoveEntityTypes)
    }

    property bool shouldRestart: false
    property bool wasInPauseBefore: false
    function pauseScene() {
      wasInPauseBefore = true

      // do NOT set running to false directly here, otherwise a new squaby would be created when the counter is resumed again
      //running = false
      squabyCreator.pause()


      // required steps:
      // pause squaby movement, whichever state it is currently in (path movement, whirled, dying, the spriteSequence must be paused!)
      // pause tower animations & movement
      // pause particle system


      console.debug("SquabyScene: calling System.pauseGameForObject()")
      // NOTE: do not pause all qt timers, animations and QML Timers from the whole scene (there might be animations going on), but only from the level, i.e. from the entities!
      //system.pauseGameForObject(scene);
      system.pauseGameForObject(level);

      // this is paused automatically
      //physicsWorld.running = false

    }


}
