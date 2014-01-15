import QtQuick 1.1

// it uses the settings from BalancingSettings and wraps a Component around each squaby type, which can be created with the EntityManager
// so with this item, it is not necessary to create an own qml file
Item {

    // needed so it can be accessed by outside, by SquabyCreator
    property alias squabyYellow: squabyYellow
    property alias squabyOrange: squabyOrange
    property alias squabyRed: squabyRed
    property alias squabyGreen: squabyGreen
    property alias squabyBlue: squabyBlue
    property alias squabyGrey: squabyGrey

    Component {
        id: squabyYellow
        Squaby {
            id: sy
            variationType: "squabyYellow"
            score: balancingSettings.squabyYellow.score
            gold: balancingSettings.squabyYellow.gold
            health: balancingSettings.squabyYellow.health
            damageMultiplicatorNailgun: balancingSettings.squabyYellow.damageMultiplicatorNailgun
            damageMultiplicatorFlamethrower: balancingSettings.squabyYellow.damageMultiplicatorFlamethrower
            pathMovementPixelsPerSecond: balancingSettings.squabyYellow.pathMovementPixelsPerSecond
        }
    }

    Component {
        // high fire resistance
        id: squabyOrange
        Squaby {
            variationType: "squabyOrange"
            score: balancingSettings.squabyOrange.score
            gold: balancingSettings.squabyOrange.gold
            health: balancingSettings.squabyOrange.health
            damageMultiplicatorNailgun: balancingSettings.squabyOrange.damageMultiplicatorNailgun
            damageMultiplicatorFlamethrower: balancingSettings.squabyOrange.damageMultiplicatorFlamethrower
            pathMovementPixelsPerSecond: balancingSettings.squabyOrange.pathMovementPixelsPerSecond
        }
    }

    Component {
        id: squabyRed
        Squaby {
            variationType: "squabyRed"
            score: balancingSettings.squabyRed.score
            gold: balancingSettings.squabyRed.gold
            health: balancingSettings.squabyRed.health
            damageMultiplicatorNailgun: balancingSettings.squabyRed.damageMultiplicatorNailgun
            damageMultiplicatorFlamethrower: balancingSettings.squabyRed.damageMultiplicatorFlamethrower
            pathMovementPixelsPerSecond: balancingSettings.squabyRed.pathMovementPixelsPerSecond
        }
    }

    Component {
        id: squabyGreen
        Squaby {
            variationType: "squabyGreen"
            score: balancingSettings.squabyGreen.score
            gold: balancingSettings.squabyGreen.gold
            health: balancingSettings.squabyGreen.health
            damageMultiplicatorNailgun: balancingSettings.squabyGreen.damageMultiplicatorNailgun
            damageMultiplicatorFlamethrower: balancingSettings.squabyGreen.damageMultiplicatorFlamethrower
            pathMovementPixelsPerSecond: balancingSettings.squabyGreen.pathMovementPixelsPerSecond
        }
    }
    Component {
        id: squabyBlue
        Squaby {
            variationType: "squabyBlue"
            score: balancingSettings.squabyBlue.score
            gold: balancingSettings.squabyBlue.gold
            health: balancingSettings.squabyBlue.health
            damageMultiplicatorNailgun: balancingSettings.squabyBlue.damageMultiplicatorNailgun
            damageMultiplicatorFlamethrower: balancingSettings.squabyBlue.damageMultiplicatorFlamethrower
            pathMovementPixelsPerSecond: balancingSettings.squabyBlue.pathMovementPixelsPerSecond
        }
    }
    Component {
        id: squabyGrey
        Squaby {
            variationType: "squabyGrey"
            score: balancingSettings.squabyGrey.score
            gold: balancingSettings.squabyGrey.gold
            health: balancingSettings.squabyGrey.health
            damageMultiplicatorNailgun: balancingSettings.squabyGrey.damageMultiplicatorNailgun
            damageMultiplicatorFlamethrower: balancingSettings.squabyGrey.damageMultiplicatorFlamethrower
            pathMovementPixelsPerSecond: balancingSettings.squabyGrey.pathMovementPixelsPerSecond
        }
    }

}
