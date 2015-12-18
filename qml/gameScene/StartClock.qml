import QtQuick 2.0
import VPlay 2.0

Item {
    id: startClock

    // running gets accessed by SquabyScene, when the game is paused
    // it is false by default! only when enabled & running is set to true, it will start creating squabies!
    property bool running: false
    property alias waitsForStart: background.visible

    // this property can be used to completely turn off
    property bool enabled: true

    // is called every time the game gets restarted
    function restart() {
      background.visible = 1.0
      squabyCreator.reset()
    }

    function start() {
      if(running) {
        console.debug("ERROR: StartClock was already running, but start() was called again - this is a programmer error and should not happen")
        return
      }

      running = true
    }

    function pause() {
      running = false

      if(squabyCreator.enabled) {
        squabyCreator.pause()
      }
    }

    // is only called when switchted to the levelEditing state - the squaby creation should not be paused then, but fully stopped
    function stop() {
      running = false
    }

    onEnabledChanged: {
        if(enabled && !running) {
            running = true;
        }
        if(!enabled && running)
            running = false;
    }

    onRunningChanged: {
        // only allow setting running to true when enabled is true!
        if(running && !enabled) {
            console.debug("Start Clock: running was true, but enabled was false, thus change running to false as well");
            running = false;
        }
    }

    Rectangle {
      id: background
      x: scene.gameWindowAnchorItem.x
      y: scene.gameWindowAnchorItem.y
      width: scene.gameWindowAnchorItem.width
      height: scene.gameWindowAnchorItem.height

      opacity: 0.2
      MouseArea {
        anchors.fill: parent
        onClicked: {
          stop()
          startClock.triggerClock()
        }
      }
      color: "black"
      visible: false
    }

    Text {
      id: startGameCountdown
      visible: background.visible
      color: "white"
      anchors.verticalCenter: parent.verticalCenter
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenterOffset: -hud.height/2
      text: qsTr("Tap to Start") + (levelEditor.currentLevelNameString.toLowerCase().search("level")<0 ? qsTr(" Level") : "")
      font.family: jellyFont.name
      font.pixelSize: 42
    }
    Text {
      visible: background.visible
      color: "white"
      anchors.top: startGameCountdown.bottom
      anchors.topMargin: 2
      anchors.horizontalCenter: parent.horizontalCenter
      text: levelEditor.currentLevelNameString
      font.family: jellyFont.name
      font.pixelSize: 42
    }

    function triggerClock() {
       background.visible = false
       if(tutorials.running && !scene.cameFromLevelEditing) {
         tutorials.nextAction("startClock","startGame")
       } else {
         squabyCreator.restart()
       }
    }
}
