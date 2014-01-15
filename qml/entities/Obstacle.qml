import QtQuick 1.1
import VPlay 1.0
import Box2D 1.0 // needed for Box category

/**
 * This component can be used for all obstacles in the level, e.g. bed, closet, teddy, chocolate, toy bricks, etc.
 * A collider is added for it, by default a 2*2 grid. For the bed and the closet a bigger collider is set.
 *
 */
EntityBaseDraggable {
  id: obstacle

  // columnn & row may be set from outside, for easier positioning along the grid
  property int column
  property int row

  // this is the default in GameWindow anyway and needs not be set
  //gridSize: scene.gridSize

  entityType: "obstacle"
  // the variationType may be bed, teddy, chocolate, toy
  variationType: "teddy"

  x: column*gridSize
  y: row*gridSize

  // it must be above the path
  z: 1

  width: sprite.width
  height: sprite.height

  colliderComponent: collider
  // Cat3 is the foundationCollider of the towers, obstacles and path
  // Cat4 is the dragged tower - so this is exactly exchanged, so the dragged tower collides with the already existing towers
  colliderCategoriesWhileDragged: Box.Category4
  colliderCollidesWithWhileDragged: Box.Category3
  selectionMouseArea.width: sprite.width
  selectionMouseArea.height: sprite.height
  selectionMouseArea.x: -sprite.width/2
  selectionMouseArea.y: -sprite.height/2

  // this mouseArea should only be enabled when in levelEditing mode, where the obstacle can be dragged around or be destroyed
  // it should never be enabled for closet & bed, as these should not be selectable but fixed!
  selectionMouseArea.enabled: scene.state === "levelEditing" && variationType !== "closet" && variationType !== "bed" && variationType !== "closet-door1" && variationType !== "closet-door2"

  opacityChangeItemWhileSelected: sprite

  onEntityClicked: {
    if(scene.state === "levelEditing") {
      hud.entitySelected(obstacle);
    }
  }

  Component.onCompleted: {
    var type = variationType;
    if(type==="bed") {
      sprite.source = "bed.png";
      obstacle.z = 1; // this is needed for QML - z only is useful for siblings, and obstacle is the sibling elment!
      sprite.z = 1;
      sprite.vertexZ = 2; // this is required for cocos, when the squabies are not in the same spritesheet as the background, because then z-ordering doesnt work!

      // this is required, otherwise it would be deleted when a new level is loaded (as removeAllEntities is called there)
      preventFromRemovalFromEntityManager = true
    } else if (type==="closet"){
      obstacle.z = 1;
      sprite.z = 1;
      sprite.vertexZ = 2; // this is required for cocos, when the squabies are not in the same spritesheet as the background, because then z-ordering doesnt work!
      sprite.source = "closet-main.png";

      preventFromRemovalFromEntityManager = true
    } else if (type==="closet-door1"){
      sprite.source = "closet-door1.png";
      preventFromRemovalFromEntityManager = true
    } else if (type==="closet-door2"){
      sprite.source = "closet-door2.png";
      preventFromRemovalFromEntityManager = true
    } else if (type==="choco"){
      sprite.source = "choco-right.png";
    } else if (type==="book"){
      sprite.source = "book-left.png";
    } else if (type==="pillow"){
      sprite.source = "pillow.png";
    } else if (type==="soccerball"){
      sprite.source = "soccerball-left.png";
    } else if (type==="teddy"){
      sprite.source = "teddy.png";
    } else if (type==="toyblocks"){
      sprite.source = "toyblocks-left.png";
    } else{
      console.debug("WARNING: unknown obstacleType", type);
    }
  }

  SingleSpriteFromFile {
    id: sprite
    filename: "../img/all-sd.json"
    // source gets modified by the type
    z:obstacle.z // forward the z value set to the Obstacle, e.g. for bed & closet this will be set to 1 by default

    // We want to use anchoring for the closet doors so disable translate to center for these
    translateToCenterAnchor: (variationType === "closet" || variationType === "closet-door1" || variationType === "closet-door2") ? false : true
  }

  BoxCollider {
    id: collider
    // old:
    // colliderSize is by default 2*2 grids for all obstacle types (all except closet & bed)
    // the closet is split up in 3 files! thus set the original size of it manually to 74x91
    width: {
      if (obstacle.variationType==="bed") {
        return sprite.width;
      } else if(obstacle.variationType==="closet") {
        return 74;
      } else
        return 2*gridSize;
    }
    height: {
      if (obstacle.variationType==="bed") {
        return sprite.height;
      } else if(obstacle.variationType==="closet") {
        return 91;
      } else
        return 2*gridSize;
    }

    collisionTestingOnlyMode: true

    // the closet is not translated to the center!
    x: obstacle.variationType==="closet" ? 0 : -width/2
    y: obstacle.variationType==="closet" ? 0 : -height/2

    // Cat3 is the foundationCollider of the towers and obstacles
    // Cat4 is the dragged tower
    categories: Box.Category3
    collidesWith: Box.Category4
  }

  // for debugging the size of the obstacle
//  Rectangle {
//    //anchors.fill: parent
//    width: 30
//    height: 20
//    color: "green"
//    opacity: 0.9
//  }
}
