import QtQuick 1.1
import VPlay 1.0
import VPlay 1.0
// this is only needed to get access to Box2DFixture class, containing the categories
import Box2D 1.0

TowerBase {
    id: nailgun
    entityType: "nailgun"

    // these get set per tower, are the logic properties and could be put into an own component!?
    shootDelayInMilliSeconds: level.balancingSettings.nailgun.shootDelayInMilliSeconds
    cost: level.balancingSettings.nailgun.cost
    saleRevenue: level.balancingSettings.nailgun.saleRevenue
    upgradeLevels: level.balancingSettings.nailgun.upgradeLevels

    NailgunSprite {
        id: sprite
    }
    
    Sound {
        id: shootEffect
        source: "../snd/nailgunShoot04.wav"
        volume: 0.7
    }

    Timer {
        id: shootTimer
        interval: shootDelayInMilliSeconds // fire every x ms - this should be adjusted by the designer, and might be upgraded for the tower!
        repeat: true
        triggeredOnStart: true // causes onTriggered to be called when running switches to true - this is important because otherwise the initial rotation action would only be started "interval" ms after the initial contact
        // running gets set when aimingAtTargetChanged changes! also only shoot, when a target is set!
        onTriggered: {
          console.debug("Nailgun: shootTimer triggered! this:", shootTimer)
            // play a fire sound effect and play the fire animation when the squaby is aimed
            shoot();
        }
    }

    onAimingAtTargetChanged: {
        console.debug("aimingAtTarget of nailgun changed to:", aimingAtTarget);
        if(aimingAtTarget && !shootTimer.running) {
            shootTimer.running = true;
        }
    }

    onTargetRemoved: {
        shootTimer.running = false;
    }

    // TODO: add pooling to the towers, so overwrite onMovedToPool instead of onEntityDestroyed then
    onEntityDestroyed: {
      // when this entity got destroyed, but put into an array to avoid immediate removal because of delayEntityRemoval is set to true, the timer must be stopped!
      shootTimer.running = false;
    }


    property date lastShoot: new Date()

    // play the animation and the sound - gets called only if the target is aimed at
    function shoot() {

      // this might be false when the game is restarted, because the shootTimer is restarted when the pauseScene is left!
      // thus, to avoid an error below when accessing the targetEntity, stop the timer here
      if(!targetEntity) {
        shootTimer.running = false;
        return;
      }

        var now = new Date();
        var dt = now-lastShoot;
        lastShoot = now;
        console.debug("Nailgun: shoot() called, dt:", dt);
        sprite.playShootAnimation();

        shootEffect.play();

        // call this directly on the entity, alternatively call it on the healthComponent?
        targetEntity.hitWithAttackerIdAndType(entityId, entityType);
    }
}
