import QtQuick 2.0
import VPlay 2.0

/*!
  This component is used to load the level in 2 phases: first the window state is set to loading so the LoadingScene appears.
  Afterwards the level is loaded and the window state is changed from "loading" to "game".
 */
// must be an Item not a QtObject, because the Timer child is needed
Item {

  // is only used internally, to precreate some entities
  property bool __loadLevelForFirstTime: true
  // instead of that, decide based on the levelData storageType: if application or user level, no editing should be possible - if authorLevels editing should be allowed
  // do NOT decide that here! but in levelEditor.onLoaded, where the storageType is known!
  property bool startInLevelEditingMode: false

  // this should be removed from here - it must be stored in the customData of the level and handled in LevelBase.onSaved() and onLoaded()
  property variant loadedWaypoints

  property url toLoadLevelUrl

  // is set in startLoadingLevel
  property variant __toLoadLevelData
  property bool __createNewLevel

  /*
    if the SquabyScene was already loaded before and the level is not new to set, the game state can be entered immediately
    otherwise at first the SquabyScene needs to be loaded, followed, by loading the level, and by precreation of entities if it is the first application run

    createNewLevel is set to true if the new level button was clicked in LevelSelectionScene
    levelData contains the metaData of the level:
      - If createNewLevel is true, it contains: { {levelName: "newLevelName", levelBaseName: "DynamicLevel01" }}
      - If createNewLevel is false, it contains: { {levelId: 1, levelName: "Level 1", levelBaseUrl: "01/Level01.qml"}}
        this is the data stored in LevelEditor::qmlLevelList, or loaded dynamically from the authorStorage

    So only the metaData is provided to this function, as the whole levelData is not known here.
   */
  function startLoadingLevel(createNewLevel, levelMetaData) {

    console.debug("TwoPhaseLevelLoader: startLoadingLevel() called, createNewLevel:", createNewLevel, ", levelData:", JSON.stringify(levelMetaData))

    if(scene.state !== "levelEditing" && !levelStore.noAdsGood.purchased) {
      chartboostView.showAdvertIfAvailable()
    }

    // if __toLoadLevelData was already set, this means that the game was started at least once
    if(__toLoadLevelData &&  __createNewLevel === createNewLevel) {

      var levelDataStayedTheSame = true
      for(var propName in levelMetaData) {
        // if any of the properties doesn't match, we have a different level
        if(levelMetaData[propName] !== __toLoadLevelData[propName]) {
          levelDataStayedTheSame = false
          break;
        }
      }

      // Do not test for "new level" edition, because if the last level was created and saved without changing anything, there should still be a new level created!
      if(levelDataStayedTheSame && !createdNewLevel && !reloadLevel) {
        // but if the entities get removed at leaving the scene as it is now, we could switch to game state directly!
        // so this allows faster loading, if the same level was selected (no loading scene will be displayed)
        // skip the loading scene below
        console.debug("TwoPhaseLevelLoader: old and new levelData are the same, thus skip the loading scene")
        // this simulates we are finished loading the level
        levelEditor.loadLevelFinished()
        // exit scene
        scene.exitScene()
        // enter scene again
        scene.enterScene()
        return;
      }

      if(reloadLevel) {
        reloadLevel = false
      }

    }

    __createNewLevel = createNewLevel
    __toLoadLevelData = levelMetaData

    console.debug("TwoPhaseLevelLoader: set window state to 'loading' from previous state", window.state)
    window.state = "loading"
  }

  // sets the levelSource to toLoadLevelUrl
  // gets called from onFinishedLoadingAnimation from SquabyMain when the LoadingScene finished its opacity animation
  function startGameAfterLevelLoadingAnimationFinished() {

    console.debug("TwoPhaseLevelLoader: startGameAfterLevelLoadingAnimationFinished called")

    // this cant happen any more here - it is guaranteed that the SquabyScene was loaded before, because startGame() was called before and switchted to state loading, where the scene source got set afterwards
//    if(!gameSceneLoader.item) {
//      console.debug("ERROR: TwoPhaseLevelLoader: the level is not loaded yet - that happens when it is started for the 1st time, when the LoadingScene timer is not finished yet")
//      return;
//    }

    console.debug("TwoPhaseLevelLoader: starting the loadDelayPhaseOne timer")
    loadLevelDelayedTimer.start()

  }

  Timer {
    id: loadLevelDelayedTimer
    // on MeeGo, the delay needs to be longer to avoid the "Application not responding" message
    // it also helps on other platforms to set a delay here, because then the scaling of the SquabyScene is correct initially - on desktops though it is not required as they are usually very fast
    interval: system.desktopPlatform ? 0 : (system.Meego ? 2000 : 50)

    onTriggered: {

      if(__createNewLevel) {
        levelEditor.createNewLevel(__toLoadLevelData)
      } else {
        levelEditor.loadSingleLevel(__toLoadLevelData)
      }

    }
  } // end of Timer


}
