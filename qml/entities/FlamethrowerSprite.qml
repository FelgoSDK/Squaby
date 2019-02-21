import QtQuick 2.0
import Felgo 3.0

TowerBaseSprite {
  id: flamethrowerSprite

  // all upgrade states have the same base image
  spriteSheetSource: "../../assets/img/towers/flamethrower/flamegun_basement_1.png"
  property string spriteSheetSourceTurret: "../../assets/img/towers/flamethrower/flamegun_turret_"+frameElement+".png"

  // smaller grafics so that the sprites do not overlap because this problem can not be solved with z values because both parts are in the same entity which has lower/higher z value than a other tower
  scale: 0.875

  Item {
    // the main tower is rotate against the rotation of the whole entity, because the base should not rotate. Therefore we apply the entity rotation here so that the gun rotates
    rotation: flamethrowerSprite.parent.rotation
    MultiResolutionImage {
      translateToCenterAnchor: true
//      filename: "../../assets/img/all-sd.json"
      source: spriteSheetSourceTurret
    }
  }
}
