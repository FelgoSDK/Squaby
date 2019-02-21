import QtQuick 2.0
import Felgo 3.0

import "otherScenes"
import "gameScene"
import "levels"
import "common"

Item {
  // all properties assigned here are accessible from all entities!
  // the reason for that is, because EntityManager is created in here, and only the parents of EntityManager where new entities get created are known!
  property alias level: gameSceneLoader.level
  property alias levelScene: levelScene

  property alias hud: gameSceneLoader.hud // needs to be accessed from the towers when they are clicked to update the upgrade menu

  property bool createdNewLevel: false
  // when author wants to play it's own level this flag needs to be set true.
  property bool editAuthorLevel: false
  property bool reloadLevel: false

  Player {
    // because it is defined here at the root object, it is accessible from all components
    id: player
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
    } else if(lastActiveState === "credits") {
      flurry.endTimedEvent("Display.Credits");
    } else if(lastActiveState === "gameOver") {
      flurry.endTimedEvent("Display.GameOver");
    } else if(lastActiveState === "levels") {
      flurry.endTimedEvent("Display.Levels");
    } else if(lastActiveState === "waveDefeated") {
      flurry.endTimedEvent("Display.waveDefeated");
    }

    if(state === "main") {
      flurry.logTimedEvent("Display.Main");
    } else if(state === "game") {
      flurry.logTimedEvent("Display.Game");
    } else if(state === "pause") {
      flurry.logTimedEvent("Display.Pause");
    } else if(state === "credits") {
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
    } else if(state === "waveDefeated") {
      flurry.logTimedEvent("Display.waveDefeated");
    }

    lastActiveState = state;
  }

  SquabyGameNetwork {
    id: gameNetwork
  }

  // this is called from FelgoGameNetwork when it gets synced
  // and after resuming the app after it was in background from StackTheBoxWithCommunityEditorMain
  function reloadUserBestLevelStats() {
    console.debug("reloadUserBestLevelStats() called")
    // if the user is not in sync yet, it will be called from STBGameNetwork when it gets in sync
    if(gameNetwork.userInitiallyInSync) {
      levelEditor.loadBestLevelStats()
    }
  }

  SquabyLevelStore {
    id: levelStore

    levelEditorItem: levelEditor
  }

  // moved the logic into an own component, as it is more code than Flurry for example
  FacebookConnector {
    id: facebook
  }

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

  DefeatedScene {
    id: waveDefeatedScene
    onRestartGame: {
      flurry.logEvent("Defated.Restart","Level",levelEditor.currentLevelNameString)
      if(!levelStore.noAdsGood.purchased)
        chartboostView.doNotShowAdvert()
      scene.restartGame()
    }
    onContinueGame: {
      flurry.logEvent("Defated.ContinuesGame","Level",levelEditor.currentLevelNameString)
      if(!levelStore.noAdsGood.purchased)
        chartboostView.doNotShowAdvert()
      scene.continueGame()
    }
    onNextLevel: {
      flurry.logEvent("Defated.NextLevel","Level",levelEditor.currentLevelNameString)
      if(!levelStore.noAdsGood.purchased)
        chartboostView.doNotShowAdvert()
      scene.nextLevel()
    }
    onGameOver: {
      flurry.logEvent("Defated.GameOver","Level",levelEditor.currentLevelNameString)
      if(!levelStore.noAdsGood.purchased)
        chartboostView.doNotShowAdvert()
      scene.exitScene()
    }
    onBackButtonPressed: {
      flurry.logEvent("Defated.BackPressed","Level",levelEditor.currentLevelNameString)
      if(!levelStore.noAdsGood.purchased)
        chartboostView.doNotShowAdvert()
    }

    onShowHighscoreForLevel: {
      gameNetwork.showLeaderboard(leaderboard)
      vplayGameNetworkScene.cameFromScene = "waveDefeated"
      window.state = "gameNetwork"
      flurry.logEvent("Level.ShowHighscore","leaderboard",leaderboard)
    }
  }

  property alias creditsScene: creditsSceneLoader.item
  Loader {
    id: creditsSceneLoader
  }


  LevelSelectionScene {
    id: levelScene

    onBackClicked: window.state = "main"
    onNewLevelClicked: {
      for(var ii = 0; ii < levelEditor.applicationJSONLevels.length; ++ii) {
        if(levelEditor.applicationJSONLevels[ii].levelName === "MyLevel") {
          createdNewLevel = true
          twoPhaseLevelLoader.startLoadingLevel(false,levelEditor.applicationJSONLevels[ii])
        }
      }
      flurry.logEvent("LevelSelection.NewLevel")
    }
    onShowProfileView: {
      vplayGameNetworkScene.cameFromScene = "selectLevel"
      window.state = "gameNetwork"
      // this opens the profileView tab
      gameNetwork.showProfileView()
      flurry.logEvent("LevelSelection.ShowProfile")
    }
    onShowHighscoreForLevel: {
      // gets called from LevelItem
      // showLeaderboard() activates the view of the leaderboard and sets it as currentActiveLeaderboard
      gameNetwork.showLeaderboard(leaderboard)
      vplayGameNetworkScene.cameFromScene = "selectLevel"
      window.state = "gameNetwork"
      flurry.logEvent("LevelSelection.ShowHighscore","leaderboard",leaderboard)
    }
  }

  // Set MainMenuScene as last so it is in front of the game scene for our custom fade animation
  MainMenuScene {
    id: mainMenuScene

    onPlayClicked: {
      // to track how often the players select the my levels menu
      flurry.logEvent("MainMenu.Play")

      // by changing the storageLocation, the levelScene will listen to a change of the result
      levelScene.storageLocation = levelEditor.applicationJSONLevelsLocation
      window.state = "levels"
    }

    onMyLevelsClicked: {
      // to track how often the players select the my levels menu
      flurry.logEvent("MainMenu.Levels")

      // by changing the storageLocation, the levelScene will listen to a change of the result
      levelScene.storageLocation = levelEditor.authorGeneratedLevelsLocation
      window.state = "levels"
    }

    onCreditsClicked: {
      flurry.logEvent("MainMenu.Credits")
      creditsSceneLoader.source = "otherScenes/CreditsScene.qml"
      window.state = "credits"
    }

    onGameNetworkViewClicked: {
      flurry.logEvent("MainMenu.GameNetwork")
      gameNetwork.showProfileView()
      vplayGameNetworkScene.cameFromScene = "menu"
      window.state = "gameNetwork"
    }
  }

  FelgoGameNetworkScene {
    id: vplayGameNetworkScene
    onBackButtonPressed: {
      flurry.logEvent("GameNetwork.BackPressed","from",cameFromScene)
      if(cameFromScene === "menu") {
        window.state = "main"
      } else if(cameFromScene === "selectLevel"){
        window.state = "levels"
      } else if(cameFromScene === "waveDefeated") {
        window.state = "waveDefeated"
      }
    }
  }

  AchievementOverlay {
    id: achievementOverlay
    z: 100
  }

  property alias levelEditor: squabyLevelEditor
  SquabyLevelEditor {
    id: squabyLevelEditor
    // this is required, otherwise the entityManager is not known (as it comes from LevelEditor in the engine, but still not clear why no access to entityManager (also not with an alias to it)!)
    entityManagerItem: entityManager
  }

  ChartboostView {
    id: chartboostView
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

  // is used to first load the scene if it did not exist before, and then set the state to game
  TwoPhaseLevelLoader {
    id: twoPhaseLevelLoader
  }

  Component.onCompleted: {
    // lock all levels when app starts the first time
    lockAllLevels()
  }

  function pauseGame() {
    if(state === "game" && gameSceneLoader.item) {
      gameSceneLoader.item.showPauseScene()
    }
  }

  function lockAllLevels() {
    var levelInit = settings.getValue("levelsInit")
    if(levelInit === undefined) {
      settings.setValue("levelsInit", true)
      settings.setValue(3863, true) // 2
      settings.setValue(7335, true) // 3
      settings.setValue(6849, true) // 4
      settings.setValue(1805, true) // 5
      settings.setValue(7612, true) // 6
      settings.setValue(130, true) // 7
      settings.setValue(8646, true) // 8
      settings.setValue(9201, true) // 9
      settings.setValue(5840, true) // 10
    }
  }

  function unlockNextLevel(currentLevel) {
    if(currentLevel === "Level 1") {
      settings.setValue(3863, false)
      return true
    } else if(currentLevel === "Level 2") {
      settings.setValue(7335, false)
      return true
    } else if(currentLevel === "Level 3") {
      if(!settings.getValue(3863)) { // check if last level was unlocked
        settings.setValue(6849, false)
        return true
      }
      return false
    } else if(currentLevel === "Level 4") {
      if(!settings.getValue(7335)) { // check if last level was unlocked
        settings.setValue(1805, false)
        return true
      }
      return false
    } else if(currentLevel === "Level 5") {
      if(!settings.getValue(6849)) { // check if last level was unlocked
        settings.setValue(7612, false)
        return true
      }
      return false
    } else if(currentLevel === "Level 6") {
      if(!settings.getValue(1805)) { // check if last level was unlocked
        settings.setValue(130, false)
        return true
      }
      return false
    } else if(currentLevel === "Level 7") {
      if(!settings.getValue(7612)) { // check if last level was unlocked
        settings.setValue(8646, false)
        return true
      }
      return false
    } else if(currentLevel === "Level 8") {
      if(!settings.getValue(130)) { // check if last level was unlocked
        settings.setValue(9201, false)
        return true
      }
      return false
    } else if(currentLevel === "Level 9") {
      if(!settings.getValue(8646)) { // check if last level was unlocked
        settings.setValue(5840, false)
        return true
      }
      return false
    } else if(currentLevel === "Level 10") {
      return false
    }
  }

  function unlockLevel(name) {
    if(name === "Level 1") {
      settings.setValue(3863, false)
    } else if(name === "Level 2") {
      settings.setValue(3863, false)
    } else if(name === "Level 3") {
      settings.setValue(7335, false)
    } else if(name === "Level 4") {
      settings.setValue(6849, false)
    } else if(name === "Level 5") {
      settings.setValue(1805, false)
    } else if(name === "Level 6") {
      settings.setValue(7612, false)
    } else if(name === "Level 7") {
      settings.setValue(130, false)
    } else if(name === "Level 8") {
      settings.setValue(8646, false)
    } else if(name === "Level 9") {
      settings.setValue(9201, false)
    } else if(name === "Level 10") {
      settings.setValue(5840, false)
    }
  }

  function isBuyable(currentLevel) {
    if(currentLevel === "Level 2" && settings.getValue(3863)) {
      return true
    } else if(currentLevel === "Level 3" && settings.getValue(7335) && !settings.getValue(3863)) {
      return true
    } else if(currentLevel === "Level 4" && settings.getValue(6849) && !settings.getValue(7335)) {
      return true
    } else if(currentLevel === "Level 5" && settings.getValue(1805) && !settings.getValue(6849)) {
      return true
    } else if(currentLevel === "Level 6" && settings.getValue(7612) && !settings.getValue(1805)) {
      return true
    } else if(currentLevel === "Level 7" && settings.getValue(130) && !settings.getValue(7612)) {
      return true
    } else if(currentLevel === "Level 8" && settings.getValue(8646) && !settings.getValue(130)) {
      return true
    } else if(currentLevel === "Level 9" && settings.getValue(9201) && !settings.getValue(8646)) {
      return true
    } else if(currentLevel === "Level 10" && settings.getValue(5840) && !settings.getValue(9201)) {
      return true
    }
    return false
  }

  function isCommunityLevel(currentLevel) {
    // Note that iOS Qt 5.3.1 only allows a maximum of 8 subseuqent case branches, otherwise an assertion in QVector is
    // triggered
    switch(currentLevel) {
      case "Level 1":
      case "Level 2":
      case "Level 3":
      case "Level 4":
        return false
      case "Level 5":
      case "Level 6":
      case "Level 7":
      case "Level 8":
      case "Level 9":
      //case "Level 10": // last level is not seen as community level to get the according buttons in the win scene
        return false
      default:
        return true
      }
  }

  function activateMain() {
    // fade in
    state = "main"
  }

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
          if(lastActiveScene === waveDefeatedScene || lastActiveScene === scene ) {
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
      PropertyChanges { target: waveDefeatedScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = waveDefeatedScene
          waveDefeatedScene.enterScene();
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
      name: "gameNetwork"
      PropertyChanges {target: vplayGameNetworkScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = vplayGameNetworkScene
        }
      }
    },
    State {
      name: "gameover"
      PropertyChanges { target: scene; opacity: 1}
      PropertyChanges { target: waveDefeatedScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = waveDefeatedScene
          waveDefeatedScene.enterScene();
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
    },
    State {
      name: "waveDefeated"
      PropertyChanges { target: scene; opacity: 1}
      PropertyChanges { target: waveDefeatedScene; opacity: 1}
      StateChangeScript {
        script: {
          window.activeScene = waveDefeatedScene
          waveDefeatedScene.enterScene();
        }
      }
    }
  ]

  transitions: [
    Transition {
      from: "main"
      //to: "game"
      animations: mainMenuFadeAnimation
    },
    Transition {
      from: ""
      to: "main"
      PropertyAnimation { target: mainMenuScene; property: "opacity"; duration: 1000 }
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
