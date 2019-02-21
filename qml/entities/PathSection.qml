import QtQuick 2.0

import Felgo 3.0
import "../gameScene/hud" // for SingleSquabySprite

// by now, a PathSection only is the physics collider
// in a later version, the path section should also contain an Image with the single path element
// does it really need to be an Entity? the pathSection is not modifiable directly at the moment, only the waypoints - but ther might be added a cost for this edge (=section) for example later!
EntityBase {
  id: pathSection
  // to show up in the debugger more readable
  entityType: "pathSection"

  // this gets removed & destroyed a lot, so pooling is useful here!
  // but the sprites in the repeater get recreated!?
  //poolingEnabled: true

    // x, y, width & height get set by PathEntity

  // these are the first and second Qt.point() objects - second may be undefined, when it is the section to the last waypoint!
  property variant first
  property variant second

  property real gridSize: scene.gridSize


  // the default transformOrigin is Center, which would position the children incorrectly!
  transformOrigin: Item.TopLeft


//    Component.onCompleted: {
//        console.debug("PathSection.onCompleted(), parent:", parent)
//    }

    // the base item must not be a BoxCollider, because then owningEntity where to retrieve the position from would not be known!
    BoxCollider {
        collisionTestingOnlyMode: true

        // anchoring wont work here, because the base entity has a width & height assigned, which gets forwarded to this BoxCollider!
        // so the collider would still be positioned top-left, not by the center
        //anchors.centerIn: parent
        x: -width/2
        y: -height/2

        // Cat3 is the foundationCollider of the towers, obstacles and the path
        // Cat4 is the dragged tower
        categories: Box.Category3
        collidesWith: Box.Category4

    }

    // this may be used for debugging the size & center position of the PathSection
//    Rectangle {
//      color: "red"
//      opacity: 0.3
//      x: -pathSection.width/2
//      y: -pathSection.height/2
//      width: parent.width
//      height: parent.height
//    }

    Repeater {
      id: repeater

      SingleSquabySprite {
        x: -pathSection.width/2 + width*(index+1)
        y: -height/2
        source: "../../assets/img/steps/steps-6-straight.png"
      }


      /*!
      Image {
        id: image
        source: calculateSource()
        width: 2*gridSize
        height: 2*gridSize

        // x is the offset here!
        x: -pathSection.width/2 + width*(index+1)
        y: -height/2
      }*/
    }

    Component.onCompleted: {
      var rot = calculateRotation();
      pathSection.rotation = rot

      // don't count the first and the last waypoint tile, thus -4*gridSize (1 tile is actually 2*gridSize)
      var numberSteps = (width-4*gridSize) / (2*gridSize)
      repeater.model = numberSteps
    }

//    function calculateSource() {
//      return "../../assets/img/steps-6-straight.png";
//    }

    function calculateRotation () {
      if(second.x>first.x) {
        return 0;
      } else if(second.x < first.x) {
        return 180;
      } else if(second.y > first .y) {
        return 90;
      } else
        return 270;
    }

}
