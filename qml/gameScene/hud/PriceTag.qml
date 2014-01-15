import QtQuick 1.0
//import VPlay 1.0 // why isnt this working?
import VPlay 1.0

// unfortunatley no gradient for font color/filling is possible, so use the precreated images
//Text {
//    FontLoader { id: jelly; source: "img/JellyBelly.ttf" }
//    font.family: jelly.name
//    font.pointSize: 15
//    text: "TestText 123456789"
//}
//Item {
//    id: costItem
//    clip: true
//    width: 32
//    height: 23
//    // the price can be set in steps of 5, beginning with 5 and ending with 90 (so 5, 10, 15,20,...,90) because these images are set in the priceTags.png image
//    property int cost: 5

//    //onPriceChanged: priceImage.x = (price/5)-1*priceItem.width

//    Image {
//        id: priceImage
//        source: "img/priceTags.png"
//        //
//        x: -((cost/5)-1)*costItem.width
//    }

//}

SingleSquabySprite {
    // old, without loading the image from a file
//    frameWidth: 32
//    frameHeight: 23
//    startFrameColumn: cost/5
//    spriteSheetSource: "img/priceTags.png"

    // each priceTag has its own image file in 5-multiple steps, e.g.: 5.png, 10.png, ...
    source: Math.abs(cost) + ".png"

    // the price can be set in steps of 5, beginning with 5 and ending with 90 (so 5, 10, 15,20,...,90) because these images are set in the priceTags.png image
    // cost can also be set to negative, which will add the revenue to player gold for the sell button
    property int cost: 5
}