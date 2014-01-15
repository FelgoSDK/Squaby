import QtQuick 1.1
import VPlay 1.0
// Plugins
import VPlay.plugins.gamecenter 1.0
import VPlay.plugins.flurry 1.0

import "otherScenes"
import "gameScene"
import "levels" // for LevelSelectionScene

GameWindow {
  id: window  
  width: 960//480*2//*1.5 // for testing on desktop with the highest res, use *1.5 so the -hd2 textures are used
  height: 640//320*2//*1.5

  // for better readability of the fps, make them white
  fpsTextItem.color: "white"

  // this would disable the fps label both for QML & cocos renderer - if only qml renderer should be disabled use fpsTextItem.visible: false
  displayFpsEnabled: developerBuild

  // all properties assigned here are accessible from all entities!
  // the reason for that is, because EntityManager is created in here, and only the parents of EntityManager where new entities get created are known!
  property alias level: gameSceneLoader.level

  property alias hud: gameSceneLoader.hud // needs to be accessed from the towers when they are clicked to update the upgrade menu

  // set this to false for the retail version for the store, and when releasing as demo for the V-Play SDK
  // in the developer version, the fps are displayed
  // also, cheating is possible by clicking on the closet
  property bool developerBuild: !system.publishBuild

  // when this propety is enabled, the levels menu appears in the main menu to open the LevelSelectionScene, and custom levels can be created
  // as this feature is now ready for all players, add it to the release version and do not set it to developerBuild  
  property bool allowMultipleLevels: true

  Player {
    // because it is defined here at the root object, it is accessible from all components
    id: player
  }

  // be sure to enable GameCenter for your application (developer.apple.com)
  GameCenter {
    id: gameCenter

    // Use highscore from GameCenter if it is higher than our local one
    onAuthenticatedChanged: {
      if (authenticated === true) {
        // For debugging only
        // resetAchievements();

        var gameCenterScore = getGameCenterScore();
        if (gameCenterScore > player.maxScore)
          player.maxScore = gameCenterScore;
      }
    }
  }

  // flurry is only available on iOS and Android, on all other platforms the log calls are just ignored
  Flurry {
    id: flurry
    // this is the app key for the Squaby-SDK-Demo, be sure to get one for your own application if you want to use Flurry
    applicationKey: "QQT3CKTQDGF7XGMFSF97"
  }

  // this gets used for analytics, to know which state was ended before
  property string lastActiveState: ""
  onStateChanged: {

    //console.debug("__________SquabyMain: new state:", state, ", lastActiveState:", lastActiveState)

    // Attention:
    // Keep in mind that the first state change happens even before the Flurry session is opened (sessionAutostart is
    // set to true but this will happen not until onCompleted is called), so the first Display.Main event is not sent!

    // flurry anayltics
    if(lastActiveState === "main") {
      flurry.endTimedEvent("Display.Main");
    } else if(lastActiveState === "game") {
      flurry.endTimedEvent("Display.Game");
    } else if(lastActiveState === "pause") {
      flurry.endTimedEvent("Display.Pause");
    } else if(lastActiveState === "highscore") {
      flurry.endTimedEvent("Display.Highscore");
    }  else if(lastActiveState === "credits") {
      flurry.endTimedEvent("Display.Credits");
    } else if(lastActiveState === "gameOver") {
      flurry.endTimedEvent("Display.GameOver");
    } else if(lastActiveState === "levels") {
      flurry.endTimedEvent("Display.Levels");
    }

    if(state === "main") {
      flurry.logTimedEvent("Display.Main");
    } else if(state === "game") {
      flurry.logTimedEvent("Display.Game");
    } else if(state === "pause") {
      flurry.logTimedEvent("Display.Pause");
    } else if(state === "highscore") {
      flurry.logTimedEvent("Display.Highscore");
    }  else if(state === "credits") {
      flurry.logTimedEvent("Display.Credits");
    } else if(state === "gameOver") {
      flurry.logTimedEvent("Display.GameOver");

      // when the gameOver state is entered, the game is lost and the reached score, waves, etc. should be sent for analytics
      var objectWithPlayerProperties = {};
      // here all player properties are set as properties, e.g. waves, score, gold, number nailguns built, etc.
      player.addPlayerPropertiesToAnalyticsObject(objectWithPlayerProperties);
      flurry.logEvent("Game.Finished", objectWithPlayerProperties);

    } else if(state === "levels") {
      flurry.logTimedEvent("Display.Levels");
    }

    lastActiveState = state;
  }

  // moved the logic into an own component, as it is more code than Flurry for example
  FacebookConnector {
    id: facebook
  }

  // Custom fonts
  FontLoader {
    id: jellyFont
    source: "fonts/JellyBelly.ttf"
  }

  // Custom font - jellybelly is very hard to read! thus use a different one!
  FontLoader {
    id: hudFont
    source: "fonts/COOPBL.ttf"
  }

  // the initial state should be the main state
  state: "main"

  // Scenes
  // the default value {} is used so no QML ReferenceErrors occurs at start-up (when scene is not loaded yet) - these errors would not break the game, but this solution is nicer
  property variant scene: gameSceneLoader.item ? gameSceneLoader.item : {}
  Loader {
    id: gameSceneLoader

    property variant level: item ? item.level : {}
    property variant hud: item ? item.hud : {}
    property variant entityContainer: item ? item.entityContainer : undefined//{}

    // this would simulate if the scene is loaded directly - but the initialization order is different than defining a SquabyScene directly here!
//    source: "gameScene/SquabyScene.qml"

    //onItemChanged: console.debug("______________SquabyScene item changed, this means the SquabyScene is loaded and we have access to entityContainer")
    //onEntityContainerChanged: console.debug("______________entityContainerChanged to", entityContainer)

    onLoaded: {

      console.debug("SquabyMain: SquabyScene loaded")

      loadItemWithCocos(item)

      // NOTE: this causes the dynamicCreationEntityList to be created!
      // do not set the entityContainer like this, because it is then not possible to create an entity in SquabyLevelContainer.onCompleted!
      // itemChanged is called BEFORE the siblings of SquabyScene (to which PhysicsWorld belongs to!) are not initialized!
//      entityManager.entityContainer = item.entityContainer

    }

  }

  // this is shown when the play button is pressed the first time, or when a new level is loaded
  LoadingScene {
    id: loadingScene

    // after the loadingScene is finished with the animation, start loading the SquabyScene
    onFinishedLoadingAnimation: {

      console.debug("LoadingScene: finishedLoadingAnimation, set gameScene source to SquabyScene (this might be a lenghty operation the first time loaded!)")
      gameSceneLoader.source="gameScene/SquabyScene.qml"

      // the above is a lenghty call the first time when the SquabyScene is built up
      // however, we can be sure the squabyScene was fully initialized here, as it is a synchronous call

      // start the game: load level, precreate entities
      twoPhaseLevelLoader.startGameAfterLevelLoadingAnimationFinished()
    }
  }

  PauseScene {
    id: pauseScene

    // this guarantees it is on top of the closet
    property real vertexZ: 10

    onRestartGame: {
      scene.restartGame()
    }
  }

  GameOverScene {
    id: gameOverScene

    property real vertexZ: 10
  }

  HighscoreScene {
    id: highScoreScene

    property real vertexZ: 10
  }

  property alias creditsScene: creditsSceneLoader.item
  Loader {
    //    source: "otherScenes/CreditsScene.qml"
    //  CreditsScene {
    id: creditsSceneLoader

    property real vertexZ: 10

    onLoaded: {
      console.debug("finished loading CreditsScene")
      window.loadItemWithCocos(creditsScene)
    }
  }

  // put the LevelSelectionScene into a loader, so it is not loaded into memory for the current retail version of the game - that speeds up the initial loading time of the app!
  Component {
    id: levelSelectionSceneComponent
    LevelSelectionScene {
      //id: levelScene      

      property real vertexZ: 10

      // NOTE: this is required, because the scene is put into a loader, and the gameWindow is set to parent by default, which is not true in this case, because the parent of the Scene here is the loader not the GameWindow
      sceneGameWindow: window

      Component.onCompleted: console.debug("finished loading LevelSelectionScene")
    }
  }
  Loader {
    id: levelSelectionSceneLoader
    sourceComponent: allowMultipleLevels ? levelSelectionSceneComponent : undefined
    //onLoaded: console.debug("levelSelectionScene loaded")

  }

  property alias levelScene: levelSelectionSceneLoader.item

  // Set MainMenuScene as last so it is in front of the game scene for our custom fade animation
  MainMenuScene {
    id: mainMenuScene

    // this guarantees it is on top of the hud labels (vertexZ=5)
    property real vertexZ: 10

//    opacity: 0.2 // for debugging only (to see if the SquabyScene got correctly initialized if it is loaded from beginning with the Loader)

    onPlayClicked: {
      //console.debug("Play button clicked - show a list of application levels")

      // this does not work, because the levelData is the one stored locally in the storage
      //twoPhaseLevelLoader.startLoadingLevel(false, levelEditor.qmlLevelList[0])

      // this works - it uses the data that was stored in the dynamic version of Level01.qml, and loads level01 directly
      // this is just a temporary solution, until the highscore service is added for mutiple levels!
      twoPhaseLevelLoader.startLoadingLevel(false, {"creationTime":"Fri, 26 Apr 2013 08:21:32 GMT","lastModificationTime":"Fri, 26 Apr 2013 08:21:32 GMT","levelBaseUrl":"01/Level01.qml","levelId":1,"levelName":"Level 1","storageLocation":"applicationJSON"} )

    /*
      // instead of the call above, use this section in the end to allow a level selection menu when pressing play, when the highscore service is available
      mainMenuScene.state = "exited"
      window.state = "levels"

      // after changing the state above, we have access to the levelScene here as it is a synchronous call

      // change levelScene state to ApplicationLevels
      // either use the QML, or the JSON levels as storage
      // we could also add the two together by adding the entries of the models, but that will not be used in the final game anyway (only dynamic OR static levels will be used, but not mixed)
      // the QML levels could also be saved to the authorGeneratedLevels, and then exported as json levels
      //levelScene.storageLocation = levelEditor.applicationQMLLevelsLocation
      levelScene.storageLocation = levelEditor.applicationJSONLevelsLocation

      console.debug("new storageLocation:", levelScene.storageLocation, ", new levelModel:", levelScene.levelModel)
    */
    }

    onMyLevelsClicked: {

      // to track how often the players select the my levels menu
      flurry.logEvent("MainMenu.MyLevels.clicked")

      mainMenuScene.state = "exited"
      window.state = "levels"

      // the authorLevels are available immediately after this call, as it is a local database and a synchronous call
      // for the userGeneratedLevels, an asynrhonous call is done
      // by updating the storageLocation below, a change of the levelEditor will be detected in LevelScene
      levelEditor.loadAllLevelsFromStorageLocation(levelEditor.authorGeneratedLevelsLocation)

      // by changing the storageLocation, the levelScene will listen to a change of the result
      levelScene.storageLocation = levelEditor.authorGeneratedLevelsLocation
    }

    onCreditsClicked: {
      creditsSceneLoader.source = "otherScenes/CreditsScene.qml"      
    }
  }

  property alias levelEditor: squabyLevelEditor
  SquabyLevelEditor {
    id: squabyLevelEditor
    // this is required, otherwise the entityManager is not known (as it comes from LevelEditor in the engine, but still not clear why no access to entityManager (also not with an alias to it)!)
    entityManagerItem: entityManager
  }

  // the EntityManager must be accessible here and not in SquabyScene, so entities can be pre-created for pooling
  EntityManager {
    id: entityManager
    entityContainer: gameSceneLoader.entityContainer

    poolingEnabled: true

    // this property is required to enter all entities that should be loadable dynamically into the level here
    // the entities added here are also the ones that can be created with createEntityFromEntityTypeAndVariationType()
    // they are required so these entities are pooled and pre-created at app start, which allows the ItemEditor to show the entity types
    // it is also required for the LevelEditor to be able to create entities based on their entityType string - otherwise at loading of a json-stored level would fail because there is no connection from the entityType to the real qml component
    // if only static qml levels are loaded with the LevelEditor and no entities should be modified in the ItemEditor, this property is not needed
    dynamicCreationEntityList: [
      // we do not need to add Flamethrower here for example, because it cannot be contained in a level file
      // we need to add it, once we want to modify it with the ItemEditor      
      Qt.resolvedUrl("entities/Obstacle.qml"), // this is required, as they are read from dynamic level files
    ]
  }

  BackgroundMusic {
    id: backgroundMusic
    // dont use mp3 on Symbian & MeeGo (they are not supported there), on all others play mp3
    // ogg is NOT supported on ios
    source: system.isPlatform(System.Symbian)||system.isPlatform(System.Meego)||system.isPlatform(System.BlackBerry) ? "snd/backgroundMusic.ogg" : "snd/backgroundMusic.mp3"
    volume: 0.6
  }

  // is used to first load the scene if it did not exist before, and then set the state to game
  TwoPhaseLevelLoader {
    id: twoPhaseLevelLoader
  }

  Component.onCompleted: {

    // Authenticate player to gamecenter
    gameCenter.authenticateLocalPlayer();

    // the sounds may be disabled while developing the game - in debug build set soundsEnabled to false with the following statement:
    // this may be added to deactivate sounds in debug builds
//    if(system.debugBuild) {
//      settings.ignoredPropertiesForStoring = ["soundEnabled"]
//      settings.soundEnabled = false
//    }

    console.debug("SquabyMain.onCompleted");
  }

  // for debugging:
  //onStateChanged: console.debug("SquabyMain.state changed to", state)
  //onActiveSceneChanged: console.debug("active scene changed to", activeScene)

  states: [
    State {
      name: "main"
      PropertyChanges { target: mainMenuScene; opacity: 1}
      StateChangeScript {
        script: {
          var lastActiveScene = window.activeScene
          window.activeScene = mainMenuScene

          console.debug("SquabyMain: change to state 'main'")

          mainMenuScene.enterScene();
          // it may be paused before, when in the pause scene
          backgroundMusic.play();

          // if the main menu was reached from the pause or the gameOver screen, the previous entities should be deleted
          // the last state can also be the scene, when coming from LevelEditingMenu and "Back to Levels" is pressed
          // this fixes a bug, that caused squabies to be existing when another level was loaded, although they should get removed when it is switched to levelediting mode
          if(lastActiveScene === pauseScene || lastActiveScene === gameOverScene || lastActiveScene === scene ) {
            scene.exitScene()
          }
        }
      }
    },
    State {
      name: "game"
      // this does not work, because the PropertyChanges are applied before the StateChangeScript! and then the SquabyScene is not loaded
      PropertyChanges { target: scene; opacity: 1}
      StateChangeScript {
        script: {
          console.debug("SquabyMain: change to state 'game'")

          window.activeScene = scene
          scene.enterScene();
          backgroundMusic.play();

          // make sure the exited state is set, otherwise the loadingAnimationFinished signal wouldnt be emitted
          loadingScene.state = "exited"
        }
      }
    },
    State {
      name: "loading"
      PropertyChanges { target: loadingScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = loadingScene
          loadingScene.enterScene();
        }
      }
    },
    State {
      name: "pause"
      PropertyChanges { target: scene; opacity: 1}
      PropertyChanges { target: pauseScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = pauseScene
          pauseScene.enterScene();
          backgroundMusic.pause();
        }
      }
    },
    State {
      name: "highscore"
      PropertyChanges { target: highScoreScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = highScoreScene
          highScoreScene.enterScene();
        }
      }
    },
    State {
      name: "credits"
      PropertyChanges { target: creditsScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = creditsScene
          creditsScene.enterScene();
        }
      }
    },
    State {
      name: "gameover"
      PropertyChanges { target: gameOverScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = gameOverScene
          gameOverScene.enterScene();
        }
      }
    },
    State {
      name: "levels"
      PropertyChanges { target: levelScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = levelScene
          levelScene.enterScene();
        }
      }
    }
  ]

  transitions: [
    Transition {
      from: "main"
      //to: "game"
      animations: mainMenuFadeAnimation
    }
  ]

  // Animation for fading the mainmenu scene over another
  NumberAnimation {
    id: mainMenuFadeAnimation
    target: mainMenuScene
    duration: 900
    property: "opacity"
    easing.type: Easing.InOutQuad
  }
}
