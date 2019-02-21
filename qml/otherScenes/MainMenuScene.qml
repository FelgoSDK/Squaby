import QtQuick 2.0
import Felgo 3.0
import "../common"

SquabySceneBase {
  id: mainMenuScene

  state: "exited"

  signal playClicked
  signal myLevelsClicked
  signal creditsClicked
  signal gameNetworkViewClicked

  property string exitAction: ""
  // only if this is set to true, the exit dialog should quit the app
  property bool exitDialogShown: false
  property bool vplayLinkShown: false

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

  Column {
    id: menuColumn
    anchors.left: parent.gameWindowAnchorItem.left
    y:15
    spacing: 4

    // Play button
    MainMenuButton {
      id: b1

      offsetX: -80

      text: qsTr("Play")

      onClicked: {
        mainMenuScene.state = "exited"
        exitAction = "playClicked"
      }
    }

    MainMenuButton {
      id: b2

      offsetX: -60
      delay: 500
      text: qsTr("Levels")

      onClicked: {
        mainMenuScene.state = "exited"
        exitAction = "myLevelsClicked"
      }
    }

    MainMenuButton {
      id: b3

      offsetX: -40
      delay: 1000
      text: qsTr("Credits")

      onClicked: {
        mainMenuScene.state = "exited"
        exitAction = "creditsClicked"
      }
    }

    MainMenuButton {
      id: settingsButton
      slideInFromRight: false

      offsetX: (system.isPlatform(System.IOS) || system.isPlatform(System.Android)) ? -410 : -310
      delay: 1500
      outslidedXBase: -115

      Row {
        id: moreSubRowMyLevels
        spacing: 10
        y: 1
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 5

        // Music
        MenuButton {
          source: "../../assets/img/menu-settings-music.png"
          active: !settings.musicEnabled
          onClicked: {
            settings.musicEnabled ^= true
            flurry.logEvent("Settings.Changed","Music",settings.musicEnabled)
          }
        }
        // Sound
        MenuButton {
          source: "../../assets/img/menu-settings-sound.png"
          active: !settings.soundEnabled
          onClicked: {
            settings.soundEnabled ^= true
            flurry.logEvent("Settings.Changed","Sound",settings.musicEnabled)
          }
        }

        Item {
          width: adsButton.width
          height: adsButton.height
          visible: system.isPlatform(System.IOS) || system.isPlatform(System.Android)

          MultiResolutionImage {
            id: adsButton
            source: "../../assets/img/menu-ad-purchased.png"
            visible: levelStore.noAdsGood.purchased
          }
          MultiResolutionImage {
            source: "../../assets/img/menu-ad.png"
            visible: !levelStore.noAdsGood.purchased
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              parent.scale = 1.0
              if(!levelStore.noAdsGood.purchased) {
                flurry.logEvent("Store","Advert")
                levelStore.buyItem(levelStore.noAdsGood.itemId)
              }
            }
            onPressed: {
              parent.scale = 0.85
            }
            onReleased: {
              parent.scale = 1.0
            }
            onCanceled: {
              parent.scale = 1.0
            }
          }
        }

        Item {
          width: fbSettingsButton.width
          height: fbSettingsButton.height
          visible: system.isPlatform(System.IOS) || system.isPlatform(System.Android)

          MultiResolutionImage {
            id: fbSettingsButton
            source: "../../assets/img/menu-settings-fb-on.png"
            visible: gameNetwork.facebookConnectionSuccessful
          }
          MultiResolutionImage {
            source: "../../assets/img/menu-settings-fb-off.png"
            visible: !gameNetwork.facebookConnectionSuccessful
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              parent.scale = 1.0
              flurry.logEvent("Store","Facebook")
              gameNetworkViewClicked()
            }
            onPressed: {
              parent.scale = 0.85
            }
            onReleased: {
              parent.scale = 1.0
            }
            onCanceled: {
              parent.scale = 1.0
            }
          }
        }

        MenuButton {
          source: "../../assets/img/menu-settings.png"
          active: !settingsButton.slidedOut
          onClicked: {
            if(settingsButton.slidedOut) {
              settingsButton.slideIn()
            } else {
              settingsButton.slideOut()
            }
          }
        }
      }
    }
  } // end of Column

  Image {
    id: logo
    anchors.left: mainMenuScene.gameWindowAnchorItem.left
    anchors.leftMargin: 10
    anchors.bottom: mainMenuScene.gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    source: "../../assets/img/felgo-logo.png"
    // the image size is bigger (for hd2 image), so only a single image no multiresimage can be used
    // this scene is not performance sensitive anyway!
    fillMode: Image.PreserveAspectFit
    height: 55

    MouseArea {
      anchors.fill: parent
      onClicked: {
        vplayLinkShown = true
        flurry.logEvent("MainScene.ShowDialog.VPlayWeb")
        nativeUtils.displayMessageBox(qsTr("Felgo"), qsTr("This game is built with Felgo. The source code is available in the free Felgo SDK - so you can build your own tower defense in minutes! Visit Felgo.net now?"), 2)
      }
    }

    SequentialAnimation {
      running: true
      loops: -1
      NumberAnimation { target: logo; property: "opacity"; to: 0.1; duration: 1200 }
      NumberAnimation { target: logo; property: "opacity"; to: 1; duration: 1200 }
    }
  }

  Connections {
    // nativeUtils should only be connected, when this is the active scene
      target: activeScene === mainMenuScene ? nativeUtils : null
      onMessageBoxFinished: {
        console.debug("the user confirmed the Ok/Cancel dialog with:", accepted)
        if(accepted && exitDialogShown) {
          Qt.quit()
        } else if(accepted && vplayLinkShown) {
          flurry.logEvent("MainScene.Show.VPlayWeb")
          nativeUtils.openUrl("https://felgo.com/showcases/?utm_medium=game&utm_source=squaby&utm_campaign=squaby#squaby");
        }

        // set it to false again
        exitDialogShown = false
        vplayLinkShown = false
      }
  }

  onBackButtonPressed: {
    exitDialogShown = true
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
      PropertyChanges { target: settingsButton; opacity: 1 }

      StateChangeScript {
        script: {
          b1.slideIn();
          b2.slideIn();
          b3.slideIn();
          //settingsButton.slideIn();
        }
      }
    },
    State {
      name: "exited"
      PropertyChanges { target: squabyBg; opacity: 0 }
      PropertyChanges { target: settingsButton; opacity: 0 }
      StateChangeScript {
        script: {
          b1.slideOut();
          b2.slideOut();
          b3.slideOut();
          settingsButton.slideOut();
          sceneChangeTimer.start()
        }
      }
    }
  ]

  Timer {
    id: sceneChangeTimer
    interval: b3.slideDuration
    onTriggered: {
      if(exitAction === "playClicked") {
        playClicked()
      } else if(exitAction === "myLevelsClicked") {
        myLevelsClicked()
      } else if(exitAction === "creditsClicked") {
        creditsClicked()
      }
    }
  }

  transitions: Transition {
      NumberAnimation {
        targets: [squabyBg,settingsButton]
        duration: 900
        property: "opacity"
        easing.type: Easing.InOutQuad
      }
    }

}
