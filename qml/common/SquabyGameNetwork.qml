import QtQuick 2.0
import VPlay 2.0

VPlayGameNetwork {
  gameId: 73
  secret: "squabyDev"

  gameNetworkView: vplayGameNetworkScene.gameNetworkView

  facebookItem: facebook
  // enable if there is a GameNetwork error during development to clear the offline queue
  //clearOfflineSendingQueueAtStartup: true
  //clearAllUserDataAtStartup: true // enable this property if there was a failed request in any of the WebStorages, otherwise the request is re-sent at every app start

  property double positionChange: 0

  onUserInitiallyInSyncChanged: {

    if(userInitiallyInSync) {
      // this updates the userBestLevelStats of the LevelEditor to reward the player
      reloadUserBestLevelStats()
    }
  }

  achievements: [

    Achievement {
      key: "play10"
      name: "Hobby Defender"
      iconSource: "../../assets/img/achievements/hobby-defender.png"
      target: 10
      points: 5
      description: "Finish 10 game sessions"
    },
    Achievement {
      key: "play100"
      name: "Passionate Defender"
      iconSource: "../../assets/img/achievements/passionate-defender.png"
      target: 100
      points: 25
      description: "Finish 100 game sessions"
    },
    Achievement {
      key: "play1000"
      name: "Obsessed Defender"
      iconSource: "../../assets/img/achievements/obsessed-defender.png"
      target: 1000
      points: 50
      description: "Finish 1000 game sessions"
    },
    Achievement {
      key: "publish1"
      name: "Level Creator"
      iconSource: "../../assets/img/achievements/level-creator.png"
      target: 1
      points: 5
      description: "First level published"
    },
    Achievement {
      key: "publish10"
      name: "Level Creator Master"
      iconSource: "../../assets/img/achievements/level-creator-master.png"
      target: 10
      points: 10
      description: "Publish 10 levels"
    },
    Achievement {
      key: "publish100"
      name: "Level Creator Genius"
      iconSource: "../../assets/img/achievements/level-creator-genious.png"
      target: 100
      points: 50
      description: "Publish 100 levels"
    },
    Achievement {
      key: "rate4"
      name: "Quality Level Maker"
      iconSource: "../../assets/img/achievements/quality-level-maker.png"
      target: 1
      points: 5
      description: "One of your levels got rated with more than 4 stars"
    },
    Achievement {
      key: "download1"
      name: "Novice Level Maker"
      iconSource: "../../assets/img/achievements/novice-level-maker.png"
      target: 1
      points: 5
      description: "One of your levels got downloaded once"
    },
    Achievement {
      key: "download5"
      name: "Popular Level Maker"
      iconSource: "../../assets/img/achievements/popular-level-maker.png"
      target: 5
      points: 10
      description: "One of your levels got downloaded 5 times"
    },
    Achievement {
      key: "download10"
      name: "Great Level Maker"
      iconSource: "../../assets/img/achievements/great-level-maker.png"
      target: 10
      points: 15
      description: "One of your levels got downloaded 10 times"
    },
    Achievement {
      key: "download100"
      name: "Awesome Level Maker"
      iconSource: "../../assets/img/achievements/awesome-level-maker.png"
      target: 100
      points: 25
      description: "One of your levels got downloaded 100 times"
    },
    Achievement {
      key: "download1000"
      name: "Leading Level Maker"
      iconSource: "../../assets/img/achievements/leading-level-maker.png"
      target: 1000
      points: 50
      description: "One of your levels got downloaded 1000 times"
    },
    Achievement {
      key: "rated1"
      name: "Novice Level Rater"
      iconSource: "../../assets/img/achievements/novice-level-rater.png"
      target: 1
      points: 5
      description: "Rate 1 level"
    },
    Achievement {
      key: "rated10"
      name: "Cool Level Rater"
      iconSource: "../../assets/img/achievements/cool-level-rater.png"
      target: 10
      points: 10
      description: "Rate 10 levels"
    },
    Achievement {
      key: "rated100"
      name: "Leading Level Rater"
      iconSource: "../../assets/img/achievements/leading-level-rater.png"
      target: 100
      points: 25
      description: "Rate 100 levels"
    },
    Achievement {
      key: "downloader1"
      name: "Novice Level Downloader"
      iconSource: "../../assets/img/achievements/novice-level-downloader.png"
      target: 1
      points: 5
      description: "Download 1 level"
    },
    Achievement {
      key: "downloader10"
      name: "Awesome Level Downloader"
      iconSource: "../../assets/img/achievements/awesome-level-downloader.png"
      target: 10
      points: 10
      description: "Download 10 levels"
    },
    Achievement {
      key: "downloader100"
      name: "Major Level Downloader"
      iconSource: "../../assets/img/achievements/major-level-downloader.png"
      target: 100
      points: 25
      description: "Download 100 levels"
    }
  ]


  // do not use onAchievementUnlocked, because giving credits must be approved by the server, as devices may not be in sync
  onAchievementUnlockedAfterServerApproval: {

    // getAchievementFromKey() is a GameNetwork function to return the Achievement object from the achievements list
    var ach = getAchievementFromKey(key)
    levelStore.giveCurrency(ach.points)

    achievementOverlay.showAchievement(ach)
  }

  onNewHighscoreAfterServerApproval: {
    positionChange = posChange
    if(window.state === "waveDefeated") {
      waveDefeatedScene.positionChange(posChange)
    }
    updatePlayerNameIfNotSet()
  }

  // facebook signal and property handling:
  onFacebookSuccessfullyConnected: {
    if(facebookConnectionSuccessful) {
      var fbAlreadyConnected = settings.getValue("facebookLinked")
      if(!fbAlreadyConnected) {
        settings.setValue("facebookLinked",1)
        levelStore.giveItem("currency_money_id",5)
        nativeUtils.displayMessageBox(qsTr("Facebook Connected"), qsTr("You just successfully connected to facebook and you got 5 Credits, congrats!"))
      }
    }
  }
  onFacebookSuccessfullyDisconnected: {
    nativeUtils.displayMessageBox(qsTr("Facebook Disconnected"), qsTr("You just successfully disconnected from facebook..."))
  }
  onFacebookConnectionError: {
    // also show this in publish builds, useful for finding the issue if customer requests are sent
    nativeUtils.displayMessageBox(qsTr("Facebook Error"), JSON.stringify(error))
  }

  function updatePlayerNameIfNotSet() {
    // call gameNetwork so the user can enter his user name, when gameNetwork is visible we will check again and call the dialog
    if(gameNetwork && !gameNetwork.isUserNameSet(gameNetwork.userName)) {
      if(window.state === "waveDefeated") {
        vplayGameNetworkScene.cameFromScene = "waveDefeated"
      }
      window.state = "gameNetwork"
      gameNetwork.showProfileView()


      showUserNameInputTimer.start()
    }
  }

  Timer {
    id: showUserNameInputTimer
    interval: 600
    onTriggered: {
      vplayGameNetworkScene.gameNetworkView.profileView.showPlayerNameChangeDialog("Change Playername", "Congratulations - you reached a new highscore! Please enter your player name:")
    }
  }

  function increaseGamesPlayed() {
    console.debug("increaseGamesPlayed()")
    gameNetwork.incrementAchievement("play10")
    gameNetwork.incrementAchievement("play100")
    gameNetwork.incrementAchievement("play1000")
  }


  function increasePublishedLevels() {
    console.debug("increasePublishedLevels()")
    gameNetwork.incrementAchievement("publish1")
    gameNetwork.incrementAchievement("publish10")
    gameNetwork.incrementAchievement("publish100")
  }


  function setLevelDownloadsOfOwnLevels(downloads) {
    console.debug("setLevelDownloadsOfOwnLevels() with", downloads, "downloads")

    if(downloads >= 1)
      gameNetwork.unlockAchievement("download1")
    if(downloads >= 5)
      gameNetwork.unlockAchievement("download5")
    if(downloads >= 10)
      gameNetwork.unlockAchievement("download10")
    if(downloads >= 100)
      gameNetwork.unlockAchievement("download100")
    if(downloads >= 1000)
      gameNetwork.unlockAchievement("download1000")
  }

  function setBestLevelRatingOfOwnLevels(bestRating) {
    console.debug("setBestLevelRatingOfOwnLevels() with rating", bestRating)
    if(bestRating >= 4)
      gameNetwork.unlockAchievement("rate4")
  }

  function increaseRatedLevels() {
    console.debug("increaseRatedLevels()")
    gameNetwork.incrementAchievement("rated1")
    gameNetwork.incrementAchievement("rated10")
    gameNetwork.incrementAchievement("rated100")
  }

  function increaseDownloadedLevels() {
    console.debug("increaseDownloadedLevels()")
    gameNetwork.incrementAchievement("downloader1")
    gameNetwork.incrementAchievement("downloader10")
    gameNetwork.incrementAchievement("downloader100")
  }
}
