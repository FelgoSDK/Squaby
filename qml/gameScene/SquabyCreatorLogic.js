//  this reduces the delay between 2 squaby creations by this value per wave
//var squabyDelayDecrementPerWave = 500;
//var pauseBetweenWavesDecrementPerWave = 500;

// this guarantees that at high wave count the delay never gets lower than this number
//var minimumSquabyDelay = 2000; // this setting has high impact on performance - if set too low, a heap of squabies gets created which might cause the application to run slowly on slow devices!
//var minimumPauseBetweenWaves = 3000;

var currentSquabyDelay = 8000; // this is the initial delay between 2 squaby creations
var currentPauseBetweenWaves = 5000; // this is the initial waiting time between waves, which can be used to adjust the towers (repair, sell or upgrade them if in game its too hectic)

// this is used for getting the last wave from the level - when no more waves are defined, they simply get repeated, and currentWave is increased so an increasing number can be shown in the hud!
// so internalWaveIndex is equal to currentWave as long as waves.length, then it stays at wave.length
var internalWaveIndex = 1;

// this gets set to true after all squabies were created for this wave
var __isWaitingForNextWave = false;
//var squabiesBuiltInCurrentWave = 0;

// this is true while timerTriggered is call - it is a guard for the initial (first time loading) of SquabyScene, where it might be that multiple entities are created
var isCurrentlyCreating = false;

function initialize() {

  currentWave = 1
  internalWaveIndex = currentWave
  percentageCreatedInWave = 1
  squabiesBuiltInCurrentWave = 0

  if(!waves) {
    console.debug("SquabyCreatorLogic: no waves known yet!")
    return
  }

  __isWaitingForNextWave = false;

  squabyCreator.state = ""


  // warning no waves set
  if(!getCurrentWave())
    return

  currentSquabyDelay = getCurrentWave().squabyDelay;

  currentPauseBetweenWaves = getCurrentWave().pauseBetweenWaves;

  amountSquabiesInCurrentWave = getCurrentWave().amount;

  //console.debug("amountSquabiesInCurrentWave initialized to", amountSquabiesInCurrentWave)

  setIntervalOfCreationTimer(currentSquabyDelay);
}

function setIntervalOfCreationTimer(interval) {
  console.debug("SquabyCreatorLogic: set creationTimer interval to", interval);
  // ATTENTION: a change of interval automatically restarts the timer!
  creationTimer.interval = interval;
}


/*
// look at the level file for description of each squaby type!

// this is defined in Level now!
// abbreviations for faster writing - earlier by types, now squabyTypes are the ids to real components!
var sy = "squabyYellow";
// change this to squabyOrange once it is available, but now for testing with only 1 squaby type leave it with that
var so = "squabyOrange";
var sr = "squabyRed";
var sgreen = "squabyGreen";
var sblue = "squabyBlue";
var sgrey = "squabyGrey";

// this is defined in level now, as this is a level-specific setting!

var waves = [
// for testing a single squaby type, use the line below with the intended types:
//{amount: 50, types:[ {type: sgrey, p: 1}, {type: so, p: 0} ]},
// optionally, the intended time between 2 squaby creations can be set, or also the desired delay from the last wave; if one of them is not set, the default decrement-values are used..
{amount: 1, types:[ {type: sy, p: 1}, {type: so, p: 0} ]},
// these 2 parameters are optional per level: {amount: 2, squabyDelay: 2, pauseBetweenWaves: 1.8, types:[ {type: sy, p: 1}, {type: so, p: 0.1} ]},
{amount: 2, types:[ {type: sy, p: 1}, {type: so, p: 0.1} ]},
{amount: 3, types:[ {type: sy, p: 1}, {type: so, p: 0.5} ]},
{amount: 4, types:[ {type: sy, p: 1}, {type: so, p: 0.8} ]},
{amount: 5, types:[ {type: sy, p: 1}, {type: so, p: 1.0} ]},
{amount: 8, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0} ]},
{amount: 12, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}]},
{amount: 20, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}]},
{amount: 30, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}, {type: sgrey, p: 1.0}]},
// the hardest squabies have higher probability here
{amount: 30, types:[ {type: sy, p: 0.1}, {type: so, p: 0.2}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 0.5}, {type: sgrey, p: 1.0}]},
]
*/

function updatePauseBetweenWaves() {
  if(!getCurrentWave()) {
    return
  }

  // if the pauseBetweenWaves property is set, set it directly
  if(getCurrentWave().pauseBetweenWaves)
      currentPauseBetweenWaves = getCurrentWave().pauseBetweenWaves;
  // otherwise, decrease it by specified amount
  else
      currentPauseBetweenWaves -= pauseBetweenWavesDecrementPerWave;
  // guarantee the calculated value never gets below the minimum threshold
  if(currentPauseBetweenWaves<minimumPauseBetweenWaves)
      currentPauseBetweenWaves = minimumPauseBetweenWaves;
}

