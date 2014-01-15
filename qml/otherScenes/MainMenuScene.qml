import QtQuick 1.1
import VPlay 1.0

// is shown at game start and shows the maximum highscore and a button for starting the game
SquabySceneBase {
  id: mainMenuScene

  state: "exited"

  signal playClicked
  signal myLevelsClicked
  signal creditsClicked

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

  Image {
    width: 50
    height: 40
    source: settings.soundEnabled ? "../img/audio-enabled-500x400.png" : "../img/audio-mute-500x400.png"
    anchors.bottom: gameWindowAnchorItem.bottom
    // move slightly to the bottom, so the bottom border of the image is not visible (as it is distracting)
    anchors.bottomMargin: -1

    anchors.left: facebookLink.right
    // move a bit to the right so it looks better
    anchors.leftMargin: 15

    // this icon should only be displayed on Symbian & Meego, because on the other platforms the volume hardware keys work; but on Sym & Meego the volume cant be adjusted as the hardware volume keys are not working
    // also, display it when in debug build for quick toggling the sound
    visible: system.debugBuild || system.isPlatform(System.Meego) || system.isPlatform(System.Symbian)

    MouseArea {
      anchors.fill: parent
      onClicked: {
        settings.soundEnabled = !settings.soundEnabled
      }
    }
  }

  Image {
    id: facebookLink
    width: height
    height: 40-3
    source: "../img/facebook-logo-hd2.png"
    anchors.bottom: gameWindowAnchorItem.bottom
    // move slightly to the bottom, so the bottom border of the image is not visible (as it is distracting)
    anchors.bottomMargin: 3

    anchors.left: gameWindowAnchorItem.left
    // move a bit to the right so it looks better
    anchors.leftMargin: 15

    MouseArea {
      anchors.fill: parent
      onClicked: {
        facebook.openVPlayFacebookSite()
      }
    }
  }

  // the v-play logo does not really look good here
//  Image {
//    x: 5
//    y: 235
//    source: "../img/vplay.png"
//    // the image size is bigger (for hd2 image), so only a single image no multiresimage can be used
//    // this scene is not performance sensitive anyway!
//    fillMode: Image.PreserveAspectFit
//    height: 35
//    MouseArea {
//      anchors.fill: parent
//      onClicked: nativeUtils.openUrl("http://v-play.net");
//    }
//  }

  Column {
    y:15
    spacing: 4

    // Play button
    MainMenuButton {
      id: b1

      text: qsTr("Play")

      onClicked: {
        console.debug(text, " button clicked, start the game")
        mainMenuScene.state = "exited"

        playClicked()
      }
    }

    MainMenuButton {
      id: b2

      offsetX: 20
      delay: 500
      text: qsTr("Highscore")

      onClicked: {
        console.debug(text, "button clicked")

        if (gameCenter.authenticated) {
          // Show Game Center overlay
          gameCenter.showLeaderboard();
        }
        else {
          // Display highscore scene alternatively
          mainMenuScene.state = "exited"
          window.state = "highscore"
        }
      }
    }

    MainMenuButton {
      id: b3

      offsetX: 40
      delay: 1000
      text: qsTr("Credits")

      onClicked: {
        console.debug(text, " button clicked")

        creditsClicked()

        mainMenuScene.state = "exited"
        window.state = "credits"
      }
    }


    MainMenuButton {
      id: b4
      offsetX: 60
      delay: 1500

      text: qsTr("My Levels")

      // do not show the levels option for the public game yet, only for testing at the moment!
      // the level editing is not finalized, thus dont add it to the final game yet
      visible: allowMultipleLevels

      onClicked: {
        console.debug(text, " button clicked, start the game")
        myLevelsClicked()
      }
    }

  } // end of Column

  Connections {
    // nativeUtils should only be connected, when this is the active scene
      target: activeScene === mainMenuScene ? nativeUtils : null
      onMessageBoxFinished: {
        console.debug("the user confirmed the Ok/Cancel dialog with:", accepted)
        if(accepted)
          Qt.quit()
      }
  }

  onBackPressed: {
    nativeUtils.displayMessageBox(qsTr("Really quit the game?"), "", 2);
    // instead of immediately shutting down the app, ask the user if he really wants to exit the app with a native dialog
    //Qt.quit()
  }

  // Called when scene is displayed
  function enterScene() {
    state = "entered"
  }

  states: [
    State {
      name: "entered"
      PropertyChanges { target: squabyBg; opacity: 1 }
      StateChangeScript {
        script: {
          b1.slideIn();
          b2.slideIn();
          b3.slideIn();
          b4.slideIn();
        }
      }
    },
    State {
      name: "exited"
      PropertyChanges { target: squabyBg; opacity: 0 }
      StateChangeScript {
        script: {
          b1.slideOut();
          b2.slideOut();
          b3.slideOut();
          b4.slideOut();
        }
      }
    }
  ]

  transitions: Transition {
      NumberAnimation {
        target: squabyBg
        duration: 900
        property: "opacity"
        easing.type: Easing.InOutQuad
      }
    }

}
