import QtQuick 2.0
import VPlay 2.0

TowerBaseSprite {
  id: taserSprite

  spriteSheetSource: "taser_basement_"+frameElement+".png"
  property string spriteSheetSourceTower: "taser_turret_"+frameElement+".png"

  scale: 0.875

  Item {
    rotation: taserSprite.parent.rotation
    SingleSpriteFromFile {
      filename: "../../assets/img/all-sd.json"
      source: spriteSheetSourceTower
    }
  }
}
