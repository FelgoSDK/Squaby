import QtQuick 2.0
import QtMultimedia 5.0 // needed for SoundEffect.Infinite
import Felgo 3.0
// this is only needed to get access to Box2DFixture class, containing the categories

import "../particles" // for FireParticles

TowerBase {
    id: flamethrower
    entityType: "flamethrower"

    /// The squaby health component gets reduced by that amount. This value can be upgraded with the second upgrade (tho 2 towers, so the flamethrower applies more damage).
    //*0.001*100 // as an optimization, multiply it with 0.001 to avoid having to multiply it every shoot()
    property real flameAreaDamagePerSecond: level.balancingSettings.flamethrower.flameAreaDamagePerSecond
    // flag created to start the particle effects also from outside for performance tests.
    property bool running: false
    onRunningChanged: {
      if(running) {

        shootTimer.running = true;

        // starts the looping audio effect
        shootEffect.play();

        // Start particles
        if (__currentUpgradeLevels.damagePerSecond > 0) {
          if(currentParticles < maximumParticles) {
            currentParticles++
            fireParticle2.start();
          }
        }
        if(currentParticles < maximumParticles) {
          currentParticles++
          fireParticle1.start();
        }
      } else {
        // stop the looping audio effect
        shootEffect.stop();

        // Stop particle effects
        if (__currentUpgradeLevels.damagePerSecond > 0) {
          if(fireParticle2.running) {
            currentParticles--
            fireParticle2.stop();
          }
        }
        if(fireParticle1.running) {
          currentParticles--
          fireParticle1.stop();
        }
        shootTimer.running = false;
      }
    }

    shootDelayInMilliSeconds: level.balancingSettings.flamethrower.shootDelayInMilliSeconds
    cost: level.balancingSettings.flamethrower.cost
    saleRevenue: level.balancingSettings.flamethrower.saleRevenue
    upgradeLevels: level.balancingSettings.flamethrower.upgradeLevels

    // TODO: initialize this automatically in TowerBase in onCompleted() for all upgradeLevels!
    __currentUpgradeLevels: { "range": 0, "damagePerSecond": 0 }

    // TODO: add pooling to the towers, so overwrite onMovedToPool instead of onEntityDestroyed then
    onEntityDestroyed: {
      // when this entity got destroyed, but put into an array to avoid immediate removal because of delayEntityRemoval is set to true, the timer must be stopped!
      shootTimer.running = false;
    }

    FlamethrowerSprite {
      id: sprite
    }

    SoundEffect {
        id: shootEffect
        source: "../../assets/snd/flamethrowerFire01.wav"
        // the sound effect should looop when a squaby is aimed at
        loops: SoundEffect.Infinite
    }

    Particle {
        id: fireParticle1
        fileName: "../particles/FireParticle.json"
        y: 0
        x: 15
    }

    Particle {
        id: fireParticle2
        fileName: "../particles/FireParticle.json"
        y: -5
        x: 15
    }

    Timer {
        id: shootTimer
        // this adjusts how often hit() is called! the damage will always be flameAreaDamagePerSecond, regardless of this setting!
        // so this only has a visual effect, how often the healthbar should be updated!
        // don't set it too high, because then it lasts long until the first damage is applied which doesn't look good!
        // and also don't set it too low, because then many times hit() is called which is bad for performance!
        interval: 300
        repeat: true
        triggeredOnStart: true // causes onTriggered to be called when running switches to true - this is important because otherwise the initial rotation action would only be started "interval" ms after the initial contact
        // running gets set when aimingAtTargetChanged changes! also only shoot, when a target is set!
        onTriggered: {
            // apply damage to all squabies within the flameDamageArea
            shoot();
        }

        onRunningChanged: {
          console.debug("Flamethrower: running changed to", running)
          if(running) {
            // this must be done here, because if the game is paused and then resumed, it would instantly kill a squaby when the tower was firing before
            __lastShoot = new Date()
          }
        }
    }

    onAimingAtTargetChanged: {
        console.debug("aimingAtTarget of flamethrower changed to:", aimingAtTarget);
        if(aimingAtTarget && !shootTimer.running) {

            // __lastShoot must not be set here, because then users could cheat by pressing the pause button and then the next flamethrower shot would kill the squaby instantly when resumed again
            //__lastShoot = new Date();
            running = true
        }
    }

    onTargetRemoved: {
        running = false
        // this would lead to error: Cannot assign null to QDateTime
        //__lastShoot = null;
    }

    onTowerUpgradedWithCustomUpgrade: {
        if(upgradeType === "damagePerSecond") {
            flameAreaDamagePerSecond = upgradeData.value;
        }
    }

    onTowerUpgraded: {
        if(upgradeType === "damagePerSecond") {
          // decrease particle if running, because changing maxParticles will start the particle and we have to stop it.
          if(fireParticle1.running) {
            currentParticles--
          }

          // reduce particle number
          fireParticle1.maxParticles = fireParticle1.maxParticles/2
          // stop the particle because setting the maxParticles count respawns the particle
          fireParticle1.stop()
          fireParticle2.maxParticles = fireParticle2.maxParticles/2
          // stop the particle because setting the maxParticles count respawns the particle
          fireParticle2.stop()

            // Add second flame
            fireParticle1.y = 5;

          if(running && currentParticles < maximumParticles) {
            currentParticles++
            fireParticle1.start();
            fireParticle2.start();
          }
        }
        else if(upgradeType === "range") {
            // Change to napalm
            fireParticle1.startColor = "#ffffff"
            fireParticle1.startColorAlpha = 0.7
            fireParticle1.textureFileName = "../particles/particleNapalm.png";

            fireParticle2.startColor = "#ffffff"
            fireParticle2.startColorAlpha = 0.7
            fireParticle2.textureFileName = "../particles/particleNapalm.png";
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

      var damage = flameAreaDamagePerSecond*dt*0.001;

      // call this directly on the entity, alternatively call it on the healthComponent?
      targetEntity.hitByValue(entityId, entityType, damage);

      // this avoids the function call forwarding and directly modifies the health property - the difference is not so big (0.1 ms), so it is worth the better API unless this is called every frame!
      //targetEntity.healthComponent.currentHealth -= damage;

    }

}
