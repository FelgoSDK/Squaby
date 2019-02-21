import QtQuick 2.0
import Felgo 3.0

Item {
  id: tutorialSelection

  property bool running: false
  property string currentLevel: ""
  property url currentTutorialUrl: ""
  property bool paused: false
  property real deltaX: 0//(scene.gameWindowAnchorItem.width-scene.width)/2
  property real deltaY: (scene.gameWindowAnchorItem.height-scene.height)/2

  onCurrentLevelChanged: {
    if(currentLevel === "" || currentLevel === "UndefinedLevel") {
      running = false
      currentTutorialUrl = ""
      // SquabyCreator might be disabled during tutorial so we should enable it
      squabyCreator.enabled = true
      return
    }

    // Load according tutorials based on the loaded levelname
    if(currentLevel === "Level 1") {
      currentTutorialUrl = "TutorialsNailGun.qml"
      running = true
    } else if(currentLevel === "Level 2") {
      currentTutorialUrl = "TutorialsFlamethrower.qml"
      running = true
    } else if(currentLevel === "Level 3") {
      currentTutorialUrl = "TutorialsTurbine.qml"
      running = true
    } else {
      running = false
      currentTutorialUrl = ""
      // SquabyCreator might be disabled during tutorial so we should enable it
      squabyCreator.enabled = true
    }
  }


  function nextAction(source,action,position) {
    if(currentTutorialUrl === "" || paused)
      return true

    if(tutorialImpl.item) {
      var returnValue = tutorialImpl.item.nextAction(source,action,position)
      if(!returnValue) {
        notAllowedMessage.show()
      }
      return returnValue
    }
    return true
  }

  function reset() {
    paused = false

    if(currentTutorialUrl === "")
      return

    if(tutorialImpl.item) {
      tutorialImpl.item.reset()
    }
    notAllowedMessage.opacity = 0.0
  }

  function pause() {
    paused = true

    if(currentTutorialUrl === "")
      return

    if(tutorialImpl.item) {
      tutorialImpl.item.pause()
    }
    notAllowedMessage.opacity = 0.0
  }

  function resume() {
    paused = false

    if(currentTutorialUrl === "")
      return

    if(tutorialImpl.item) {
      tutorialImpl.item.resume()
    }
  }

  Particle {
    id: notificationParticle
    fileName: "../../particles/TutorialNotification.json"
    autoStart: false
    scale: 0.5
  }

  Loader {
    id: tutorialImpl
    source: tutorialSelection.currentTutorialUrl
  }

  Item {
    id: action
    visible: false
    width: sprite.width
    height: sprite.height

    onVisibleChanged: {
      // reset scale, might be not 1.0 when running disabled, then next time it runs, this will be the default value instead of the original size.
      scale = 1.0
    }

    NumberAnimation {
      running: action.visible; target: action; property: "scale"; duration: 1800; easing.type: Easing.SineCurve
      loops: -1; to: 1.3
    }

    SingleSquabySprite {
      id: sprite
      source: "../../../assets/img/menu_labels/hint.png"
      anchors.centerIn: parent
    }
  }

  Text {
    id: notAllowedMessage
    x: scene.gameWindowAnchorItem.x+scene.gameWindowAnchorItem.width/2-notAllowedMessage.width/2
    y: scene.gameWindowAnchorItem.y+scene.gameWindowAnchorItem.height/2-notAllowedMessage.height/2
    text: "Not Allowed!"
    color: "white"
    opacity: 0

    function show() {
      notAllowedMessage.opacity = 1
    }

    Behavior on opacity {
      // the cross-fade animation should last 350ms
      NumberAnimation { duration: 450 }
    }

    onOpacityChanged: {
      if(opacity >= 1) {
        hideMessage.start()
      }
    }

    Timer {
      id: hideMessage
      interval: 700
      repeat: false
      onTriggered: {
        notAllowedMessage.opacity = 0
      }
    }
  }

}

