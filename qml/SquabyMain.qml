import QtQuick 2.0
import Felgo 3.0

import "common"

GameWindow {
  id: window
  screenWidth: 960//480 // for testing on desktop with the highest res, use *1.5 so the -hd2 textures are used
  screenHeight: 640//320

  // You get free licenseKeys from https://felgo.com/licenseKey
  // With a licenseKey you can:
  //  * Publish your games & apps for the app stores
  //  * Remove the Felgo Splash Screen or set a custom one (available with the Pro Licenses)
  //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
  //licenseKey: "<generate one from https://felgo.com/licenseKey>"


  settings.style: SquabyStyle {}
//  fullscreen: false

  // for better readability of the fps, make them white
//  fpsTextItem.color: "white"

  // this would disable the fps label both for QML & cocos renderer - if only qml renderer should be disabled use fpsTextItem.visible: false
//  displayFpsEnabled: developerBuild

  // set this to false for the retail version for the store, and when releasing as demo for the Felgo SDK
  // in the developer version, the fps are displayed
  // also, cheating is possible by clicking on the closet
  property bool developerBuild: !system.publishBuild //false

  // set this to true, to get 100 gold when clicking on the closet - by default, it is only enabled when debugBuild is true
  // but for conventions & events, it is often better to allow this, but disable fps & performance options menu; in that case, set developerBuild to false as well!
  property bool cheatMoneyEnabled: developerBuild //true

  // regulate maximum number of particles dependent on screensize (which means also in cpu power in most cases)
  property int maximumParticles: (window.width < 960) ? 8 : 18
  property int currentParticles: 0

  // flurry is only available on iOS and Android, on all other platforms the log calls are just ignored
  Flurry {
    id: flurry
    // this is the app key for the Squaby-SDK-Demo, be sure to get one for your own application if you want to use Flurry
    apiKey: "QQT3CKTQDGF7XGMFSF97"
  }

  // Custom fonts
  FontLoader {
    id: jellyFont
    source: "fonts/JellyBelly.ttf"
  }

  // Custom font - jellybelly is very hard to read! thus use a different one!
  FontLoader {
    id: hudFont
    source: "fonts/COOPBL.ttf"
  }

  // the initial state should be the main state
  state: "main"

  BackgroundMusic {
    id: backgroundMusic
    // don't use mp3 on Symbian & MeeGo (they are not supported there), on all others play mp3
    // ogg is NOT supported on ios
    source: system.isPlatform(System.Symbian)||system.isPlatform(System.Meego)||system.isPlatform(System.BlackBerry) ? "../assets/snd/backgroundMusic.ogg" : "../assets/snd/backgroundMusic.mp3"
    volume: 0.6
  }

  Timer {
    id: splashScreenOff
    interval: 1000
    onTriggered: {
      if(splashLoader.item) {
        splashLoader.item.exitScene()
      }
    }
  }
  Timer {
    id: startLoading
    interval: 1000
    onTriggered: {
      // load actual game
      implLoader.source = "SquabyMainItem.qml"
    }
  }

  Connections {
    target: splashLoader.item ? splashLoader.item : null
    onLoadingFinished: {
      if(implLoader.item) {
        implLoader.item.activateMain()
      }
      // unload splashscreen
      splashLoader.source = ""
    }
  }

  Loader {
    id: splashLoader
    source: "SplashScreen.qml"
    onLoaded: {
      if(item) {
        item.enterScene()
      }
      startLoading.start()
    }
  }

  Loader {
    id: implLoader
    onLoaded: {
      if(item) {
        splashScreenOff.start()
      }
    }
  }

  onStateChanged: {
    if(implLoader.item) implLoader.item.state = state
  }

  onApplicationPaused: {
    if(implLoader.item) implLoader.item.pauseGame()
  }
}
