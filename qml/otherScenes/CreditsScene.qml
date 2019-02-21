import QtQuick 2.0
import Felgo 3.0
import "../common/"
// This scene is only displayed if there is no gamecenter connection
SquabySceneBase {
  id: creditsScene

  state: "exited"

  onBackButtonPressed: {
    creditsScene.state = "exited"
    sceneChangeTimer.start()
  }

  MultiResolutionImage {
    source: "../../assets/img/bgSubmenu.png"
    anchors.centerIn: parent
    property int pixelFormat: 3
  }

  Column {
    id: leftColumn
    x: 30
    y: 20
    spacing: 10

    Text {
      text: qsTr("Felgo Team:\nAlex Leutgoeb\nChristian Feldbacher\nDavid Berger")
      color: "white"
      font.family: hudFont.name
      font.pixelSize: 13
    }

    Text {
      text: qsTr("Game Design:\nAlexander Dammerer")
      color: "white"
      font.family: hudFont.name
      font.pixelSize: 13
    }

    Column {
      Text {
        text: qsTr("Graphics:\nWolfgang Hoffelner")
        color: "white"
        font.family: hudFont.name
        font.pixelSize: 13
      }

      Image {
        source: "../../assets/img/woho-logo.png"
        height: 40
        fillMode: Image.PreserveAspectFit

        MouseArea {
          anchors.fill: parent
          onClicked: nativeUtils.openUrl("http://www.wo-ho.at")
        }
      }
    }



    Text {
      text: qsTr("Sounds:\nMartin Lenzelbauer")
      color: "white"
      font.family: hudFont.name
      font.pixelSize: 13
    }
  }

  Column {
    id: rightColumn
    x: creditsScene.width/ 2 + 30
    y: 20
    spacing: 20

    Text {
      text: qsTr("Initial Squaby Team:\nRoman Divotkey\nXue Cheng\nMartin Grammer\nChristian Herzog\nMatthias Hochgatterer\nMartina Karrer\nFlorian Lettner\nMario Moser\nPhilipp Rakuschan\nJohannes Stuehler")
      color: "white"
      font.family: hudFont.name
      font.pixelSize: 13
    }
  }


  Item {
    id: button
    height: b1.height
    anchors.left: parent.gameWindowAnchorItem.left
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 30

    MainMenuButton {
      id: b1

      text: qsTr("Back")

      onClicked: {
        creditsScene.state = "exited"
        sceneChangeTimer.start()
      }

      Timer {
        id: sceneChangeTimer
        interval: b1.slideDuration
        onTriggered: window.state = "main"
      }
    }
  }

  Column {
    id: logoColumn
    anchors.top: button.top
    anchors.topMargin: -8
    anchors.left: rightColumn.left
    spacing: 8

    Text {
      text: qsTr("Proudly developed with")
      color: "white"
      font.family: hudFont.name
      font.pixelSize: 11
    }

    Image {
      source: "../../assets/img/felgo.png"
      // the image size is bigger (for hd2 image), so only a single image no multiresimage can be used
      // this scene is not performance sensitive anyway!
      fillMode: Image.PreserveAspectFit
      height: 55

      MouseArea {
        anchors.fill: parent
        onClicked: nativeUtils.openUrl("https://felgo.com/showcases/?utm_medium=game&utm_source=squaby&utm_campaign=squaby#squaby");
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
      PropertyChanges { target: leftColumn; opacity: 1 }
      PropertyChanges { target: rightColumn; opacity: 1 }
      PropertyChanges { target: logoColumn; opacity: 1 }
      StateChangeScript {
        script: {
          b1.slideIn();
        }
      }
    },
    State {
      name: "exited"
      PropertyChanges { target: leftColumn; opacity: 0 }
      PropertyChanges { target: rightColumn; opacity: 0 }
      PropertyChanges { target: logoColumn; opacity: 0 }
      StateChangeScript {
        script: {
          b1.slideOut();
        }
      }
    }
  ]

  transitions: Transition {
    NumberAnimation {
      duration: 900
      property: "opacity"
      easing.type: Easing.InOutQuad
    }
  }

}
