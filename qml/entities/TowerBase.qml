import QtQuick 2.0
import Felgo 3.0
// this is only needed to get access to Box2DFixture class, containing the categories


//EntityBase {
EntityBaseDraggable {
    id: towerBase
    // the entityType property must be set by the derived concrete towers!

    // it must be above the path and obstacles
    z: 2

    //property variant targetEntity: null
    // NOTE: we must not use targetEntityConnection.target any more, because initially that points to the towerBase entity which leads to an error in Qt5!
    property QtObject targetEntity: null

    // can be used to disable the collider temporarily, e.g. for turbine
    property alias fireRangeCollider: collider

    // this is the radius the nailgun has at firing, set the default value to 4 squares(4*16=64), because the nailgun itself is 2 squares, and 2 further away it should collide
    property real colliderRadius: 4*scene.gridSize // the default radius (not upgraded) is 64 (4 grids)

    inLevelEditingMode: true

    // it is important that this is not set smaller than the animation time of nailgun! otherwise the sprite animation can not keep up
    // set the default shoot rate to 600ms, if upgraded to 400
    // this is only needed for nailgun & turbine, for flamethrower it is unused, and a custom upgrade damgePerSecond is used!
    // thus don't set a default value here, but set the explicit value in Nailgun.qml
    property int shootDelayInMilliSeconds//: 600

    // these get set per tower, are the logic properties and could be put into an own component!?
    property int cost//: 20
    property int saleRevenue//: 5
    property variant upgradeLevels/*: {
        // the status field for the upgrade is only needed for turbine upgrade!
        "range": [{"level": 1, "cost": 10, "value": 5*scene.gridSize, "additionalSaleRevenue": 5}],
        "shootDelay": [{"level": 1, "cost": 15, "value": 400, "additionalSaleRevenue": 10}]
    }*/
    //property variant rangeUpgradeLevels : [ { level: 1, cost: 30, value: 80, additionalSaleRevenue: 5 } ]
    //property variant shootDelayUpgradeLevels = [ { level: 1, cost: 40, value: 0.05, additionalSaleRevenue: 10 } ]

    property variant __currentUpgradeLevels: { "range": 0, "shootDelay": 0 }
    property int __saleRevenue: saleRevenue // this gets increased internally when the tower gets upgraded, and gets added to the player gold when the tower gets sold

    /** Gets emitted when MoveToPointHelper toggles the aimingAtTarget-boolean-flag. May be used to enable the shooting. */
    signal aimingAtTargetChanged(bool aimingAtTarget)
    /** Gets emitted when the target gets removed or gets out of the collider. */
    signal targetRemoved

    /** Gets emitted when a custom upgrade was used, like repair or damagePerSecond. UpgradeData is a variant of the upgrade and contains e.g. {"level": 1, "cost": 15, "value": 400, "additionalSaleRevenue": 10}*/
    signal towerUpgradedWithCustomUpgrade(string upgradeType, variant upgradeData)

    /** Gets emitted on every upgrade so that subtypes can implement their own logic there; for parameters see towerUpgradedWithCustomUpgrade  */
    signal towerUpgraded(string upgradeType, variant upgradeData)


    // anchoring doesn't work, because the collider is not centered in the entity!
    //selectionMouseArea.anchors.fill: foundationCollider
    selectionMouseArea.width: foundationCollider.width
    selectionMouseArea.height: foundationCollider.height
    selectionMouseArea.anchors.centerIn: towerBase

    // set the selectionMouseArea to sprite in the derived TowerBase components, as sprite is defined only there!
    colliderComponent: foundationCollider
    // Cat3 is the foundationCollider of the towers, obstacles and path
    // Cat4 is the dragged tower - so this is exactly exchanged, so the dragged tower collides with the already existing towers
    colliderCategoriesWhileDragged: Box.Category4
    colliderCollidesWithWhileDragged: Box.Category3
    // set this to true when in game mode (towers should be selectable), but not in levelEdit mode
    clickingAllowed: scene.state !== "levelEditing"
    // dragging should only be allowed in levelEditMode!
    draggingAllowed: false
    // the Rectangle shouldnt be used for towers, because the range circle gets colored green or red instead
    showRectangleWhenBuildingNotAllowed: false

    // Flag only used in performance tests (false means, aimingAtTarget signal is not emitted)
    property bool emitAimingAtTargetSignal: true

    onEntityClicked: {
        console.debug("tower clicked");
        towerSelected();

//        if(scene.state === "levelEditing") {
//          hud.entitySelected(block);
//        }

    }

    Connections {
        id: targetEntityConnection
        // this gets set when a squaby collides with the tower
        target: targetEntity
//        ignoreUnknownSignals: true

        // why is onDestroyed not known?
//        onDestroyed: {
//            // if the target got destroyed, clear the connection
//            targetEntityConnection.target=null
//        }

        // not usable, is valid for the Connections element not for the target
//        Component.onDestruction: {
//            console.debug("this is the wrong onDestroyed function: it is the one from the connections item! the interesting one would be from the target!")
//        }

        // this signal was manually added in EntityBase
        onEntityDestroyed: {
            console.debug("entityDestroyed received in targetEntityConnection, set target to 0");
            removeTarget();
        }

        // does complain that targetChanged does not exist, which is reasonable because for the target object it really doesn't exist!?
        // error message: QML Connections: Cannot assign to non-existent property "onTargetChanged"
//        onTargetChanged: {
//            console.debug("target changed to:", target);
//        }
    }

//    Connections {
//        target: targetEntityConnection
//        // this doesn't work!? error message: ReferenceError: Can't find variable: target
//        onTargetChanged: console.debug("target changed to:", target);
//    }


    CircleCollider {
        id: collider
        radius: colliderRadius // this is the radius the nailgun has at firing, set the default value to 4 squares, because the nailgun itself is 2 squares, and 2 further away it should collide
//        width: 64
//        height: 64
        x: -radius
        y: -radius

        // this is a performance optimization (position of body is not propagated back to entity) and sets the sensor-flag to true
        // by setting collisionTestingOnlyMode to true, body.sleepingAllowed and fixture.isSensor get modified!
        collisionTestingOnlyMode: true

        // ATTENTION: setting body.sleepingAllowed to false is VERY important if the positions get set from outside! otherwise no BeginContact and EndContact events are received!
        // it would be enough to set this flag for one of the two colliding bodies though as a performance improvement
//        body.sleepingAllowed: false
//        fixture.sensor: true

        // set a categories, but don't set collidesWith, because when a tower is dragged into the playground, the towers should collide with each other!
        // category 2 are the towers, so squabies don't collide with each other, but with towers
        categories: Box.Category2
        // towers should only collide with squabies, not with other towers!
        fixture.collidesWith: Box.Category1


        Component.onCompleted: {
            console.debug("isSensor of nailgun is", collider.fixture.sensor);

        }

        fixture.onBeginContact: {
            // if there already is a target, return immediately
            if(targetEntity)
                return;

            var fixture = other;
            var body = other.getBody();
            //var component = body.parent;
            var entity = body.target;
            //var collidedEntityType = entity.entityType;

            //console.debug("nailgun beginContact with: ", other, body, component);
            //console.debug("nailgun collided with entity type:", collidedEntityType, ", other entity:", entity);
            //console.debug("is collided entity ofType(squaby):", entity.isOfType("squaby"));

            // look here for information about connectings signals in QML: https://qt-project.org/doc/qt-4.8/qmlevents.html
            // this doesn't work with the default destroyed-signal! only with signals defined in QML!
            //entity.destroyed.connect(targetDestroyed);
            // -> to solve this issue, a custom signal entityDestroyed was created for EntityBase!
            // with this entityDestroyed is called whenever the target gets destroyed! this is the same like done in the Connection element! so use the Connections-approach
            //entity.entityDestroyed.connect(targetDestroyed);

            setTarget(entity);
        }

        // only receive the contactChanged signals, when there is no target assigned (so when the target was removed once it was inside)
        Connections {
          target: targetEntity ? null : collider.fixture
            onContactChanged: {
                if(targetEntity) {
                    // this IS gonna be called! not clear yet when exactly! probably sometime in between removeTarget()
                    console.debug("TowerBase: onContactChanged() - this should never be called, because the connection shouldnt be enabled when no targetEntity exists!")
                    return;
                }

                console.debug("target of tower got removed, set to new one...")
                var entity = other.getBody().target;
                setTarget(entity);
            }
        }

        fixture.onEndContact: {
            var entity = other.getBody().target;

            // only remove the target, if this was the one assigned before in onBeginContact
            if(entity === targetEntity)
                removeTarget();
        }
    }

    // this collider is for building the tower, which gets tested at dragging towers in
    BoxCollider {
        id: foundationCollider
        width: 2*scene.gridSize-1 // if it would be set to 32, they would collide by exactly 1 pixel!
        height: 2*scene.gridSize-1
        collisionTestingOnlyMode: true

        categories: Box.Category3
        collidesWith: Box.Category4

        anchors.centerIn: parent

        // the physics body should not rotate with the entity! it always stays the same!
        //body.rotation: 0
        body.fixedRotation: true
    }

/*
    don't use this approach any more, because the MoveToPointHelper in C++ is faster and easier to use
    MoveToPointHelper {
        id: steerToPointBehavior
        // use the target from targetEntityConnection, which is 0 if not current target is active
        targetObject: targetEntity
        aimingAngleThreshold: 40 // set this high enough! because the nailgun rotates faster than the squaby, it can be assumed that once the target is aimed at initially, it will only exit after when the target leaves the range!

        onAimingAtTargetChanged: {
            // emit the towerBase signal
            towerBase.aimingAtTargetChanged(aimingAtTarget);
        }
    }

    // instead of updating the steering behavior in update(), use a timer for it!
    Timer {
        id: steeringUpdateTimer
        interval: 75 // adjust this setting so it still looks good, and set to the highest available value
        repeat: true
        triggeredOnStart: true // causes onTriggered to be called when running switches to true - this is important because otherwise the initial rotation action would only be started "interval" ms after the initial contact
        onTriggered: {
            // in here, the nailgun is rotated towards the squaby
            steerToPointBehavior.update();
        }
    }
*/

    // this is a C++ item, which sets its output xAxis & yAxis properties based on the target position
    MoveToPointHelper {
        id: moveToPointHelper
        targetObject: targetEntity

        // distanceToTargetThreshold is not used for the towers - they only need to rotate left/right not move forward/backward
        // so it doesnt matter what value is set for that - the targetReached() signal is emitted if the distanceToTarget is smaller than distanceToTargetThreshold
        //distanceToTargetThreshold: 20
        allowSteerForward: false

        property real aimingAngleThreshold: 10

        property bool aimingAtTarget: false

        onAimingAtTargetChanged: {
            console.debug("TowerBase: aimintAtTarget changed to", aimingAtTarget);

            // emit the towerBase signal
            if(emitAimingAtTargetSignal) {
              towerBase.aimingAtTargetChanged(aimingAtTarget);
            }
        }

        onTargetObjectChanged: {
            console.debug("TowerBase: targetObject changed to", targetObject);
            if(!targetObject)
                aimingAtTarget = false;
        }

        onAbsoluteRotationDifferenceChanged: {
            //console.debug("TowerBase: absoluteRotationDifference:", absoluteRotationDifference)
            if(absoluteRotationDifference < aimingAngleThreshold && !aimingAtTarget) {
                // set the aimingAtTarget to true, but only when previously it was not aiming
                aimingAtTarget = true;
            } else if(absoluteRotationDifference > aimingAngleThreshold && aimingAtTarget) {
                // set the aimingAtTarget to false, but only when it was aiming before
                aimingAtTarget = false;
            }
        }
        //onOutputXAxisChanged: console.debug("outputXAxis changed to", outputXAxis)
    }

    MovementAnimation {
      target: towerBase
      property: "rotation"
      // the tower should only rotate, when the target is not reached
      // this must be set to "targetEntity ? true : false" when velocity is changed!
      // i.e. when there is a target set, take the input from the STPB - but this would not work for the acceleration, because then the velocity is still modified when the acceleration gets set to 0!
      running: targetEntity ? true : false
      // when acceleration should be modified - if output changes to 0, the acc gets 0 but the velocity still exists!
      // NOTE: this is an issue in Squaby only, because the targetEntity is still set, even if the squaby was "logically" removed!
      // if the entityDestroyed-signal of targetEntity would be connected, the above should be able to use!?
      // but it IS connected, so no idea why the animation works too long, even when targetEntity is unset!?
      //running: moveToPointHelper.outputXAxis!=0 ? true : false

      // setting the acceleration makes the tower rotate slower (so it takes longer to reach the desired targetRotation)
//      acceleration: 500*moveToPointHelper.outputXAxis
      velocity: 300*moveToPointHelper.outputXAxis


      // this avoids over-rotating, so rotating further than allowed
      maxPropertyValueDifference: moveToPointHelper.absoluteRotationDifference
    }

    function removeTarget() {
        console.debug("TowerBase.removeTarget() called");
        // set the target to 0
        targetEntity = null;

        // setting running to false has the bad effect that it stops in the middle of the animation!
        // thus control the animation manually by calling playShootAnimation, which will run to the end of the animation
        //sprite.running = false;

//        steeringUpdateTimer.running = false;

        // this is also necessary, otherwise the onAimingAtTargetChanged would never be triggered and shooting would not start!
//        steerToPointBehavior.aimingAtTarget = false;

        // emit the signal which gets connected in the derived classes
        towerBase.targetRemoved();
    }

    function setTarget(target) {
        console.debug("TowerBase: setTarget() called for", target);
        console.debug("TowerBase: previous targetEntity (should be 0!):", targetEntity);

        targetEntity = target;

//        steeringUpdateTimer.running = true;

        //steerToPointBehavior.targetObject = target; // this gets set from the targetEntityConnection.target
    }

    function towerSelected() {
        var message = createTowerInfo();
        hud.towerSelected(message);
    }

    function createTowerInfo() {
        var upgradeArrayForGui = new Array();
        // upgradeType has the value "range", "shootDelay" and "repair" (turbine-only)
        for (var upgradeType in upgradeLevels) {

            var currentUpgradeLevelForType = __currentUpgradeLevels[upgradeType];
            var currentUpgradesForType = upgradeLevels[upgradeType];

            // this is necessary to prevent accessing upgrades for already fully upgraded towers
            // this local variable will be decreased by 1 so the latest available upgrade, but the correct (unmodified) upgradeLevel will be sent below for currentPlayerUpgradeLevel
            // if the upgradeLevel of the sent level is the same like the current player, the maximum upgrade is reached!
            // so if currentPlayerUpgradeLevel would be set to 1, this would mean this upgrade is fully built and the upgrade will be deactivated in the gui
            if(currentUpgradeLevelForType >= currentUpgradesForType.length)
                currentUpgradeLevelForType = currentUpgradesForType.length-1;

            var currentUpgradeForType = currentUpgradesForType[currentUpgradeLevelForType];

            // additionally, status for the upgrade should be added, which can either be AVAILABLE (if it should be greyed out in the gui, e.g. if repairing is not possible because lives are not 0),	NOT_AFFORDABLE or ALREADY_BUILT (this is irrelevant as the upgrade system is complexer now than in original iphone squaby..),
            var upgradeData = {	type: upgradeType,
                cost: currentUpgradeForType.cost,
                upgradeLevel: currentUpgradeForType.level,
                currentPlayerUpgradeLevel: __currentUpgradeLevels[upgradeType],
                status: currentUpgradeForType.status
            }
            //print("upgradeData.status: " + upgradeData.status + " for type: " + upgradeType);

            upgradeArrayForGui.push( upgradeData );
        }

        var message = {
                entityId: towerBase.entityId,
                entityType: towerBase.entityType,
                colliderRadius: collider.radius,
                saleRevenue: towerBase.__saleRevenue, // use the updated saleRevenue here, as this is the real value of the tower (it gets more valuable with upgrades)
                upgrades: upgradeArrayForGui,
                towerPosition: {x:towerBase.x, y:towerBase.y}
            }
        return message;
    }

    // returns whether the upgrade is affordable or not
    function upgradeTower(upgradeType) {
        // these are the common upgrade types for all 3 towers - repair is implemented in the turbine only!
        if(upgradeType === "sell") {

          if(!scene.tutorials.nextAction("upgradeButton","sold"))
            return

          // this is interesting for analytics!
          if(entityType === "nailgun")
            player.nailgunsDestroyed++;
          else if(entityType === "flamethrower")
            player.flamethrowersDestroyed++;
          else if(entityType === "taser")
            player.tasersDestroyed++;
          else if(entityType === "tesla")
            player.teslasDestroyed++;
          else if(entityType === "turbine")
            player.turbinesDestroyed++;
          flurry.logEvent("Tower.Sold", {"towerType": entityType, "playerGold": player.gold, "wave": player.wave});


            //print("sale revenue for sold tower: " + __saleRevenue);
            //changeGoldByValue(saleRevenue);

            // send this event to the gameLogic, so the gold can be modified there
//            var scriptEvent = {
//                    eventType: "tower_sold",
//                    entityId: this.entityId,
//                    saleRevenue: __saleRevenue
//            }
//            createAndEnqueueEvent(scriptEvent);
            player.gold += towerBase.__saleRevenue;

            // remove the sold tower
            entityManager.removeEntityById(towerBase.entityId);

        } else {
            // handle all other upgrade types here, also the custom ones like damagePerSecond(flamegun), repair(turbine), shootDelay(nailgun & turbine) and the common for all range
            var currentUpgradeLevelForType = __currentUpgradeLevels[upgradeType];
            var currentUpgradesForType = upgradeLevels[upgradeType];

            // if the tower is not upgraded, currentUpgradeLevelForType=0 and __currentUpgradeLevels has length of 1
            if(currentUpgradeLevelForType < currentUpgradesForType.length) {
                var currentUpgradeForType = currentUpgradesForType[currentUpgradeLevelForType];

                if(currentUpgradeForType.cost > player.gold) {
                    print("insufficient funds for upgrading the weapon with upgradeType: " + upgradeType);
                    return false;
                }

                // this is interesting for analytics!
                flurry.logEvent("Tower.Upgraded", { "upgradeType": upgradeType, "towerType": variationType, "playerGold": player.gold, "wave": player.wave});



                print("upgrade can be bought... value for upgrade:", currentUpgradeForType.value);
                // reduce the player's gold, as this tower gets bought - the internal saleRevenue also gets bigger, as the tower gets more valuable after upgrading!
                player.gold -= currentUpgradeForType.cost;
                __saleRevenue += currentUpgradeForType.additionalSaleRevenue;

                if(upgradeType === "range") {
                    colliderRadius = currentUpgradeForType.value;
                    console.debug("update colliderRadius from", colliderRadius, "to", currentUpgradeForType.value)
                } else if(upgradeType === "shootDelay")
                    shootDelayInMilliSeconds = currentUpgradeForType.value;
                else
                    // the repair upgrade & the flamethrower Damage upgrade handling to modify the lives is done in the derived classes Flamethrower & Turbine and should be handled there!
                    towerUpgradedWithCustomUpgrade(upgradeType, currentUpgradeForType);

                towerUpgraded(upgradeType, currentUpgradeForType);

                // the repair upgrade should always be available, so do not increase this level! the gui knows that upgrading is only possible when the turbine got damaged before! - nope, also increase the upgradeLevel of the repair upgrade - so it is known in the gui if the upgrade was built!
                // the upgradeLevel of the repair upgrade must be DECREASED when the tower is in the destroyed state (no more lives left)
                //if(upgradeType!="repair")

                // this has no effect, because var-properties in QML components are read-only! thus move into a separate js file then the next call is possible!
                //__currentUpgradeLevels[upgradeType]++;

                // alternative to above, copy the current upgradeLevels locally, update teh copy and copy back to original with updated level
                var newUpgradeLevels = __currentUpgradeLevels;
                newUpgradeLevels[upgradeType]++;
                __currentUpgradeLevels = newUpgradeLevels;

                // update the animation sprite for the tower depending on the upgrade levels
                var message = createTowerInfo();
                sprite.setTowerImageFromEvent(message);

                console.debug("upgradeLevel changed to", __currentUpgradeLevels[upgradeType], "for upgrade type", upgradeType);

//                print("before selectedtower_information event creation, this in sharedTowerLogic.upgradeTower(): " + this);
//                sendSelectedTowerEvent(this.entityId, this.entityType);

                // it is needed to call this again, so the upgradeWeapons in the HUD get updated to the new upgradeLevels
                towerSelected();

//                // this event is needed by the gameLogic (to modify the gold) and NOT any more by the gui, this is done by a tower_selected event (to modify the state of the tower, so to change the image and animations to the upgraded state)
//                var scriptEvent = {
//                    eventType: "tower_upgraded",
//                    entityId: this.entityId,
//                    entityType: this.entityType,
//                    upgradeType: upgradeType,
//                    cost: currentUpgradeForType.cost
//                }
//                createAndEnqueueEvent(scriptEvent);

            } else {
                print("no upgrading is possible because no more upgrades are available for upgradetype: " + upgradeType );
                return false; // do NOT return false here! the tower is affordable, but internally fully built
            }
        }
        return true;
    }
}
