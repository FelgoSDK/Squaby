import QtQuick 2.0
// this must be imported globally! so only once in main.qml
//import "levelLogic.js" as Logic
import VPlay 2.0

BuildEntityButton {
    id: buyTowerButton

    //anchors.fill: buttonSprite - this doesn't work, because anchoring only works for parent or sibling! thus set the width & height manually
    width: buttonSprite.width
    height: buttonSprite.height

    // is needed to set the source for DragWeapon, which is the name of the png in the spritesheet json file
    // has e.g. the value "nailgun.png" - mention that the path is irrelevant, as the image is looked up in the json file
    property alias source: buttonSprite.source

    // the cost property is set in onCreatedEntityChanged, after the entity for this button was created and the cost is retrieved
    property alias cost:priceTag.cost

    // affordable should change with the player gold - if the player has more gold than the tower costs, it is affordable; if non-affordable, opacity will be set to 0.5
    property bool __affordable: player.gold>=cost
    opacity: __affordable ? 1 : 0.5

    // only allow dragging (so enable the MouseArea of BuildEntityButton), when the button is affordable
    enabled: __affordable

    // this is called before the base class constructor BuildEntityButton, so the entity is not available in here but only in onCreatedEntityChanged
//    Component.onCompleted: {
//        console.debug("BuyTowerButton.onCompleted");
//    }

    Connections {
      id: buyTowerButtonConnection
      //target: level.balancingSettings.nailgun
      onCostChanged: {
        var theNewCost = 0
        if(createdEntity.entityType === "nailgun") {
          theNewCost = level.balancingSettings.nailgun.cost
        } else if(createdEntity.entityType === "flamethrower") {
          theNewCost = level.balancingSettings.flamethrower.cost
        } else if(createdEntity.entityType === "taser") {
          theNewCost = level.balancingSettings.taser.cost
        } else if(createdEntity.entityType === "tesla") {
          theNewCost = level.balancingSettings.tesla.cost
        } else if(createdEntity.entityType === "turbine") {
          theNewCost = level.balancingSettings.turbine.cost
        }
        buyTowerButton.cost = theNewCost
      }
    }

    // not needed any more, was moved to default behavior of BuildEntityButton
    onCreatedEntityChanged: {
        console.debug("BuyTowerButton: createdEntityChanged to", createdEntity)
        if(createdEntity) {

            // Does not work anymore because the dynamic change is not stated in the entity.
            //cost = createdEntity.cost
          if(createdEntity.entityType === "nailgun") {
            buyTowerButtonConnection.target = level.balancingSettings.nailgun
            cost = level.balancingSettings.nailgun.cost
          } else if(createdEntity.entityType === "flamethrower") {
            buyTowerButtonConnection.target = level.balancingSettings.flamethrower
            cost = level.balancingSettings.flamethrower.cost
          } else if(createdEntity.entityType === "taser") {
            buyTowerButtonConnection.target = level.balancingSettings.taser
            cost = level.balancingSettings.taser.cost
          } else if(createdEntity.entityType === "tesla") {
            buyTowerButtonConnection.target = level.balancingSettings.tesla
            cost = level.balancingSettings.tesla.cost
          } else if(createdEntity.entityType === "turbine") {
            buyTowerButtonConnection.target = level.balancingSettings.turbine
            cost = level.balancingSettings.turbine.cost
          }

            console.debug("BuyTowerButton: setting cost of button to", cost)

//            // this is the default behavior anyway
//            //createdEntity.draggingAllowed = true;
//            //createdEntity.clickingAllowed = false;
//            // always set the enabled flag to true, otherwise it would only be enabled in levelEditingMode
//            //createdEntity.selectionMouseArea.enabled = true;
        }
    }

    onEntityPressed: {
        selectedTowerRange.isAllowedToBuild = createdEntity.allowedToBuild;
        selectedTowerRange.colliderRadius = createdEntity.colliderRadius;
        selectedTowerRange.visible = true;
      tutorials.nextAction(createdEntity.entityType, "pressed")
    }

    onEntityReleased: {
        selectedTowerRange.visible = false;
    }

    onEntityWasBuilt: {
        // play the building sound effect here
        towerConstructEffect.play();

      // this is interesting for analytics!
      if(createdEntity.entityType === "nailgun")
        player.nailgunsBuilt++;
      else if(createdEntity.entityType === "flamethrower")
        player.flamethrowersBuilt++;
      else if(createdEntity.entityType === "taser")
        player.tasersBuilt++;
      else if(createdEntity.entityType === "tesla")
        player.teslasBuilt++;
      else if(createdEntity.entityType === "turbine")
        player.turbinesBuilt++;
      flurry.logEvent("Tower.Built", {"towerType": createdEntity.entityType, "playerGold": player.gold, "wave": player.wave});

        // decrease player gold by the cost of this weapon
        player.gold -= cost;
      tutorials.nextAction(createdEntity.entityType, "entityBuilt",Qt.point(createdEntity.x,createdEntity.y))
    }


    SingleSquabySprite {
        id: buttonSprite
    }

    PriceTag {
        id: priceTag
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    // gets played when the building is allowed and the tower gets built
    SoundEffectVPlay {
        id: towerConstructEffect
        source: "../../../assets/snd/towerConstruct.wav"
    }

    // this modifies the position of the selectedTowerRange image defined in HUD
    Connections {
        target: createdEntity ? createdEntity : null
        onXChanged: {
            selectedTowerRange.x = createdEntity.x;
        }
        onYChanged: {
            selectedTowerRange.y = createdEntity.y;
        }
        onAllowedToBuildChanged: {
            //console.debug("BuyTowerButton's entity changed allowedtoBuild to:", createdEntity.allowedToBuild);
            selectedTowerRange.isAllowedToBuild = createdEntity.allowedToBuild;
        }
    }

} // end of item