function timerTriggered() {

  if(isCurrentlyCreating) {
    console.debug("OVERLOAD because too much is loading in the beginning - skip entity creation once!")
    return;
  }

  isCurrentlyCreating = true;

    console.debug("SquabyCreatorLogic: creationTimer triggered");

    // the squaby type per wave could be calculated randomly, based on the probability for each squaby type
    // check if randomnumber is deterministic (results in the same number generated every program start) - it IS when qsrand() is called at initialization, which is done in application.cpp!
    //var randomNumber = Math.floor(Math.random()*5 );
    //print("randomNumber: " + randomNumber);


    //print("__lastCreationTimer: " + __lastCreationTimer);
    //print("Core.time: " + Core.time);

    // use last wave for endless run
    if(endlessGameRunning) {
      currentWave = waves.length-1
      internalWaveIndex = currentWave
      __isWaitingForNextWave = true
    }

    // also use the lastCreationTimer for measuring the time elapsed since the last squaby in this wave was created (and since then it is in the paused state)
    if(__isWaitingForNextWave) {

        currentWave++;

        // also increase the internalWaveIndex
        internalWaveIndex = currentWave

        // e.g. when waves.length = 12, the maximum number of internalWaveIndex is also 12, because below the index is accessed with i-1
        // out-of-bounds check, is not necessary because also checked above
        if(currentWave>waves.length && !endlessGameRunning) {
          // stop next level logic will take over the role of a restart if endless game.
          squabyCreator.stop()
          isCurrentlyCreating = false;
          return
        }

        // warning no waves set
        if(!getCurrentWave()) {
          isCurrentlyCreating = false
          return
        }

        // if the squabyDelay property is set, set it directly
        if(getCurrentWave().squabyDelay)
            currentSquabyDelay = getCurrentWave().squabyDelay;
        // otherwise, decrease it by specified amount
        else
            currentSquabyDelay -= squabyDelayDecrementPerWave;
        // guarantee the calculated value never gets below the minimum threshold
        if(currentSquabyDelay<minimumSquabyDelay)
            currentSquabyDelay = minimumSquabyDelay;

        updatePauseBetweenWaves()

        if(getCurrentWave().amount)
          amountSquabiesInCurrentWave = getCurrentWave().amount

        squabiesBuiltInCurrentWave = 0;

        __isWaitingForNextWave = false;
    }

    // don't put this code into an else-block, because also if the wave was changed

    //var entity = EntityFactory.createEntityAndEngage(getSquabyType());
    // the default pose (-20, 40) is fine

    //entityManager.createEntityFromComponent(getSquabyType());
    entityManager.createEntityFromEntityTypeAndVariationType( {entityType: "squaby", variationType: getSquabyType()} );
    squabyCreator.currentActiveSquabies++

    squabiesBuiltInCurrentWave++;

    // this will never get 0, because after waiting for next wave a new squaby immediately gets created!
    percentageCreatedInWave = squabiesBuiltInCurrentWave/amountSquabiesInCurrentWave;


    if(squabiesBuiltInCurrentWave >= amountSquabiesInCurrentWave) {
        // end of this wave is reached, wait until next wave can be started
        __isWaitingForNextWave = true;

        squabyCreator.state = "waitingForNextWave";

        // update time which could differ after the first wave when settings have not been set
        updatePauseBetweenWaves()

        setIntervalOfCreationTimer(currentPauseBetweenWaves);


    } else {
        // while not waiting for the next wave, the state is waitingForNextSquaby
        squabyCreator.state = "waitingForNextSquaby";

        // for the next time the timer should have the normal delay between squabies in a wave
        setIntervalOfCreationTimer(currentSquabyDelay);
    }

    // does the timer start already while onTriggered() is called? the timer resolution is very unprecise!
    //creationTimer.start();

    isCurrentlyCreating = false;
}

function getCurrentWave() {
  if(waves.length < internalWaveIndex-1 || waves.length === 0) {
    console.debug("SquabyCreatorLogic: Out of bound when accessing waves!")
    return 0
  }
    // currentWave starts with 1, not with 0!
  // this is important to use the internalWaveIndex here, not currentWave
    return waves[internalWaveIndex-1];
}

function getSquabyType() {
    var types = [] //getCurrentWave().types;

  if(!getCurrentWave())
    return "squabyYellow"

    var type = {}
    type.type = "squabyYellow"
    type.p = getCurrentWave().yellow
    types.push(type)
    type = {}
    type.type = "squabyOrange"
    type.p = getCurrentWave().orange
    types.push(type)
    type = {}
    type.type = "squabyRed"
    type.p = getCurrentWave().red
    types.push(type)
    type = {}
    type.type = "squabyGreen"
    type.p = getCurrentWave().green
    types.push(type)
    type = {}
    type.type = "squabyBlue"
    type.p = getCurrentWave().blue
    types.push(type)
    type = {}
    type.type = "squabyGrey"
    type.p = getCurrentWave().grey
    types.push(type)

    var nextCreationType = types[0].type;
    // Math.random returns a number  0 <= x < 1
    var highestProbabilityForChosenType = types[0].p*Math.random();

    for(var i=1;i<types.length;i++) {
        var possiblyHighestProbability = types[i].p*Math.random();
        if(possiblyHighestProbability > highestProbabilityForChosenType) {
            highestProbabilityForChosenType = possiblyHighestProbability;
            nextCreationType = types[i].type;
        }
    }
    print("SquabyCreatorLogic: wavecreator pseudo-random function selected entity of type '" + nextCreationType + "' to be created next with probability value of " + highestProbabilityForChosenType);
    return nextCreationType;
}
