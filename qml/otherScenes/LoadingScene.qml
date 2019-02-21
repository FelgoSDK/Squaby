import QtQuick 2.0
import Felgo 3.0

// is shown at game start and shows the maximum highscore and a button for starting the game
SquabySceneBase {
  id: loadingScene

  state: "exited"

  signal finishedLoadingAnimation

  MultiResolutionImage {
    source: "../../assets/img/bgSubmenu.png"
    anchors.centerIn: parent
    property int pixelFormat: 3
  }

  MultiResolutionImage {
    id: squabyBg
    source: "../../assets/img/bgMainmenu.png"
    anchors.centerIn: parent
  }


  Text {
    text: "Loading..."
    color: "white"
    font.family: jellyFont.name
    font.pixelSize: 42

    x: 75
    y: 50

  }


  // Called when scene is displayed
  function enterScene() {
    state = "entered"
  }

  onStateChanged: console.debug("LoadingScene.state changed to", state)

  /*onOpacityChanged: {
    console.debug("LoadingScene opacity:", opacity)
    // this would be too early! the cocos opacity would not be affected here
//    if(opacity >= 1)
//      finishedLoadingAnimation()
  }*/

  Timer {
    id: opacityAnimationFinishedTimer
    interval: 4*opacityAnimation.duration

    onTriggered: {
      console.debug("finished opacity animation!?")
      finishedLoadingAnimation()

      // switch back to state exited, so the timer can be started again next time the loading scene is entered
      // do NOT change to exited state here, but just when the state is changed
      //loadingScene.state = "exited"
    }

  }

  states: [
    State {
      name: "entered"
      PropertyChanges { target: squabyBg; opacity: 1 }
      StateChangeScript {
        script: {
          opacityAnimationFinishedTimer.start()
        }
      }
    },
    State {
      name: "exited"
      PropertyChanges { target: squabyBg; opacity: 0 }
    }
  ]

  transitions: Transition {
    NumberAnimation {
      id: opacityAnimation
      target: squabyBg
      duration: 900
      property: "opacity"
      easing.type: Easing.InOutQuad
    }
  }
}
