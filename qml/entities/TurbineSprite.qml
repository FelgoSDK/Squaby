import QtQuick 1.1
import VPlay 1.0

TowerBaseSprite {
  id: turbineSprite
  property alias running: explodeSprite.running

  spriteSheetSource: "../img/turbine-sd.png"
  defaultFrameWidth: 28
  defaultFrameHeight: 28


  SpriteSequence {
    id: explodeSprite
    // if goalSprite is not set, the first Sprite is used

    spriteSheetSource: turbineSprite.spriteSheetSource

    // 0 degrees should point to the right, not to the bottom like the image currently is
    rotation: rotationOffset

    // must be initialized with false, by default it is running!
    running: false

    Sprite {
      id: explodeAnimation
      name: "explode"
      frameWidth: turbineSprite.contentScaledFrameWidth
      frameHeight: turbineSprite.contentScaledFrameHeight
      scale: turbineSprite.towerBaseContentScaleFactor
      frameCount: 5
      startFrameColumn: 3
      frameRate: 60 // with a frameCount of 10 and a frameRate of 40 (= frameDuration of 25ms), the whole animation takes 250ms to complete
      loop: false
      restoreOriginalFrame: false // stop with the last frame (the exploded state)

      // set the same row for all sprites
      startFrameRow: turbineSprite.startFrameRow

      // this must not be set to true, because it gets set to true by the SpriteSequence class when the nailgun should fire (and not from the start) - default is false, which is correct here
      //running: true
    }

  }
  SpriteSequence {
    id: whirlSprite
    // by default, the turbine should not whirl and not be visible!
    visible: false

    spriteSheetSource: turbineSprite.spriteSheetSource

    // 0 degrees should point to the right, not to the bottom like the image currently is
    rotation: rotationOffset

    // only run the animation when this sprite is visible (state=whirl)
    //running: visible
    running: false


    // the center of the sprite is not the whirl origin, so move this sprite by hand so it looks good
    // this offset is an arbitrary number, tested visually!
    x: - turbineSprite.width

    Sprite {
      id: whirlAnimation
      name: "whirl"
      frameY: turbineSprite.contentScaledFrameHeight * 4 // the animation starts below the differnt turbine upgrade states (4rows a 28px high)
      frameWidth: turbineSprite.contentScaledFrameWidth * 2
      frameHeight: turbineSprite.contentScaledFrameHeight * 2
      scale: turbineSprite.towerBaseContentScaleFactor
      frameCount: 3
      frameRate: 60
      loop: true

      // this must not be set to true, because it gets set to true by the SpriteSequence class when the nailgun should fire (and not from the start) - default is false, which is correct here
      //running: true
    }

  }

  function explode() {
    // there is no difference now in calling jumpTo or running=true! unless that running=true doesnt lead to a jumpTo if the spriteImage is already running!
    //explodeSprite.jumpTo("explode");
    explodeSprite.running = true;
  }

  function repair() {
    console.debug("TurbineSprite: repair()");
    // reset the image to the fully working turbine not the destroyed endStateFrame
    // if __frame gets set to 0, the startFrameCol frame will be used!
    // setting __frame is not supported by CocosWrapper, thus use setFrameNumber below!
    //explodeAnimation.__frame = 0;

    // is also received by cocos
    explodeAnimation.setFrameNumber(0);
  }

  states: [
    //        State {
    //            // this is the default state
    //            name: ""
    //        },
    State {
      name: "whirl"
      PropertyChanges { target: whirlSprite; visible: true}
      PropertyChanges { target: whirlSprite; running: true}
    }
  ]
}
