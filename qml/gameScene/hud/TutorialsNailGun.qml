import QtQuick 2.0
import Felgo 3.0

Item {
  property int squabyYellowCounter: 0
  property bool giveMoney: false
  property bool waitForRangeUpgrade: false
  property bool waitForFireUpgrade: false
  property bool waitForNextWave: false
  property bool waitForNextTower: false
  property variant towerPosition: Qt.point(0,0)
  property bool upgradeAllowed: false

  property bool dialogPauseState: false
  property bool actionPauseState: false
  property bool particlePauseState: false
  property bool tutorialFinished: false
  property bool towerRangeCurrentlyVisible: false

  function reset() {
    squabyYellowCounter = 0
    giveMoney = false
    waitForRangeUpgrade = false
    waitForFireUpgrade = false
    waitForNextWave = false
    towerPosition = Qt.point(0,0)
    upgradeAllowed = false
    // dialog setttings
    dialog.dialogText = ""
    dialog.showButtonWhenFinished = false
    dialogBox.visible = false
    action.visible = false
    waitForNextTower = false
    tutorialFinished = false
    tutorialFinishedTimer.stop()
    if(notificationParticle.running) {
      notificationParticle.stopLivingParticles()
    }
    towerRangeCurrentlyVisible = false
  }

  function pause() {
    // save state
    dialogPauseState = dialogBox.visible
    actionPauseState = action.visible
    // set invisible
    dialogBox.visible = false
    action.visible = false
    if(tutorialFinishedTimer.running) {
      tutorialFinishedTimer.stop()
      dialogPauseState = false
    }
    particlePauseState = notificationParticle.running
    if(notificationParticle.running) {
      notificationParticle.stopLivingParticles()
    }
  }

  function resume() {
    // resume states
    dialogBox.visible = dialogPauseState
    action.visible = actionPauseState
    squabyCreator.start()
    if(particlePauseState) {
      notificationParticle.start()
    }
  }

  function nextAction(source,action,position) {
    //console.debug("[TutorialsNailGun]",source,action)
    if(tutorialFinished) {
      return true
    }

    if(source === "startClock" && action === "startGame") {
      activateSquabyCreation(false)
      setAction(true,deltaX+(developerBuild ? 0 : 32)+415,deltaY+242)
      dialog.activateMessage(["Drag & Drop the Nailgun to the room!"])
    } else if(source === "nailgun" && action === "pressed") {
      setAction(false,0,0)
      dialog.activateMessage(["The circle gets green in places you can build the tower."])
    } else if(source === "nailgun" && action === "entityBuilt") {
      if(!waitForNextTower) {
        if(position) {
          towerPosition = position
        }

        dialog.activateMessage(["Kill yellow and green Squabies with nailguns! They are too fast for other weapons!"])
        squabyCreator.createNextSingleSquabyImmediately()
      } else {
        dialog.activateMessage(["You finished the tutorial! Now you can act free!"])
        tutorialFinished = true
        tutorialFinishedTimer.start()
        activateSquabyCreation(true)
        upgradeAllowed = true
      }
    } else if(source === "squabyYellow" && action === "died") {
      squabyYellowCounter++
      if(squabyYellowCounter == 1) {
        setAction(true,deltaX+64,deltaY+242)
        dialog.activateMessage(["You can trigger the next Squaby instantly to gain more points by pressing the wave button after the tutorial!"])
        waitForNextWave = true
      } else if(squabyYellowCounter == 2) {
        activateFireUpgrade()
      }
      else if(squabyYellowCounter == 3) {
        activateSquabyCreation(false)
        activateRangeUpgrade()
      } else if(squabyYellowCounter >= 6) {
        // check if player has enough money and trigger new tower message
        if(player.gold >= 20) {
          activateSquabyCreation(false)
          dialog.activateMessage(["You should build another tower for the next wave! Press the floor anywhere to exit upgrade menu and enter build menu!"])
          waitForNextTower = true
        }
      }
    } else if(source === "squabyCreator" && action === "immediately" && waitForNextWave) {
      squabyCreator.createNextSingleSquabyImmediately()
      waitForNextWave = false
      dialogBox.visible = false
      setAction(false,0,0)
      // avoid showing not allowed message
      return true
    } else if(source === "nailgun" && action === "clicked" && (waitForRangeUpgrade||waitForFireUpgrade) && upgradeAllowed) {
      activateUpgradeMenuStatus()
    } else if(source === "upgradeButton" && action === "range" && waitForRangeUpgrade) {
      if(!upgradeAllowed) {
        return false
      }

      waitForRangeUpgrade = false
      dialogBox.visible = false
      setAction(false,0,0)
      activateSquabyCreation(true)
      upgradeAllowed = false
    } else if(source === "upgradeButton" && action === "shootDelay" && waitForFireUpgrade) {
      if(!upgradeAllowed) {
        return false
      }

      waitForFireUpgrade = false
      dialogBox.visible = false
      setAction(false,0,0)
      activateSquabyCreation(true)
      upgradeAllowed = false
    } else if(source === "upgradeButton" && (action === "shootDelay" || action === "range")) {
      return false
    } else if((source === "upgradeButton" && action === "sold") ||
              (source === "squabyCreator" && action === "immediately")) {
      return false
    } else if(source === "towerRange") {
      if(action === "visible") {
        towerRangeCurrentlyVisible = true
        if(notificationParticle.running) {
          notificationParticle.stopLivingParticles()
        }
      } else {
        towerRangeCurrentlyVisible = false
      }
    }

    return true
  }

  function activateRangeUpgrade() {
    upgradeAllowed = true
    waitForRangeUpgrade = true
    // check if player has enough money and provide some if there is not enough to buy the upgrade
    if(player.gold < 5) {
      giveMoney = true
      dialog.showButtonWhenFinished = true
      dialog.activateMessage(["You have not enough gold to buy an range upgrade! This time you get some extra credits, but the next time you have kill more Squabies to earn more gold!"])
    } else {
      setRangeUpgrade()
    }
  }

  function activateFireUpgrade() {
    upgradeAllowed = true
    waitForFireUpgrade = true
    // check if player has enough money and provide some if there is not enough to buy the upgrade
    if(player.gold < 10) {
      giveMoney = true
      dialog.showButtonWhenFinished = true
      dialog.activateMessage(["You have not enough gold to buy an fire upgrade! This time you get some extra credits, but the next time you have kill more Squabies to earn more gold!"])
    } else {
      setFireUpgrade()
    }
  }

  function setRangeUpgrade() {
    dialog.activateMessage(["Click on the tower to open the upgrade menu and buy a range upgrade!"])
    if(!towerRangeCurrentlyVisible) {
      setAction(true,towerPosition.x,towerPosition.y,true)
    } else {
      activateUpgradeMenuStatus()
    }
  }

  function setFireUpgrade() {
    dialog.activateMessage(["Click on the tower to open the upgrade menu and buy a fire upgrade!"])
    if(!towerRangeCurrentlyVisible) {
      setAction(true,towerPosition.x,towerPosition.y,true)
    } else {
      activateUpgradeMenuStatus()
    }
  }
  function activateUpgradeMenuStatus() {
    if(waitForRangeUpgrade) {
      setAction(true,deltaX+(developerBuild ? 0 : 32)+287,deltaY+242)
    } else if(waitForFireUpgrade) {
      setAction(true,deltaX+(developerBuild ? 0 : 32)+352,deltaY+242)
    }
  }

  Timer {
    id: tutorialFinishedTimer
    interval: 3000
    onTriggered: {
      dialogBox.visible = false
    }
  }

  MultiResolutionImage {
    id: dialogBox
    width: dialog.width
    height: dialog.height
    x: 10
    y: 100
    visible: false
    source: "../../../assets/img/text-dialog-background.png"
    GameTextDialog {
      id: dialog
      width: 170
      height: 110
      dialogTextDelay: 0
      showButtonWhenFinished: false
      text.color: "white"

      function activateMessage(message) {
        dialog.dialogText = message
        dialogBox.visible = true
      }

      onDialogButtonClicked: {
        if(giveMoney) {
          dialog.showButtonWhenFinished = false
          giveMoney = false
          if(waitForRangeUpgrade) {
            player.gold = 5
            setRangeUpgrade()
          } else if(waitForFireUpgrade) {
            player.gold = 10
            setFireUpgrade()
          } else {
            tutorials.reset()
            tutorials.pause()
            activateSquabyCreation(true)
          }
        }
      }
    }

  }
  function setAction(active,x,y,useParticle) {
    if(useParticle === undefined) {
      action.x = x-action.width/2
      action.y = y-action.height/2
      action.visible = active
    } else {
      notificationParticle.x = x
      notificationParticle.y = y
      action.visible = !active
      notificationParticle.start()
    }
    if(!active) {
      if(notificationParticle.running) {
        notificationParticle.stopLivingParticles()
      }
    }
  }

  function activateSquabyCreation(flag) {
    if(flag) {
      squabyCreator.enabled = true
      squabyCreator.start()
    } else {
      squabyCreator.enabled = false
    }
  }
}

