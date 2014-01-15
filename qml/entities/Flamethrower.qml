import QtQuick 1.1
import VPlay 1.0
// this is only needed to get access to Box2DFixture class, containing the categories
import Box2D 1.0
import "../particles" // for FireParticles

TowerBase {
    id: flamethrower
    entityType: "flamethrower"

    /// The squaby health component gets reduced by that amount. This value can be upgraded with the second upgrade (tho 2 towers, so the flamethrower applies more damage).
    //*0.001*100 // as an optimization, multiply it with 0.001 to avoid having to multiply it every shoot()
    property real flameAreaDamagePerSecond: level.balancingSettings.flamethrower.flameAreaDamagePerSecond

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

    Sound {
        //SoundEffect {
        id: shootEffect
        source: "../snd/flamethrowerFire01.wav"
        // the sound effect should looop when a squaby is aimed at
        loops: SoundEffect.Infinite
    }

    // Particles {
    FireParticles {
        id: fireParticle1
        emissionRate: 35
        sourcePositiony: 0
        positionType: ParticleSystem.Relative
    }

    // Particles {
    FireParticles {
        id: fireParticle2
        emissionRate: 35
        sourcePositiony: -5
        positionType: ParticleSystem.Relative
    }

    Timer {
        id: shootTimer
        // this adjusts how often hit() is called! the damage will always be flameAreaDamagePerSecond, regardless of this setting!
        // so this only has a visual effect, how often the healthbar should be updated!
        // dont set it too high, because then it lasts long until the first damage is applied which doesnt look good!
        // and also dont set it too low, because then many times hit() is called which is bad for performance!
        interval: 100
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

            shootTimer.running = true;

            // starts the looping audio effect
            shootEffect.play();

            // Start particles
            if (__currentUpgradeLevels.damagePerSecond > 0) {
                fireParticle2.start();
            }
            fireParticle1.start();
        }
    }

    onTargetRemoved: {
        // stop the looping audio effect
        shootEffect.stop();

        // Stop particle effects
        if (__currentUpgradeLevels.damagePerSecond > 0) {
            fireParticle2.stop();
        }
        fireParticle1.stop();

        shootTimer.running = false;

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
            // Add second flame
            fireParticle1.sourcePositiony = 5;

            // Start second flame if currently running
            if (fireParticle1.particleStatus === fireParticle1.ParticleSystem.Playing)
                fireParticle2.start();
        }
        else if(upgradeType === "range") {
            // Change to napalm
            fireParticle1.startColorRed = 1;
            fireParticle1.startColorGreen = 1;
            fireParticle1.startColorBlue = 1;
            fireParticle1.textureFileName = "../particles/particleNapalm.png";

            fireParticle2.startColorRed = 1;
            fireParticle2.startColorGreen = 1;
            fireParticle2.startColorBlue = 1;
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
