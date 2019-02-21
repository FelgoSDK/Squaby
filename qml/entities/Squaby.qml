import QtQuick 2.0
// this is only needed to get access to Box2DFixture class, containing the categories

import Felgo 3.0
import "../particles"
import "../gameScene" // for HealthBar component

EntityBase {
    // the entityId should be set by the level file!
    //entityId: "car"
    entityType: "squaby"
    variationType: "squabyYellow" // this may be changed to other types with different property initializations
    id: squaby

    // these 2 props are different for every squaby type
    // they get accessed by the health component when a killed_event is created
    property int score: 5
    property int gold: 5
    // ATTENTION: this property binding (gold+5) would be overwritten if pooling would be used, thus don't use pooling yet!
    //property int goldPlus5: gold+5

    // defining an enum is not possible from QML right?
    //property enumeration concreteType: { squabyYellow,

    // these aliases are only introduced to allow modification of the entities directly from EntityManager for testing toggling animations and the healthbar
    property alias squabySprite: squabySpriteElement.squabySprite
    property alias healthbar: healthbar
    property alias pathMovement: pathMovement
    // this is only for testing the performance difference between calling hitByValue() and directly manipulating currentHealth!
    property alias healthComponent: healthComponent

    // these get accessed for balancing
    property alias health: healthComponent.health
    property real damageMultiplicatorNailgun: 1
    property real damageMultiplicatorFlamethrower: 1
    property real damageMultiplicatorTaser: 1
    property real damageMultiplicatorTesla: 1
    /// Duration how long it takes a squaby to move from the first to the last waypoint, so this determines the squaby speed.
    //property alias completePathAnimationDuration: pathMovement.completePathAnimationDuration
    property alias pathMovementPixelsPerSecond: pathMovement.velocity

    // This property is set by levelloader or leveleditor when new waypoints are available. True by default to fetch waypoints during initialisation
    property bool movementAnimationNeedUpdate: true

    // ATTENTION: damageMultiplicators can only be accessed from outside, but not from the same component here!
    // thus move this initialization to the healthComponent itself!
    //property alias damageMultiplicators: healthComponent.damageMultiplicators
//    healthComponent.damageMultiplicators: {
//        "nailgun": damageMultiplicatorNailgun,
//        "flamethrower": damageMultiplicatorFlamethrower
//    }

    // this might be used for x&y positioning of the path, but pathPosition is not known here!
    //anchors.centerIn: pathMovement.pathPosition

    // enable pooling (by default it is set to false)
    poolingEnabled: true

    onMovedToPool: {
      console.debug("Squaby: onMovedToPool(), stopping all children components");

      // this is set to false in onDied anyway, so the binding is destroyed!
      //collidersActive = false;

      // only for testing where the particles are, and if they really get destroyed
      //visible = true

      // the particle may still play, as they are not looping anyway
      // NOTE: stopLivingParticles must be called here, because stop() would not kill the already living particles from the death animation, and so when it gets reused soon after, the old particles would still be visible!

      if(hitParticle.running)
        hitParticle.stopLivingParticles()
      if(deathParticle.running)
        deathParticle.stopLivingParticles()

      squabySprite.running = false
      pathMovement.running = false

      if(whirlRotationAnimation.running)
        whirlRotationAnimation.stop()
      if(dieAfterWhirlTimer.running)
        dieAfterWhirlTimer.stop()


      // if the squaby was whirled, its rotation would not be 0 initially
      squaby.rotation = 0

      // NOTE: this must be set! because the squaby could have been destroyed in between of the game, when it was not died!
      // if it would not be set explicitly, this pooled entity would otherwise be active for collisions!
      if(collidersActive)
        collidersActive=false

      // set it to invisible here, not from entityDestroyed
      //visible = false
      // this can be set, to see where the squabies are while they are pooled and what they do
//      visible = true
//      opacity = 0.5
//      squabySprite.opacity = 0.5

    }

    onUsedFromPool: {
      console.debug("Squaby: onUsedFromPool(), re-initialize all children components");

      // this makes the healthbar visible again, when the percent get below 1
      squaby.state = ""

      healthComponent.resetHealth();

      // when the squaby was whilred, this was set to false
      pathMovement.rotationAnimationEnabled = true

      // update movement animation when new waypoints are available otherways reset the animation.
      updatePathPosition()

      // this is required, so the correct position of the entity is set in this frame and not in the next
      // this is a cocos issue, because batched sprites use a cached nodeToWorldTransform for performance improvements
      //squaby.updateItemPositionAndRotationImmediately();

      // restart pathMovement
      pathMovement.running = true; // might have been set to false when it got killed in between


      // gets reset automatically
      //whirlingTurbineId  = "";

      // when the squaby died from a nailgung or flamethrower, it played the fadeout animation, thus reset the opacity to 1
      if(squabySpriteElement.opacity !== 1)
        squabySpriteElement.opacity = 1;

      // this might be set for debugging, to test which squabies are pooled!
      //squabySprite.opacity = 0.5

      // note: if we set running to false above, we also must set it true here, otherwise nothing is animated
      squabySprite.running = true
      squabySprite.jumpTo("walk");

      // they must get set to active explicitly, because they were set to false in onDied()!
      collidersActive = true;

      // it is set visible in EntityBase.onEntityCreated, which is called afterwards anyway
      //visible = true

    }

    function updatePathPosition() {
      // only if waypoint have change to a general update of the movementAnimation, otherways only entity position update
      if(movementAnimationNeedUpdate) {
        //console.debug("Squaby: pathMovement needs update because level waypoints have changed!")
        pathMovement.waypoints = level.pathEntity.waypoints
        // this also positions the entity to the first waypoint position!
        pathMovement.updateAnimationsFromWaypoints();
        movementAnimationNeedUpdate = false
      } else {
        pathMovement.reset()
      }
    }

    // gets played when HealthComponent.onDied is received
    SoundEffect {
        id: dieSound
        // an ogg file is not playable on windows, because the extension is not supported!
        source: "../../assets/snd/squafurScream.wav"
    }
    // these 2 soundEffects are played randomly when a squaby dies, so 2 different die sounds (not based on the squaby type, as they both sound good and should be randomly switched)
    SoundEffect {
        id: dieSound2
        source: "../../assets/snd/squatanScream.wav"
    }

    // Particle when Squaby gets hit
    Particle {
        id: hitParticle
        fileName: "../particles/SplatterParticle.json"
        //positionType: ParticleSystem.Relative
        x: -5
    }

    // Particle when Squaby dies
    Particle {
        id: deathParticle
        fileName: "../particles/DeathParticle.json"
    }

    SquabySprite {
        id: squabySpriteElement

        NumberAnimation on opacity {
            id: hideAnimation
            to: 0
            duration: 1000
            running: false
            easing.type: Easing.InQuart

            onStarted: {
              console.debug("Squaby: start fadeout animation after dying")
            }

            onStopped: {
              console.debug("Squaby: finished fadeout animation after dying, remove self")
              // after fading out, remove the entity
              squaby.removeEntity();
              squabyCreator.squabyDied(variationType)
            }
        }

        Timer {
            id: waitTimer
            // this timer could be used, if the fadeout should start after the DeathParticles, which has a duration of 2 seconds, + the duration until the last blood particles fade out
            interval: deathParticle.duration*1000 + 100
            running: false
            onTriggered: hideAnimation.start();
        }

        onAnimationFinished: {
          console.debug("Squaby: SpriteSequence.onAnimationFinished was emitted, this means the died animation is over");
          // this is only emitted if the squaby has finished playing its dying animation, so after the dying animation the squaby should be destroyed


          // it looks better if the fadeout starts after the death effect
//          waitTimer.start();

          // since no death effect is used, the hideAnimation can start immediately after the die animation is over
          hideAnimation.start()
        }
        //onAnimationChanged: console.debug("squaby.onAnimationChanged with name:", name)
    }

    PathMovement {
        // duration from the start to the end, gets linearly interpolated along all path segments
        // for longer path segments, the entity also needs longer, so it gets interpolated at a constant speed for the whole path, not for a specific time for a single segment
        //completePathAnimationDuration: 15000

        id: pathMovement

        velocity: 100

        waypoints: level.pathEntity.waypoints

        // this only gets triggered when loops-property is not set to infinite!
        onPathCompleted: {
          // a pathCompleted also occurs, when the squaby was whirled to the turbine! thus check if the waypoints is still the level waypoints
          //console.debug("waypoints:", waypoints, ", length:", waypoints.length, "level.waypoints.length:", level.pathEntity.waypoints.length)
          // NOTE: a check if waypointS!==level.pathEntity.waypoints wont work, because a local copy of the variant gets created!! so the pointers are not the same!
          // in case the squaby is pulled by a turbine, the waypoints length is 2, so with this check it works
          if(waypoints.length !== level.pathEntity.waypoints.length)
            return;

          console.debug("Squaby: pathCompleted, destroy squaby");
          // when the squaby finished the path, this means it should be destroyed and player's lives be decreased
          // do this only for the real application, for performance testing squaby removal might not be desired, but rather to start from the beginning again!

          player.lives--;

          // no die sound should be played, and the player should not get a score but loose a life, as he didnt kill the squaby before the bed
          //squaby.destroy();
          squaby.removeEntity();
          squabyCreator.squabyDied(variationType)
        }
    }

    // this is the same like rotation: -parent.rotation in healthbar
    //onRotationChanged: healthbar.rotation=-rotation;
    Healthbar {
        id:healthbar

        // 0/0 is the center now, so shift it the same way as SpriteSequence was
        // don't position the x&y directly, only the x&y of the child item
        absoluteX: -width/2
        absoluteY: -16//-squabySprite.height/2

        width: 32//squabySprite.width
        height: 3

        // this connects the visual item with the logical one
        percent: healthComponent.healthInPercent
        //onPercentChanged: console.debug("Squaby.Healthbar: percent changed to", percent)

        // do not make it visible when it is full of health, and also when in died-state
        visible: percent<1 && squaby.state!="died"

        // this is an optimization, to guarantee only the sprite version is loaded not the rectangles first
        useSpriteVersion: true
    } // end of Healthbar

    HealthComponent {
        id: healthComponent
        // the healthInPercent is connected with the visual item healthBar
        // when a hit() is received, forward it to this component

        //autoDestroyEntityWhenDied: true // only set this to true when testing, because when died the score must also be added to the player!

        damageMultiplicators: {
            "nailgun": damageMultiplicatorNailgun,
            "flamethrower": damageMultiplicatorFlamethrower,
            "taser": damageMultiplicatorTaser,
            "tesla": damageMultiplicatorTesla
        }

        onDied: {
            console.debug("onDied called for squaby");

            // this gets checked for the Healthbar - when in state died, the healthbar is invisible
            squaby.state = "died"
            // old Hide healthbar during dying
            // don't set it like that, otherwise the binding would be broken!
            //healthbar.visible = false;

            // this signal should be emitted, otherwise the nailguns still aim towards this squaby!
            // the squaby does not exist logically here any more, but only visually (playing the die animation)
            // db this isn't used anymore because the target gets removed anyway because squaby.collidersActive = false triggers a fixture.onEndContact in tower base.
            //console.debug("emitting squaby.entityDestroyed() manually");
            //squaby.entityDestroyed();

            // this must be set to visible=true explicitly, because at entityDestroyed() visible is set to false!
            // but it must be visible, because the squaby should play a die-animation and fadeout!
            //squaby.visible = true;
            // also, set collidersActive to false - it would usually be connected with the visible property, but the logical entity is removed, but still visible!
            squaby.collidersActive = false;

            // when a squaby gets killed by another tower while it is in whirl from turbine it should stop the turbine!
            whirlRotationAnimation.stop()
            dieAfterWhirlTimer.stop()

            // the collider must be destroyed, otherwise there would still be emitted a contactChanged-signal!
            // ATTENTION: the collider must NOT be destroyed, otherwise pooling wont work!
            //collider.destroy();
            // alternatively, a died() signal (which should be added to the base entity class) could also be emitted here, which indicates the logical entity got removed, but still exists visually and add a property died to entity, which can be checked in the Nailgun's onContactChanged for entity!?

            // ATTENTION:!!! if ids are accessible depend on WHERE the EntityManager is placed!!! when placed in GameWindow, all ids in window are known!!

            // window and scene are known because they are "direct" ancestors! player is only known if defined as alias in any of the parents!
            // TODO: why are not all direct ancestors known (level, world)??
//            console.debug("window.width:", window.width, ", scene.entityContainer:", scene.entityContainer);
//            console.debug("activeScene:", activeScene); // activeScene (property of window) is accessible
//            console.debug("entityContainer:", entityContainer); // this is accessible, don't know why!? it was defined as property in scene
//            console.debug("testIdAccessor in window:", testIdAccessor); // this is also known!!!

//            //console.debug("backgroundMusic in scene:", backgroundMusic); // this is not known, because only items in window are known
//            //console.debug("world:", world); // world is not accessible!? why not?
//            console.debug("level:", level); // level is not accessible! why not?
//            //console.debug("level.player:", level.player);
//            //console.debug("playerVariant:", playerVariant); // playerVariant is not accessible! why not?

          // don't start the death particles, as they may be too violent and also distract from the game
          //deathParticle.start();

          die();


            // ATTENTION: if destroyed here, the dieSound would not be played because it gets unloaded in the destructor!
            //owningEntity.destroy();


            // start dying animation
            // this leads to the signal onAnimationFinished() being emitted in SpriteSequence, after which the squaby should be destroyed!
            // this also fixes the sound playing issue!
            squabySprite.jumpTo("die");

            // stop the path movement here! otherwise the squaby would be moved until the end of the die animation!
            pathMovement.running = false;

            // also, a NumberAnimatin on visibility could be added here as visual effect!?!
        }
    }

    CircleCollider {
        id: collider
        radius: scene.gridSize
        // w&h are only needed for a BoxCollider
//        width: 32
//        height: 32

        // for testing performance difference, deactive the collider
        //active: false

        // this is a performance optimization (position of body is not propagated back to entity) and sets the sensor-flag to true
        // by setting collisionTestingOnlyMode to true, body.sleepingAllowed and fixture.isSensor get modified!
        collisionTestingOnlyMode: true

        // set a collisionMask & flag for squabies, to avoid colliding squabies with squabies but only with towers
        // category 2 are the towers, so squabies don't collide with each other, but with towers
        categories: Box.Category1
        collidesWith: Box.Category2
    }

    /* this would move x&y independently! unwanted
    PropertyAnimation {
        id: whirlAnimation
        properties: "x,y"
        target: squaby
    }*/

    // this gets set when whirled and applied to the PathMovement component's path - not needed any more!
//    Path {
//        id: whirlPath
//        // the values of startRotationa nd targetRotation get set manually in startWhirlingToTarget()
//        PathAttribute { id: startRotation; name: "rotation"; value: 0 }
//        PathLine { id: targetPoint }
//        PathAttribute { id: targetRotation; name: "rotation"; value: 0 }
//    }

    // this may be used for a rotationAnimation when the squaby gets whirled, because it is no common behavior for the PathMovement
    NumberAnimation on rotation {
        id: whirlRotationAnimation
        // gets set to true when the squaby gets whirled by a turbine
        running: false
        // gets set based on the distance
        //duration: 250
        // gets set to the tower rotation
        //to: 360
        // should not rotate, looks strange
        //loops: Animation.Infinite
    }

    // an Id must be saved here and not a reference, because qobjects cant be stored as variants, and also because it is possible that the turbine gets removed during the die-animation!
    property string whirlingTurbineId

    Timer {
        id: dieAfterWhirlTimer
        // interval gets set to duration of whirling towards turbine in startWhirlingToTarget
        onTriggered: {
            console.debug("Squaby: end of whirling towards turbine, kill squaby");
            // manually emit the died-signal, which causes the die-animation and die-sound to be played
            // NO! the die-signal should not be emitted, because the die-animation should not be played!
            // the squaby can be destroyed immediately!
            //healthComponent.died();

            // if it does not exist, this means the turbine got removed in the meantime, so e.g. it got sold by the user in between!
            var whirlingTurbineEntity = entityManager.getEntityById(whirlingTurbineId);
            if(whirlingTurbineEntity) {
                whirlingTurbineEntity.whirlingOfSquabySuccessful(entityId);
            } else {
                console.debug("Squaby: no whirlingTurbine exists - it must have been sold during the whirling process!");
            }

            die();

            //squaby.destroy();
            squaby.removeEntity();
            squabyCreator.squabyDied(variationType)
        }
    }

    // forward this message to healthComponent, which originates from towers when they fire
    function hitWithAttackerIdAndType(attackerId, attackerType) {
        // Show particles if hit by a nailgun
        if (attackerType === "nailgun" && currentParticles < maximumParticles)
          hitParticle.start();
        healthComponent.hitWithAttackerIdAndType(attackerId, attackerType);
    }

    function hitByValue(attackerId, attackerType, damageValue) {
       healthComponent.hitByValue(attackerId, attackerType, damageValue);
    }

    /** Gets called by the turbine when it should start moving towards the turbine and stop path movement.*/
    function startWhirlingToTarget(towerTarget) {

      console.debug("Squaby: startWhirlingToTarget()")

      // tell squaby to catch original movementaniamtion path data when respawned, otherwise the whirl animation movement data is still active.
      movementAnimationNeedUpdate = true

        // start the whirl animation of squaby
        squabySprite.jumpTo("whirl");

        // speed how fast squaby is whirled to the turbine may be adjusted here:
        //pathMovement.pixelsPerSecond *= 1.2;

        // use a custom rotation to animate the whirling, as it has nothing to do with the PathAnimation
        pathMovement.rotationAnimationEnabled = false;
        var whirlWaypoints = [ {x:squaby.x, y:squaby.y}, {x:towerTarget.x, y: towerTarget.y} ];
        // by overwriting the waypoints, the animations get restarted and the duration gets recalculated based on the pixelsPerSecond property
        pathMovement.waypoints = whirlWaypoints;

        // the rotation destination should be the tower rotation
        whirlRotationAnimation.to = towerTarget.rotation;
        whirlRotationAnimation.duration = pathMovement.completePathAnimationDuration*0.9;
        whirlRotationAnimation.running = true;

/*
        // stop the path movement first before the new path is set! otherwise undefined behavior when changing the path at runtime!
        pathMovement.running = false;

        var distanceX = squaby.x-towerTarget.x;
        var distanceY = squaby.y-towerTarget.y;
        var distanceSquared = Math.sqrt(distanceX*distanceX + distanceY*distanceY);


        // make duration depending on the distance, to simulate constant movement - the squaby may be started to be whirled in different distances (e.g. when the tower delay is over while a squaby is in the collider)
        // move at 50px/second
        var whirlToTurbineSpeedPxPerSecond = 50;
        pathMovement.completePathAnimationDuration = 1000*distanceSquared/whirlToTurbineSpeedPxPerSecond;

        whirlPath.startX = squaby.x;
        whirlPath.startY = squaby.y;
        startRotation.value = squaby.rotation;
        targetPoint.x = towerTarget.x;
        targetPoint.y = towerTarget.y;
        targetRotation.value = towerTarget.rotation;

        console.debug("startRotation:", startRotation.value, "targetRot:", targetRotation.value);

        pathMovement.path = whirlPath;
        // reenable the pathmovement with the turbine as target
        pathMovement.running = true;


        */

        // save it here, so the tower knows when it should count the whirled squaby
        whirlingTurbineId = towerTarget.entityId;
        console.debug("whirlingTurbine set to", squaby.whirlingTurbineId);

        // the timer should be a bit shorter than the distance, so the squaby should look like it disappears in front of the turbine
        // TODO: for exact position, not the time should be adjusted but the distanceSquared should be reduced by the turbine foundation, and then the percentage should be calculated!
        // but it is not visually detectable, so leave it with this simple approach (the tower doesn't have

        console.debug("set dieAfterWhirlTimter to almost pathDuration:", pathMovement.completePathAnimationDuration);
        dieAfterWhirlTimer.interval = pathMovement.completePathAnimationDuration*0.9;
        dieAfterWhirlTimer.running = true;


    }

    // play die sound and add score and gold to player
    function die() {

        // do not play if in debug mode
        if(!system.debugBuild) {

            // Math.random() returns a random number between 0 and 1
            var random = Math.random();

            // play one of the 2 die sound
            if(random>0.5)
                dieSound.play();
            else
                dieSound2.play();
        }

        // add score and gold of this squaby to the player
        player.score += squaby.score
        player.gold += squaby.gold

    }

    onStateChanged: console.debug("Squaby: state changed to", state)
}
