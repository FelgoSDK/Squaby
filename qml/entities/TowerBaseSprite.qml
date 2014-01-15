import QtQuick 1.1
import VPlay 1.0

Item {
  id: towerBaseSprite
  // the logical 0° point is to the right, but the images are pointing downwards, so to let them look to the right as well they must be rotated 90° counterclockwise
  property int rotationOffset: -90

  // this will be set in every derived tower
  property alias spriteSheetSource: towerBase.spriteSheetSource
  property alias defaultFrameWidth: towerBase.frameWidth
  property alias defaultFrameHeight: towerBase.frameHeight

  property alias startFrameRow: towerBase.startFrameRow

  // the size might be important to be defined (2 grids=32), otherwise the MouseArea doesnt know where to be filled
  // however, because the child sprites hava a transform assigned, the anchoring for it does not work!
  // also, the width&height is not the width of the real sprites (which are higher because of the fire animation!), but for MouseArea only 2 grids should be defined
  // thus it is better to let this be set in the calling tower qml class!
  // but it can be used here as well, because e.g. for the turbine the size is important because of the size of the HealthBar!
  width: contentScaledFrameWidth * towerBaseContentScaleFactor
  height: contentScaledFrameHeight * towerBaseContentScaleFactor
  //    width: 2*scene.gridSize
  //    height: 2*scene.gridSize


  Component.onCompleted: {
    fileChooser.filename = towerBaseSprite.spriteSheetSource
  }

  ContentScaleFileChooser {
    id: fileChooser

    // this would cause a binding loop! thus set it from onCompleted above!
    //filename: towerBaseSprite.spriteSheetSource

    onModifiedFilenameChanged: {
      // overwrite the spriteSheetSource with this one
      towerBaseSprite.spriteSheetSource = modifiedFilename
      //whirlSprite.spriteSheetSource = modifiedFilename

      // this must be set, otherwise the rotation would not be centered
      //turbineSprite.scale = internalScaleFactorForMultiResImages
      //whirlSprite.scale = internalScaleFactorForMultiResImages

      // make the frames bigger - internalScaleFactor is 1, 0.5 and 0.25
      towerBaseSprite.contentScaledFrameWidth = towerBaseSprite.defaultFrameWidth/internalScaleFactorForMultiResImages
      towerBaseSprite.contentScaledFrameHeight = towerBaseSprite.defaultFrameHeight/internalScaleFactorForMultiResImages

      towerBaseSprite.towerBaseContentScaleFactor = internalScaleFactorForMultiResImages

      towerBaseSprite.defaultFrameWidth = towerBaseSprite.contentScaledFrameWidth
      towerBaseSprite.defaultFrameHeight = towerBaseSprite.contentScaledFrameHeight
    }
  }

  // gets set in onModifiedFilenameChanged
  property int contentScaledFrameWidth
  property int contentScaledFrameHeight
  property real towerBaseContentScaleFactor


  SingleSpriteFromSpriteSheet {

    // it must be on top of the path (so the all.png spritesheet with z=0)!
    // the spriteBatchNodeZ is the z value of the SpriteBatchNode, to be able to set an order in the SpriteBatchContainer!
    // this is used by the SquabySprite and has no other effect than in cocos!
    // set it to 1, because z=2 are the squabies and z=0 is the path
    // it is enough to set this here in the TowerBaseSprite and not to every sprite of the derived towers, because the z value set here applies to the whole sprite sheet!
    property int spriteBatchNodeZ: 1

    id: towerBase
    frameWidth: 28
    frameHeight: 28
    startFrameColumn: 2
    scale: towerBaseContentScaleFactor
    //spriteSheetSource: "../img/nailgun.png" // will be overwritten by every tower

    // do NOT rotate the nailgun with the entity!
    rotation: -parent.rotation+rotationOffset
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
      startFrameRow = 4;
    } else if(rangeUpgrade.currentPlayerUpgradeLevel === 1) {
      startFrameRow = 3;
    } else if(shootDelayUpgrade.currentPlayerUpgradeLevel === 1) {
      startFrameRow = 2;
    } else
      startFrameRow = 1;

  }
}
