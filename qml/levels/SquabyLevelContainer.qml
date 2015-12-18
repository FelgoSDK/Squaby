import QtQuick 2.0
import VPlay 2.0 // for System
import "../entities"
import "../balancing"

// in this component, only the shared settings for ALL levels are entered
// all level-specific settings are set in e.g. Level01.qml, Level02.qml, ...
Item {
  id: level
  // the whole level has scene.width(=480)/scene.gridSize(=16) = 30 columns and scene.height(=320-64)/16=16 rows

  // by default, the level should get the size of its parent (the scene)
  // the level size is needed for instance by EntityBaseDraggable to determine the level boundaries
  width: parent.width
  height: parent.width

  // this might be changed in the performance test options menu for a strong entity to test only the effect of the towers, not of dying squabies
  property bool createYellowSquaby: true

  // needed for the LevelEditor
  property alias levelLoader: levelLoader

  // an alias is not possible here, because item is null in the beginning!
  property variant pathEntity: levelLoader.loadedLevel ? levelLoader.loadedLevel.pathEntity : null
  property variant waves: levelLoader.loadedLevel ? levelLoader.loadedLevel.waves : null
  property variant nextLevelId: levelLoader.loadedLevel ? levelLoader.loadedLevel.nextLevelId : null

  property variant difficulty: levelLoader.loadedLevel ? levelLoader.loadedLevel.difficulty : null
  property variant maxPlayerLife: levelLoader.loadedLevel ? levelLoader.loadedLevel.maxPlayerLife : null
  property variant startGold: levelLoader.loadedLevel ? levelLoader.loadedLevel.startGold : null
  property variant endlessGame: levelLoader.loadedLevel ? levelLoader.loadedLevel.endlessGame : null
  property variant towerPermissions: levelLoader.loadedLevel ? levelLoader.loadedLevel.towerPermissions : null

  property alias loadedLevel: levelLoader.loadedLevel

  // by default, load the local obstacles, may also be loaded from remote server or from database (see LevelEditingMenu for that)!
  //Loader {
  LevelLoader {
    id: levelLoader
    // by default, load the first level
// don't set anything by default! that may be set in levelLoader.qml if wanted to load a level initially!
//    levelSource: "01/Level01.qml"

//    onSourceChanged: {
//      console.debug("LevelBase: levelSource changed to", levelSource)
//    }

    Component.onCompleted: {
      console.debug("SquabyLevelContainer: LevelLoader.onCompleted - pathEntity:", pathEntity, "item:", levelLoader.loadedLevel)
    }

    onLoaded: {
//      console.debug("LevelLoader: loaded level with source", source)

      console.debug("________________SquabyLevelContainer: loaded with LevelLoader:", levelSource)

      // after the level got loaded, the waypoints must be initialized
      // TODO: this causes the app to crash if started with it!? because they are removed when not created completely!
      // this must not be called here, because in onCompleted of PathEntity there is an initialize anyway!
      //pathEntity.initializeFromWaypoints(pathEntity.waypoints)
    }
  }




  // creates squabies that get removed immediately, so they can be used for the entity pool
  function preCreateEntitiesForPool() {

    // don't pool entities on Sym & meego - creation takes very long on these platforms
    if(system.isPlatform(System.Meego) || system.isPlatform(System.Symbian))
      return;

    // NOTE: precreation 120 entities takes far too long! only precreate the first couple of squabies, then create on demand!
    entityManager.createPooledEntitiesFromComponent(sy, 5);
    // also add these entities, because the performance during gameplay is key, it is not that bad if loading takes a bit longer!
    entityManager.createPooledEntitiesFromComponent(sgreen, 3);
    entityManager.createPooledEntitiesFromComponent(so, 2);
    entityManager.createPooledEntitiesFromComponent(sr, 2);
    entityManager.createPooledEntitiesFromComponent(sgrey, 2);
    entityManager.createPooledEntitiesFromComponent(sblue, 2);
  }

  // this needs to be accessed by squabies and towers
  property alias balancingSettings: balancingSettings
  BalancingSettings {
    id: balancingSettings
  }
  SquabyTypes {
    id: squabyTypes
  }

  Binding {
    target: player
    property: "balancingSettings"
    value: balancingSettings
  }

  // for faster accessing in the waves-definition in each concrete level
  property alias sy: squabyTypes.squabyYellow
  property alias so: squabyTypes.squabyOrange
  property alias sr: squabyTypes.squabyRed
  property alias sgreen: squabyTypes.squabyGreen
  property alias sblue: squabyTypes.squabyBlue
  property alias sgrey: squabyTypes.squabyGrey
  //property alias squabyTypes: squabyTypes // this is only internally, only the concrete components are required for wave definitions! so no alias is needed for squabyTypes


  // the bed & path are not snapped to the raster, but positioned freely!
  // thus the positions are retrieved from photoshop and not specified with column&row
  Obstacle {
    id: bed
    x: 486
    y: 207
    variationType: "bed"
  }

  Obstacle {
    id: closet

    x: -5
    y: 0

    variationType: "closet"
  }

  Obstacle {
    id: closetDoor1
    anchors.left: closet.right
    anchors.top: closet.top
    variationType: "closet-door1"
  }

  Obstacle {
    id: closetDoor2
    anchors.left: closet.right
    anchors.bottom: closet.bottom
    variationType: "closet-door2"
  }




  // this is a dev-only testing area for cheating (get more gold) or performance tests create squabies
  MouseArea {        
    enabled: cheatMoneyEnabled
    anchors.fill: closet
    onClicked: {
      // only in game mode, not in editor
      if(scene.state === "levelEditing")
        return

      player.gold += 100
    }
  }
  MouseArea {
    enabled: developerBuild
    x: bed.x - bed.width/2
    y: bed.y - bed.height/2
    width: bed.width
    height: bed.height
    onClicked: {
      // only in game mode, not in editor
      if(scene.state === "levelEditing")
        return

      // this is just for debugging: allow to add a squaby by clicking the closet
      // this would create a squaby with the default settings
      //entityManager.createEntity(Qt.resolvedUrl("entities/Squaby.qml"));
      if(createYellowSquaby)
        entityManager.createEntityFromComponent(sy);
      else
        entityManager.createEntityFromComponent(sgrey);
    }
  }


  Component.onCompleted: {
    console.debug("SquabyLevelContainer.onCompleted");

    // entityContainer is valid here, but only if the alias is used for in the GameSceneLoader!
    // if set in onLoaded, the onCompleted is called first and no entityContainer would be available here!
    console.debug("___________entityManager:", entityManager, ", entityContainer:", entityManager.entityContainer)
    //var entityId = entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("../entities/Waypoint.qml"), {x:200, y: 100})
    //var entity = entityManager.getEntityById(entityId)
    //console.debug("created entity and parents:", entity, entity.parent)

    // change this for debugging purposes to test the game logic
    // position at the 9th column, 6th row
    //entityManager.createEntityWithProperties(Qt.resolvedUrl("entities/Nailgun.qml"), {"x":scene.gridSize*9, "y":scene.gridSize*6} );

    // the below is the same as: entityManager.createEntity("Squaby.qml")
    //entityManager.createEntityWithProperties(Qt.resolvedUrl("entities/"Squaby.qml"), {});//{"x":150, "y":300, "rotation":45} );

    // only for testing the z-ordering of closet
    //entityManager.createEntityWithProperties(Qt.resolvedUrl("entities/Obstacle.qml"), {"column":1, "row":1, "obstacleType": "soccerball"} );
  }

  // this gets added dynamically by EntityManager - but by adding it here as well, both approaches get tested
  //    Squaby {
  //        // x & y are irrelevant, as animation starts at the first waypoint at squaby anyway!
  //        x:250
  //        y:200
  //    }

  // uncomment the following for adding prebuilt towers, e.g. for quick testing the upgrading functionality
//  Nailgun {
//    x: scene.gridSize*9
//    y: scene.gridSize*6
//  }
//  Flamethrower {
//    x: scene.gridSize*9
//    y: scene.gridSize*4
//  }
//  Turbine {
//    x: scene.gridSize*9
//    y: scene.gridSize*6
//  }
}
