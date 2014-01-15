import QtQuick 1.1
import VPlay 1.0

TowerBaseSprite {
    id: nailgunSprite
    property alias running: fireSprite.running    

    spriteSheetSource: "../img/nailgun-sd.png"
    defaultFrameWidth: 28
    defaultFrameHeight: 56

    SpriteSequence {
        id: fireSprite
        // if goalSprite is not set, the first Sprite is used

        spriteSheetSource: nailgunSprite.spriteSheetSource

        // 0 degrees should point to the right, not to the bottom like the image currently is
        rotation: rotationOffset

        // the animation should NOT run from the beginning! once jumpTo is called, it gets set to true automatically!
        running: false

        // the same effect is reached by setting translateToCenterAnchor, or setting x&y manually
        translateToCenterAnchor: false

        x: -width/2
        y: -height/2

        // gets set in onModifiedFilenameChanged
        property int contentScaledFrameWidth
        property int contentScaledFrameHeight

        Sprite {
            id: shootAnimation
            name: "shoot"
            frameWidth: nailgunSprite.contentScaledFrameWidth
            frameHeight: nailgunSprite.contentScaledFrameHeight
            scale: nailgunSprite.towerBaseContentScaleFactor
            frameCount: 10
            startFrameColumn: 3
            frameRate: 60 // with a frameCount of 10 and a frameRate of 60 (= frameDuration of 25ms), the whole animation takes 167ms to complete
            loop: false

            // set the same row for all sprites
            startFrameRow: nailgunSprite.startFrameRow
        }

    }

    function playShootAnimation() {
        // jumpTo automatically sets the running property of SpriteSequence to true
        fireSprite.jumpTo("shoot");
    }
}
