import QtQuick 2.0
import Felgo 3.0
import ".."


SquabyLevelBase {

    //  this reduces the delay between 2 squaby creations by this value per wave
    squabyDelayDecrementPerWave: 100
    pauseBetweenWavesDecrementPerWave: 300

    // this guarantees that at high wave count the delay never gets lower than this number
    minimumSquabyDelay: 500 // this setting has high impact on performance - if set too low, a heap of squabies gets created which might cause the application to run slowly on slow devices!
    minimumPauseBetweenWaves: 500

    nextLevelId: ""
    difficulty: 5

    maxPlayerLife: 5
    onMaxPlayerLifeChanged: {
      balancingSettings.playerStartLives = maxPlayerLife
    }

    startGold: 40
    onStartGoldChanged: {
      balancingSettings.playerStartGold = startGold
    }

    endlessGame: false
    // To enable new towers add lines in MyLevel.json:
    // ,{"checked":false,"name":"tesla"},{"checked":false,"name":"turbine"}
    // add lines in LevelEmpfty.qml
    //{checked: false, name: "taser"},
    //{checked: false, name: "tesla"},
    // and add buttons in BuyTowersHUD.qml
    // add lines in SquabyBalacingSettings.qml
    towerPermissions: [
      {checked: true, name: "nailgun"},
      {checked: false, name: "flamethrower"},
      //{checked: false, name: "taser"},
      //{checked: false, name: "tesla"},
      {checked: false, name: "turbine"},
    ]

    EditableComponent {

      editableType: "GameSettings"
      // this is needed, because all EditableComponents for type "SquabySettings" have the same property names - this would not work without the defaultGroup set
      defaultGroup: "settings"

      properties: {
        "settings": {
          "difficulty": {"min": 1, "max": 10, "stepsize": 1, "label": "Difficulty"},
          "nextLevelId": {"label": "Next Level", "enabled": developerBuild},
        },

        "environment": {
          "maxPlayerLife": {"min": 1, "max": 50, "stepsize": 1, "label": "Player Lifes"},
          "startGold": {"min": 0, "max": 1000, "stepsize": 5, "label": "Start Gold"},
          //"endlessGame": {"label": "Endless Game"}, not used atm because there is no benefit of it.
          "towerPermissions": {"propertyType": "simpleArrayDelegate"}
        },

        "waveData":
          {
            "squabyDelayDecrementPerWave": {"min": 0, "max": 1000, "stepsize": 100, "label": "Entity Spawn Delay"},
            "pauseBetweenWavesDecrementPerWave": {"min": 0, "max": 1000, "stepsize": 100, "label": "Wave Spawn Delay"},
            "minimumSquabyDelay": {"min": 0, "max": 10000, "stepsize": 100, "label": "Min Squaby Delay"},
            "minimumPauseBetweenWaves": {"min": 0, "max": 10000, "stepsize": 100, "label": "Min Pause Delay"}
          }
      }
    }


    EditableComponent {
      editableType: "WaveSettings"
      defaultGroup: "waves"

      properties: {
        "waves": {
            "propertyType": "waveArrayDelegate"
        }
      }
    }

    // this gets used by SquabyCreator
    waves: [
      // for testing a single squaby type, use the line below with the intended types:
      //{amount: 50, types:[ {type: sgrey, p: 1} ]},
      //{amount: 50, squabyDelay: 0, pauseBetweenWaves: 0, yellow: 0, orange: 0, red: 0, green: 0, blue: 0, grey: 1},

      // uncomment the next line for testing all squaby types shortly after each other:
      //{amount: 30, squabyDelay: 2000, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}, {type: sgrey, p: 1.0}]},
      //{amount: 30, squabyDelay: 2500, pauseBetweenWaves: 0, yellow: 1, orange: 1, red: 1, green: 1, blue: 1, grey: 1},

      // optionally, the intended time between 2 squaby creations can be set, or also the desired delay from the last wave; if one of them is not set, the default decrement-values are used..
      // the 2 parameters "squabyDelay" and pauseBetweenWaves" are optional per level, e.g.: {amount: 2, squabyDelay: 2000, pauseBetweenWaves: 1800, types:[ {type: sy, p: 1}, {type: so, p: 0.1} ]},
//      /* 1 */ {amount: 1, squabyDelay: 5000, pauseBetweenWaves: 1000, types:[ {type: sy, p: 1}]},
//      /* 2 */ {amount: 10, squabyDelay: 2500, pauseBetweenWaves: 6000, types:[ {type: sy, p: 1}]},
      /* 1 *///{amount: 1, squabyDelay: 5000, pauseBetweenWaves: 1000, yellow: 1, orange: 0, red: 0, green: 0, blue: 0, grey: 0},
      /* 2 *///{amount: 10, squabyDelay: 2500, pauseBetweenWaves: 6000, yellow: 1, orange: 0, red: 0, green: 0, blue: 0, grey: 0},
//      // 11 squabies created, 9*5=45 gold earned

//      // first appearance of green squaby, vulnerable against fire
//      /* 3 */ {amount: 10, squabyDelay: 2500, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.9}, {type: sgreen, p: 1.0}]},
      /* 3 *///{amount: 10, squabyDelay: 2500, pauseBetweenWaves: 6000, yellow: 0.9, orange: 0, red: 0, green: 1.0, blue: 0, grey: 0},

//      // first appearance of orange squaby, with high fire resistance
//      /* 4 */ {amount: 10, squabyDelay: 4000, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.7}, {type: sgreen, p: 0.8}, {type: so, p: 1} ]},

//      // first appearance of red squaby, with max fire resistance
//      /* 5 */ {amount: 20, squabyDelay: 3000, pauseBetweenWaves: 6000, types:[ {type: sy, p: 0.5}, {type: sgreen, p: 0.6}, {type: so, p: 0.5}, {type: sr, p: 0.7} ]},

//      // blue squaby with high resistance for nailgun&fire
//      /* 6 */ {amount: 20, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}]},

//      // grey squaby with max resistance for nailgung&fire
//      /* 7 */ {amount: 30, types:[ {type: sy, p: 1}, {type: so, p: 1.0}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 1.0}, {type: sgrey, p: 1.0}]},

//      // the hardest squabies have higher probability here
//      /* 8 */ {amount: 30, types:[ {type: sy, p: 0.5}, {type: so, p: 0.5}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 0.5}, {type: sgrey, p: 1.0}]},
//      /* 9 */ {amount: 30, types:[ {type: sy, p: 0.1}, {type: so, p: 0.2}, {type: sr, p: 1.0}, {type: sgreen, p: 1.0}, {type: sblue, p: 0.5}, {type: sgrey, p: 1.0}]},
    ]

    // no static Obstacles are needed here, they all get loaded dynamically!

}

