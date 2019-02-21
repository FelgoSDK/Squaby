import QtQuick 2.0
import Felgo 3.0
import "../../common"

Item {
  id: levelItem
  // can either be "", or "shareLevel"
  property string inputState

  // for debugging the entry data
  Component.onCompleted: console.debug("modelData at completion:", JSON.stringify(modelData))

  width: 90
  height: 90

  opacity: (displayLock && !displayPurchase)  ? 0.5 : 1.0

  property bool isAuthorLevel: modelData["storageLocation"] === levelEditor.authorGeneratedLevelsLocation
  property bool isUserLevel: modelData["storageLocation"] === levelEditor.userGeneratedLevelsLocation
  property bool isSquabyLevel: modelData["storageLocation"] === levelEditor.applicationJSONLevelsLocation
  property bool isDownloaded: levelEditor.isLevelDownloaded(modelData.levelId)
  property bool isPublished: modelData["publishedLevelId"] !== undefined
  property bool isLoggedInPlayer: (modelData && modelData.user && modelData.user.id === gameNetwork.user.userId) ? true : false
  property bool displayUser: modelData["user"] !== undefined
  property bool displayLeaderboard: (((isUserLevel || levelScene.state === "myDownloadedLevels") && (isDownloaded || isLoggedInPlayer)) || (isAuthorLevel && isPublished) || isSquabyLevel)&&!displayLock
  property bool displayScore: displayLeaderboard  && (gameNetwork.userPositionForLeaderboard(getPublishedLevelId()) !== -1)
  property bool displayRating: modelData["average_quality"] !== undefined && !displayLock
  property bool displayPurchase: ((isUserLevel || levelScene.state === "myDownloadedLevels") && !isDownloaded && !isLoggedInPlayer) || (displayLock && isBuyable(modelData["levelName"]) )
  property bool displayLock: settings.getValue(getPublishedLevelId()) === undefined ? false : settings.getValue(getPublishedLevelId())
  //property bool displayInfo: (isUserLevel || levelScene.state === "myDownloadedLevels") && !isDownloaded && !isPublished

  function getPublishedLevelId() {
    // if the level has publishedLevelId, it is a local level, but the highscore should be shown for the published one!
    if(isPublished) {
      return modelData["publishedLevelId"].toString()
    } else {
      return modelData["levelId"].toString()
    }
  }

  MultiResolutionImage {
    id: basePlate
    source: "../../../assets/img/level-base.png"
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      // only unlocked levels can be selected (effects only app levels) and of course only bought levels can be played
      if(!displayLock && !displayPurchase) {
        parent.scale = 1.0
        levelScene.levelSelected(modelData, isAuthorLevel, isUserLevel, isDownloaded, isPublished, isLoggedInPlayer)
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

  ResponsiveText {
    id: levelName
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 2
    anchors.top: parent.top
    anchors.topMargin: 7

    text: modelData.levelName

    color: "white"
    y: 17
    font.pixelSize: 12
    font.family: hudFont.name
  }

  ResponsiveText {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 2
    anchors.top: levelName.bottom
    anchors.topMargin: 2

    text: modelData["user"] ? gameNetwork.getDisplayNameFromUserName(modelData.user.name, modelData.user) : ""
    visible: displayUser

    color: "white"
    font.pixelSize: 8
    font.family: hudFont.name
  }

  MultiResolutionImage {
    anchors.bottom: ratingData.top
    anchors.bottomMargin: 5
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 2
    source: "../../../assets/img/level-base-locked.png"
    visible: displayLock
  }

  Item {
    id: ratingData
    anchors.bottom: levelbaseplate.top
    anchors.horizontalCenter: levelbaseplate.horizontalCenter
    width: levelbaseplate.width
    height: 1

    visible: displayRating

    MultiResolutionImage {
      id: rating1
      y: -(height*1/4+2)
      source: modelData["average_quality"] >= 1 ? "../../../assets/img/star.png" : "../../../assets/img/star-no.png"
      anchors.right: rating2.left
      anchors.rightMargin: width*1/4
      scale: 0.7
    }
    MultiResolutionImage {
      id: rating2
      y: -height*3/4
      source: modelData["average_quality"] >= 2 ? "../../../assets/img/star.png" : "../../../assets/img/star-no.png"
      anchors.right: rating3.left
      anchors.rightMargin: width*1/4
      scale: 0.8
    }
    MultiResolutionImage {
      id: rating3
      source: modelData["average_quality"] >= 3 ? "../../../assets/img/star.png" : "../../../assets/img/star-no.png"
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
    }
    MultiResolutionImage {
      id: rating4
      y: -height*3/4
      source: modelData["average_quality"] >= 4 ? "../../../assets/img/star.png" : "../../../assets/img/star-no.png"
      anchors.left: rating3.right
      anchors.leftMargin: width*1/4
      scale: 0.8
    }
    MultiResolutionImage {
      id: rating5
      y: -(height*1/4+2)
      source: modelData["average_quality"] >= 5 ? "../../../assets/img/star.png" : "../../../assets/img/star-no.png"
      anchors.left: rating4.right
      anchors.leftMargin: width*1/4
      scale: 0.7
    }
  }

  MultiResolutionImage {
    id: levelbaseplate
    anchors.bottom: basePlate.bottom
    source: "../../../assets/img/level-base-button.png"
    visible: !(isAuthorLevel && !isPublished) && !(displayLock && !isBuyable(modelData.levelName))
    MouseArea {
      anchors.fill: parent
      onClicked: {
        parent.scale = 1.0
        if(displayLeaderboard) {
          // this signal is handled in MainItem and then switched to the GameNetworkView
          levelScene.showHighscoreForLevel(getPublishedLevelId())
        } else if(displayPurchase) {
          flurry.logEvent("Level.Download")
          // only download network games, app games should only be unlocked
          if(displayLock) {
            var balance = levelStore.currency.balance
            levelStore.takeItem(levelStore.currency.itemId, 20)
            if(balance >= 20) {
              levelScene.storageLocation = 0
              flurry.logEvent("Store","Unlock.Level",modelData.levelName)
              unlockLevel(modelData.levelName)
              levelScene.storageLocation = levelEditor.applicationJSONLevelsLocation
            }
          } else {
            levelScene.downloadLevelClicked(modelData)
          }
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

  MultiResolutionImage {
    id: leaderBoard
    source: "../../../assets/img/level-base-vpgn.png"
    anchors.left: levelbaseplate.left
    anchors.leftMargin: displayScore ? 14 : levelbaseplate.width/2-width/2
    anchors.bottom: levelbaseplate.bottom
    anchors.bottomMargin: 10
    visible: displayLeaderboard
  }

  Item {
    anchors.left: leaderBoard.right
    anchors.right: levelbaseplate.right
    anchors.rightMargin: 3
    anchors.leftMargin: 3
    anchors.bottom: levelbaseplate.bottom
    anchors.bottomMargin: 8
    height: levelbaseplate.height/2

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.left: parent.left
      property int userPosition: ((gameNetwork.userPositionForLeaderboard(getPublishedLevelId()) !== -1) ? gameNetwork.userPositionForLeaderboard(getPublishedLevelId(), true) : 0)
      text: "#" + userPosition
      color: "white"
      font.family: hudFont.name
      font.pixelSize: userPosition > 99999 ? 12 : 14
    }

    visible: displayScore
  }

  MultiResolutionImage {
    anchors.centerIn: levelbaseplate
    source: "../../../assets/img/level-base-buy.png"
    visible: displayPurchase
    Text {
      anchors.verticalCenter: parent.verticalCenter
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenterOffset: -3
      anchors.horizontalCenterOffset: 2
      text: ""+(displayLock?"20":"1")
      color: "#405e83"
      font.pixelSize: 11
      font.family: hudFont.name
    }
  }

  Item {
    id: downloadInfos
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 2
    anchors.bottom: levelbaseplate.top
    anchors.bottomMargin: 5
    height: downloadImage.height
    width: downloadImage.width+downloadText.width

    visible: isPublished
    MultiResolutionImage {
      id: downloadImage
      source: "../../../assets/img/level-base-downloads.png"
    }
    Text {
      id: downloadText
      anchors.left: downloadImage.right
      anchors.leftMargin: 3
      anchors.verticalCenter: downloadImage.verticalCenter
      text: getDownloads() // only works when calling levelEditor.loadUserOrFriendsLevels(params) in LevelSelectionScene
      function getDownloads() {
          if(levelEditor.userOrFriendsLevels) {
              for(var idx=0; idx < levelEditor.userOrFriendsLevels.length; ++idx) {
                  if(levelEditor.userOrFriendsLevels[idx].levelId == getPublishedLevelId()) {
                      return levelEditor.userOrFriendsLevels[idx].times_downloaded
                  }
              }
          }
          return ""
      }
      color: "white"
      font.pixelSize: 16
      font.family: hudFont.name
    }
  }
}
