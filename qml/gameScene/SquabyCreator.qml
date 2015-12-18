import QtQuick 2.0
import "SquabyCreatorLogic.js" as Logic

// this component creates the squabies based on a time
Item {
    id: squabyCreator
    // running gets accessed by SquabyScene, when the game is paused
    // it is false by default! only when enabled & running is set to true, it will start creating squabies!
    property alias running: creationTimer.running

    // this property can be used to completely turn off
    property bool enabled: true

    // the waves may be changed at runtime, when the level is changed!
    property variant waves: level.waves

    // currentWave starts with 1, not with 0!
    // this gets updated internally by Logic! if it gets modified, forward the change to the player.wave property in onCurrentWaveChanged!
    // is resetted to 1 in initialize()
    property int currentWave: 1

    // gets updated internally by logic, if e.g. the wave has 4 squabies and 1 is already created, percentageCreated is 0.25
    // can be connected to the wave progress bar in the hud
    property real percentageCreatedInWave: 1

    //  this reduces the delay between 2 squaby creations by this value per wave
    property int squabyDelayDecrementPerWave: level.loadedLevel ? level.loadedLevel.squabyDelayDecrementPerWave : 100
    property int pauseBetweenWavesDecrementPerWave: level.loadedLevel ? level.loadedLevel.pauseBetweenWavesDecrementPerWave : 300

    // this guarantees that at high wave count the delay never gets lower than this number
    property int minimumSquabyDelay: level.loadedLevel ? level.loadedLevel.minimumSquabyDelay : 500 // this setting has high impact on performance - if set too low, a heap of squabies gets created which might cause the application to run slowly on slow devices!
    property int minimumPauseBetweenWaves: level.loadedLevel ? level.loadedLevel.minimumPauseBetweenWaves : 500

    // this is not used yet
    property int initialDelayWhenGameStarts: 2000

    property int squabiesBuiltInCurrentWave: 0
    property int amountSquabiesInCurrentWave: 1
    property int currentActiveSquabies: 0
    property bool endlessGameRunning: false

    onCurrentActiveSquabiesChanged: {
      triggerLevelChange()
    }

    function triggerLevelChange() {
      if(currentActiveSquabies <= 0 && currentWave>waves.length && !endlessGameRunning) {
        if(level.endlessGame) {
          scene.lastWaveSend()
        } else {
          scene.changeToNextLevel()
        }
      }
    }

    function squabyDied(squabyType) {
      tutorials.nextAction(squabyType,"died")
      currentActiveSquabies--
    }

    // these 2 properties are needed to be able to pause the squaby creation and pause mode between waves
    property date __lastStartedTime
    // is only set when the game was paused, otherwise it has value 0
    property int timeSpentBeforePaused: 0
    // just for debugging internally
//    property alias timer: creationTimer
//    property int lastTimeSpent
//    property int newInterval
//    property int oldInterval
//    // make as big as the scene for debugging
//    anchors.fill: parent
//    Text {
//      text: "timeSpentBeforePaused: " + timeSpentBeforePaused + "\nlastStart: " + __lastStartedTime + "\nlastTimeSpent: " + lastTimeSpent + "\nnewInterval: " + newInterval + "\noldInterval:" + oldInterval + "\ninterval: " + timer.interval + "\ncurrentSquabyDelay: " + currentSquabyDelay + "\ncurrentPauseBetweenWaves: " + currentPauseBetweenWaves
//    }

    // set the player property to the one from here
    Binding {
      target: player
      property: "squabiesBuiltInCurrentWave"
      value: squabiesBuiltInCurrentWave
    }

    // is called when player wants to play endless
    function continueEndless() {
      endlessGameRunning = true
      start()
    }

    // is called every time the game gets restarted
    function restart() {
      if(!enabled)
        return

      console.debug("SquabyCreator.restart()")

      currentActiveSquabies = 0
      endlessGameRunning = false

      // is this really required? we are single-threaded anyway
      creationTimer.stop()

      Logic.initialize()

      // this is important, otherwise the first trigger would not be called
      timeSpentBeforePaused = 0

      // this must be set AFTER initialize(), because there the interval is set to the one of the first wave!
      // not supported yet, start immediately!
      //creationTimer.interval = initialDelayWhenGameStarts
      creationTimer.restart()
    }

    // is called every time the game gets restarted
    function reset() {
      currentActiveSquabies = 0
      endlessGameRunning = false

      // is this really required? we are single-threaded anyway
      creationTimer.stop()

      Logic.initialize()

      // this is important, otherwise the first trigger would not be called
      timeSpentBeforePaused = 0
    }

    function start() {

      if(!enabled)
        return

      console.debug("SquabyCreator.start()")

      // this happened before, when start() was also called in entering the default scene state, and from enterScene()
      // however, if called multiple times the interval would be reduced twice
      if(running) {
        console.debug("ERROR: SquabyCreator was already running, but start() was called again - this is a programmer error and should not happen")
        return;
      }

      if(timeSpentBeforePaused != 0) {

        var newInterval = creationTimer.interval - timeSpentBeforePaused

        //console.debug("_________SquabyCreator.start: timeSpentBeforePaused:", timeSpentBeforePaused, ", old interval:", creationTimer.interval, ", new interval:", newInterval)
        //lastTimeSpent = timeSpentBeforePaused
        //oldInterval = creationTimer.interval

        if(newInterval <= 0) {
          // this causes an immediate trigger
          timeSpentBeforePaused = 0
        } else {
          // this causes the squaby not be created immediately, because timeSpentBeforePaused is set
          // a change of interval automatically restarts the timer (if it is running) - but since start will only be called when it is not running, it is safe to do so here
          creationTimer.interval = newInterval
        }
      }

      // if timeSpentBeforePaused has a value here, no squaby is created immediately
      // otherwise, a squaby is created immediately because onTriggered() is called when running changes to true because triggeredOnStart is set to true
      running = true

    }

    function pause() {
      //console.debug("SquabyCreator.pause()")

      var now = new Date()
      var dt = now - __lastStartedTime
      console.debug("SquabyCreator.pause: timeSpentBeforePaused:", dt, ", current interval:", creationTimer.interval)
      timeSpentBeforePaused = dt

      running = false
    }

    // is only called when switchted to the levelEditing state - the squaby creation should not be paused then, but fully stopped
    function stop() {
      // resets this variable, so the next call of start() will create a squaby immediately
      timeSpentBeforePaused = 0
      running = false
    }

    Component.onCompleted: {
        Logic.initialize();
    }

    onEnabledChanged: {
        console.debug("SquabyCreator: changed enabled to:", enabled);
        if(enabled && !running) {
            running = true;
        }
        if(!enabled && running)
            running = false;
    }

    onRunningChanged: {
        console.debug("SquabyCreator: onRunningChanged to:", running);

        // only allow setting running to true when enabled is true!
        if(running && !enabled) {
            console.debug("SquabyCreator: running was true, but enabled was false, thus change running to false as well");
            running = false;
        }

        console.debug("SquabyCreator: after modifying running, changed running to:", running);
    }

    onWavesChanged: {
      console.debug("SquabyCreator: waves changed! initialize now!")

      // this happens, when the level changes and the waves change
      Logic.initialize()
    }

    onCurrentWaveChanged: {
      console.debug("SquabyCreator: currentWave changed to", currentWave)
      player.wave = currentWave;
      triggerLevelChange()
    }

    Timer {
        id: creationTimer
        // the interval gets modified in which wave level the player currently is
        //interval: 7000
        interval: initialDelayWhenGameStarts
        repeat: true
        // the running-property should be set from outside! defaults to false - if not set from outside (by setting running of SquabyCreator to true) it will not start
        // update: this gets set explicitly by calling restart() from the SquabyScene, otherwise the squabies would be created from the beginning!
        //running: squabyCreator.enabled && creationTimer.running

        // TODO: do not set this to true, so there is more time when the game starts!
        // not supported yet, start immediately!
        // NOTE: when restart() is called, onTriggered will be called immediately when this is set to true!
        triggeredOnStart: true // call onTriggered when started, so a squaby is created immediately when started

        onTriggered: {

            if(timeSpentBeforePaused != 0) {
              console.debug("SquabyCreator.onTriggered: do not create yet and wait for the next interval, time spent:", timeSpentBeforePaused, ", interval:", interval)
              // reset it here - this should only happen once - if it is resumed multiple times, timeSpentBeforePaused gets set multiple times
              timeSpentBeforePaused = 0
              return;
            }

            Logic.timerTriggered();

            // if the interval was not changed, e.g. because within the same wave, the last started time should still be reset here
            __lastStartedTime = new Date()

            //entityManager.createEntityFromComponent(level.squabyTypes.squabyYellow);
            //entityManager.createEntityFromComponent(level.squabyTypes.squabyOrange);
        }

        onRunningChanged: {
          if(running) {
            // required to be able to calculate the correct pause time
            __lastStartedTime = new Date()
            //console.debug("_________SquabyCreator.onRunningChanged to true")
          }
        }
        // a change of the interval also triggers a restart of the timer, which would not be detected otherwise!
        onIntervalChanged: {
          if(running) {
            // required to be able to calculate the correct pause time
            __lastStartedTime = new Date()
            //console.debug("_________SquabyCreator.onIntervalChanged to", interval, ", restarting the timer")
          }
        }
    }

    function createNextSquabyImmediately() {
      // don't allow instant spawning in tutorials
      if(tutorials.running == true && !tutorials.nextAction("squabyCreator","immediately"))
        return

      if(squabiesBuiltInCurrentWave >= amountSquabiesInCurrentWave && currentWave >= waves.length)
        return

      //  When creating instantly we can ignore the pause time.
      timeSpentBeforePaused = 0

      var returnVal = new Date() - __lastStartedTime

      if(squabiesBuiltInCurrentWave >= amountSquabiesInCurrentWave) {
        // next wave time
        returnVal = Logic.currentPauseBetweenWaves-returnVal
      } else {
        // next squaby time
        returnVal = Logic.currentSquabyDelay-returnVal
      }

        // this is sent by the HUD at pressing the wave button
        // it can be used to reduce waiting between waves, or to immediately create
        creationTimer.restart(); // this would not be needed when it is guaranteed the interval changes, but since it may be the same if defined by user, make sure restart() is called before!
        // a restart() with enabled triggeredOnStart-property causes Logic.timerTriggered() to be called immediately already
        //Logic.timerTriggered();

      return returnVal
    }

    function createNextSingleSquabyImmediately() {
        Logic.timerTriggered();
    }

    // TODO: the logic could make use of these states as well!
    states: [
        State {
            name: "waitingForNextSquaby"

        },
        State {
            // this is active, when the last squaby of a wave was created - the next time Logic.timerTriggered() is called the wave-counter will be increased!
            name: "waitingForNextWave"

        }
    ]

}
