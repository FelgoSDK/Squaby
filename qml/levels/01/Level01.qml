import QtQuick 1.1
import ".."

SquabyLevelBase {

  Component.onCompleted: {
    //console.debug("Level01 completed!")
    //console.debug("entityManager:", entityManager, ", entityContainer:", entityManager.entityContainer)
    //var entityId = entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("../../entities/Waypoint.qml"), {x:200, y: 300, entityId: "wap1"})
//    var entityId = entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("../../entities/Obstacle.qml"), { variationType: "choco", x:200, y: 150, entityId: "choco1"})
//    var entity = entityManager.getEntityById(entityId)
//    console.debug("___Level01 created entity:", entity, entity.parent, entity.parent.parent)

  // these also work here, as they got created as soon as entityContainer got available
//    entityManager.createEntityFromEntityTypeAndVariationType( {entityType: "squaby", variationType: "squabyYellow", x: 200, y: 200 } )
//    entityManager.createEntityFromEntityTypeAndVariationType( {entityType: "obstacle", variationType: "choco", x:200, y: 150, entityId: "choco1"} )
  }


     waypoints: [
         { x:16, y:48},
         { x:112, y:48},
         { x:112, y:144},

         // when x<=16, the waypoint wont be deleted, it is added to the pool, but it is still visible afterwards, although entity.visible is false!?!?
         // TODO: i dont have a clue why it is still visible, although added to the pool!?
//             { x:16, y:144},
//             { x:16, y:240},

       // thus as a workaround, just set ti to 32!
         { x:16+32, y:144},
         { x:16+32, y:240},

         { x:144, y:240},
         { x:144, y:176},
         { x:208, y:176},
         { x:208, y:16},
         { x:336, y:16},
         { x:336, y:80},
         { x:432, y:80},
         { x:432, y:112},
         { x:304, y:112},
         { x:304, y:208},
         { x:464, y:208}
     ]


    //  this reduces the delay between 2 squaby creations by this value per wave
    squabyDelayDecrementPerWave: 100
    pauseBetweenWavesDecrementPerWave: 300

    // this guarantees that at high wave count the delay never gets lower than this number
    minimumSquabyDelay: 2500 // this setting has high impact on performance - if set too low, a heap of squabies gets created which might cause the application to run slowly on slow devices!
    minimumPauseBetweenWaves: 5000

    // this gets used by SquabyCreator
    waves: [
      // for testing a single squaby type, use the line below with the intended types:
      //{amount: 50, types:[ {type: sgrey, p: 1} ]},

      // uncomment the next line for testing all squaby types shortly after each other:
      //{amount: 30, squabyDelay: 2000, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}, {type: sgrey, p: 1.0}]},

      // optionally, the intended time between 2 squaby creations can be set, or also the desired delay from the last wave; if one of them is not set, the default decrement-values are used..
      // the 2 parameters "squabyDelay" and pauseBetweenWaves" are optional per level, e.g.: {amount: 2, squabyDelay: 2000, pauseBetweenWaves: 1800, types:[ {type: sy, p: 1}, {type: so, p: 0.1} ]},
      // NOTE: set the first squabyDelay quite high, because that is the first start of the game and the user should have enough time for reacting!
      /* 1 */ {amount: 1, squabyDelay: 15000, pauseBetweenWaves: 10000, types:[ {type: sy, p: 1}]},
      /* 2 */ {amount: 10, squabyDelay: 2500, pauseBetweenWaves: 6000, types:[ {type: sy, p: 1}]},
      // 11 squabies created, 9*5=45 gold earned

      // first appearance of green squaby, vulnerable against fire
      /* 3 */ {amount: 10, squabyDelay: 2500, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.9}, {type: sgreen, p: 1.0}]},

      // first appearance of orange squaby, with high fire resistance
      /* 4 */ {amount: 10, squabyDelay: 4000, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.7}, {type: sgreen, p: 0.8}, {type: so, p: 1} ]},

      // first appearance of red squaby, with max fire resistance
      /* 5 */ {amount: 20, squabyDelay: 3000, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.5}, {type: sgreen, p: 0.6}, {type: so, p: 0.5}, {type: sr, p: 0.7} ]},

      // blue squaby with high resistance for nailgun&fire
      /* 6 */ {amount: 20, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}]},

      // grey squaby with max resistance for nailgung&fire
      /* 7 */ {amount: 30, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}, {type: sgrey, p: 1.0}]},

      // the hardest squabies have higher probability here
      /* 8 */ {amount: 30, types:[ {type: sy, p: 0.5}, {type: so, p: 0.5}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 0.5}, {type: sgrey, p: 1.0}]},
      /* 9 */ {amount: 30, types:[ {type: sy, p: 0.1}, {type: so, p: 0.2}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 0.5}, {type: sgrey, p: 1.0}]},
    ]

    Obstacles {}
}

