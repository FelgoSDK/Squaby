import QtQuick 2.0
import VPlay 2.0
import "../otherScenes" // for MainMenuButton and SquabySceneBase
import "levelSelection"
import"../common"

SquabySceneBase {
  id: levelSelectionScene

  signal backClicked
  signal levelSelected(variant levelData, bool isAuthorLevel, bool isUserLevel, bool isDownloaded, bool isPublished, bool isLoggedInPlayer)
  signal newLevelClicked
  signal clearSelectedItems
  // is called when the fb connection dialog was shown due to no friends
  signal showProfileView
  signal showHighscoreForLevel(string leaderboard)
  signal unpublishLevelClicked(variant levelData)
  // is emitted from LevelItem if the share level button is clicked
  signal downloadLevelClicked(variant levelData)


  // gets set from the MainMenuScene, depending which mainmenu button was clicked (application levels, author levels, etc.)
  // is used to disable the new level button for application levels
  // currently only user levels are used, so set this initally
  property string storageLocation: levelEditor.applicationJSONLevelsLocation

  // can have the following states: "myLevels", "myDownloadedLevels", "exited", "appLevels", "communityLevels"
  state: "exited"
  property string oldState: ""
  property string prevState: ""
  property string exitReason: ""

  onBackButtonPressed: {
    if(buyCreditDialog.opacity == 1) {
      buyCreditDialog.opacity = 0
      myLevelSelection.isLoading = false
      return
    } else if(unpublishDialog.opacity == 1) {
      unpublishDialog.opacity = 0
      return
    }

    levelSelectionScene.state = "exited"
    // make this with a timer, otherwise the animation wouldnt be played to the end!
    exitReason = "exit"
    sceneChangeTimer.start()
  }

  // either is default "", "unpublishConfirmation"
  property string dialogState
  property variant unpublishLevelData
  Connections {
    target: nativeUtils
    onMessageBoxFinished: {

      if(accepted) {
        if(dialogState === "unpublishConfirmation") {
          flurry.logEvent("LevelSelection.Unpublish")
          levelEditor.unpublishLevel(unpublishLevelData)
          editAuthorLevel = true
          singleLevelSelected(unpublishDialog.levelData)
        }
      }
      // reset the dialogState, no matter if accepted or not
      dialogState = ""
    }

  }

  MultiResolutionImage {
    source: "../../assets/img/bgSubmenu.png"
    anchors.centerIn: parent
    property int pixelFormat: 3
  }

  MultiResolutionImage {
    source: "../../assets/img/nextprev.png"
    visible: (
             (levelScene.state === "communityLevels" && levelEditor.communityLevelsPageMetaData.page > 1)) &&
             // avoid to show while the level items are created
             !currentLevelSelection.isLoading

    anchors.top: levelSelectionScene.gameWindowAnchorItem.top
    anchors.topMargin: 3
    anchors.left: levelSelectionScene.gameWindowAnchorItem.left
    anchors.leftMargin: -3
    MouseArea {
      anchors.fill: parent
      onClicked: {
        parent.scale = 1.0
        currentLevelSelection.prevPage()
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
    source: "../../assets/img/nextprev.png"
    visible: (levelScene.state === "communityLevels") &&
             levelEditor.userGeneratedLevelsPageMetaData !== undefined && levelEditor.userGeneratedLevelsPageMetaData.page < levelEditor.userGeneratedLevelsPageMetaData.pageCount &&
             // avoid to show while the level items are created
             !currentLevelSelection.isLoading
    mirror: true
    anchors.top: levelSelectionScene.gameWindowAnchorItem.top
    anchors.topMargin: 3
    anchors.right: levelSelectionScene.gameWindowAnchorItem.right
    anchors.rightMargin: -3

    MouseArea {
      anchors.fill: parent
      onClicked: {
        parent.scale = 1.0
        currentLevelSelection.nextPage()
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
    id: header
    anchors.top: gameWindowAnchorItem.top
    anchors.topMargin: -2
    anchors.horizontalCenter: gameWindowAnchorItem.horizontalCenter
    source: "../../assets/img/menuBar.png"

    Text {
      anchors.centerIn: parent
      visible: levelSelectionScene.state === "appLevels"
      text: qsTr("Select Level")
      color: "white"
      font.family: jellyFont.name
      font.pixelSize: 42
    }

    Text {
      anchors.centerIn: parent
      visible: levelSelectionScene.state === "exited"
      text: qsTr("...")
      color: "white"
      font.family: jellyFont.name
      font.pixelSize: 42
    }

    Row {
      id: headerRow
      anchors.centerIn: parent
      spacing: 10

      visible: levelSelectionScene.state !== "appLevels" && levelSelectionScene.state !== "communityLevels" && levelSelectionScene.state !== "exited"

      MenuButton {
        source: "../../assets/img/menu-new.png"
        visible: levelSelectionScene.state === "myLevels" || levelScene.state === "myDownloadedLevels"
        onClicked: {
          levelSelectionScene.state = "exited"
          exitReason = "newLevel"
          sceneChangeTimer.start()
        }
      }
      MenuButton {
        source: "../../assets/img/menu-saved.png"
        active: levelScene.state === "myLevels"
        onClicked: {
          flurry.logEvent("LevelSelection.ChangeTo","myLevels")
          levelScene.state = "myLevels"
          previousMyLevelState = levelScene.state
        }
      }
      MenuButton {
        source: "../../assets/img/menu-downloaded.png"
        active: levelScene.state === "myDownloadedLevels"
        onClicked: {
          flurry.logEvent("LevelSelection.ChangeTo","myDownloadedLevels")
          levelScene.state = "myDownloadedLevels"
          previousMyLevelState = levelScene.state
        }

        onPressAndHold: {
          // don't add this functionality in publish builds, just during testing
          if(system.publishBuild)
            return

          // this is just during testing, to test the behavior of no downloaded(=bought) levels
          console.debug("clearing all bought levels...")
          levelStore.clearAllBoughtLevels()
        }
      }
    }// headerRow

    property bool sort: true

    MenuButton {
      id: dataSettings
      source: "../../assets/img/menu-clock.png"
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 5
      visible: levelScene.state === "communityLevels" && header.sort

      onClicked: {
        flurry.logEvent("LevelSelection.Sorting","Time")
        header.sort^=1
      }
    }

    MenuButton {
      source: "../../assets/img/menu-sort.png"
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.leftMargin: 5
      visible: levelScene.state === "communityLevels" && !header.sort

      onClicked: {
        flurry.logEvent("LevelSelection.Sorting","Sort")
        header.sort^=1
      }
    }

    Item {
      height: parent.height
      width: parent.width - dataSettings.width
      anchors.left: dataSettings.right
      anchors.verticalCenter: parent.verticalCenter
      visible: levelScene.state === "communityLevels"

      Row {
        id: moreSubRow
        spacing: 15
        anchors.centerIn: parent
        height: parent.height

        MenuButtonText {
          id: highestRated
          anchors.verticalCenter: parent.verticalCenter
          text: "Highest Rated"
          active: levelScene.orderString() === text
          visible: header.sort
          onClicked: {
            flurry.logEvent("LevelSelection.Sorting","average_quality")
            levelScene.order = "average_quality"
          }
        }
        MenuButtonText {
          id: newestText
          anchors.verticalCenter: parent.verticalCenter
          text: "Newest"
          active: levelScene.orderString() === text
          visible: header.sort
          onClicked: {
            flurry.logEvent("LevelSelection.Sorting","created_at")
            levelScene.order = "created_at"
          }
        }
        MenuButtonText {
          id: mostDownloaded
          anchors.verticalCenter: parent.verticalCenter
          text: "Most Downloaded"
          active: levelScene.orderString() === text
          visible: header.sort
          onClicked: {
            flurry.logEvent("LevelSelection.Sorting","times_downloaded")
            levelScene.order = "times_downloaded"
          }
        }

        MenuButton {
          id: alltime
          source: "../../assets/img/menu-alltime.png"
          active: levelScene.timeLimit === 0
          visible: !header.sort
          onClicked: {
            flurry.logEvent("LevelSelection.AllTime")
            levelScene.timeLimit = 0
          }
        }
        MenuButton {
          id: week
          source: "../../assets/img/menu-7d.png"
          active: levelScene.timeLimit === 24*7
          visible: !header.sort
          onClicked: {
            flurry.logEvent("LevelSelection.ThisWeek")
            levelScene.timeLimit = 24*7
          }
        }
        MenuButton {
          id: today
          source: "../../assets/img/menu-24h.png"
          active: levelScene.timeLimit === 24
          visible: !header.sort
          onClicked: {
            flurry.logEvent("LevelSelection.Today")
            levelScene.timeLimit = 24
          }
        }
      }
    } // moreSubRow

  }// header


  // is set in onStateChanged
  property variant currentLevelSelection: myLevelSelection

  LevelSelection {
    id: myLevelSelection
    visible: levelSelectionScene.state !== "exited" && !isLoading
    anchors.top: header.bottom
    anchors.topMargin: 10
    anchors.bottom: backButtonItem.top
    anchors.bottomMargin: 10
    anchors.left: gameWindowAnchorItem.left
    anchors.leftMargin: grid.width < levelSelectionScene.gameWindowAnchorItem.width  ? (levelSelectionScene.gameWindowAnchorItem.width-grid.width)/2-2 : 1
    anchors.right: gameWindowAnchorItem.right
    anchors.rightMargin: 1
    clip: false
    levelMetaDataArray: (levelScene.state === "myLevels" || levelScene.state === "appLevels") ? storageFromLocation() : (levelScene.state === "myDownloadedLevels" ? levelEditor.downloadedLevels : levelEditor.communityLevels)
    pageCount: levelScene.state === "communityLevels" ? levelEditor.communityLevelsPageMetaData.pageCount : 1
  }


  MultiResolutionImage {
    id: loading
    source: "../../assets/img/splash-text.png"
    anchors.centerIn: parent.gameWindowAnchorItem
    //anchors.verticalCenter: parent.parent.gameWindowAnchorItem.verticalCenter
    //anchors.horizontalCenter: parent.parent.gameWindowAnchorItem.horizontalCenter
    //anchors.horizontalCenterOffset: -parent.x
    visible: myLevelSelection.isLoading
  }

  Connections {
    target: levelStore
    onInsufficientFundsError: {
      flurry.logEvent("Level.InsufficientFunds")
      buyCreditDialog.opacity = 1
      myLevelSelection.isLoading = false
    }
    onLevelBoughtSuccessfully: {
      flurry.logEvent("Level.BoughtSucc")
      console.debug("level bought:", JSON.stringify(levelData))
    }
    onLevelDownloadedSuccessfully: {
      flurry.logEvent("Level.Downloaded")
      console.debug("level downloaded:", JSON.stringify(levelData))
    }
    onItemNotFoundError:  {
      myLevelSelection.isLoading = false
    }
    onItemPurchased: {
      myLevelSelection.isLoading = false
    }

    onStorePurchaseCancelled: {
      myLevelSelection.isLoading = false
    }

    onStorePurchased: {
      myLevelSelection.isLoading = false
    }
  }

  BuyCreditDialog {
    id: buyCreditDialog
    opacity: 0
    onOpacityChanged: {
      if(opacity == 1) {
        myLevelSelection.isLoading = true
      }
    }
    onCancelClicked: {
      myLevelSelection.isLoading = false
    }

    z: 100
  }

  DialogField {
    id: unpublishDialog

    width: levelScene.gameWindowAnchorItem.width
    height: levelScene.gameWindowAnchorItem.height

    descriptionText: qsTr("Your level is published, play it or unpublish it for editing!")
    options1Text: qsTr("Play")
    options2Text: qsTr("Edit")
    options3Text: qsTr("Unpublish")

    opacity: 0
    z: 100

    onOption1Pressed: {
      flurry.logEvent("LevelSelection.Published.Dialog","Play")
      editAuthorLevel = false
      singleLevelSelected(levelData)
    }

    onOption2Pressed: {
      flurry.logEvent("LevelSelection.Published.Dialog","Edit")
      reloadLevel = true
      editAuthorLevel = true
      singleLevelSelected(levelData)
    }

    onOption3Pressed: {
      flurry.logEvent("LevelSelection.Published.Dialog","Unpublish")
      unpublishLevelClicked(levelData)
    }

    property variant levelData
  }

  onLevelSelected: {
    if(isAuthorLevel && !isPublished) {
      editAuthorLevel = true
      singleLevelSelected(levelData)
    } else if(isAuthorLevel && isPublished) {
      editAuthorLevel = false
      unpublishDialog.opacity = 1.0
      unpublishDialog.levelData = levelData
    } else {
      editAuthorLevel = false
      singleLevelSelected(levelData)
    }
  }

  onDownloadLevelClicked: {
    // it's up to the developer if he wants to support the LevelStore - if so, then a direct download is not possible but only a buy
    // on iOS & Android, do not open the store yet, as too tedious to set up during development
    // this should be the other way around in the end, or use buyLevel for both platforms, as basic Store functionality is now also supported on desktop
    // NOTE: the supported property does also return FALSE on iOS & Android, thus a bug in Store plugin!
    //if(levelStore.supported) {

    // for testing the purchase process with the build server, by default the "stage" property is set to "test"
    // this means the build server signs the app with the V-Play certificate to allow quick testing & deployment
    // however, in-app-purchases and the Store plugin require a publish build because in-app purchases are not working with the V-Play certificate but require YOUR OWN certificate
    // thus for final testing including in-app purchases on iOS & Android, do change to publish build by changing the config.json "stage" property to "publish"
    // and to simulate the correct purchase process on build server for test builds, we directly download the level without an actual purchase on iOS & Android
    if( (system.isPlatform(System.IOS) || system.isPlatform(System.Android)) && !system.publishBuild ) {
      levelEditor.downloadLevel(levelData)
    } else {
      levelStore.buyLevel(levelData)
    }
  }


  onUnpublishLevelClicked: {
    dialogState = "unpublishConfirmation"
    // must be saved so we know the levelId to unpublish after confirmation
    unpublishLevelData = levelData
    nativeUtils.displayMessageBox("Unpublish Confirmation", "Do you really want to unpublish your level? This removes all ratings and download stats for this level.", 2)
  }

  onStateChanged: {
    if(state === "myLevels" || state === "appLevels") {
      levelEditor.loadAllLevelsFromStorageLocation(storageLocation)
      // we need to now how often a level from the user was downloaded.
      var params = {}
      params.filters =  ["created_by_user"]
      levelEditor.loadUserOrFriendsLevels(params)
    } else if(state === "myDownloadedLevels") {
      levelEditor.loadAllLevelsFromStorageLocation(levelEditor.downloadedLevelsLocation)
    } else if (state === "communityLevels") {
      // this takes into account the current ordering and timeLimit
      levelScene.reloadLevels()
    } else if(state === "exited") {

    } else {
      console.debug("ERROR: LevelScene: undefined state!", state)
    }
    prevState = oldState
    oldState = state
  }

  // is either "myLevels" or "myDownloadedLevels", and is needed to go back to these levels when "My Levels" is selected
  property string previousMyLevelState: "myLevels"

  //order - Order results by fields, newest/highst quality first Has to be one of ["created_at", "average_quality", "average_difficulty", "times_favored", "times_played", "times_downloaded"]. Default: created_at.
  property string order: "average_quality"
  onOrderChanged: {
    currentLevelSelection.page = 1
    reloadLevels()
  }
  function orderString() {
    if(order === "created_at")
      return "Newest"
    else if(order === "average_quality")
      return "Highest Rated"
    else if(order === "times_downloaded")
      return "Most Downloaded"

    return "XXX"
  }

  //timeLimit - Only return levels that have been created within time_limit hours (integer).
  property int timeLimit
  onTimeLimitChanged: {
    currentLevelSelection.page = 1
    reloadLevels()
  }

  function reloadLevels() {
    var params = {}
    if(timeLimit > 0) {
      params.timeLimit = timeLimit
    }
    params.order = order
    params.perPage = currentLevelSelection.pageSize
    params.page = currentLevelSelection.page

    if(levelScene.state === "communityLevels") {
      levelEditor.loadCommunityLevels(params)
    }
  }

  // this is used as a binding for the levelListRepeater.model property
  // every time the storageLocation changes, the model will also update
  // if the model in levelEditor then changes afterwards (e.g. authorGeneratedLevels change because a new level was added), the change will be forwarded to the model as it is a binding
  function storageFromLocation() {
    console.debug("LevelSelectionScene: storageLocation changed to", storageLocation)
    if(storageLocation === levelEditor.authorGeneratedLevelsLocation) {
      return levelEditor.authorGeneratedLevels
    } else if(storageLocation === levelEditor.applicationQMLLevelsLocation) {
      return levelEditor.applicationQMLLevels
    } else if(storageLocation === levelEditor.applicationJSONLevelsLocation) {
      return resort(levelEditor.applicationJSONLevels)
    } else {
      console.debug("ERROR: LevelSelectionScene: unknown storageLocation:", storageLocation)
      return null
    }
  }


  // used to sort the json levels in a order as they should appear to play one after another.
  function resort(levelMetaDataArray) {
    var predesignedLevelCount = 11
    if(!levelMetaDataArray || levelMetaDataArray.length < predesignedLevelCount)
      return;

    var finalOrderOfLevels = new Array
    var index = 0
    while(index < predesignedLevelCount-1) {
      for(var i=0; levelMetaDataArray && i<levelMetaDataArray.length; i++) {
        var level = levelMetaDataArray[i]
        if(index == 0 && level.levelName === "Level 1") {
          finalOrderOfLevels.push(level)
          index++
        } else if(index == 1 && level.levelName === "Level 2") {
          finalOrderOfLevels.push(level)
          index++
        } else if(index == 2 && level.levelName === "Level 3") {
          finalOrderOfLevels.push(level)
          index++
        } else if(index == 3 && level.levelName === "Level 4") {
          finalOrderOfLevels.push(level)
          index++
        } else if(index == 4 && level.levelName === "Level 5") {
          finalOrderOfLevels.push(level)
          index++
        }  else if(index == 5 && level.levelName === "Level 6") {
          finalOrderOfLevels.push(level)
          index++
        } else if(index == 6 && level.levelName === "Level 7") {
          finalOrderOfLevels.push(level)
          index++
        } else if(index == 7 && level.levelName === "Level 8") {
          finalOrderOfLevels.push(level)
          index++
        } else if(index == 8 && level.levelName === "Level 9") {
          finalOrderOfLevels.push(level)
          index++
        } else if(index == 9 && level.levelName === "Level 10") {
          finalOrderOfLevels.push(level)
          index++
        }
      }
    }
    return finalOrderOfLevels
  }
  function levelArrayFromState() {
    if(state === "myLevels" || state === "appLevels")
      return storageFromLocation()
    else if(state === "myDownloadedLevels")
      return levelEditor.downloadedLevels
    else if(state === "communityLevels")
      return levelEditor.communityLevels

    console.debug("ERROR: LevelScene: undefined state!", state)

    return undefined

  }
  Item {
    id: backButtonItem
    height: more.height
    anchors.left: parent.gameWindowAnchorItem.left
    anchors.bottom: gameWindowAnchorItem.bottom
    anchors.bottomMargin: 10
    MainMenuButton {
      id: backButton

      text: ""

      offsetX: -120

      onClicked: {
        menuImage.scale = 1.0
        backButtonPressed()
      }
      onPressed: {
        menuImage.scale = 0.85
      }
      onReleased: {
        menuImage.scale = 1.0
      }
      onCanceled: {
        menuImage.scale = 1.0
      }
      MultiResolutionImage {
        id: menuImage
        source: "../../assets/img/menu-back.png"
        anchors.right: parent.right
        anchors.rightMargin: 10
      }
    }
  }

    MainMenuButton {
      id: more
      slideInFromRight: false
      offsetX: (storageLocation == levelEditor.applicationJSONLevelsLocation) ? 100 : 100
      outslidedXBase: levelSelectionScene.width
      anchors.bottom: gameWindowAnchorItem.bottom
      anchors.bottomMargin: 10

      Row {
        id: moreSubRowMyLevels
        spacing: 25
        y: 1
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 15

        MenuButton {
          source: "../../assets/img/menu-author.png"
          active: levelScene.state === "myLevels" || levelScene.state === "myDownloadedLevels"
          onClicked: {
            flurry.logEvent("LevelSelection.MyLevels")
            storageLocation = levelEditor.authorGeneratedLevelsLocation
            levelScene.state = levelScene.previousMyLevelState
          }
        }

        MenuButton {
          source: "../../assets/img/menu-community.png"
          active: levelScene.state === "communityLevels"
          onClicked: {
            flurry.logEvent("LevelSelection.CommunityLevels")
            levelScene.state = "communityLevels"
          }
        }

        MenuButton {
          source: "../../assets/img/menu-grid.png"
          active: levelScene.state === "appLevels"
          onClicked: {
            flurry.logEvent("LevelSelection.AppLevels")
            storageLocation = levelEditor.applicationJSONLevelsLocation
            levelScene.state = "appLevels"
          }
        }

        MenuButton {
          source: "../../assets/img/menu-buy.png"

          onClicked: {
            buyCreditDialog.opacity = 1
          }
          onPressAndHold: {

            // don't add this functionality in publish builds, just during testing
            if(system.publishBuild)
              return

            // just for testing during development to reset the playerCredits
            levelStore.resetCurrency()
          }
          Text {
            text: levelStore.playerCredits
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 2
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -5
            //anchors.left: parent.right
            color: "#405e83"
            font.family: jellyFont.name
            font.pixelSize: 14
          }
        }

      } // moreSubRowMyLevels
    }


  // Called when scene is displayed
  function enterScene() {
    if(oldState === "" || oldState === "exited") {
      if(storageLocation == levelEditor.applicationJSONLevelsLocation) {
        state = "appLevels"
      } else if(storageLocation == levelEditor.authorGeneratedLevelsLocation) {
        state = "myLevels"
      }
    } else {
      state = oldState
    }
  }

  function singleLevelSelected(levelData) {
    console.debug("LevelSelectionScene: single level selected, switch to state game and load the level with LevelEditor")
    flurry.logEvent("LevelSelection.LoadLevel.clicked")
    state = "exited"
    exitReason = "levelStart"
    sceneChangeTimer.levelData = levelData
    sceneChangeTimer.start()
  }

  Timer {
    id: sceneChangeTimer
    interval: backButton.slideDuration
    onTriggered: {
      if(exitReason === "exit") {
        levelScene.backClicked()
      } else if(exitReason === "levelStart") {
        reloadLevel = true
        twoPhaseLevelLoader.startLoadingLevel(false, levelData)
      } else if(exitReason === "newLevel") {
        newLevelClicked()
      }
    }
    property variant levelData
  }

  states: [
    State {
      PropertyChanges { target: header; opacity: 1 }
      PropertyChanges { target: currentLevelSelection; opacity: 1 }
      name: "myLevels"
      StateChangeScript {
        script: {
          backButton.slideIn()
          more.slideIn()
        }
      }
    },
    State {
      PropertyChanges { target: header; opacity: 1 }
      PropertyChanges { target: currentLevelSelection; opacity: 1 }
      name: "appLevels"
      StateChangeScript {
        script: {
          backButton.slideIn()
          more.slideIn()
        }
      }
    },
    State {
      PropertyChanges { target: header; opacity: 0 }
      PropertyChanges { target: currentLevelSelection; opacity: 0 }
      name: "exited"
      StateChangeScript {
        script: {
          backButton.slideOut()
          more.slideOut()
        }
      }
    },
    State {
      PropertyChanges { target: header; opacity: 1 }
      PropertyChanges { target: currentLevelSelection; opacity: 1 }
      name: "myDownloadedLevels"
      StateChangeScript {
        script: {
          backButton.slideIn()
          more.slideIn()
        }
      }
    },
    State {
      PropertyChanges { target: header; opacity: 1 }
      PropertyChanges { target: currentLevelSelection; opacity: 1 }
      name: "communityLevels"
      StateChangeScript {
        script: {
          backButton.slideIn()
          more.slideIn()
        }
      }
    }
  ]

  transitions: Transition {
    NumberAnimation {
      targets: [header,currentLevelSelection]
      duration: 900
      property: "opacity"
      easing.type: Easing.InOutQuad
    }
  }
}
