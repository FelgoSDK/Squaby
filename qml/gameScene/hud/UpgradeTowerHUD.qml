import QtQuick 2.0
import VPlay 2.0

Row {
  id: upgradeTowerHUD

  // this is only used for the turbine
  UpgradeWeapon {
    id: repairUpgrade
    upgradeType: "repair"
    source: "../../../assets/img/menu_labels/repair.png"
    onClicked: {
      towerUpgradeEffect.play();
    }
    // this is invisible in the default state! must be in upgradingTower state so it gets visible!
    visible: false
  }

  UpgradeWeapon {
    id: rangeUpgrade
    upgradeType: "range"
    onClicked: {
      towerUpgradeEffect.play();
    }
  }

  UpgradeWeapon {
    id: shootDelayUpgrade
    upgradeType: "shootDelay"
    onClicked: {
      towerUpgradeEffect.play();
    }
  }
  // source and price get set for the upgrades by code when a selected_tower event is received
  // the source gets set in the UpgradeWeapon itself
  UpgradeWeapon {
    id: sellButton
    source: "../../../assets/img/menu_labels/sell.png"
    upgradeType: "sell"

    // the sell button is not bound to the default behavior (only get available when the player gold is higher than the cost)
    // but it should always be visible!
    affordable: true
    // reset the hud to the buy-state after the tower was sold
    onClicked: {
      hud.state="buildTowers"
      // the selectedTowerRange has the same x&y as the sold tower, so this can be used for selling
      // it would be better though if towerSold would be called at receiving an EntityDestroyedEvent
      // the scaling of the scene does not affect the x and y coordinate, because it is set as a transform, so no division by scene.xScaleFactor is needed!
      // scene.Logic.towerSold does NOT work, no access to scripts in ohter files!
      // this should not be called any more directly, because it gets called when an EntityDestroyedEvent is received in main.qml file
      //scene.towerSold(selectedTowerRange.x, selectedTowerRange.y);

      towerSellEffect.play();
    }

    SoundEffectVPlay {
      id: towerSellEffect
      source: "../../../assets/snd/towerDestruct.wav"
    }
  }

  SoundEffectVPlay {
    id: towerUpgradeEffect
    source: "../../../assets/snd/towerUpgrade.wav"
  }

  function towerSelected(message) {


    var towerId = message.entityId;
    var towerType = message.entityType;


    // the upgrade type for 2nd upgrade changes depending on the type
    if(towerType === "nailgun" || towerType === "turbine") {
      shootDelayUpgrade.upgradeType = "shootDelay";
    } else if(towerType === "flamethrower") {
      shootDelayUpgrade.upgradeType = "damagePerSecond";
    } else if(towerType === "taser") {
      shootDelayUpgrade.upgradeType = "damagePerSecond";
    } else if(towerType === "tesla") {
      shootDelayUpgrade.upgradeType = "damagePerSecond";
    }

    rangeUpgrade.setUpgradeButtonFromEvent(message);
    shootDelayUpgrade.setUpgradeButtonFromEvent(message);


    // set this, so at sending the sell command it is known which tower is affected
    sellButton.selectedTowerId = towerId;
    // by setting the cost to negative, the gold will be added to the player's gold
    // however, the saleRevenue gets added in TowerBase to the player gold
    // but the pricetag must be modified, so set the cost of sellButton manually here
    sellButton.cost = -message.saleRevenue;

    selectedTowerRange.x = message.towerPosition.x;
    selectedTowerRange.y = message.towerPosition.y;
    selectedTowerRange.colliderRadius = message.colliderRadius;
    // when selected from an already built tower, the green (allowed) range should be displayed
    selectedTowerRange.isAllowedToBuild = true;

    if(towerType === "turbine") {
      // only call this here, otherwise the repair-upgrade would not be contained in the message, and the repairUpgrade button only gets visible if state is upgradingTurbine anyway
      repairUpgrade.setUpgradeButtonFromEvent(message);
      upgradeTowerHUD.state = "upgradingTurbine";
    } else {
      upgradeTowerHUD.state = "";
    }

    hud.state = "upgrading";

    // set this after the hud-change, otherwise the selectedTowerId would always be the default undefined value!
    selectedTowerId = towerId;

    console.debug("HUD: switched hud to state", hud.state, ", selectedTowerId:", selectedTowerId);
  }

  states: [
      State {
      name: "upgradingTurbine"

      PropertyChanges { target: repairUpgrade; visible: true}
    }
  ]
} // end of UpgradeButtons Row
