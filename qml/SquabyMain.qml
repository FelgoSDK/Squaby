import QtQuick 2.0
import VPlay 2.0
// Plugins
import VPlayPlugins.flurry 1.0
import VPlayPlugins.infinario 1.0

import "common"

GameWindow {
  id: window
  width: 960//480 // for testing on desktop with the highest res, use *1.5 so the -hd2 textures are used
  height: 640//320

  // You get free licenseKeys from http://v-play.net/licenseKey
  // With a licenseKey you can:
  //  * Publish your games & apps for the app stores
  //  * Remove the V-Play Splash Screen or set a custom one (available with the Pro Licenses)
  //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
  //licenseKey: "<generate one from http://v-play.net/licenseKey>"


  settings.style: SquabyStyle {}
//  fullscreen: false

  // for better readability of the fps, make them white
//  fpsTextItem.color: "white"

  // this would disable the fps label both for QML & cocos renderer - if only qml renderer should be disabled use fpsTextItem.visible: false
//  displayFpsEnabled: developerBuild

  // set this to false for the retail version for the store, and when releasing as demo for the V-Play SDK
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
    // the licenseKey of this plugin only works with this demo game; you get licenseKeys for your games for free with a V-Play license (www.v-play.net/license/plugins)
    licenseKey: "1802219D9DB5B476BA12870EB3692921CF8F51009303CD091C54CAE8FB752667BB25303DB9D850EB8B6926F4BFE64424E2E8A5FF0CA7388E685BB0F1FD1D58EED1CF3F6DF719AD6F70A6CFDAF6C22DA6C689D92CD429BB6D030E5844E7E63B20E66583D981906CB4262600EE44D09A1A10497DBB4A4F9361811F3DD3B9BBFBEF79568E8A54B6DF2F8DF60BFB84227DE6"
    // this is the app key for the Squaby-SDK-Demo, be sure to get one for your own application if you want to use Flurry
    apiKey: "QQT3CKTQDGF7XGMFSF97"
  }

  // the Infinario Analytics plugin is available on all plaforms
  // it is useful for tracking game design & improving it
  Infinario {
      id: infinario
      token: 'b772896e-bb7d-11e4-943b-b083fedeed2e'
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
