import QtQuick 1.1
import VPlay 1.0

// This scene is only displayed if there is no gamecenter connection
SquabySceneBase {
  id: creditsScene

  state: "exited"

  onBackPressed: {
    creditsScene.state = "exited"
    sceneChangeTimer.start()
  }

  MultiResolutionImage {
    source: "../img/bgSubmenu-sd.png"
    anchors.centerIn: parent
    property int pixelFormat: 3
  }

  Column {
    id: leftColumn
    x: 30
    y: 20
    spacing: 10

    Text {
      text: qsTr("V-Play Team:\nAlex Leutgoeb\nChristian Feldbacher")
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
        source: "../img/woho-logo.png"
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


  MainMenuButton {
    id: b1

    text: qsTr("Back")

    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 30

    onClicked: {
      console.debug(text, " button clicked")

      creditsScene.state = "exited"
      sceneChangeTimer.start()
    }

    Timer {
      id: sceneChangeTimer
      interval: b1.slideDuration
      onTriggered: window.state = "main"
    }
  }

  Column {
    id: logoColumn
    anchors.top: b1.top
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
      source: "../img/vplay.png"
      // the image size is bigger (for hd2 image), so only a single image no multiresimage can be used
      // this scene is not performance sensitive anyway!
      fillMode: Image.PreserveAspectFit
      height: 55

      MouseArea {
        anchors.fill: parent
        onClicked: nativeUtils.openUrl("http://v-play.net");
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
