import QtQuick 2.0
import VPlay 2.0

//import "HealthComponentLogic.js" as Logic

ComponentBase {

    /// Health might be set to bigger values than 100 as well!
    property real health: 100

    // this may be used by other components
    // ATTENTION:: this shows up high in the profiler, because a change triggers a change in HealthBar.width!
    // this is in between 0 and 1
    property real healthInPercent: currentHealth*__healthInverse

    // this is just for performance optimization, because the healthInPercent can use a multiplication instead of a division!
    property real __healthInverse: 1/health

    // these get modified at runtime, start with the health value
    // if currentHealth gets changed to health again, this means the HealthComponent should be resetted (gets used for pooling)
    // the binding would be destroyed in resetHealth anyway! but it must be set initially, to have the correct value after initialisation (also possible would be to set it in onCompleted)
    property real currentHealth: health

    // these could also come from the hit() event!
    // if type is set to "applySimple", the damage is applied at once
    // if type is set to "perSecond", the damage value is per second, so the time difference between the hit-calls is measured for that damage source
    // for Squaby, only 1 perSecond-damage is used, but there may be multiple ones so it must be stored in an array for each type
    property variant damages: {
        "nailgun": { value: 20, type: "applySimple"},
        // ATTENTION: this isnt used for squaby yet! instead, the time-based damage is calculated in each tower!
        "flamethrower": { value: 40, type: "perSecond"},
        "taser": { value: 40, type: "perSecond"},
        "tesla": { value: 40, type: "perSecond"}
    }

    // gets overwritten for each squaby type, so the resistance against each weapon can be defined here
    property variant damageMultiplicators: {
        "nailgun": 1,
        "flamethrower": 1,
        "taser": 1,
        "tesla": 1
    }

    /// Set this to true if the entity should be destroyed when the health get below zero. Defaults to false.
    property bool autoDestroyEntityWhenDied: false

    // this gets emitted when the __health gets below 0
    signal died

    // security check to prevent emitting died() multiple times if hit() gets called multiple times (e.g. from different towers)
    property bool __alreadyDied: false

    Component.onCompleted: {
        // here the logic component would need to be initialized
        //Logic.initialize();
    }

    onHealthChanged: {
      // this is required to be set explicitly here, because the currentHealth binding is destroyed in resetHealth()
      //currentHealth = health;
      resetHealth();
    }

    onCurrentHealthChanged: {
      //console.debug("HealthComponent: currentHealth:", currentHealth, "healthInverse:", __healthInverse, "healthInPercent:", healthInPercent, ", initial health:", health)
      // this was only added for pooling, but it has a negative performance effect as in every changed it is compared with the initial health (another binding call!)
      if(currentHealth === health) {
        //console.debug("HealthComponent: resetting health because currentHealth equals initial health")
        // this sets alreadyDied to false, nothing else (currentHealth already has the same value as health
        resetHealth();
      } else if(currentHealth<0.001) {

        // check if this squaby was marked as died, so prevent calling died() multiple times
        // hit() may be called multiple time a frame, e.g. from different towers!
        // but an entity can only die once!
        // as there may be slight floating-point inaccuracies, test if smaller than 0.01, which is just a value which should be big enough of a error-adoption
        if(!__alreadyDied) {
          __alreadyDied = true;
          // emit died signal
          died();
          if(autoDestroyEntityWhenDied) {
            //owningEntity.destroy();
            owningEntity.removeEntity();
          }
        }

        // this guarantees the percent cant get negative
        currentHealth = 0;
      }
    }

    //onHealthInPercentChanged: console.debug("HealthComponent: healthInPercent changed to:", healthInPercent)

    function resetHealth() {
      console.debug("HealthComponent: resetHealth called, setting currentHealth to health value:", health)
      // ATTENTION: this destroys the binding of currentHealth!!! thus it is required to track a change of health, and set currentHealth there!
        currentHealth = health;
        __alreadyDied = false;

        // this gets set automatically to 100!
        //healthInPercent = 100;
    }

    // simplest form of hit-methods, without taking any resistances into account!
    function hit(damageValue) {
        __applyDamage(damageValue);
    }

    function hitWithAttackerIdAndType(attackerId, attackerType) {
        var damageForAttacker = damages[attackerType].value;
        if(damageForAttacker) {
            __applyDamageComplex(attackerId, attackerType, damageForAttacker);
        }
    }

    /// Use this function e.g. for time-based damage that should get applied directly from the calling class, and not from damages-array in HealthComponent
    function hitByValue(attackerId, attackerType, damageValue) {
        __applyDamageComplex(attackerId, attackerType, damageValue);
    }


    function __applyDamage(damage) {
      //console.debug("HealthComponent: applyDamage: of", damage, ",current health:", health, ", new currentHealth value:", currentHealth-damage);
      currentHealth -= damage;
    }

    function __applyDamageComplex(attackerId, attackerType, damageForAttacker) {

        var damageMultiplicatorForAttacker = damageMultiplicators[attackerType];

        //console.debug("HealthComponent: damageForAttacker:", damageForAttacker, ", old health:", __health);

       __applyDamage(damageForAttacker*damageMultiplicatorForAttacker);
    }
}
