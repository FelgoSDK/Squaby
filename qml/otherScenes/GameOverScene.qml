import QtQuick 1.1
import VPlay 1.0

// This scene is only displayed if there is no gamecenter connection
SquabySceneBase {
  id: gameOverScene

  state: "exited"

  onBackPressed: {
    // return to main menu
    window.state = "main"
  }

  MultiResolutionImage {
    source: "../img/bgSubmenu-sd.png"
    anchors.centerIn: parent
    property int pixelFormat: 3
  }

  MultiResolutionImage {
    id: squabyBg
    source: "../img/bgMainmenu-sd.png"
    anchors.centerIn: parent
  }

  Column {
    id: gameOverColumn
    spacing: 20
    y: 20

    Text {
      id: gameOverText

      anchors.left: gameOverColumn.left
      anchors.leftMargin: 20

      text: qsTr("Game over")
      color: "white"
      font.family: jellyFont.name
      font.pixelSize: 42
    }

    Text {
      id: highScoreText

      anchors.left: gameOverColumn.left
      anchors.leftMargin: 20

      text: (player.score == player.maxScore ? qsTr("New Highscore:") : qsTr("Your score:")) + " " + player.score
      color: "white"
      font.family: jellyFont.name
      font.pixelSize: 36
    }

    MainMenuButton {
      id: b2

      text: qsTr("Restart")

      onClicked: {
        console.debug(text, " button clicked")
        scene.restartGame()
        window.state = "game"
      }
    }

    MainMenuButton {
      id: b1

      offsetX: 20
      delay: 500
      text: qsTr("Main Menu")

      onClicked: {
        console.debug(text, " button clicked")
        window.state = "main"
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
      StateChangeScript {
        script: {
          b1.slideIn();
          b2.slideIn();
        }
      }
    },
    State {
      name: "exited"
      StateChangeScript {
        script: {
          b1.slideOut();
          b2.slideOut();
        }
      }
    }
  ]

}
