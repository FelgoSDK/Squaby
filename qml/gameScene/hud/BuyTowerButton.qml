import QtQuick 1.0
// this must be imported globally! so only once in main.qml
//import "levelLogic.js" as Logic
import VPlay 1.0

BuildEntityButton {
    id: buyTowerButton

    //anchors.fill: buttonSprite - this doesnt work, because anchoring only works for parent or sibling! thus set the width & height manually
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

    // not needed any more, was moved to default behavior of BuildEntityButton
    onCreatedEntityChanged: {
        console.debug("BuyTowerButton: createdEntityChanged to", createdEntity)
        if(createdEntity) {
            cost = createdEntity.cost
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
      else if(createdEntity.entityType === "turbine")
        player.turbinesBuilt++;
      flurry.logEvent("Tower.Built", {"towerType": createdEntity.entityType, "playerGold": player.gold, "wave": player.wave});

        // decrease player gold by the cost of this weapon
        player.gold -= cost;
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
    Sound {
        id: towerConstructEffect
        source: "../../snd/towerConstruct.wav"
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
