import QtQuick 1.1
import "../gameScene/hud"
import "PathCreationLogic.js" as Logic


Item {
  id: draggableArea
  // this gets enabled only, when scene.pathCreationMode is set to true

  // set this size to the playfield (=scene.height-hud.height)

  // this is required, so the path waypoints are snapped to a grid
  property real pathSize: scene.gridSize*2

  property bool isDraggingPath: false

  // this are the center points of the waypoints - the images for starting and stopping the dragging are centered around this point!
  property variant firstWaypoint: Qt.point(16, 48)
  // 1 to the left from the right anchor,
  property variant finalWaypoint: Qt.point(464, 208)

  // the green range is shown where to start the dragging, and the red range where to end it
  Image {
    id: firstWaypointImage
    x: firstWaypoint.x-width/2
    y: firstWaypoint.y-height/2

    width: 2*gridSize
    height: 2*gridSize
    source: "../img/range_radius80_allowed.png"
  }


  Image {
    id: finalWaypointImage
    x: finalWaypoint.x-width/2
    y: finalWaypoint.y-height/2
    width: 2*gridSize
    height: 2*gridSize
    source: "../img/range_radius80_forbidden.png"

    // with hoverEnabled, it also doesnt work!
//    MouseArea {
//      anchors.fill: parent
//      hoverEnabled: true

//      onContainsMouseChanged: {
//        console.debug("containsMouse changed to", containsMouse)
//      }
//      onEntered: console.debug("target point onEntered")
//    }
  }

  Item {
    id: pathCreationDraggedObject
    visible: isDraggingPath

    // just for debugging
    Rectangle {
      color:"red"
      width: pathSize; height:pathSize
      opacity: 0.3
      anchors.centerIn: parent
    }
  }

  // this is shown at the position of the last waypoint (the image there can not be drawn yet, because the direction isnt known
  Item {
    id: lastWaypointPosition
    visible: isDraggingPath

    // just for debugging
    Rectangle {
      color:"green"
      width: pathSize; height:pathSize
      anchors.centerIn: parent
      opacity: 0.5

//      SequentialAnimation on opacity{
//        NumberAnimation {
//          to: 1
//        }
//        NumberAnimation {
//          to: 0
//        }
//      }
    }
  }


  MouseArea {
    anchors.fill: firstWaypointImage

    // this is only for testing!
    // drag is not good here, because then the initial offset is used!
    //drag.target: pathCreationDraggedObject

    property bool targetReached: false

    onPressed: {
      isDraggingPath = true

      console.debug("start creating a new path")

      targetReached = false;

      // initialize with an empty array, so all path entities get removed
      level.pathEntity.initializeFromWaypoints([]);

      Logic.pressed(firstWaypoint.x, firstWaypoint.y);
      // the mouse pos cant be set, it is read-only!
      //mouseX = firstWaypoint.x
      //mouseY = firstWaypoint.y
    }

    onPositionChanged: {

      // because of anchors.fill to the image, the x position is moved by the position of firstWaypointImage!
      var sceneMouseX = mouseX+firstWaypointImage.x;
      var sceneMouseY = mouseY+firstWaypointImage.y;

      // limit to the logical scene bounds
      if(sceneMouseX>draggableArea.width)
        sceneMouseX=draggableArea.width;
      else if(sceneMouseX<0)
        sceneMouseX=0;
      if(sceneMouseY>draggableArea.height)
        sceneMouseY=draggableArea.height;
      else if(sceneMouseY<0)
        sceneMouseY=0;

      if(targetReached)
        return;

      if(sceneMouseX>finalWaypointImage.x && sceneMouseX<finalWaypointImage.x+finalWaypointImage.width
          && sceneMouseY>finalWaypointImage.y && sceneMouseY<finalWaypointImage.y+finalWaypointImage.height) {

        console.debug("the final waypoint is reached! stop there!")

        finishPathToLastWaypoint();

        // for knowing that finishPathToLastWaypoint() needs not be called any more
        targetReached = true;

      } else {
        Logic.positionChanged(sceneMouseX, sceneMouseY);
      }

      pathCreationDraggedObject.x = sceneMouseX;
      pathCreationDraggedObject.y = sceneMouseY;
    }

    onReleased: {
      console.debug("the mouse was released, build path to last waypoint")

      if(!targetReached) {

        // NOPE: add a waypoint in between here
        // dont add it here - it might be a straight line, then the waypoint couldnt be rotated!
//        var sceneMouseX = mouseX+firstWaypointImage.x;
//        var sceneMouseY = mouseY+firstWaypointImage.y;
//        Logic.positionChanged(sceneMouseX, sceneMouseY);

        // NOTE: this is also called, when the target is reached! so we need to test if the path was already created before in onPositionChanged!
        finishPathToLastWaypoint();
      }
    }

    onExited: {
      console.debug("PathCreationOverlay: mouseArea.onExited")
      // this is called when the initial size is left, but creating the path must go on! until the mouse is released!
//      if(!targetReached) {
//        // NOTE: this is also called, when the target is reached! so we need to test if the path was already created before in onPositionChanged!
//        finishPathToLastWaypoint();
//      }
    }
  }


  function finishPathToLastWaypoint() {
    isDraggingPath = false

    Logic.released(finalWaypoint.x, finalWaypoint.y)

    isDraggingPath = false;

    console.debug("update the waypoints of PathEntity to this array:")



    var newWaypoints = Logic.waypoints

    // here, the waypoints would not be valid! so not possible to directly assign an array from the js file!
    // thus copy it below!
//    storedWaypoints = newWaypoints;
//    for(var i=0;i<storedWaypoints.length; i++) {
//      console.debug("A: storedWP[", i, "]:", storedWaypoints[i].x, storedWaypoints[i].y)
//    }

    // NOTE: assigning an Array() object to a property DOES NOT WORK!!!
    // you must initialize it with [], not with "new Array" to work!!!
    var tempWP = new Array;

    for(var i=0;i<newWaypoints.length; i++) {
      // this is valid, but storedWaypoints is not valid!
      console.debug("newWayPoints[", i, "]:", newWaypoints[i].x, newWaypoints[i].y)
      // both work
      tempWP.push({ x: newWaypoints[i].x, y:newWaypoints[i].y });
      //tempWP.push( Qt.point(newWaypoints[i].x, newWaypoints[i].y) );
      console.debug("tempWP[", i, "]:", tempWP[i].x, tempWP[i].y)
    }

//    storedWaypoints = tempWP;
//    for(var i=0;i<storedWaypoints.length; i++) {
//      console.debug("B: storedWP[", i, "]:", storedWaypoints[i].x, storedWaypoints[i].y)
//    }

    // NOTE: this does NOT work!
    //level.pathEntity.initializeFromWaypoints(newWaypoints);

    // this works
//    level.pathEntity.initializeFromWaypoints(tempWP);
  }

  signal waypointCreated(variant waypoint)

  onWaypointCreated: {

    // set this, to see the last position of the waypoint
    lastWaypointPosition.x = waypoint.x
    lastWaypointPosition.y = waypoint.y

    console.debug("PathCreationOverlay: new waypoint got created at pos", waypoint.x, waypoint.y)
    level.pathEntity.appendSingleWaypoint(waypoint);
  }


  // for testing, if the storing to the property works
//  property variant storedWaypoints



  //  MouseArea {
  //    enabled: false
  //    anchors.fill: parent

  //    onPressed: {
  //      console.debug("start creating a new path")

  //      Logic.pressed(mouseX, mouseY);

  //    }

  //    onPositionChanged: {
  //      Logic.positionChanged(mouseX, mouseY);

  //    }

  //    onReleased: {
  //      Logic.released(mouseX, mouseY);

  //    }

  //    onExited: {
  //      console.debug("PathCreationOverlay: onExited!")
  //    }
  //  }


}
