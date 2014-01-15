import QtQuick 1.1
import VPlay 1.0

// This scene is only displayed if there is no gamecenter connection
SquabySceneBase {
  id: highScoreScene

  state: "exited"

  onBackPressed: {
    highScoreScene.state = "exited"
    sceneChangeTimer.start()
  }

  MultiResolutionImage {
    source: "../img/bgSubmenu-sd.png"
    anchors.centerIn: parent
    property int pixelFormat: 3
  }

  Text {
    id: highScoreText

    anchors.top: highScoreScene.top
    anchors.topMargin: 50
    anchors.left: highScoreScene.left
    anchors.leftMargin: 20

    text: qsTr("Highscore:") + " " + player.maxScore
    color: "white"
    font.family: jellyFont.name
    font.pixelSize: 42
  }

  MainMenuButton {
    id: b1

    text: qsTr("Back")

    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 30

    onClicked: {
      console.debug(text, " button clicked")

      highScoreScene.state = "exited"
      sceneChangeTimer.start()
    }

    Timer {
      id: sceneChangeTimer
      interval: b1.slideDuration
      onTriggered: window.state = "main"
    }
  }

  // Called when scene is displayed
  function enterScene() {
    state = "entered"
  }

  states: [
    State {
      name: "entered"
      PropertyChanges { target: highScoreText; opacity: 1 }
      StateChangeScript {
        script: {
          b1.slideIn();
        }
      }
    },
    State {
      name: "exited"
      PropertyChanges { target: highScoreText; opacity: 0 }
      StateChangeScript {
        script: {
          b1.slideOut();
        }
      }
    }
  ]

  transitions: Transition {
    NumberAnimation {
      target: highScoreText
      duration: 900
      property: "opacity"
      easing.type: Easing.InOutQuad
    }
  }

}
