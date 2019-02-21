import QtQuick 2.0
import QtMultimedia 5.0 // needed for SoundEffect.Infinite
import Felgo 3.0
import "../particles" // for Sparkle particle

TowerBase {
    id: tesla
    entityType: "tesla"

    /// The squaby health component gets reduced by that amount. This value can be upgraded with the second upgrade (tho 2 towers, so the tesla applies more damage).
    //*0.001*100 // as an optimization, multiply it with 0.001 to avoid having to multiply it every shoot()
    property real teslaAreaDamagePerSecond: level.balancingSettings.tesla.teslaAreaDamagePerSecond
    // flag created to start the particle effects also from outside for performance tests.
    property bool running: false
    onRunningChanged: {
      if(running) {

          shootTimer.running = true;

          // starts the looping audio effect
          shootEffect.play();

          // Start particles
        if(currentParticles < maximumParticles) {
          currentParticles++
          teslaParticle.start();
        }
      } else {

        // stop the looping audio effect
        shootEffect.stop();

        if(teslaParticle.running) {
          currentParticles--
          teslaParticle.stop();
        }
        shootTimer.running = false;
      }
    }

    shootDelayInMilliSeconds: level.balancingSettings.tesla.shootDelayInMilliSeconds
    cost: level.balancingSettings.tesla.cost
    saleRevenue: level.balancingSettings.tesla.saleRevenue
    upgradeLevels: level.balancingSettings.tesla.upgradeLevels

    // TODO: initialize this automatically in TowerBase in onCompleted() for all upgradeLevels!
    __currentUpgradeLevels: { "range": 0, "damagePerSecond": 0 }

    // TODO: add pooling to the towers, so overwrite onMovedToPool instead of onEntityDestroyed then
    onEntityDestroyed: {
      // when this entity got destroyed, but put into an array to avoid immediate removal because of delayEntityRemoval is set to true, the timer must be stopped!
      shootTimer.running = false;
    }

    TeslaSprite {
        id: sprite
    }

    SoundEffect {
        id: shootEffect
        source: "../../assets/snd/teslafire.wav"
        // the sound effect should looop when a squaby is aimed at
        loops: SoundEffect.Infinite
    }

    Particle {
        id: teslaParticle
        fileName: "../particles/tesla.json"
        y: 0
        x: 15
    }

    Timer {
        id: shootTimer
        // this adjusts how often hit() is called! the damage will always be flameAreaDamagePerSecond, regardless of this setting!
        // so this only has a visual effect, how often the healthbar should be updated!
        // don't set it too high, because then it lasts long until the first damage is applied which doesn't look good!
        // and also don't set it too low, because then many times hit() is called which is bad for performance!
        interval: 100
        repeat: true
        triggeredOnStart: true // causes onTriggered to be called when running switches to true - this is important because otherwise the initial rotation action would only be started "interval" ms after the initial contact
        // running gets set when aimingAtTargetChanged changes! also only shoot, when a target is set!
        onTriggered: {
            // apply damage to all squabies within the flameDamageArea
            shoot();
        }

        onRunningChanged: {
          console.debug("Tesla: running changed to", running)
          if(running) {
            // this must be done here, because if the game is paused and then resumed, it would instantly kill a squaby when the tower was firing before
            __lastShoot = new Date()
          }
        }
    }

    onAimingAtTargetChanged: {
        console.debug("aimingAtTarget of tesla changed to:", aimingAtTarget);
        if(aimingAtTarget && !shootTimer.running) {
            running = true
        }
    }

    onTargetRemoved: {
        running = false
    }

    onTowerUpgradedWithCustomUpgrade: {
        if(upgradeType === "damagePerSecond") {
            teslaAreaDamagePerSecond = upgradeData.value;
        }
    }

    onTowerUpgraded: {
        if(upgradeType === "damagePerSecond") {
            teslaParticle.finishColor = "#ca8f00"
        }
        else if(upgradeType === "range") {
            teslaParticle.speed = teslaParticle.speed*2
        }
    }

    // gets set when a new target is found, and reset when it is removed
    property date __lastShoot

    // play the animation and the sound - gets called only if the target is aimed at
    function shoot() {

      // this might be false when the game is restarted, because the shootTimer is restarted when the pauseScene is left!
      // thus, to avoid an error below when accessing the targetEntity, stop the timer here
      if(!targetEntity) {
        shootTimer.running = false;
        return;
      }

      var now = new Date;
      var dt = now-__lastShoot;
      __lastShoot = now;

      var damage = teslaAreaDamagePerSecond*dt*0.001;

      // call this directly on the entity, alternatively call it on the healthComponent?
      targetEntity.hitByValue(entityId, entityType, damage);
    }

}
