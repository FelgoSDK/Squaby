import QtQuick 2.0
import Felgo 3.0
import "../gameScene/hud" // for SingleSquabySprite

// this may become an EntityBaseDraggable, when the position of it should be changable, and it should be createable at runtime from the building menu!
EntityBase {
  id: waypoint
  // to show up in the debugger more readable
  entityType: "waypoint"

  // these may also be arrays in future versions, if crossings should be possible!
  property variant prev
  // current is the current pos!
  //property variant current
  property variant next

  poolingEnabled: true

  // this is for trying why the waypoints at x=16 are still visible - no clue why!?
//  onMovedToPool: {
//    // this is useeless here, because when visible is set to false, the position is not forwarded any more!
//    waypoint.x = 100
//    waypoint.y = 100
//    waypoint.rotation = 0

//    updateItemPositionAndRotationImmediately()

//    waypoint.visible = false
//    sprite.visible = false
//    sprite.visible = false

//    waypoint.opacity = 0.5

//  }

  onUsedFromPool: {

//    console.debug("used from pool, to set pos:", x, y)
    calculateRotationAndMirroring()

    // this is required, otherwise the transform would be the old!
    // otherwise it will shortly flicker when it gets visible, when used for pooling!
    //updateItemPositionAndRotationImmediately()

    // see bug testinga bove
//    sprite.visible = true
//    sprite.visible = true
//    waypoint.x = 100
//    waypoint.y = 100
  }

  // this is useless here - the rotation is not modified!
  // the default transformOrigin is Center, which would position the children incorrectly!
  //transformOrigin: Item.TopLeft

  SingleSquabySprite {
    id: sprite

    translateToCenterAnchor: true
    source: "../../assets/img/steps/steps-4-corner-from-left-to-top.png"
  }

  // for debugging only
//  Rectangle {
//    anchors.fill: sprite
//    color: "red"
//    opacity: 0.3
//  }


  // without the spritesheet
//  Image {
//    id: image
//    source: calculateSource()
//    width: 2*gridSize
//    height: 2*gridSize
//    //rotation: calculateRotation()
//    anchors.centerIn: parent
//  }


  Component.onCompleted: {
    //console.debug("Waypoint: onCompleted for pos:", x, y)
    calculateRotationAndMirroring()
  }

  function calculateRotationAndMirroring() {
    var fromLeft;
    var fromRight;
    var fromTop;
    var fromBottom;

    // initialize it with false, it might have been set to true before when used from pool!
    sprite.mirrorX = false;



    // prev is from the left, no mirroring necessary
    if(prev.x < x) {
      fromLeft = true;
    } else if(prev.x > x) {
      fromRight = true;
    } else if(prev.y < y) {
      fromTop = true;
    } else if(prev.y > y) {
      fromBottom = true;
    }

    var toLeft;
    var toRight;
    var toTop;
    var toBottom;

    if(next.x > x) {
      toRight = true;
    } else if(next.x < x) {
      toLeft = true;
    } else if(next.y > y) {
      toBottom = true;
    } else if(next.y < y) {
      toTop = true;
    }

    if(fromLeft && toTop) {
      // do nothing, default image
      waypoint.rotation = 0;
    } else if(fromTop && toRight) {
      waypoint.rotation = 90;
    } else if(fromRight && toBottom) {
      // this is problematic!? don't know why, but this waypoint when placed on the right side of the screen, is never set to invisible!?!
      // that only happens when rotation is set to 180
      waypoint.rotation = 180;
    } else if(fromBottom && toLeft) {
      waypoint.rotation = 270;
    } else {
      // now the mirrored ones start!
      sprite.mirrorX = true;
    }

    if(fromRight && toTop) {
      waypoint.rotation = 0;
    } else if(fromBottom && toRight) {
      waypoint.rotation = 90;
    } else if(fromLeft && toBottom) {
      waypoint.rotation = 180;
    } else if(fromTop && toLeft) {
      waypoint.rotation = 270;
    }

  }


}
