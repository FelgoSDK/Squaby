import QtQuick 2.0
import Felgo 3.0

import "../common"
import "../gameScene/hud"

// Shown when the player defeates the last wave during a game
SquabySceneBase {
  id: waveDefeatedScene

  state: "exited"

  // Used to temporarly save the next window state
  property string __nextWindowState

  // when this is called, scene.restart() will be called
  signal restartGame

  // when this is called, scene.continueGame() will be called
  signal continueGame

  // when this is called, scene.nextLevel() will be called
  signal nextLevel

  // when this is called, scene.exitScene() will be called
  signal gameOver

  signal showHighscoreForLevel(string leaderboard)

  property bool showNextLevelButton: true

  property int localHighscore: player.score+player.gold*1.5+player.lives*100+player.instantBonus
  // NOTE: currentImprovement cannot be < -1! if the user increases his highscoreteam, he cannot loose a position; 0 is returned if the position didn't change
  property int currentImprovement: 0

  onBackButtonPressed: {
    if(window.state === "pause") {
      // return to game (NOT the main menu) when back is pressed in the pause menu
      __nextWindowState = "game"
      waveDefeatedScene.state = "exited"
    } else {
      __nextWindowState = "levels"
      gameOver()
      waveDefeatedScene.state = "exited"
    }
  }

  Rectangle {
    id: bgRectangle

    anchors.fill: gameWindowAnchorItem
    color: "black"
    opacity: 0.5

    MouseArea {
      anchors.fill: parent
      onClicked: {
        if(window.state === "pause") {
          __nextWindowState = "game"
          waveDefeatedScene.state = "exited"
        }
        // just eat the event so the user can not press anything in the game scene.
      }
    }

    onOpacityChanged: {
      if(opacity <= 0) {
        // Check if we have a next windows state, otherwise the default one would be set on launch
        if (__nextWindowState != "") {
          window.state = __nextWindowState
          __nextWindowState = ""
        }
      }
    }

    // AdMob is not implemented yet
    AdMobBanner {
      id: admobSmart
      // Add your own adUnitId here - this one is owned by Felgo and just for demo purposes
      // If you do not have an AdMob account yet, you can create a new one at http://www.google.com/ads/admob/
      // you could also use a different adUnit id for iOS & Android
      adUnitId: "ca-app-pub-9155324456588158/5512522827"
      // Enter your testDeviceIds here, so your adUnitId does not get blocked by Google
      testDeviceIds: [ ]
      visible: !levelStore.noAdsGood.purchased && window.state === "pause"
      //anchors.horizontalCenter: parent.horizontalCenter
      //anchors.top: parent.top
      // the AdMob.Smart enum is only available on the platforms where the AdMob plugin is supported, so only on iOS & Android
      banner: (system.isPlatform(System.IOS) || system.isPlatform(System.Android)) ? AdMobBanner.Smart : undefined
    }
  }

  Text {
    id: winText
    text: qsTr("You succeeded in ") + (levelEditor.currentLevelNameString.toLowerCase().search("level")<0 ? qsTr("level ") : "" ) +((typeof levelEditor.currentLevelNameString !== "undefined") ? levelEditor.currentLevelNameString : "") +" !"
    font.family: jellyFont.name
    color: "white"
    font.pixelSize: 30
    anchors.bottom: menuBox.top
    anchors.bottomMargin: 8
    anchors.horizontalCenter: parent.gameWindowAnchorItem.horizontalCenter

    visible: window.state !== "pause" && window.state !== "gameover"
  }

  Text {
    id: statusText
    text: window.state === "gameover" ? qsTr("Game over") : qsTr("Paused")

    font.family: jellyFont.name
    color: "white"
    font.pixelSize: 50
    anchors.horizontalCenter: parent.gameWindowAnchorItem.horizontalCenter
    anchors.verticalCenter: parent.gameWindowAnchorItem.verticalCenter
    anchors.verticalCenterOffset: -hud.height/2

    visible: window.state === "pause" || window.state === "gameover"
  }

  MultiResolutionImage {
    id: menuBox
    anchors.centerIn: parent.gameWindowAnchorItem
    anchors.verticalCenterOffset: -hud.height/2+15
    source: "../../assets/img/menu-box.png"
    visible: window.state !== "pause" && window.state !== "gameover"

    Text {
      id: scoreText
      text: qsTr("Score")

      font.family: jellyFont.name
      color: "white"
      font.pixelSize: 24


      anchors.top: parent.top
      anchors.topMargin: 10
      anchors.left: parent.left
      anchors.leftMargin: 5
    }

    Text {
      id: scoreTextResult
      text: player.score

      font.family: jellyFont.name
      color: "white"
      font.pixelSize: 24


      anchors.top: parent.top
      anchors.topMargin: 10
      anchors.right: parent.right
      anchors.rightMargin: 7
    }

    Text {
      id: goldText
      text: qsTr("Gold Bonus")

      font.family: jellyFont.name
      color: "white"
      font.pixelSize: 24


      anchors.top: scoreText.bottom
      anchors.topMargin: 1
      anchors.left: parent.left
      anchors.leftMargin: 5
    }

    Text {
      id: goldTextResult
      text: ~~(player.gold*1.5)

      font.family: jellyFont.name
      color: "white"
      font.pixelSize: 24


      anchors.top: scoreTextResult.bottom
      anchors.topMargin: 1
      anchors.right: parent.right
      anchors.rightMargin: 7
    }

    Text {
      id: livesText
      text: qsTr("Lives Bonus")

      font.family: jellyFont.name
      color: "white"
      font.pixelSize: 24


      anchors.top: goldText.bottom
      anchors.topMargin: 1
      anchors.left: parent.left
      anchors.leftMargin: 5
    }

    Text {
      id: livesTextResult
      text: player.lives*100

      font.family: jellyFont.name
      color: "white"
      font.pixelSize: 24


      anchors.top: goldTextResult.bottom
      anchors.topMargin: 1
      anchors.right: parent.right
      anchors.rightMargin: 7
    }

    Text {
      id: instantText
      text: qsTr("Wave Bonus")

      font.family: jellyFont.name
      color: "white"
      font.pixelSize: 24


      anchors.top: livesText.bottom
      anchors.topMargin: 1
      anchors.left: parent.left
      anchors.leftMargin: 5
    }

    Text {
      id: instantTextResult
      text: player.instantBonus

      font.family: jellyFont.name
      color: "white"
      font.pixelSize: 24


      anchors.top: livesTextResult.bottom
      anchors.topMargin: 1
      anchors.right: parent.right
      anchors.rightMargin: 7
    }

    MouseArea {
      anchors.fill: parent
      enabled: (level.nextLevelId ? true : false) && showNextLevelButton && window.state === "waveDefeated"
      onClicked: {
        parent.scale = 1.0
        nextLevel()
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

    MultiResolutionImage {
      id: levelbaseplate
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      source: "../../assets/img/menu-box-base.png"
      MouseArea {
        anchors.fill: parent
        onClicked: {
          parent.scale = 1.0
          if(levelEditor.currentLevelStorageLocation === levelEditor.authorGeneratedLevelsLocation) {
            waveDefeatedScene.showHighscoreForLevel(levelEditor.currentLevelData.levelMetaData.publishedLevelId)
          } else if(levelEditor.currentLevelStorageLocation === levelEditor.userGeneratedLevelsLocation) {
            waveDefeatedScene.showHighscoreForLevel(levelEditor.currentLevelData.levelMetaData.levelId)
          } else if(levelEditor.currentLevelStorageLocation === levelEditor.applicationJSONLevelsLocation) {
            waveDefeatedScene.showHighscoreForLevel(levelEditor.currentLevelId)
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

    Text {
      id: highScoreNumberText

      anchors.right: levelbaseplate.right
      anchors.rightMargin: 10
      anchors.verticalCenter: leaderItem.verticalCenter
      text: localHighscore
      color: "white"
      font.family: jellyFont.name
      font.pixelSize: 30
    }

    Item {
      id: leaderItem
      width: leaderBoard.width+3+positionText.width
      height: leaderBoard.height*2
      anchors.left: levelbaseplate.left
      anchors.leftMargin: 30
      anchors.bottom: levelbaseplate.bottom
      anchors.bottomMargin: 15

      MultiResolutionImage {
        id: leaderBoard
        anchors.verticalCenter: parent.verticalCenter
        source: "../../assets/img/level-base-vpgn.png"
      }

      Text {
        id: positionText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: leaderBoard.right
        anchors.leftMargin: 3
        //anchors.bottom: parent.bottom
        text: "#" + ((gameNetwork.userPositionForCurrentActiveLeaderboard !== -1) ? gameNetwork.userPositionForCurrentActiveLeaderboard : "-")
        color: "white"
        font.pixelSize: 30
        font.family: hudFont.name

      }
    }
  }

  MultiResolutionImage {
    id: leftNav
    visible: window.state !== "pause" && window.state !== "gameover" && !scene.cameFromLevelEditing && isCommunityLevel(levelEditor.currentLevelNameString)
    anchors.left: parent.gameWindowAnchorItem.left
    anchors.leftMargin: (menuBox.x-parent.gameWindowAnchorItem.x-width)/2
    anchors.verticalCenter: parent.gameWindowAnchorItem.verticalCenter
    anchors.verticalCenterOffset: -hud.height/2
    source: "../../assets/img/level-base.png"


    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 8
      text: qsTr("Create")
      color: "white"
      font.pixelSize: 16
      font.family: hudFont.name
    }

    MenuButton {
      anchors.centerIn: parent

      source: "../../assets/img/menu-new.png"
      active: false
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        parent.scale = 1.0
        levelScene.storageLocation = levelEditor.authorGeneratedLevelsLocation
        levelScene.oldState = "myLevels"
        __nextWindowState = "levels"
        waveDefeatedScene.state = "exited"
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

    Item {
      width: 96
      height: createLevelText.height

      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.horizontalCenter: parent.horizontalCenter

      ResponsiveText {
        id: createLevelText
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("your own levels")
        color: "white"
        font.family: hudFont.name
      }
    }

  }

  MultiResolutionImage {
    id: rightNav
    visible: window.state !== "pause" && window.state !== "gameover" && !scene.cameFromLevelEditing  && isCommunityLevel(levelEditor.currentLevelNameString)
    anchors.right: parent.gameWindowAnchorItem.right
    anchors.rightMargin: ((parent.gameWindowAnchorItem.x+parent.gameWindowAnchorItem.width)-(menuBox.x+menuBox.width)-width)/2
    anchors.verticalCenter: parent.gameWindowAnchorItem.verticalCenter
    anchors.verticalCenterOffset: -hud.height/2
    source: "../../assets/img/level-base.png"

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 8
      text: qsTr("Play")
      color: "white"
      font.pixelSize: 16
      font.family: hudFont.name
    }

    MenuButton {
      anchors.centerIn: parent

      source: "../../assets/img/menu-community.png"
      active: false
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        parent.scale = 1.0
        levelScene.storageLocation = levelEditor.authorGeneratedLevelsLocation
        levelScene.oldState = "communityLevels"
        __nextWindowState = "levels"
        waveDefeatedScene.state = "exited"
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

    Item {
      width: 96
      height: playLevelText.height

      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.horizontalCenter: parent.horizontalCenter

      ResponsiveText {
        id: playLevelText
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("community levels")
        color: "white"
        font.family: hudFont.name
      }
    }
  }

  MultiResolutionImage {
    id: subMenu
    anchors.bottom: parent.gameWindowAnchorItem.bottom
    anchors.horizontalCenter: parent.gameWindowAnchorItem.horizontalCenter
    source: "../../assets/img/menuBackground.png"

    // resume
    MenuButton {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 10

      source: "../../assets/img/button-play.png"
      active: false
      visible: window.state === "pause"
      onClicked: {
        __nextWindowState = "game"
        waveDefeatedScene.state = "exited"
      }
    }

    Row {
      anchors.centerIn: parent
      spacing: 20
      // Levels
      MenuButton {
        source: "../../assets/img/menu-grid.png"
        active: false
        visible: !scene.cameFromLevelEditing //&& (isCommunityLevel(levelEditor.currentLevelNameString) || window.state === "pause" || window.state === "gameover")
        onClicked: {
          flurry.logEvent("Defated.Grid","Last.State",levelScene.prevState)
          if(levelScene.prevState === "appLevels") {
            levelScene.storageLocation = levelEditor.applicationJSONLevelsLocation
            levelScene.oldState = "appLevels"
          } else if(levelScene.prevState === "communityLevels") {
            levelScene.storageLocation = levelEditor.authorGeneratedLevelsLocation
            levelScene.oldState = "communityLevels"
          } else if(levelScene.prevState ===  "myLevels") {
            levelScene.storageLocation = levelEditor.authorGeneratedLevelsLocation
            levelScene.oldState = "myLevels"
          } else if(levelScene.prevState ===  "myDownloadedLevels") {
            levelScene.storageLocation = levelEditor.authorGeneratedLevelsLocation
            levelScene.oldState = "myDownloadedLevels"
          } else {
            levelScene.storageLocation = levelEditor.applicationJSONLevelsLocation
            levelScene.oldState = "appLevels"
          }

          __nextWindowState = "levels"
          gameOver()
          waveDefeatedScene.state = "exited"
        }
      }
      // rate dialog
      MenuButton {
        source: "../../assets/img/star-big.png"
        active: false
        visible: !scene.cameFromLevelEditing  && isCommunityLevel(levelEditor.currentLevelNameString) && window.state === "waveDefeated" &&
                 (typeof levelEditor.currentLevelData != "undefined" && typeof levelEditor.currentLevelData.levelMetaData != "undefined" && typeof levelEditor.currentLevelData.levelMetaData["rating"] != "undefined")
        onClicked: {
          ratingDialog.currentRating = levelEditor.currentLevelData.levelMetaData["rating"]["quality"]
          ratingDialog.opacity = 1
        }
      }
      // restart
      MenuButton {
        source: "../../assets/img/button-replay.png"
        active: false
        //visible: window.state !== "waveDefeated" || isCommunityLevel(levelEditor.currentLevelNameString)
        onClicked: {
          // NOTE: this must be called BEFORE the state of the pauseScene is changed!
          // otherwise, the SquabyScene gets called its enterScene(), and there the wasInPauseBefore is still set
          // so the timer would be called twice - once in enterScene, and again in restart()
          restartGame()

          __nextWindowState = "game"
          waveDefeatedScene.state = "exited"
        }
      }
      // continues endless
      MenuButton {
        source: "../../assets/img/button-infinite.png"
        active: false
        // only show in real game modes
        visible: scene.endlessGameAllowed ? scene.endlessGameAllowed : false
        onClicked: {
          continueGame()

          __nextWindowState = "game"
          waveDefeatedScene.state = "exited"
        }
      }
      // next level
      MenuButton {
        source: "../../assets/img/button-fastforward.png"
        active: false
        visible: (level.nextLevelId ? level.nextLevelId : false) && showNextLevelButton && window.state === "waveDefeated"
        onClicked: {
          nextLevel()

          waveDefeatedScene.state = "exited"
        }
      }
    }

    Row {
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right
      anchors.rightMargin: 10
      spacing: 20
      visible: window.state === "pause"
      // Music
      MenuButton {
        source: "../../assets/img/menu-settings-music.png"
        active: !settings.musicEnabled
        onClicked: {
          settings.musicEnabled ^= true
          flurry.logEvent("Settings","Music",settings.musicEnabled)
        }
      }
      // Sound
      MenuButton {
        source: "../../assets/img/menu-settings-sound.png"
        active: !settings.soundEnabled
        onClicked: {
          settings.soundEnabled ^= true
          flurry.logEvent("Settings","Sound",settings.musicEnabled)
        }
      }
    }
  }

  DialogField {
    id: newPositionReached

    width: waveDefeatedScene.gameWindowAnchorItem.width
    height: waveDefeatedScene.gameWindowAnchorItem.height

    descriptionText: qsTr("You improved by ") + Math.abs(currentImprovement) + ((currentImprovement < 2) ? qsTr(" rank") : qsTr(" ranks"))+ qsTr(" and your new score is: ")+parent.localHighscore
    options1Text: qsTr("Ok")

    styledDialog: true

    opacity: (currentImprovement>0) ? 1.0 : 0.0

    onOption1Pressed: {
      // reset improved ranks, comes from server when improved
      currentImprovement = 0
    }

    property variant levelData
  }

  RatingDialog {
    id: ratingDialog
    opacity: 0

    property int levelId

    onLevelRated: {
      flurry.logEvent("Level.Rated",ratingDialog.levelId,rateValue)
      // levelId is required
      levelEditor.rateLevel( {levelId: ratingDialog.levelId, quality: rateValue })
      // to reload the server levels, maybe call another load here; but we don't know what was the last request (friend or all levels, which ordering, filtering etc.)
      // refresh level list after rating so it is visible
      levelScene.reloadLevels()
    }
  }

  // Called when scene is displayed
  function enterScene() {
    state = "entered"

    // tracking
    if (window.state === 'waveDefeated' || window.state === 'gameover') {
        var sum = 0;
        var n = Math.min(player.wave, scene.level.waves.length)
        for (var i = 0; i < n - 1; ++i) {
          sum += scene.level.waves[i].amount
        }
        sum += player.squabiesBuiltInCurrentWave

        var objectWithPlayerProperties = {
            state: (window.state === 'waveDefeated' ? 'victory' : window.state),
            level_id: levelEditor.currentLevelData.levelMetaData.levelId,
            level_name: levelEditor.currentLevelData.levelMetaData.levelName,
            monsters: sum
        };

        player.addPlayerPropertiesToAnalyticsObject(objectWithPlayerProperties);
    }


    if(window.state === "pause") {
      // use add mob here
      flurry.logEvent("Advert.Admob","Show")
    } else if(window.state === "gameover" && scene.state !== "levelEditing" && !levelStore.noAdsGood.purchased) {
      flurry.logEvent("Advert.Charboost","Show")
      chartboostView.showAdvertIfAvailable()
    }

    if(window.state === "pause" || window.state === "gameover") {
      flurry.logEvent("Defated","State",window.state)
      return
    }

    // in training mode, the currentLevelId is 0 and no highscore should be reported because there is no leaderboard for it
    // if in state testing (when testing the own level) this should also not be entered because no highscore should be submitted during testing
    if(scene.state !== "levelEditing" && levelEditor.currentLevelId && vplayGameNetworkScene.cameFromScene !== "waveDefeated") {
      gameNetwork.increaseGamesPlayed()
      console.debug("current levelId for highscore:", levelEditor.currentLevelId, levelEditor.currentLevelData.levelMetaData.levelId, vplayGameNetworkScene.cameFromScene)
      // if the level was started from the authorGeneratedLevels, the levelId is the local id and not the publishedLevelId!
      if(levelEditor.currentLevelStorageLocation === levelEditor.authorGeneratedLevelsLocation) {
        flurry.logEvent("Defated.Win","Player.Levels",levelEditor.currentLevelNameString)
        // this branch is only entered if the level was started to play (and not testing!) from the My Levels tab; so in that case, publishedLevelId must exist as otherwise the play mode cannot be entered
        gameNetwork.reportScore(localHighscore, levelEditor.currentLevelData.levelMetaData.publishedLevelId)
      } else if(levelEditor.currentLevelStorageLocation === levelEditor.userGeneratedLevelsLocation) {
        flurry.logEvent("Defated.Win","Community.Levels",levelEditor.currentLevelNameString)
        gameNetwork.defaultLeaderboardName = levelEditor.currentLevelData.levelMetaData.levelId
        gameNetwork.reportScore(localHighscore, levelEditor.currentLevelData.levelMetaData.levelId)
        // show a 5 star rating, and then rate with its value
        if(levelEditor.currentLevelData.levelMetaData && levelEditor.currentLevelData.levelMetaData["rating"] === undefined) {
          ratingDialog.currentRating = 0//levelEditor.currentLevelData.levelMetaData["rating"]["quality"]
          ratingDialog.opacity = 1
          ratingDialog.levelId = levelEditor.currentLevelData.levelMetaData.levelId
        }
      } else if(levelEditor.currentLevelStorageLocation === levelEditor.applicationJSONLevelsLocation) {
        flurry.logEvent("Defated.Win","App.Levels",levelEditor.currentLevelNameString)
        showNextLevelButton = unlockNextLevel(levelEditor.currentLevelNameString)
        gameNetwork.reportScore(localHighscore, levelEditor.currentLevelId)
      }
      levelScene.reloadLevels()
    }
    if(vplayGameNetworkScene.cameFromScene === "waveDefeated") {
      vplayGameNetworkScene.cameFromScene = ""
    }
  }

  states: [
    State {
      name: "entered"
      PropertyChanges { target: bgRectangle; opacity: 0.5 }
      PropertyChanges { target: subMenu; opacity: 1 }
      PropertyChanges { target: rightNav; opacity: 1 }
      PropertyChanges { target: leftNav; opacity: 1 }
      PropertyChanges { target: menuBox; opacity: 1 }
      PropertyChanges { target: statusText; opacity: 1 }
      PropertyChanges { target: winText; opacity: 1 }
    },
    State {
      name: "exited"
      PropertyChanges { target: bgRectangle; opacity: 0 }
      PropertyChanges { target: subMenu; opacity: 0 }
      PropertyChanges { target: rightNav; opacity: 0 }
      PropertyChanges { target: leftNav; opacity: 0 }
      PropertyChanges { target: menuBox; opacity: 0 }
      PropertyChanges { target: statusText; opacity: 0 }
      PropertyChanges { target: winText; opacity: 0 }
    }
  ]

  transitions: Transition {
    SequentialAnimation {
      // First fade the background out (buttons are slided simultaneously) and afterwards change the window's state
      NumberAnimation {
        targets: [bgRectangle,subMenu,rightNav,leftNav,menuBox,statusText]
        duration: 900
        property: "opacity"
        easing.type: Easing.InOutQuad
      }
    }
  }

  function positionChange(positionChange) {
    currentImprovement = positionChange
    console.debug("Player ranks improved by ",currentImprovement)
  }
}
