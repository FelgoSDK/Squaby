import QtQuick 1.1
import VPlay 1.0


SpriteSequence {    
    // if goalSprite is not set, the first Sprite is used
    id: squabySprite
    goalSprite: "walk"

    // ATTENTION: initialize the spriteSheetSource with an empty string, because switching of spriteSehetSource is not supported at the moment
    //spriteSheetSource: "../img/squafurY.png"

    rotation: -90

    // by default, use the variationType of the parent
    property string variationType: parent.variationType

    // changing the variationType at runtime is not supported (this would lead to a change of the used spritesheet in SpriteBatchNode, so do not support changing after creation!
//    onVariationTypeChanged: {
//        setSpriteSheetSourceBasedOnVariationType();
//    }

    Component.onCompleted: {
        setSpriteSheetSourceBasedOnVariationType();
    }

    function setSpriteSheetSourceBasedOnVariationType() {

        // ATTENTION: this is a costly operation! it takes mean time 23ms for this function!

        console.log("variationType property used for image source: " + variationType);

      var tempSpriteSheetSource;

        if(variationType === "squabyYellow")
            tempSpriteSheetSource = "../img/squ1-sd.png"
        else if(variationType === "squabyOrange")
            tempSpriteSheetSource = "../img/squ2-sd.png"
        else if(variationType === "squabyRed")
            tempSpriteSheetSource = "../img/squ3-sd.png"        
        else if(variationType === "squabyGreen")
            tempSpriteSheetSource = "../img/squ4-sd.png"
        // the "blue" one acutally is light grey, the grey one is dark grey
        else if(variationType === "squabyBlue")
            tempSpriteSheetSource = "../img/squ5-sd.png"
        else if(variationType === "squabyGrey")
            tempSpriteSheetSource = "../img/squ6-sd.png"
        else
            console.log("WARNING: undefined variationType, not known which sprite to use! " + variationType);

        //fileChooser.modifyFilenameBasedOnSceneScale(tempSpriteSheetSource)
        fileChooser.filename = tempSpriteSheetSource
    }

    //transformOrigin: Item.TopLeft - doesnt help
    // the rotation is wrong!!! would be the same issue with SingleSpriteFromFile probably!!!
    //translateToCenterAnchor: false
    //__internalScaleFactorForMultiResImages: 0.5

    ContentScaleFileChooser {
      id: fileChooser

      //filename: squabySprite.spriteSheetSource

      onModifiedFilenameChanged: {
        squabySprite.spriteSheetSource = modifiedFilename

        // this must be set, otherwise the rotation would not be centered
        squabySprite.scale = internalScaleFactorForMultiResImages

        //squabySprite.width = squabySprite.width*internalScaleFactorForMultiResImages
        //squabySprite.height = squabySprite.height*internalScaleFactorForMultiResImages

        // make the frames bigger - internalScaleFactor is 1, 0.5 and 0.25
        squabySprite.contentScaledFrameWidth = 32/internalScaleFactorForMultiResImages
        squabySprite.contentScaledFrameHeight = 32/internalScaleFactorForMultiResImages

        squabyContentScaleFactor = internalScaleFactorForMultiResImages

      }
    }

    // gets set in onModifiedFilenameChanged
    property int contentScaledFrameWidth//: 32*2
    property int contentScaledFrameHeight//: 32*2

    // this is used by the healthbar sprite
    property real squabyContentScaleFactor



    Sprite {
        name: "walk"
        frameWidth: contentScaledFrameWidth
        frameHeight: contentScaledFrameHeight
        frameCount: 4
        startFrameColumn: 2
        frameRate: 20
        // this must not be set to true, because it gets set to true by the SpriteSequence class!
        //running: true
        // optionally provide a name to which animation it should be changed after this is finished
        //to: "whirl"
    }
    Sprite {
        name: "whirl"
        frameWidth: contentScaledFrameWidth
        frameHeight: contentScaledFrameHeight
        frameCount: 2
        startFrameColumn: 14
        frameRate: 20
        //loop: true // loop must be set to true explicitly if to would be set, otherwise the Sprite wont loop when a to-property is set!
        // for this squabySprite, jumpTo("die") is called from Squaby.qml, so no to-property is useful!
        //to: "die"
    }
    // the jump animation could be used when the squaby jumps under the bed - it is not used atm, because it is not good visible
    Sprite {
        name: "jump"
        frameWidth: contentScaledFrameWidth
        frameHeight: contentScaledFrameHeight
        frameCount: 4
        startFrameColumn: 5
        frameRate: 10
        // for testing the loop and repeatCount combination, this animation should be played 5 times
//        loop: false
//        repeatCount: 5
    }
    Sprite {
        name: "die"
        frameWidth: contentScaledFrameWidth
        frameHeight: contentScaledFrameHeight
        frameCount: 4
        startFrameColumn: 9
        loop: false
        frameRate: 10
        restoreOriginalFrame: false
        //to: "walk" // just for testing, after the die animation the squaby should get destroyed
        // if no repeatCount is specified, it defaults to a single repetition!
        //repeatCount: 2 // just for testing, should be 1
    }


}


////// this may be used to test performance without sprites, so without animation timers and clipping
//Item {
//    width: 32
//    height: 32
//    x:-width/2
//    y:-height/2
//}

// this tests the performance impact of timers - if a SingleSpriteFromSpriteSheet is used, the timer's running flag is set to false
//SingleSpriteFromSpriteSheet {
//    frameWidth: 32
//    frameHeight: 32
//    startFrameColumn: 3
//    spriteSheetSource: "../img/squafurY.png"
//}
