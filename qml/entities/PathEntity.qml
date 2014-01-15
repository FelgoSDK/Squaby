import QtQuick 1.1
import VPlay 1.0

/**
 * This is not a real "entity" - it contains a list of waypoints, with a collider being created for each waypoint.
 * The path also does not move, so it is a static entity, and it only collides with the DragWeapon.
 * Currently, only 90°-edges are allowed for neighbour waypoints.
 * Between each waypoint a physics collider is created.
 * DONE: also a visual path component should be added between each waypoint, the footsteps - as this is not trivial to look good (especially in the borders the steps should be rotated!), this is kept for later and only a single image is used for the path.
 */
Item {
    id: pathEntity
    property real pathSize: scene.gridSize*2

    //property list<point> waypoints // list<point> does not work! the prop in list must be a registerd QDeclarativeItem type! (e.g. there exists a Point item in Qt3D)

    //  TODO: a waypoint should not only have x/y (so not a point), but a list of neighbours! so it would be possible to have spreading paths with multiple neighbours
    // by default, the neighbourIndex gets set to the next item in the list, or to nothing if the end of the list is reached!
    // like this a specification would look like: waypoints: waypoints: [ { x:16,  y:48}, { x: 112, y: 48 } ]
    // important to initialize it as an array, as the .length property is queried below! so when not defined in empty levels, it still must be an empty array!
    property variant waypoints: []


    Component.onCompleted: {
      initializeFromWaypoints(waypoints, true);
    }

    // dont recreate every time - appendSingleWaypoint may be called, where also the waypoints variant is modified, but there the old entities shouldnt be removed!
    // so to initialize the waypoints, call initializeFromWaypoints()!
//    onWaypointsChanged: {
//      createPathFromWaypoints();
//    }

    function appendSingleWaypoint(newWaypoint) {

      // this is the only way to overwrite the variant property with the modified wps!
      var tempWaypoints = waypoints;
      if(!tempWaypoints)
        tempWaypoints = new Array;

      tempWaypoints.push(newWaypoint);
      waypoints = tempWaypoints;

      if(waypoints.length < 2) {
        // this is normal behavior, this function may also be called when only 1 waypoints is in here!
        //console.debug("PathEntity: at least 2 waypoints need to exist for calling addSingleWaypoint!");
        return;
      }

      var lastElementIndex = waypoints.length-1;
      var wp = waypoints[lastElementIndex];
      var previosWaypoint = waypoints[lastElementIndex-1];
      var prevPrevWaypoint;
      if(lastElementIndex>=2)
        prevPrevWaypoint = waypoints[lastElementIndex-2]

      createEntitiesForSingleWaypoint(wp, previosWaypoint, prevPrevWaypoint)

    }

    function initializeFromWaypoints(initialWaypoints, calledFromOnCompleted) {

      console.debug("PathEntity: initializeFromWaypoints:", JSON.stringify(initialWaypoints))

      var now = Date.now();

      var waypointsStayedEqual = true
      // initialWaypoints might be an empty {} or undefined when loading from a dynamic level
      // the order of these check are important, otherwise the following error would occur: TypeError: Result of expression 'initialWaypoints' [undefined] is not an object.
      if(calledFromOnCompleted ||
          !initialWaypoints || !waypoints ||
          !waypoints["length"] || !initialWaypoints["length"] ||
          waypoints.length !== initialWaypoints.length) {
        waypointsStayedEqual = false
      } else {
        for(var i=0; i<initialWaypoints.length && waypointsStayedEqual; i++) {
          console.debug("comparing waypoint index", i)
          if(waypoints[i].x !== initialWaypoints[i].x || initialWaypoints[i].y !== initialWaypoints[i].y) {
            console.debug("PathEntity: there was a change in the waypoints, at waypoint with index", i)
            waypointsStayedEqual = false
            // this would not be required, because the condition in the for loop has a check for it
            break;
          }
        }

        if(waypointsStayedEqual) {
          var activePathSections = entityManager.getEntityArrayByType("pathSection")
          //console.debug("PathEntity: current active waypoint entities:", activePathSections.length, ", initialWaypoints.length:", initialWaypoints.length)
          // the real waypoints also must be the same, because otherwise there have been some removed in the meanwhile
          // this might happen when the user creates a new level with the levelName, goes back to the level menu, and then loads the same level again
          // the pathEntity is not reset in that case, but all entities got removed when the new level was loaded from LevelEditor
          // the reael waypoints must be 1 less, because for the first and last point no waypointentity is created
          // so this calculation will always yield false for 1 waypoint, but then no waypoints entities will be removed anyway
          waypointsStayedEqual = activePathSections.length === initialWaypoints.length-1
        }
      }

      if(waypointsStayedEqual) {
        console.debug("PathEntity: waypoints are the same, thus skip removing the old ones and loading the new ones")
        return;
      }

      // overwrite the waypoints of the PathEntity, which gets usedy by the Squabies
      waypoints = initialWaypoints;

      // remove all paths and waypoints
      var toRemoveEntityTypes = ["pathSection", "waypoint"];
      entityManager.removeEntitiesByFilter(toRemoveEntityTypes);

      if(!initialWaypoints) {
        console.debug("PathEnttiy: no waypoints were defined - this occurs when a new level is created")
        return;
      }

      // remove the old entities that got created before - that is important when the waypoints get loaded from the outside, and the old path should be removed
      // without this guard, .length would lead to an error at initial loading
//      if(__pathSections){
//        for(var i=0; i< __pathSections.length; i++) {
//          console.debug("old pathSection:", __pathSections[i])
//          //__pathSections[i].destroy();
//          __pathSections[i].removeEntity();
//        }
//      }

//      if(__waypointEntities) {
//        for(var i=0; i< __waypointEntities.length; i++) {
//          //__waypointEntities[i].destroy();
//          __waypointEntities[i].removeEntity();
//        }
//      }


      // create a physicsCollider-entity between each neighbour waypoints
//      console.debug("PathEntity: pathElements in path:", initialWaypoints.length);
//      for(var i=0; i<initialWaypoints.length; i++) {
//        console.debug("PathEntity: waypoint[", i, "]:", initialWaypoints[i].x, initialWaypoints[i].y, initialWaypoints[i])
//      }


//      var waypointComponent = Qt.createComponent("Waypoint.qml");
//      var pathSectionComponent = Qt.createComponent("PathSection.qml");
//      // this check would not be needed - they are local components and not loaded from the web, so they must be ready immediately
//      if (pathSectionComponent.status === Component.Ready && waypointComponent.status === Component.Ready) {

          // start at the second waypoint, because a collider must be created between 2 neighbours
      for(var i=1; i<initialWaypoints.length; i++) {

        var prevPrevWaypoint;
        if(i>=2)
          prevPrevWaypoint  = initialWaypoints[i-2];

        var lastWaypoint = initialWaypoints[i-1];
        var waypoint = initialWaypoints[i];


        createEntitiesForSingleWaypoint(waypoint, lastWaypoint, prevPrevWaypoint);

      }

      var dt = Date.now() - now;
      console.debug("PathEntity: dt for path creation:", dt)


    }

    // prevPrevWaypoint is optional, this needs at least 2 waypoints in the list
    function createEntitiesForSingleWaypoint(waypoint, prevWaypoint, prevPrevWaypoint) {


      // helpers for each section to create
      var sectionX;
      var sectionY;
      var sectionWidth;
      var sectionHeight;


      // the order of these calculations is important!
      // the width used for the center of the PhysicsCompoent is the difference between the positions
      // as only 90°-angles for the waypoints are allowed, width or height must be 0 here! but that is intended
      sectionWidth = waypoint.x-prevWaypoint.x;
      sectionHeight = waypoint.y-prevWaypoint.y;
      // the center of the new section is in between the paths
      sectionX = prevWaypoint.x + sectionWidth*0.5;
      sectionY = prevWaypoint.y + sectionHeight*0.5;

      // width might be negative (if lastWaypoint is above the current waypoint)
      sectionWidth = Math.abs(sectionWidth);
      sectionHeight = Math.abs(sectionHeight);

      // set the dimension that is 0 to the pathSize (2 grids)
      // also add pathSize to the other dimension, because the x&y defined for the path is the center, which is surrounded by pathSize (1 grid in each direction)
      if(sectionWidth === 0) {
          sectionWidth = pathSize;
          sectionHeight+=pathSize;
      } else if (sectionHeight === 0) {
          sectionHeight = pathSize;
          sectionWidth+=pathSize;
      } else {
        console.debug("WARNING: the path is non-90 degree! this is not supported! problematic between last waypoint at pos", prevWaypoint.x, prevWaypoint.y ," and current wp", waypoint.x, waypoint.y, "sectionWidth:", sectionWidth, "sectionHeight:", sectionHeight);
        return;
      }

      if(sectionHeight > sectionWidth) {
        var tempForChange = sectionWidth;
        sectionWidth = sectionHeight;
        sectionHeight = tempForChange;
      }

      //console.debug("calculated center for PathSection: x=", sectionX, "y=", sectionY, "width=", sectionWidth, "height=", sectionHeight);

      entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("PathSection.qml"),
                                                      {"x": sectionX, "y":sectionY,
                                                        "width": sectionWidth, "height": sectionHeight,
                                                        "first": prevWaypoint,
                                                        "second": waypoint
                                                      });

      // create the WaypointEntity for the last waypoint
      if(prevPrevWaypoint) {
      entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("Waypoint.qml"),
                                                      {"x": prevWaypoint.x, "y": prevWaypoint.y,
                                                        "prev": prevPrevWaypoint,
                                                        "next": waypoint
                                                      });
      }



//      var pathSectionEntity = pathSectionComponent.createObject(pathEntity,
//                                            {"x": sectionX, "y":sectionY,
//                                              "width": sectionWidth, "height": sectionHeight,
//                                              "first": lastWaypoint,
//                                              "second": waypoint
//                                            }
//                                            );
//      var wpEntity = waypointComponent.createObject(pathEntity,
//                                                   {
//                                                     "x": waypoint.x, "y": waypoint.y,
//                                                     "prev": lastWaypoint,
//                                                     "next": nextWaypoint
//                                                   } );

//      sections.push(pathSectionEntity);
//      waypointEntities.push(wpEntity);

      // this is done automatically, when the entity is created dynamically with entityManager!
//      window.loadItemWithCocos(wpEntity);
//      window.loadItemWithCocos(pathSectionEntity);

    }

}
