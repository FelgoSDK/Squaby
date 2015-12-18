import QtQuick 2.0
import VPlay 2.0

TowerBaseSprite {
  id: nailgunSprite

  // all upgrade states have the same base image
  spriteSheetSource: "../../assets/img/spritesheets/nailgun/1-base.png"
  property alias running: spriteSequence.running

  scale: 0.875

  Item {
//    rotation: nailgunSprite.parent.rotation
    // could also be an AnimatedSpriteVPlay, because there is only 1 animation
    SpriteSequenceVPlay {
      id: spriteSequence
      rotation: nailgunSprite.parent.rotation

      anchors.centerIn: parent

//      filename: "../../assets/img/all-sd.json"
      defaultSource: "../../assets/img/spritesheets/nailgun/nailgun.png"

      // the animation should NOT run from the beginning! once jumpTo is called, it gets set to true automatically!
      // dont set running to false now, this is changed in onUsedFromPool()
//      running: false

      SpriteVPlay {
        name: "idle"
        startFrameColumn: 1
        startFrameRow: frameElement
        frameWidth: 32
        frameHeight: 64
        // setting a long frameDuration is a performance improvement, because the animation isnt switched internally then
        frameDuration: 100000
      }

      SpriteVPlay {
        id: shootAnimation
        name: "shoot"
        frameWidth: 32
        frameHeight: 64

        frameCount: 10
        startFrameColumn: 1
        startFrameRow: frameElement
        frameRate: 60 // with a frameCount of 10 and a frameRate of 40 (= frameDuration of 25ms), the whole animation takes 250ms to complete
        to: {"idle": 1}
      }
    }
  }

  function playShootAnimation() {
    // jumpTo automatically sets the running property of SpriteSequence to true
    spriteSequence.jumpTo("shoot");
  }
}
