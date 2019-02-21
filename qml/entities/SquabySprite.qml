import QtQuick 2.0
import Felgo 3.0


Item {
  id: rootSprite
  rotation: -90

  property alias squabySprite: squabySprite
  signal animationFinished

  SpriteSequence {
    // if goalSprite is not set, the first Sprite is used
    id: squabySprite
    goalSprite: "walk"

    anchors.centerIn: parent

    // running gets set to true by default
    // we set it to false in Squaby.onMovedToPool() and enable it in onUsedFromPool

    spriteSheetSource: "../../assets/img/spritesheets/squ" + squabySprite.variationTypeNumber + ".png"

    onCurrentSpriteObjectChanged: {
      if(currentSpriteObject === dieAnimationFinished) {
        rootSprite.animationFinished()
      }
    }
    // animationFinished doesnt exist any more, instead detect a change of animations with currentSpriteObjectChanged
//    onAnimationFinished: rootSprite.animationFinished()

    // by default, use the variationType of the parent
    property string variationType: parent.parent.variationType
    property int variationTypeNumber: 1
    onVariationTypeChanged: {
      if(variationType === "squabyYellow")
        variationTypeNumber = 1
      else if(variationType === "squabyOrange")
        variationTypeNumber = 2
      else if(variationType === "squabyRed")
        variationTypeNumber = 3
      else if(variationType === "squabyGreen")
        variationTypeNumber = 4
      else if(variationType === "squabyBlue")
        variationTypeNumber = 5
      else if(variationType === "squabyGrey")
        variationTypeNumber = 6
    }

    Sprite {
      name: "walk"
      frameWidth: 32
      frameHeight: 32
      frameCount: 4
      startFrameColumn: 1
      frameRate: 20
//      frameNames: [
//        "squ"+squabySprite.variationTypeNumber+"-walk-1.png",
//        "squ"+squabySprite.variationTypeNumber+"-walk-2.png",
//        "squ"+squabySprite.variationTypeNumber+"-walk-3.png",
//        "squ"+squabySprite.variationTypeNumber+"-walk-4.png",
//      ]
    }
    Sprite {
      name: "whirl"
      frameWidth: 32
      frameHeight: 32
      startFrameColumn: 14
//      frameNames: [
//        "squ"+squabySprite.variationTypeNumber+"-whirl-1.png",
//        "squ"+squabySprite.variationTypeNumber+"-whirl-2.png",
//        "squ"+squabySprite.variationTypeNumber+"-whirl-3.png",
//        "squ"+squabySprite.variationTypeNumber+"-whirl-4.png",
//      ]
      frameCount: 2
      frameRate: 20
    }
    // the jump animation could be used when the squaby jumps under the bed - it is not used atm, because it is not good visible
    Sprite {
      name: "jump"
      frameWidth: 32
      frameHeight: 32
      startFrameColumn: 5
//      frameNames: [
//        "squ"+squabySprite.variationTypeNumber+"-jump-1.png",
//        "squ"+squabySprite.variationTypeNumber+"-jump-2.png",
//        "squ"+squabySprite.variationTypeNumber+"-jump-3.png",
//        "squ"+squabySprite.variationTypeNumber+"-jump-4.png",
//      ]
      frameCount: 4
      frameRate: 10
    }
    // this is Felgo 1 code - the restoreOriginalFrame property is not supported yet
//    Sprite {
//      name: "die"
//      frameNames: [
//        "squ"+squabySprite.variationTypeNumber+"-die-1.png",
//        "squ"+squabySprite.variationTypeNumber+"-die-2.png",
//        "squ"+squabySprite.variationTypeNumber+"-die-3.png",
//        "squ"+squabySprite.variationTypeNumber+"-die-4.png",
//      ]
//      loop: false
//      frameRate: 10
//      restoreOriginalFrame: false
//    }

    Sprite {
      name: "die"
      frameWidth: 32
      frameHeight: 32
      frameCount: 3
      startFrameColumn: 10
      frameRate: 10
      // play die animation once and then stay at the last frame
      to: {"dieLastFrame":1}
    }
    Sprite {
      // this is required to be able to detect the end of the die animation
      id: dieAnimationFinished
      name: "dieLastFrame"
      startFrameColumn: 12
      frameWidth: 32
      frameHeight: 32
      duration: 10000 // performance saver
      // frameCount is set to 1 by default
      to: {"dieLastFrame":1}
    }

  }
}
