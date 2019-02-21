import QtQuick 2.0
import Felgo 3.0

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
  property alias taser: taser
  property alias tesla: tesla
  property alias turbine: turbine

  // for testing, set gold & lives high, so the functionality can be tested
  // set the initial gold, so the user can upgrade once, but not buy a flamegun from the beginning! (flamethrower start cost=50)
  property int playerStartGold: 40 // default values need to be changed in LevelEmpty too when they get changed here!
  property int playerStartLives: 5 // default values need to be changed in LevelEmpty too when they get changed here!

  SquabyBalancingSettings {
    // highly vulnerable for fire&nailgun
    id: squabyYellow
    variationType: "squabyYellow"
  }


  SquabyBalancingSettings {
    // very fast, vulnerable for nailgun, resistang against fire
    id: squabyGreen
    variationType: "squabyGreen"
  }

  SquabyBalancingSettings {
    // nailgun resistance, vulnerable against fire
    id: squabyOrange
    variationType: "squabyOrange"
  }

  SquabyBalancingSettings {
    // more nailgun resistance, vulnerable against fire
    id: squabyRed
    variationType: "squabyRed"
  }

  SquabyBalancingSettings {
    // slow, resistance against all
    id: squabyBlue
    variationType: "squabyBlue"
  }

  SquabyBalancingSettings {
    // hardest enemy, maximum lives, max. resistance of nailgun and fire
    id: squabyGrey
    variationType: "squabyGrey"
  }


  // ------------------------------ TOWER SETTINGS ------------------------------ //

  TowerBalancingSettings {
    id: nailgun
    variationType: "nailgun"

    useShootDelayInMilliSeconds: true
    shootDelayInMilliSeconds: 600
    cost: 20
    saleRevenue: 5
    upgradeLevels: {
        "range": [{"level": 1, "cost": 5, "value": 5*scene.gridSize, "additionalSaleRevenue": 5}],
        "shootDelay": [{"level": 1, "cost": 10, "value": 450, "additionalSaleRevenue": 10}]
    }


  }
  TowerBalancingSettings {
    id: flamethrower
    variationType: "flamethrower"

    // use shootDelayInMilliSeconds as taserAreaDamagePerSecond for easier balancing
    shootDelayInMilliSeconds: 40
    cost: 50
    saleRevenue: 25
    upgradeLevels: {
      "range": [{"level": 1, "cost": 15, "value": 5*scene.gridSize, "additionalSaleRevenue": 10}],
      "damagePerSecond": [{"level": 1, "cost": 35, "value": 55, "additionalSaleRevenue": 20}]
    }
    /// The squaby health component gets reduced by that amount. This value can be upgraded with the second upgrade (tho 2 towers, so the flamethrower applies more damage).
    property real flameAreaDamagePerSecond: shootDelayInMilliSeconds
  }
  TowerBalancingSettings {
    id: taser
    variationType: "taser"

    // use shootDelayInMilliSeconds as taserAreaDamagePerSecond for easier balancing
    shootDelayInMilliSeconds: 40
    cost: 45
    saleRevenue: 25
    upgradeLevels: {
      "range": [{"level": 1, "cost": 15, "value": 5*scene.gridSize, "additionalSaleRevenue": 10}],
      "damagePerSecond": [{"level": 1, "cost": 35, "value": 55, "additionalSaleRevenue": 20}]
    }
    /// The squaby health component gets reduced by that amount. This value can be upgraded with the second upgrade (tho 2 towers, so the taser applies more damage).
    property real taserAreaDamagePerSecond: shootDelayInMilliSeconds
  }
  TowerBalancingSettings {
    id: tesla
    variationType: "tesla"

    // use shootDelayInMilliSeconds as taserAreaDamagePerSecond for easier balancing
    shootDelayInMilliSeconds: 60
    cost: 60
    saleRevenue: 45
    upgradeLevels: {
      "range": [{"level": 1, "cost": 20, "value": 5*scene.gridSize, "additionalSaleRevenue": 10}],
      "damagePerSecond": [{"level": 1, "cost": 40, "value": 55, "additionalSaleRevenue": 20}]
    }
    /// The squaby health component gets reduced by that amount. This value can be upgraded with the second upgrade (tho 2 towers, so the tesla applies more damage).
    property real teslaAreaDamagePerSecond: shootDelayInMilliSeconds
  }
  TowerBalancingSettings {
    id: turbine
    variationType: "turbine"

    useShootDelayInMilliSeconds: true
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
