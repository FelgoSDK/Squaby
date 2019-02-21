import QtQuick 2.0
import QtMultimedia 5.0 // needed for SoundEffect.Infinite
import Felgo 3.0
import "../particles" // for Sparkle particle

TowerBase {
    id: taser
    entityType: "taser"

    /// The squaby health component gets reduced by that amount. This value can be upgraded with the second upgrade (tho 2 towers, so the flamethrower applies more damage).
    //*0.001*100 // as an optimization, multiply it with 0.001 to avoid having to multiply it every shoot()
    property real taserAreaDamagePerSecond: level.balancingSettings.taser.taserAreaDamagePerSecond
    property bool running: false

    shootDelayInMilliSeconds: level.balancingSettings.taser.shootDelayInMilliSeconds
    cost: level.balancingSettings.taser.cost
    saleRevenue: level.balancingSettings.taser.saleRevenue
    upgradeLevels: level.balancingSettings.taser.upgradeLevels

    // TODO: initialize this automatically in TowerBase in onCompleted() for all upgradeLevels!
    __currentUpgradeLevels: { "range": 0, "damagePerSecond": 0 }

    // TODO: add pooling to the towers, so overwrite onMovedToPool instead of onEntityDestroyed then
    onEntityDestroyed: {
      // when this entity got destroyed, but put into an array to avoid immediate removal because of delayEntityRemoval is set to true, the timer must be stopped!
      shootTimer.running = false;
    }

    TaserSprite {
        id: sprite
    }

    SoundEffect {
        //SoundEffect {
        id: shootEffect
        source: "../../assets/snd/taserfire.wav"
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
        // this adjusts how often hit() is called! the damage will always be taserAreaDamagePerSecond, regardless of this setting!
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
          console.debug("taser: running changed to", running)
          if(running) {
            // this must be done here, because if the game is paused and then resumed, it would instantly kill a squaby when the tower was firing before
            __lastShoot = new Date()
          }
        }
    }

    onAimingAtTargetChanged: {
        console.debug("aimingAtTarget of taser changed to:", aimingAtTarget);
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
            running = true
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
        running = false

        shootTimer.running = false;

        // this would lead to error: Cannot assign null to QDateTime
        //__lastShoot = null;
    }

    onTowerUpgradedWithCustomUpgrade: {
        if(upgradeType === "damagePerSecond") {
            taserAreaDamagePerSecond = upgradeData.value;
        }
    }

    onTowerUpgraded: {
        if(upgradeType === "damagePerSecond") {
            // Add second flame
            fireParticle1.y = 5;

          if(running)
            fireParticle2.start();
        }
        else if(upgradeType === "range") {
            // Change to napalm
            fireParticle1.startColor = "#ffffff"
            fireParticle1.textureFileName = "../particles/particleNapalm.png";

            fireParticle2.startColor = "#ffffff"
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

      var damage = taserAreaDamagePerSecond*dt*0.001;

      // call this directly on the entity, alternatively call it on the healthComponent?
      targetEntity.hitByValue(entityId, entityType, damage);

      // this avoids the function call forwarding and directly modifies the health property - the difference is not so big (0.1 ms), so it is worth the better API unless this is called every frame!
      //targetEntity.healthComponent.currentHealth -= damage;

    }

}
