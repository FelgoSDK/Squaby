import QtQuick 2.0
import Felgo 3.0

TowerBaseSprite {
  id: turbineSprite

  // all upgrade states have the same base image
  spriteSheetSource: "../../assets/img/spritesheets/turbine/1-Turbine_base.png"
//  property string spriteSheetSourceTower: frameElement+"-Turbine_idle.png"
  property alias running: explodeSprite.running

  property alias sprite: explodeSprite

  scale: 0.875

  Item {
    rotation: turbineSprite.parent.rotation
    SpriteSequence {
      id: explodeSprite
      anchors.centerIn: parent

      defaultSource: "../../assets/img/spritesheets/turbine/turbine.png"

      // the animation should NOT run from the beginning! once jumpTo is called, it gets set to true automatically!
//      running: false

      Sprite {
        id: idle
        name: "idle"
        startFrameColumn: 1
        startFrameRow: frameElement
        frameCount: 1
        frameWidth: 32
        frameHeight: 32
//        frameRate: 0 // with a frameCount of 10 and a frameRate of 60 (= frameDuration of 25ms), the whole animation takes 167ms to complete
//        restoreOriginalFrame: false // stop with the last frame (the exploded state)
//        loop: false
        // setting a long frameDuration is a performance improvement, because the animation isnt switched internally then
        frameDuration: 100000
      }

      Sprite {
        id: explodeAnimation
        name: "explode"
        startFrameColumn: 2
        startFrameRow: frameElement
        frameCount: 4
        frameWidth: 32
        frameHeight: 32
        frameRate: 10 // with a frameCount of 10 and a frameRate of 60 (= frameDuration of 25ms), the whole animation takes 167ms to complete
//        restoreOriginalFrame: false // stop with the last frame (the exploded state)
//        loop: false
        to: { "explodeLastFrame": 1 }
      }

      Sprite {
        id: explodeLastFrameAnimation
        name: "explodeLastFrame"
        startFrameColumn: explodeAnimation.startFrameColumn+explodeAnimation.frameCount - 1
        startFrameRow: frameElement
        frameCount: 1
        frameWidth: 32
        frameHeight: 32
        frameRate: 100000
      }
    }

    SpriteSequence {
      id: whirlSprite      

      defaultSource: "../../assets/img/spritesheets/turbine/whirl.png"

      // by default, the turbine should not whirl and not be visible!
      visible: false

      // only run the animation when this sprite is visible (state=whirl)
      running: false

      x: -whirlSprite.width/2
      // the center of the sprite is not the whirl origin, so move this sprite by hand so it looks good
      // this offset is an arbitrary number, tested visually!
      y: -16

      Sprite {
        id: whirlAnimation
        name: "whirl"
//        frameNames: [
//          "wrl-Turbine_01.png",
//          "wrl-Turbine_02.png",
//          "wrl-Turbine_03.png"
//        ]

        frameCount: 3
        frameRate: 60
        frameWidth: 64
        frameHeight: 64
//        loop: true
      }

    }
  }

  function explode() {
    explodeSprite.jumpTo("explode");
  }

  function repair() {
    explodeSprite.jumpTo("idle");
  }

  states: [
    State {
      name: "whirl"
      PropertyChanges { target: whirlSprite; visible: true}
      PropertyChanges { target: whirlSprite; running: true}
    }
  ]
}
