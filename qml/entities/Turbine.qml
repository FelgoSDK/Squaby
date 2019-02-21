import QtQuick 2.0
import QtMultimedia 5.0 // needed for SoundEffect.Infinite
import Felgo 3.0
import "../particles"
// for HealthBar & HealthComponent
import "../gameScene"
// this is only needed to get access to Box2DFixture class, containing the categories


TowerBase {
    id: turbine
    entityType: "turbine"

    // this is the initial setting for the lives
    property real lives: level.balancingSettings.turbine.lives // set to 1 for testing the explode phase faster


    // use this for debugging the whirl behavior if it works correctly, easier to debug with bigger collider!
    // if nothing is set, the default colliderRadius defined in TowerBase is 4 grids
    //colliderRadius: 15*scene.gridSize

    // these get set per tower, are the logic properties and could be put into an own component!?
    shootDelayInMilliSeconds: level.balancingSettings.turbine.shootDelayInMilliSeconds // is set to 7000
    cost: level.balancingSettings.turbine.cost
    saleRevenue: level.balancingSettings.turbine.saleRevenue
    upgradeLevels: level.balancingSettings.turbine.upgradeLevels

    /*
    upgradeLevels: {
        "range": [{"level": 1, "cost": 30, "value": 5*scene.gridSize, "additionalSaleRevenue": 5}],
        "shootDelay": [{"level": 1, "cost": 60, "value": 3000, "additionalSaleRevenue": 30}],
        // the value here is the amount of lives the tower has after repairing, probably the same like at initialization, but it would also be possible to add different levels which cost more for each repair
        "repair": [{"level": 1, "cost": 40, "value": 2, "additionalSaleRevenue": 0}]
    }*/
    //property variant rangeUpgradeLevels : [ { level: 1, cost: 30, value: 80, additionalSaleRevenue: 5 } ]
    //property variant shootDelayUpgradeLevels = [ { level: 1, cost: 40, value: 0.05, additionalSaleRevenue: 10 } ]

    // TODO: initialize this automatically in TowerBase in onCompleted() for all upgradeLevels!
    // ATTENTION: at the beginning the repair upgrade should NOT be available, thus set its level to 1!
    __currentUpgradeLevels: { "range": 0, "shootDelay": 0, "repair": 1 }

    // TODO: add pooling to the towers, so overwrite onMovedToPool instead of onEntityDestroyed then
    onEntityDestroyed: {
      // when this entity got destroyed, but put into an array to avoid immediate removal because of delayEntityRemoval is set to true, the timer must be stopped!
      coolOffTimer.running = false;
    }

    TurbineSprite {
        id: sprite
    }

    SoundEffect {
        id: whirlEffect
        source: "../../assets/snd/turbineRunning.wav"
        loops: SoundEffect.Infinite
    }

    SoundEffect {
        id: squabyShredderEffect
        source: "../../assets/snd/turbineShredder.wav"
    }

    SoundEffect {
        id: turbineExplodeEffect
        source: "../../assets/snd/turbineExplode.wav"
    }

    Particle {
        id: smokeParticle
        fileName: "../particles/SmokeParticle.json"
        duration: shootDelayInMilliSeconds*0.001
    }
    Particle {
        id: puddleParticle
        fileName: "../particles/DeathParticle.json"
        x: -25
        // particle needs to be under the healthbar
        z: sprite.z-1
    }
    // Following two blood praticle effets are for minced squabies
    Particle {
        id: splatterParticle
        fileName: "../particles/SplatterParticle.json"
        x: -15
        // particle needs to be under the healthbar
        z: sprite.z-1
    }

    Timer {
        id: coolOffTimer
        interval: shootDelayInMilliSeconds // fire every x ms - this should be adjusted by the designer, and might be upgraded for the tower!
        repeat: false
        // running gets set to true when finished the whirl process, so when switching to state coolOff
        running: false
        onTriggered: {
            console.debug("Turbine: coolOffTimer triggered, switch back to default state, current state:", turbine.state);
            // switch back to default state from state coolOff, so start MoveToPointHelper and enable collider again
            turbine.state = "";
        }
    }


    Healthbar {
        id:healthbar
        // 0/0 is the center now, so shift it the same way as SpriteSequence was
        // don't position the x&y directly, only the x&y of the child item
        absoluteX: -sprite.sprite.width/2
        absoluteY: -sprite.sprite.height/2
        width: sprite.sprite.width
        height: 3
        // this connects the visual item with the logical one
        percent: healthComponent.healthInPercent
        useSpriteVersion: true
    } // end of Healthbar

    HealthComponent {
        id: healthComponent
        health: lives

        onDied: {
            console.debug("Turbine: turbine's lives are over, play explode animation");

            // this starts the turbine animation, and will stop at the last frame (the exploded frame)
            sprite.explode();

            turbineExplodeEffect.play();

            var upgradeLevelsCopy = __currentUpgradeLevels;
            // this sets the level to 0, so the repair upgrade gets available
            upgradeLevelsCopy.repair = 0;
            __currentUpgradeLevels = upgradeLevelsCopy;
            console.debug("Turbine: updated repair level:", __currentUpgradeLevels.repair);

            // if the hud is currently upgrading this tower, update the hud
            // hud.selectedTowerId is only valid if state is upgrading, so this check is redundant!
            //if(hud.state === "upgrading")
            //console.debug("Turbine: hud.selectedTowerId:", hud.selectedTowerId, ", turbine.entityId:", turbine.entityId);
            if(hud.selectedTowerId === turbine.entityId) {
                console.debug("Turbine: the selectedTowerId equals this tower's, so update the hud");
                // inform the hud about the state change of the currently selected turbine
                towerSelected();
            }

            turbine.state = "exploded";
        }
    }

    onTowerUpgradedWithCustomUpgrade: {
      if(upgradeType === "repair") {
        console.debug("Turbine: repair upgrade used");
        lives = upgradeData.value;
        // set the lives to the health value of this upgrade - this wouldnt be needed if the new health is different than the old one, but since the repair upgrade could also be the same amount of lives, make sure the internal __health are updated!
        healthComponent.resetHealth();

        // sets the frame to the first one
        sprite.repair();

        // switch back to default state
        turbine.state = "";

        // stop the smoke particle effect when the tower is repaired
        smokeParticle.stop();
        // particle should not rotate with parent when new target is spotted after repair value
        puddleParticle.stopLivingParticles()
      }
    }

    onAimingAtTargetChanged: {
        console.debug("Turbine: aimingAtTarget changed to:", aimingAtTarget);
        if(aimingAtTarget && turbine.state === "") {
            whirl();
        }
    }

    onTargetRemoved: {
        console.debug("Turbine: onTargetRemoved()");

        whirlEffect.stop();

        // set the whirl animation to invisible again
        sprite.state = "";
    }

    // play the animation and the sound - gets called only if the target is aimed at
    function whirl() {
        sprite.state = "whirl";

        whirlEffect.play();

        // NOTE: with qt 5, we must not write startWhirlingToTarget(this) anymore! this is not the turbine
        targetEntity.startWhirlingToTarget(turbine);
    }

    function whirlingOfSquabySuccessful(squabyId) {
        // reset the whirl state - this is not necessary, because targetRemoved is called anyway, and there the state gets reset!
        //sprite.state = "";

        // ATTENTION: this must be set BEFORE hit(1) is called, because a hit might lead to a died-signal, which changes the state to exploded! and if this would be written afterwards, the state would get overwritten!
        // do not set this in onTargetRemoved, because targetRemoved might also happen if the squaby got destroyed by a different tower!
        // coolOff should only be reached, if this turbine really whirled the squaby to death
        turbine.state = "coolOff";

        // Start particles
        smokeParticle.start();
        // Trigger later?
        splatterParticle.start();
        puddleParticle.start();

        // a check targetEntity===squaby is not possible, because squaby got marshalled as JS object! a check of ids would be necessary!
        if(targetEntity && targetEntity.entityId === squabyId) {
            console.debug("Turbine: successfully whirled a squaby to death, reduce its health");

            squabyShredderEffect.play();
            // decrease health by 1
            healthComponent.hit(1);

        } else {
            console.debug("WARNING: unknown behavior! targetEntity is not equal squaby parameter! targetEntity:", targetEntity, ", squabyId:", squabyId)
        }
    }

    states: [
        State {
            name: ""
            StateChangeScript { script: console.debug("Turbine: changed state to default") }

            //PropertyChanges { target: fireRangeCollider; active: true } // this is not needed, is reverted automatically
        },
        State {
            name: "coolOff"
            StateChangeScript { script: console.debug("Turbine: changed state to coolOff") }
            PropertyChanges { target: fireRangeCollider; active: false }
            PropertyChanges { target: coolOffTimer; running: true }
        },
        State {
            name: "exploded"
            StateChangeScript { script: console.debug("Turbine: changed state to exploded") }
            PropertyChanges { target: fireRangeCollider; active: false }
        }
    ]

}
