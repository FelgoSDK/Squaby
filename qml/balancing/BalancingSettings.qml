import QtQuick 1.1

// this is a combination of all properties for balancing for the whole game - modify this to maximize the fun and also tweaking per level would be possible
Item {
  // needed so it can be accessed by outside, by SquabyCreator
  property alias squabyYellow: squabyYellow
  property alias squabyOrange: squabyOrange
  property alias squabyRed: squabyRed
  property alias squabyGreen: squabyGreen
  property alias squabyBlue: squabyBlue
  property alias squabyGrey: squabyGrey

  property alias nailgun: nailgun
  property alias flamethrower: flamethrower
  property alias turbine: turbine

  // for testing, set gold & lives high, so the functionality can be tested
  // set the initial gold, so the user can upgrade once, but not buy a flamegun from the beginning! (flamethrower start cost=50)
  property int playerStartGold: 40 //900
  property int playerStartLives: 10 //50

  // this is a factor that is multiplied with every damageMultiplicator value for each squaby!
  // so by setting it lower than 1, it makes the game more difficult! if setting higher than 1, it makes it easiser because the squabies are more vulnerable for all weapons!
  property real difficultyFactor: 0.7

  SquabyBalancingSettings {
    // highly vulnerable for fire&nailgun
    id: squabyYellow
    variationType: "squabyYellow"
    score: 5
    gold: 5
    health: 100
    // should die with 2 shots from nailgun
    damageMultiplicatorNailgun: difficultyFactor*1.5
    // highly vulnerable against flamethrowers
    damageMultiplicatorFlamethrower: difficultyFactor*1.5
    // speed of 70 will lead to 15 seconds pathDuration
    pathMovementPixelsPerSecond: 70
  }


  SquabyBalancingSettings {
    // very fast, vulnerable for fire, resistang against nailgun
    // otherwise similar to yellow one!
    id: squabyGreen
    variationType: "squabyGreen"
    score: 25
    gold: 10
    health: 100
    damageMultiplicatorNailgun: difficultyFactor*0.3
    damageMultiplicatorFlamethrower: difficultyFactor*1.5
    pathMovementPixelsPerSecond: 100
  }

  SquabyBalancingSettings {
    // high fire resistance, vulnerable against nailgun
    id: squabyOrange
    variationType: "squabyOrange"
    score: 10
    gold: 6
    health: 100
    damageMultiplicatorNailgun: difficultyFactor*0.4
    damageMultiplicatorFlamethrower: difficultyFactor*0.2
    pathMovementPixelsPerSecond: 75
  }

  SquabyBalancingSettings {
    // maximum fire resistance
    id: squabyRed
    variationType: "squabyRed"
    score: 20
    gold: 8
    health: 100
    damageMultiplicatorNailgun: difficultyFactor*0.3
    damageMultiplicatorFlamethrower: difficultyFactor*0.1
    pathMovementPixelsPerSecond: 80
  }

  SquabyBalancingSettings {
    // slow, high nailgun resistance, high lives
    id: squabyBlue
    variationType: "squabyBlue"
    score: 35
    gold: 14
    health: 100
    damageMultiplicatorNailgun: difficultyFactor*0.08
    damageMultiplicatorFlamethrower: difficultyFactor*0.06
    pathMovementPixelsPerSecond: 65
  }

  SquabyBalancingSettings {
    // hardest enemy, maximum lives, max. resistance of nailgun
    id: squabyGrey
    variationType: "squabyGrey"
    score: 50
    gold: 18
    health: 100
    damageMultiplicatorNailgun: difficultyFactor*0.03
    damageMultiplicatorFlamethrower: difficultyFactor*0.02
    pathMovementPixelsPerSecond: 50
  }


  // ------------------------------ TOWER SETTINGS ------------------------------ //

  TowerBalancingSettings {
    id: nailgun
    shootDelayInMilliSeconds: 600
    cost: 20
    saleRevenue: 5
    upgradeLevels: {
        "range": [{"level": 1, "cost": 10, "value": 5*scene.gridSize, "additionalSaleRevenue": 5}],
        "shootDelay": [{"level": 1, "cost": 15, "value": 450, "additionalSaleRevenue": 10}]
    }
  }
  TowerBalancingSettings {
    id: flamethrower
    //shootDelayInMilliSeconds: 600 - no shootDelay is set for flamethrower, it fires continuously
    cost: 50
    saleRevenue: 25
    upgradeLevels: {
      "range": [{"level": 1, "cost": 20, "value": 5*scene.gridSize, "additionalSaleRevenue": 10}],
      "damagePerSecond": [{"level": 1, "cost": 40, "value": 55, "additionalSaleRevenue": 20}]
    }
    /// The squaby health component gets reduced by that amount. This value can be upgraded with the second upgrade (tho 2 towers, so the flamethrower applies more damage).
    property real flameAreaDamagePerSecond: 40
  }
  TowerBalancingSettings {
    id: turbine
    shootDelayInMilliSeconds: 7000
    cost: 90
    saleRevenue: 35
    upgradeLevels: {
        "range": [{"level": 1, "cost": 30, "value": 5*scene.gridSize, "additionalSaleRevenue": 15}],
        "shootDelay": [{"level": 1, "cost": 60, "value": 5000, "additionalSaleRevenue": 30}],
        // the value here is the amount of lives the tower has after repairing, probably the same like at initialization, but it would also be possible to add different levels which cost more for each repair
        // make repairing quite expensive, otherwise turbine is too strong!
        "repair": [{"level": 1, "cost": 60, "value": 2, "additionalSaleRevenue": 0}]
    }
    // this is the initial setting for the lives
    property real lives: 2
  }

}
