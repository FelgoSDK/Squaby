import QtQuick 2.0
import VPlay 2.0

import "otherScenes"

SquabySceneBase {
  id: splashScreen

  state: "exited"

  signal loadingFinished()

  Rectangle {
    anchors.fill: gameWindowAnchorItem
    color: "#38577a"
  }

  MultiResolutionImage {
    id: squabyBg
    source: "../assets/img/SplashScreen.png"
    anchors.centerIn: gameWindowAnchorItem
  }

  // Called when scene is displayed
  function enterScene() {
    state = "entered"
    opacity = 1.0
  }
  function exitScene() {
    opacity = 0.0
  }

  Behavior on opacity {
    PropertyAnimation {
      duration: 600
      onRunningChanged: {
        if(!running) {
          if(splashScreen.opacity === 0.0) {
            loadingFinished()
          }
        }
      }
    }
  }
}
