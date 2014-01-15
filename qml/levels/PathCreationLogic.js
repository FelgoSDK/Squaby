var lastMousePoints = new Array;
var lastMousePointIndex = 0;

var waypoints = new Array;
var lastWaypointIndex;
// gets set to waypoints[lastWaypointIndex];
var lastWaypoint;

var horizontalDifferenceWasBiggerFirst;
var verticalDifferenceWasBiggerFirst;


function pressed(mouseX, mouseY) {
  //  lastMousePoints.push(Qt.point(mouseX, mouseY));

  delete waypoints;
  waypoints = new Array;

  // this gets set to 0 in addWaypoint
  lastWaypointIndex = -1;
  addWaypoint(mouseX, mouseY);

  horizontalDifferenceWasBiggerFirst = false;
  verticalDifferenceWasBiggerFirst = false;

}

function positionChanged(mouseX, mouseY) {

  var dx = Math.abs(lastWaypoint.x-mouseX);
  var dy = Math.abs(lastWaypoint.y-mouseY);

  console.debug("PathCreationLogic: positionChanged to", mouseX, mouseY, "delta:", dx, dy);

  if(dx>pathSize && dy>pathSize) {
    var snappedPos;

    if(dx > dy) {
      console.debug("creating a waypoint horizontally")
      snappedPos = Qt.point(getSnappedValue(mouseX, lastWaypoint.x), lastWaypoint.y);
    } else {
      console.debug("creating a waypoint vertically")
      snappedPos = Qt.point(lastWaypoint.x, getSnappedValue(mouseY, lastWaypoint.y));
    }

    console.debug("creating a wayopint at position", snappedPos.x, snappedPos.y)

    addWaypoint(snappedPos.x, snappedPos.y);
  }
}

function released(mouseX, mouseY) {
  console.debug("PathCreationLogic: released:", mouseX, mouseY)

  // TODO: there must be 90 degree ending!
  // guarantee that!

  var dx = Math.abs(lastWaypoint.x-mouseX);
  var dy = Math.abs(lastWaypoint.y-mouseY);

  // NOTE: here is NOT a dx>pathSize && dy>pathSize!!!
  // the difference can only be bigger in one direction, because this is the last part of the path
  // it is important that at first the dy is checked!
  if(dy>pathSize){
    var snappedPos = Qt.point(lastWaypoint.x, getSnappedValue(mouseY, lastWaypoint.y));
    addWaypoint(snappedPos.x, snappedPos.y)
    console.debug("add final waypoint at pos", snappedPos.x, snappedPos.y)
  }

  if(dx>pathSize){
    var snappedPos = Qt.point(getSnappedValue(mouseX, lastWaypoint.x), lastWaypoint.y);
    addWaypoint(snappedPos.x, snappedPos.y)
    console.debug("add final waypoint at pos", snappedPos.x, snappedPos.y)
  }

}

function addWaypoint(snappedPosX, snappedPosY) {
  var newWaypoint = Qt.point(snappedPosX, snappedPosY)
  waypoints.push( newWaypoint );
  lastWaypointIndex++;
  lastWaypoint=waypoints[lastWaypointIndex];


  var snappedPos = {"x": snappedPosX, "y": snappedPosY};
  console.debug("addWaypoint called for pos", snappedPos.x, snappedPos.y)
  // this is a signal in PathCreationOverlay
  //waypointCreated(newWaypoint)
  waypointCreated(snappedPos);
}

//function targetWaypointReached(mouseX, mouseY) {
//}

// the last is needed, because we only can snap to the difference - it should always be a multiple of 32!
function getSnappedValue(newXOrY, lastXOrY) {
  var delta = newXOrY-lastXOrY;
  var division = delta/pathSize;
  var rounded = Math.round(division);


  var snappedDelta= pathSize*rounded;
  var snappedAbsoluteValue = lastXOrY+snappedDelta

  console.debug("to snap value:", newXOrY, "rounded:", rounded, "snappedValue:", snappedAbsoluteValue)

  return snappedAbsoluteValue;

}
