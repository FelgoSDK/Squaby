import QtQuick 1.1
import VPlay 1.0

TowerBaseSprite {
  id: flamethrowerSprite
  spriteSheetSource: "../img/flamegun-sd.png"
  // this sets the width & height of the foundation and for the single sprite below
  defaultFrameWidth: 28
  defaultFrameHeight: 42

  // the flamethrower doesnt have a shooting animation! it uses a particle effect for shooting!
  SingleSpriteFromSpriteSheet {
    id: towerBase
    frameWidth: flamethrowerSprite.contentScaledFrameWidth
    frameHeight: flamethrowerSprite.contentScaledFrameHeight
    scale: flamethrowerSprite.towerBaseContentScaleFactor
    startFrameColumn: 3
    spriteSheetSource: flamethrowerSprite.spriteSheetSource

    // 0 degrees should point to the right, not to the bottom like the image currently is
    rotation: rotationOffset

    // set the same row for all sprites
    startFrameRow: flamethrowerSprite.startFrameRow
  }

}
