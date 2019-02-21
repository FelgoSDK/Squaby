import QtQuick 2.0
import Felgo 3.0

TowerBaseSprite {
  id: teslaSprite

  spriteSheetSource: "tesla_basement_"+frameElement+".png"
  property string spriteSheetSourceTower: "tesla_turret_"+frameElement+".png"

  scale: 0.875

  Item {
    rotation: teslaSprite.parent.rotation
    SingleSpriteFromFile {
      filename: "../../assets/img/all-sd.json"
      source: spriteSheetSourceTower
    }
  }
}
