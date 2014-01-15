import QtQuick 1.0
import VPlay 1.0
// needed for SingleSpriteFromSpriteSheet
import VPlay 1.0

// a healthbar should never get rotated with the entity! so at first a rotation is needed, then move it to the desired position
// thus an additional Item is needed, because otherwise at first the transform is applied, and afterwards the movement
// TODO: instead of applying the reverse rotation of the parent, this item should be implemented in C++ and set the QGraphicsItem flag ItemIgnoresTransformations!
//Item {
// the VisualItemPropertyObserver uses batched position updating, so prefer it over the normal item
VisualItemPropertyObserver {
/* use this for debugging visually where the rectangle is:
  it should always be in the center unrotated when ignoreParentRotation is set to true
Rectangle {
    color: "grey"
    opacity: 0.8*/

    id:healthbar

    // should be set to the same file like the contained squaby, otherwise z-ordering issues!
    // if it is not set (e.g. for turbine or for hud healthbar), the rectangles are used!
    // there is a problem when a spritesheet is used, because e.g. at the wave item there is a healthbar, and if it would be added there as a sprite, the order of the spriteBatchNode would be wrong!
    // so the alternative would be to only use a rectangle there, but not for the entities!
    property url spriteSheetSource: ""//: "img/squafurY.png"
    // if this is set explicitly by the user, it is prevented to load the rectangle version first before the spriteSheet gets set, but loads the spriteSheet version from the beginning, regardless if the source is empty or not
    property bool useSpriteVersion: false

    // initialize the health bar with 100% alive, so all is green
    // this will vary between 0 and 1
    property real percent: 1.0
    // guarantee that it is always in the range 0...1
    onPercentChanged: {
      //console.debug("Healthbar: percent changed to", percent)

      // NOTE: this must not be set here, otherwise the binding with the HealthComponent would be removed!!!
      // it must be guaranteed from HealthComponent that this is not between 0 and 1
      // alternatively, another internal property (internalPercent) could be created, which gets clipped to 0|1 range
//        if(percent<0)
//            percent=0;
//        else if(percent>1)
//            percent=1;
    }

    // instead of calculating the position with transforms, use nested items!
    // the rotation will be reverted by applying the reverse rotation - the child item nonRotatedItem can then be positioned normally without the parent rotation!
    //property bool ignoreParentRotation: true
    // needs not to be created newly, as the property exists for VisualItemPropertyObserver
    // when this flag is set, setting a rotation is useless as the rotation value gets overwritten every time the parent rotation changes!
    // as further performance improvement, only set ignoreParentRotation to true (thus connect the rotationChanged signal of parent in C++) when this item is visible!
    ignoreParentRotation: visible

    // alternatively, a binding with a when-condition could be used, but that should not make a performance difference!
    // this would be fastest (test binding difference on mobile devices)! - the binding difference is not big, the limiting factor here is that it is called that often!
    //rotation: -parent.rotation // by overwriting the rotation in the calling class, this may be overwritten
    //rotation: (visible && ignoreParentRotation) ? -parent.rotation : 0
//    Binding {
//        target: healthbar
//        property: "rotation"
//        value: -healthbar.parent.rotation
//        when: ignoreParentRotation
//    }

    property alias absoluteX: nonRotatedItem.x
    property alias absoluteY: nonRotatedItem.y

    // there must be a 1 pixel wide border (thus the image is 3x3 pixels), otherwise the texture will look blurred
    // these must get set explicitly from outside, when useSpriteVersion is enabled!
    // NOTE: no alias possible to greenHealthbarSprite & redHealthbarSprite, because they are defined within a Component element!
    property int alivePixelX
    property int alivePixelY
    property int diedPixelX
    property int diedPixelY

    // ATTENTION: this is necessary, otherwise the reverted rotation would be applied in the center leading to wrong results!
    // this must be provided when width or height are not 0, to get the expected reverting effect with ignoreParentRotation set to true!
    transformOrigin: Item.TopLeft


    Loader {
        id: nonRotatedItem

        // width & height need not be set explicitly, they get set to the source component!

        // if a spriteSheetSource was set explicitly, the sprite version will be used
        // only use the spritesheet on cocos renderer! so not on Meego or Symbian, as performance is worse there with clipped images!
        // a check of spriteSheetSource.toString() is a slow process! 1 binding needs 27ms on Windows, which is far too long!
        // think of a faster approach for this binding!
        sourceComponent: (system.cocosRenderer && (useSpriteVersion || spriteSheetSource!="")) ? spriteBarsComponent : rectangleBarsComponent

        // for testing individually
        //sourceComponent: rectangleBarsComponent
        //sourceComponent: spriteBarsComponent
    }

    // this gets loaded when a spritesheetSource was defined
    Component {
        id: spriteBarsComponent

        Item {
            Component.onCompleted: console.debug("Healthbars loaded from spritesheet with source", spriteSheetSource)

            width: healthbar.width
            height: healthbar.height

            SingleSpriteFromSpriteSheet {
                id: greenHealthbarSprite
                // this should be the same like for squaby!
                spriteSheetSource: healthbar.spriteSheetSource
                // there must be a 1 pixel wide border (thus the image is 3x3 pixels), otherwise the texture will look blurred
                // these must get set explicitly from outside!
                frameX: alivePixelX
                frameY: alivePixelY
                frameWidth: 1
                frameHeight: 1
                width: healthbar.width*healthbar.percent
                height: healthbar.height

                translateToCenterAnchor: false

                // NOTE: this is an important performance improvement, to prevent continuously call onWidthChanged!
                ignoreWidthAndHeightChangedSignals: true
            }
            SingleSpriteFromSpriteSheet {
                id: redHealthbarSprite
                // this should be the same like for squaby!
                spriteSheetSource: healthbar.spriteSheetSource
                // there must be a 1 pixel wide border (thus the image is 3x3 pixels), otherwise the texture will look blurred
                // these must get set explicitly from outside!
                frameX: diedPixelX
                frameY: diedPixelY
                frameWidth: 1
                frameHeight: 1
                width: healthbar.width*(1-healthbar.percent)
                height: healthbar.height

                translateToCenterAnchor: false

                anchors.right: parent.right

                // NOTE: this is an important performance improvement, to prevent continuously call onWidthChanged!
                ignoreWidthAndHeightChangedSignals: true
            }
        } // end of Item
    } // end of component

    Component {
        id: rectangleBarsComponent

        Item {
            Component.onCompleted: console.debug("Healthbars loaded from rectangle")

            //id: nonRotatedItem
            width: healthbar.width
            height: healthbar.height

            Rectangle {
                width: healthbar.width*healthbar.percent
                height: healthbar.height
                // green
                color: "#2cc908"
            }
            Rectangle {
                width: healthbar.width*(1-healthbar.percent)
                height: healthbar.height
                // red
                color: "#e00f0f"
                anchors.right: parent.right
                //x:0
                //y:10
            }
        } // end of item
    }// end of component

}
