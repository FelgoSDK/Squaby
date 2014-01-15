import QtQuick 1.1
import VPlay 1.0

// Shown when the player presses the menu button during a game
SquabySceneBase {
  id: pauseScene

  state: "exited"

  // Used to temporarly save the next window state
  property string __nextWindowState

  // when this is called, scene.restart() will be called
  signal restartGame()

  onBackPressed: {
    // return to game (NOT the main menu) when back is pressed in the pause menu
    __nextWindowState = "game"
    pauseScene.state = "exited"
  }

  Rectangle {
    id: bgRectangle

    anchors.fill: gameWindowAnchorItem
    color: "black"
    opacity: 0.5
  }

  // resume the game, when clicked anywhere else
  MouseArea {
    anchors.fill: parent
    onClicked: {
      __nextWindowState = "game"
      pauseScene.state = "exited"
    }
  }

  Column {
    y:50
    spacing: 10

    MainMenuButton {
      id: b1

      text: qsTr("Resume")

      onClicked: {
        console.debug(text, "button clicked")
        __nextWindowState = "game"
        pauseScene.state = "exited"
      }
    }

    MainMenuButton {
      id: b2

      offsetX: 20
      delay: 500
      text: qsTr("Restart")

      onClicked: {
        console.debug(text, "button clicked")

        // NOTE: this must be called BEFORE the state of the pauseScene is changed!
        // otherwise, the SquabyScene gets called its enterScene(), and there the wasInPauseBefore is still set
        // so the timer would be called twice - once in enterScene, and again in restart()
        restartGame()

        __nextWindowState = "game"
        pauseScene.state = "exited"
      }
    }

    MainMenuButton {
      id: b3

      offsetX: 40
      delay: 1000
      text: qsTr("Main Menu")

      onClicked: {
        console.debug(text, "button clicked")
        __nextWindowState = "main"
        pauseScene.state = "exited"
      }
    }
  }

  // Called when scene is displayed
  function enterScene() {
    state = "entered"
  }

  states: [
    State {
      name: "entered"
      PropertyChanges { target: bgRectangle; opacity: 0.5 }
      StateChangeScript {
        script: {
          b1.slideIn();
          b2.slideIn();
          b3.slideIn();
        }
      }
    },
    State {
      name: "exited"
      PropertyChanges { target: bgRectangle; opacity: 0 }
      StateChangeScript {
        script: {
          b1.slideOut();
          b2.slideOut();
          b3.slideOut();
        }
      }
      StateChangeScript {
        name: "changeSceneScript"
        script: {
          // Check if we have a next windows state, otherwise the default one would be set on launch
          if (__nextWindowState != "") {
            window.state = __nextWindowState
            __nextWindowState = ""
          }
        }
      }
    }
  ]

  transitions: Transition {
    SequentialAnimation {
      // First fade the background out (buttons are slided simultaneously) and afterwards change the window's state
      NumberAnimation {
        target: bgRectangle
        duration: 900
        property: "opacity"
        easing.type: Easing.InOutQuad
      }
      ScriptAction { scriptName: "changeSceneScript" }
    }
  }

}
