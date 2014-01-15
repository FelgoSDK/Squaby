import VPlay 1.0
import QtQuick 1.1
import "../entities"

// we might use the levelSaved, levelLoaded and levelUnloaded signals here
LevelBase {
  id: squabyLevelBase

  property alias pathEntity: pathEntity
  property alias waypoints: pathEntity.waypoints

  onLevelAboutToBeSaved: {
    console.debug("SquabyLevelBase: onLevelAboutToBeSaved()")
    // modify customData property so it gets stored with the level
    levelData.customData = { waypoints: squabyLevelBase.waypoints }
  }

  onLevelLoaded: {
    console.debug("SquabyLevelBase: onLevelLoaded()")
    // no waypoints might have been stored
    if(levelData.customData && levelData.customData["waypoints"]) {

      console.debug("loaded waypoints dynamically from customData:", JSON.stringify(levelData.customData))

      pathEntity.initializeFromWaypoints(levelData.customData.waypoints)
    }
  }

  // just for debugging if the levelData access works
//  Text {
//    text: "levelName: " + levelData.levelMetaData.levelName
//    property real vertexZ: 30
//    color: "white"
//    anchors.right: parent.right
//    anchors.bottom: parent.bottom
//  }

  // the pathEntity is not a real entity as it does not get created or removed and does not derive from EntityBase
  // it is just the glue logic that creates the entities that make up a path: PathSection and Waypoint
  PathEntity {
    id: pathEntity

    // example for waypoints:
//    waypoints: [
//      { x:16, y:48},
//      { x:112, y:48}
//    ]

  }

  //  this reduces the delay between 2 squaby creations by this value per wave
  property int squabyDelayDecrementPerWave: 100
  property int pauseBetweenWavesDecrementPerWave: 300

  // this guarantees that at high wave count the delay never gets lower than this number
  property int minimumSquabyDelay: 2500 // this setting has high impact on performance - if set too low, a heap of squabies gets created which might cause the application to run slowly on slow devices!
  property int minimumPauseBetweenWaves: 5000

  // this gets used by SquabyCreator
  property variant waves
// example:
//    [
//    // for testing a single squaby type, use the line below with the intended types:
//    //{amount: 50, types:[ {type: sgrey, p: 1} ]},

//    // uncomment the next line for testing all squaby types shortly after each other:
//    //{amount: 30, squabyDelay: 2000, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}, {type: sgrey, p: 1.0}]},

//    // optionally, the intended time between 2 squaby creations can be set, or also the desired delay from the last wave; if one of them is not set, the default decrement-values are used..
//    // the 2 parameters "squabyDelay" and pauseBetweenWaves" are optional per level, e.g.: {amount: 2, squabyDelay: 2000, pauseBetweenWaves: 1800, types:[ {type: sy, p: 1}, {type: so, p: 0.1} ]},
//    /* 1 */ {amount: 1, squabyDelay: 5000, pauseBetweenWaves: 10000, types:[ {type: sy, p: 1}]},
//    /* 2 */ {amount: 10, squabyDelay: 2500, pauseBetweenWaves: 6000, types:[ {type: sy, p: 1}]},
//    // 11 squabies created, 9*5=45 gold earned

//    // first appearance of green squaby, vulnerable against fire
//    /* 3 */ {amount: 10, squabyDelay: 2500, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.9}, {type: sgreen, p: 1.0}]},

//    // first appearance of orange squaby, with high fire resistance
//    /* 4 */ {amount: 10, squabyDelay: 4000, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.7}, {type: sgreen, p: 0.8}, {type: so, p: 1} ]},

//    // first appearance of red squaby, with max fire resistance
//    /* 5 */ {amount: 20, squabyDelay: 3000, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.5}, {type: sgreen, p: 0.6}, {type: so, p: 0.5}, {type: sr, p: 0.7} ]},

//    // blue squaby with high resistance for nailgun&fire
//    /* 6 */ {amount: 20, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}]},

//    // grey squaby with max resistance for nailgung&fire
//    /* 7 */ {amount: 30, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}, {type: sgrey, p: 1.0}]},

//    // the hardest squabies have higher probability here
//    /* 8 */ {amount: 30, types:[ {type: sy, p: 0.5}, {type: so, p: 0.5}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 0.5}, {type: sgrey, p: 1.0}]},
//    /* 9 */ {amount: 30, types:[ {type: sy, p: 0.1}, {type: so, p: 0.2}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 0.5}, {type: sgrey, p: 1.0}]},
//  ]

  // static obstacles might be added here in qml levels, for dynamic levels they are stored dynamically

}
