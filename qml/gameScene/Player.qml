import QtQuick 1.1

// the player object gets modified in the game, e.g. when a tower is built or a squaby dies
QtObject {
  id: player
  // these get reset when the game starts from SquabyScene.enterScene
  property int gold: balancingSettings ? balancingSettings.playerStartGold : 999 // the start gold
  property int lives: balancingSettings ? balancingSettings.playerStartLives : 999 // the start lives, if these are <0 the game is over
  property int wave: 1 // gets modified by SquabyCreator! but also possible to set wave to any value at runtime, to simulate an arbitrary wave!
  property int score: 0 // the start score

  property int maxScore: 0 // the maximal score from gamecenter or the local storage

  // this gets used for analytics - it is interesting how many towers are built in each wave, and after the game is lost to tweak the balancing!
  property int nailgunsBuilt: 0
  property int flamethrowersBuilt: 0
  property int turbinesBuilt: 0
  property int towersBuilt: nailgunsBuilt+flamethrowersBuilt+turbinesBuilt

  property int nailgunsDestroyed: 0
  property int flamethrowersDestroyed: 0
  property int turbinesDestroyed: 0
  property int towersDestroyed: nailgunsDestroyed+flamethrowersDestroyed+turbinesDestroyed

  // the active ones are the built - destroyed ones!
  property int nailgunsActive: nailgunsBuilt-nailgunsDestroyed
  property int flamethrowersActive: flamethrowersBuilt-flamethrowersDestroyed
  property int turbinesActive: turbinesActive-turbinesDestroyed
  property int towersActive: nailgunsActive+flamethrowersActive+turbinesActive

  // this gets set with a binding in SquabyCreator
  property int squabiesBuiltInCurrentWave: 0

  // this is set to the currently loaded balancing settings
  property variant balancingSettings

  // this function can be used to store all player properties for analytics as own properties in the given object
  // this is called when the game is lost, and when a new wave is started
  function addPlayerPropertiesToAnalyticsObject(object) {
    object.gold = gold
    object.lives = lives
    object.wave = wave
    object.score = score

    object.nailgunsBuilt = nailgunsBuilt
    object.flamethrowersBuilt = flamethrowersBuilt
    object.turbinesBuilt = turbinesBuilt
    object.towersBuilt = towersBuilt

    object.nailgunsDestroyed = nailgunsDestroyed
    object.flamethrowersDestroyed = flamethrowersDestroyed
    object.turbinesDestroyed = turbinesDestroyed
    object.towersDestroyed = towersDestroyed

    object.nailgunsActive = nailgunsActive
    object.flamethrowersActive = flamethrowersActive
    object.turbinesActive = turbinesActive
    object.towersActive = towersActive

    // this is also interesting, because a wave contains many squabies, to find out how many were active add this property, so for finer detail
    object.squabiesBuiltInCurrentWave = squabiesBuiltInCurrentWave
  }

  // the wave property gets increased by the SquabyCreator
  onWaveChanged: {
    // only emit this event, when the wave was increased once - otherwise the properties would be uninitialized
    if(wave > 1) {
      // when the gameOver state is entered, the game is lost and the reached score, waves, etc. should be sent for analytics
      var objectWithPlayerProperties = {};
      // here all player properties are set as properties, e.g. waves, score, gold, number nailguns built, etc.
      addPlayerPropertiesToAnalyticsObject(objectWithPlayerProperties);
      flurry.logEvent("Game.WaveIncreased", objectWithPlayerProperties);
    }
  }

  onLivesChanged: {
    if(lives <= 0) {
      console.debug("Game over, score:", score)

      // initially, the scene might not be loaded when it is loaded dynamically
      if(scene)
        // Stop current game, is this the right function?
        scene.exitScene()

      if (score > maxScore)
        maxScore = score;

      // Show gameover scene
      window.state = "gameover"
    }
  }

  // these get reset when the game starts from SquabyScene.enterScene
  function initializeProperties() {
    gold = balancingSettings.playerStartGold
    lives = balancingSettings.playerStartLives
    wave = 1
    score = 0

    nailgunsBuilt = 0
    flamethrowersBuilt = 0
    turbinesBuilt = 0
    nailgunsDestroyed = 0
    flamethrowersDestroyed = 0
    turbinesDestroyed = 0
  }

  Component.onCompleted: {
    var storedScore = settings.getValue("maximumHighscore");
    // if first-time use, nothing can be loaded and storedScore is undefined
    if(storedScore)
      maxScore = storedScore;

    // NOTE: this should not be done in onCompleted(), because otherwise the loading time until the first image is displayed gets strongly increased!
    // instead, only start precreating when the main menu is displayed and the first time a game is started!
    //console.debug("LevelBase: call preCreateEntitiesForPool()");
    // creates squabies for pool
    //preCreateEntitiesForPool()

    // Authenticate player to gamecenter
    gameCenter.authenticateLocalPlayer();
  }

  onMaxScoreChanged: {
    var storedScore = settings.getValue("maximumHighscore");
    // if not stored anything yet, store the new value
    // or if a new highscore is reached, store that
    if(!storedScore || maxScore > storedScore) {
      console.debug("stored improved highscore from", storedScore, "to", maxScore);
      settings.setValue("maximumHighscore", maxScore);
    }

    // Post highscore to Game Center
    if (gameCenter.authenticated)
      gameCenter.reportScore(maxScore);

    // and to facebook
    // not implemented yet!
    //facebook.sendNewHighscoreToUserWall(maxScore)
  }

} // end of Player
