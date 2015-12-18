// only in qtquick 1.1 implicitWidth is known!
import QtQuick 2.0
import VPlay 2.0

Item {
  id: hud
  // for testing if the BuildEntityButton entities were really built
  //opacity: 0.2


  // gets set from Obstacle when an obstacle is selected - but as the name implies this could be set to any entityId
  // if a change of this id is detected, the hud state will display the sell button to destroy the obstacle (state modifyEntity)
  //property string selectedEntityId: ""
  property variant selectedEntity

  // this gets set when a tower is selected - it is needed for the turbine when it is out of lives, and if the tower is currently selected, then the hud should be updated
  property string selectedTowerId: ""
  property alias levelEditingHud: levelEditingHUD

  // this is emitted when the menu button was clicked
  signal menuButtonClicked

  // start in the buildTowers state by default
  state: "buildTowers"

  // this will be set to visible and positioned to the selected tower when hud.towerSelected() is called, or from BuyTowerButton when the new entity gets moved
  TowerRangeCircle {
    id: selectedTowerRange

    // the size is set based on the colliderSize automatically

    // should be invisible at beginning, only gets visible when a tower is selected
    visible: false

    onVisibleChanged: {
      if(visible)
        tutorials.nextAction("towerRange", "visible")
      else
        tutorials.nextAction("towerRange", "invisible")
    }

    // a transform is needed here, because this item gets positioned by setting the center position, so the transformOrigin is in the center
    transform: [
      // mention that selectedTowerRange. is needed, otherwise they are undefined!
      // hud.y must be extracted, because selectedTowerRange gets positioned based on scene origin, and hud is shifted down by this factor!
      Translate { x: -selectedTowerRange.width/2; y: -selectedTowerRange.height/2 - hud.y}
    ]
  }

  SingleSquabySprite {
    id: menuBackground
    source: "../../../assets/img/menu_labels/menuBackground.png"

    visible: opacity > 0

    /*Behavior on opacity {
      PropertyAnimation {
        duration: 600
      }
    }*/
  }

  // instead of loading this always, speed up app start by not loading the HUD when it is never needed (i.e. when multiple levels are not allowed)
  LevelEditingHUD {
    id: levelEditingHUD

    anchors.left: parent.left
    anchors.right: parent.right

    height: hud.height

    // in the default state, the obstacles will be invisible - they get visible when in levelEditing mode
    visible: false
  }

  function changeToBuildMenu() {
    menuBackground.opacity = 1
    if(itemEditor.visible) {
      itemEditor.slideOut()
    }
  }

  function changeFromBuildMenu() {
    menuBackground.opacity = 0
    if(!itemEditor.visible) {
      itemEditor.slideIn()
    }
  }


  Item {
    id: menuButtonItem
      // this item is only needed, because the MouseArea must not be a child of Row, because anchoring is used there
      width: menuButton.width
      height: menuButton.height

      //Image { // use a res-independent spritesheet instead
      SingleSquabySprite {
          id: menuButton
          source: "../../../assets/img/menu_labels/menuIconMenuButton.png"
      }
      // the MouseArea must not be a child of SingleSquabySprite, as all the children get overwritten there!
      MouseArea {
          // the anchors.fill: menuButton causes the following QML error: "QML Row: Cannot specify left, right, horizontalCenter, fill or centerIn anchors for items inside Row"
          // it does work though, so leave it
          anchors.fill: menuButton
          onClicked: {
              menuButtonClicked();
          }
      }
  }

  // comment the real SquabyPerformanceTestOptions component at the moment as a performance improvement to speed up loading time
  SquabyPerformanceTestOptions {
    id: perfmenuButtonItem
    anchors.right: hud.right
    visible: developerBuild && scene.state !== "levelEditing"
  }

  Item {
    id: anchorItem
    anchors.right: developerBuild ? perfmenuButtonItem.left : hud.right
  }

  MenuGoldWaveItems {
    id: menuGoldWaveItems
    anchors.left: menuButtonItem.right
  }

  BuyTowersHUD {
    id: buyTowersHUD
    height: parent.height
    anchors.right: anchorItem.left
    // this gets set to visible in the PropertyChanges for the default state
    // so this is visible in the default state!
    visible: false
  }

  UpgradeTowerHUD {
    id: upgradeTowerHUD
    anchors.right: anchorItem.left
    // in the default state, the upgrades will be invisible - they get visible when a tower was selected
    visible: false
  }

  Loader {
    id: modifyEntityHUD
    source: "ModifyEntityHUD.qml"
    anchors.right: anchorItem.left
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
    tutorials.nextAction(message.entityType,"clicked",message.towerPosition)
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

      StateChangeScript {
        script: {
          // reset state.e.g. when user is in build paths mode it should exit this state so the pathmode is not enabled/visible anymore
          levelEditingHUD.state = ""
          changeToBuildMenu()
        }
      }
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
      PropertyChanges { target: menuButtonItem; visible: false}

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
      PropertyChanges { target: menuGoldWaveItems;  visible: false}
    },

    State {
      name: "modifyEntity"
      //extend: "levelEditing" // do NOT extend, otherwise selectedEntity would be set to null which is not desired!      
      PropertyChanges { target: modifyEntityHUD; visible: true}
      PropertyChanges { target: menuGoldWaveItems; visible: false}
      PropertyChanges { target: menuButtonItem; visible: false}
    }
  ]

  // for debugging-only:
  onStateChanged: console.debug("HUD: switched to state '", state, "'")
}

