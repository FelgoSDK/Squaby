import QtQuick 2.0
import Felgo 3.0

Item {
  id: towerBaseSprite
  // the logical 0° point is to the right, but the images are pointing downwards, so to let them look to the right as well they must be rotated 90° counterclockwise
  property int rotationOffset: -90

  // we do not want the base to rotate with the entity so we rotate against the parent(entity) rotation
  rotation: -parent.rotation+rotationOffset

  property string spriteSheetSource
  // update state (normal, rapid, area, super)
  property int frameElement: 1

  MultiResolutionImage {
//    filename: "../../assets/img/all-sd.json"
    source: towerBaseSprite.spriteSheetSource
    anchors.centerIn: parent
  }

  function setTowerImageFromEvent(event) {
    var rangeUpgrade;
    var shootDelayUpgrade;
    for(var i=0;i<event.upgrades.length;i++) {
      var upgrade = event.upgrades[i];
      if(upgrade.type === "range")
        rangeUpgrade = upgrade;
      else if(upgrade.type === "shootDelay" || upgrade.type === "damagePerSecond")
        shootDelayUpgrade = upgrade;
    }

    if(!rangeUpgrade || !shootDelayUpgrade) {
      console.log("WARNING: one of the necessary upgrades range or shootDelay not found, this should never happen!");
      return;
    }

    if(shootDelayUpgrade.currentPlayerUpgradeLevel === 1 && rangeUpgrade.currentPlayerUpgradeLevel === 1) {
      frameElement = 4;
    } else if(rangeUpgrade.currentPlayerUpgradeLevel === 1) {
      frameElement = 3;
    } else if(shootDelayUpgrade.currentPlayerUpgradeLevel === 1) {
      frameElement = 2;
    } else {
      frameElement = 1;
    }
  }
}
