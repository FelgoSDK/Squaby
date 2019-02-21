import QtQuick 2.0
import Felgo 3.0
import "../../levels" // for the MenuButton, which is also used for the level laoding

Column {
  Item {
    width: perfPlayButton.width
    height: perfPlayButton.height
    property bool gameIsRunning: true

    SingleSquabySprite {
      id: perfPlayButton
      source: parent.gameIsRunning ? "../../../assets/img/menu_labels/perf_pause.png" : "../../../assets/img/menu_labels/perf_play.png"
    }
    MouseArea {
      anchors.fill: perfPlayButton
      onClicked: {
        if(parent.gameIsRunning) {
          scene.pauseScene()
        } else {
          scene.enterScene()
        }
        parent.gameIsRunning^=1
      }
    }
  }
  Item {
    width: perfMenuButton.width
    height: perfMenuButton.height

    //Image { // use a res-independent spritesheet instead
    SingleSquabySprite {
      id: perfMenuButton
      source: "../../../assets/img/menu_labels/perf_menu.png"
    }
    // the MouseArea must not be a child of SingleSquabySprite, as all the children get overwritten there!
    MouseArea {
      anchors.fill: perfMenuButton
      onClicked: {
        if(itemEditor.visible) {
          if(itemEditor.currentEditableType === "Performance Settings") {
            hud.changeToBuildMenu()
          } else {
            itemEditor.currentEditableType = "Performance Settings"
            itemEditor.searchAndDisplayHeaderGroup("Game Performance")
          }
        } else {
          hud.changeFromBuildMenu()
          itemEditor.currentEditableType = "Performance Settings"
          itemEditor.searchAndDisplayHeaderGroup("Game Performance")
        }
      }
    }
  }

  EditableComponent {
    id: editableEditorComponent

    editableType: "Performance Settings"
    // this is needed, because all EditableComponents for type "SquabySettings" have the same property names - this would not work without the defaultGroup set
    defaultGroup: "Game Performance"
    preventStorage: true

    properties: {
      "perfRaster": {"label": "Raster"},
      //"displayFPS": {"label": "FPS"},
      "displayHUD": {"label": "HUD"},
      "displayScore": {"label": "Score"},
      "displayLifes": {"label": "Lives"},
      "displayBG": {"label": "Background"},
      //"waves": {"label": "Waves"},
      "particles": {"label": "Particles"},
      //"testSquaby": {"label": "Test Squaby"},
      "reset": {"label": "Delete All"},
      "aimingAtNailgun": {"label": "NailGun Aim"},
      "aimingAtFlamethrower": {"label": "Flamethrower Aim"},
      "obstacles": {"label": "Obstacles"},
      "waypoints": {"label": "Waypoints"},
      //"ftShooting": {"label": "Flamethrower active"},
      //"ftUpgrade": {"label": "Flamethrower upgrade"},
      //"sounds": {"label": "Sounds"}
    }
  }

  property bool perfRaster: true
  onPerfRasterChanged: raster.visible ^=1

  //property bool displayFPS: window.displayFpsEnabled
  //onDisplayFPSChanged: window.displayFpsEnabled = displayFPS

  property bool displayHUD: true
  onDisplayHUDChanged: hud.visible ^=1

  property bool displayScore: true
  onDisplayScoreChanged: scoreRow.visible ^=1

  property bool displayLifes: true
  onDisplayLifesChanged: livesRow.visible ^=1

  property bool displayBG: true
  onDisplayBGChanged: levelBackground.visible ^=1

  property bool waves: false
  onWavesChanged: squabyCreator.enabled ^=1

  property bool particles: settings.particlesEnabled
  onParticlesChanged: settings.particlesEnabled = particles

  property bool testSquaby: false
  onTestSquabyChanged: level.createYellowSquaby ^=1

  property bool reset: true
  onResetChanged: scene.removeAllSquabiesAndTowers()

  property bool aimingAtNailgun: true
  onAimingAtNailgunChanged: {
    var obstacles = entityManager.getEntityArrayByType("nailgun")
    for(var ii=0; ii<obstacles.length; ++ii) {
      obstacles[ii].emitAimingAtTargetSignal ^= 1
    }
  }

  property bool aimingAtFlamethrower: true
  onAimingAtFlamethrowerChanged: {
    var obstacles = entityManager.getEntityArrayByType("flamethrower")
    for(var ii=0; ii<obstacles.length; ++ii) {
      obstacles[ii].emitAimingAtTargetSignal ^= 1
    }
  }

  property bool obstacles: true
  onObstaclesChanged: {
    var obstacles = entityManager.getEntityArrayByType("obstacle")
    for(var ii=0; ii<obstacles.length; ++ii) {
      obstacles[ii].visible ^= 1
    }
  }

  property bool waypoints: true
  onWaypointsChanged: {
    var obstacles = entityManager.getEntityArrayByType("waypoint")
    for(var ii=0; ii<obstacles.length; ++ii) {
      obstacles[ii].visible ^= 1
    }
    obstacles = entityManager.getEntityArrayByType("pathSection")
    for(var ii=0; ii<obstacles.length; ++ii) {
      obstacles[ii].visible ^= 1
    }
  }

  property bool ftShooting: false
  onFtShootingChanged: {
    var obstacles = entityManager.getEntityArrayByType("flamethrower")
    for(var ii=0; ii<obstacles.length; ++ii) {
      obstacles[ii].running = ftShooting
    }
  }

  property bool ftUpgrade: false
  onFtUpgradeChanged: {
    var obstacles = entityManager.getEntityArrayByType("flamethrower")
    for(var ii=0; ii<obstacles.length; ++ii) {
      // can be range or shootDelay or repair damagePerSecond
      obstacles[ii].upgradeTower("damagePerSecond")
    }
  }

  property bool sounds: settings.soundEnabled
  onSoundsChanged: {
    settings.soundEnabled = sounds

    if(!settings.soundEnabled) {
      backgroundMusic.stop();
    } else {
      backgroundMusic.play();
    }
  }
}

