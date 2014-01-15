// only in qtquick 1.1 implicitWidth is known!
import QtQuick 1.0
import VPlay 1.0

Item {
  id: hud
  property real vertexZ: 3 // this is needed, otherwise the HUD would not be on top of the bed, which has vertexZ=2

  // for testing if the BuildEntityButton entities were really built
  //opacity: 0.2


  // gets set from Obstacle when an obstacle is selected - but as the name implies this could be set to any entityId
  // if a change of this id is detected, the hud state will display the sell button to destroy the obstacle (state modifyEntity)
  //property string selectedEntityId: ""
  property variant selectedEntity

  // this gets set when a tower is selected - it is needed for the turbine when it is out of lives, and if the tower is currently selected, then the hud should be updated
  property string selectedTowerId: ""

  // this is emitted when the menu button was clicked
  signal menuButtonClicked

  // not needed any more - the hud state is switched in entitySelected()
  //    onSelectedEntityChanged: {
  //        console.debug("selectedEntity changed to:", selectedEntity);
  //        if(selectedEntity)
  //            hud.state = "modifyEntity";
  //    }

  // start in the buildTowers state by default
  state: "buildTowers"

  // this will be set to visible and positioned to the selected tower when hud.towerSelected() is called, or from BuyTowerButton when the new entity gets moved
  TowerRangeCircle {
    // this sets the vertexZ to 2.1 (3-0.9=2.1), so it is below the hud here (with vertexZ=3), but above the closet which also has a vertexZ of 2
    // NOTE: the vertexZ is the sum of all parents, not like the z property which is only relevant between siblings!
    property real vertexZ: -0.9
    // revert the HUD vertexZ here! otherwise it would be drawn on top of the tower! (because the HUD vertexZ is 3, and the nailgun spritesheet is only 0!)
    // TODO: change the TowerRange component to also use a spritesheet instead of the Image, then this is not needed any more!
    // do NOT set a negative vertexZ, because otherwise it would be below the bed,closet
    // with default settings, it is on top of the HUD & sprite batches (so also on top of tower, but that is not a problem as it still looks ok)
    //        property real vertexZ: -hud.vertexZ

    id: selectedTowerRange

    // the size is set based on the colliderSize automatically

    // should be invisible at beginning, only gets visible when a tower is selected
    visible: false

    // a transform is needed here, because this item gets positioned by setting the center position, so the transformOrigin is in the center
    transform: [
      // mention that selectedTowerRange. is needed, otherwise they are undefined!
      // hud.y must be extracted, because selectedTowerRange gets positioned based on scene origin, and hud is shifted down by this factor!
      Translate { x: -selectedTowerRange.width/2; y: -selectedTowerRange.height/2 - hud.y}
    ]
  }


  SingleSquabySprite {
    id: menuBackground
    source: "menuBackground.png"
    //z:-1 // this should not be needed for cocos, as it is the first item defined, it should be below all other siblings by default!
  }

  MenuGoldWaveItems {
    id: menuGoldWaveItems

    onMenuButtonClicked: {
      hud.menuButtonClicked();
    }
  }

  // this button is only shown, when coming from the levelEditing mode (i.e. when a new level was created)
  // in that case, there must be a quick way to go back to the level mode
  // DONE: add a nicer image instead of this ugly button
  //SimpleButton {
  ToggleGameModeButton {
    anchors.left: menuGoldWaveItems.right
    anchors.leftMargin: 5
    text: "Level\nMode"
    // only make visible when the game was started from levelEditing mode
    //visible: scene.state == "testLevelInLevelMode"
    visible: scene.cameFromLevelEditing
    onClicked: {
      scene.leaveGameToLevelEditingMode()
    }
  }

  BuyTowersHUD {
    id: buyTowersHUD
    anchors.right: hud.right
    // this gets set to visible in the PropertyChanges for the default state
    // so this is visible in the default state!
    visible: false
  }

  UpgradeTowerHUD {
    id: upgradeTowerHUD
    anchors.right: hud.right
    // in the default state, the upgrades will be invisible - they get visible when a tower was selected
    visible: false
  }

  // instead of loading this always, speed up app start by not loading the HUD when it is never needed (i.e. when multiple levels are not allowed)

  Loader {
//  LevelEditingHUD {
    id: levelEditingHUD
    source: allowMultipleLevels ? "LevelEditingHUD.qml" : ""

    anchors.left: menuGoldWaveItems.right
    anchors.right: hud.right

    height: hud.height

    // in the default state, the obstacles will be invisible - they get visible when in levelEditing mode
    visible: false
  }

  Loader {
//  ModifyEntityHUD {
    id: modifyEntityHUD
    source: allowMultipleLevels ? "ModifyEntityHUD.qml" : ""
    anchors.right: hud.right
    // in the default state, the upgrades will be invisible - they get visible when a tower was selected
    visible: false
  }



  /**
     * Gets called by Obstacle.
     */
  function entitySelected(entity) {
    // reset the internal state of the old selected entity, to stop blinking of the selected obstacle
    if(selectedEntity) {
      selectedEntity.entityState = "";
    }

    selectedEntity = entity;

    hud.state = "modifyEntity";
  }

  /**
     * Gets called by the towers when they are clicked. If they get clicked, the upgrade menu should be displayed.
     */
  function towerSelected(message) {
    // forward the update to the upgradeTowerHud
    upgradeTowerHUD.towerSelected(message);

  }

  states: [
    // the default state shows the weaponsRow, so the available towers that can be built
    State {
      name: "buildTowers"
      PropertyChanges { target: buyTowersHUD; visible: true}

      // reset the selectedTowerId when no upgrading is happening
      PropertyChanges { target: hud; selectedTowerId: ""}
    },
    State {
      name: "upgrading"      
//      PropertyChanges { target: repairUpgrade; visible: false} // the repairUpgrade should only be visible in state upgradingTurbine
      // when the upgrade state is set, the TowerRangeCircle should be visible - this has the nice effect that it gets invisible as soon as the state is switched to default!
      PropertyChanges { target: selectedTowerRange; visible: true }
      PropertyChanges { target: upgradeTowerHUD; visible: true }

    },    

    State {
      name: "levelEditing"      
      PropertyChanges { target: levelEditingHUD; visible: true}

      // this would work, but because selectedEntity may be undefined when entering the state, it would lead to an error! thus better use a StateChangeScript where a check if selectedEntity is valid can be used
      //PropertyChanges { target: selectedEntity ; state: ""}
      StateChangeScript {
        script: {
          if(selectedEntity)
            selectedEntity.entityState = "";
        }
      }

      // ATTENTION: restoreEntryValues must be set to false, otherwise selectedEntity would be reset to the initial property value (undefined) when leaving the state!
      PropertyChanges { target: hud; selectedEntity: null; restoreEntryValues: false}
      PropertyChanges { target: menuGoldWaveItems; state: "menuOnly"}
    },

    State {
      name: "modifyEntity"
      //extend: "levelEditing" // do NOT extend, otherwise selectedEntity would be set to null which is not desired!      
      PropertyChanges { target: modifyEntityHUD; visible: true}
      PropertyChanges { target: menuGoldWaveItems; state: "menuOnly"}
    }
  ]

  // for debugging-only:
  onStateChanged: console.debug("HUD: switched to state '", state, "'")
}

