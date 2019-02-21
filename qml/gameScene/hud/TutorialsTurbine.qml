import QtQuick 2.0
import Felgo 3.0

Item {
  property variant towerPosition: Qt.point(0,0)

  property bool dialogPauseState: false
  property bool actionPauseState: false
  property bool particlePauseState: false
  property bool waitingForClick: false
  property int blackSquabyCount: 0
  property bool towerRangeCurrentlyVisible: false

  function reset() {
    towerPosition = Qt.point(0,0)
    // dialog setttings
    dialog.dialogText = ""
    dialog.showButtonWhenFinished = false
    dialogBox.visible = false
    action.visible = false
    if(notificationParticle.running) {
      notificationParticle.stopLivingParticles()
    }
    waitingForClick = false
    blackSquabyCount = 0
    towerRangeCurrentlyVisible = false
  }

  function pause() {
    // save state
    dialogPauseState = dialogBox.visible
    actionPauseState = action.visible
    // set invisible
    dialogBox.visible = false
    action.visible = false
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
    console.debug("[TutorialsTurbine]",source,action)
    if(source === "startClock" && action === "startGame") {
      activateSquabyCreation(false)
      setAction(true,deltaX+(developerBuild ? 0 : 32)+415,deltaY+242)
      dialog.activateMessage(["Drag & Drop the Turbine to the room!"])
    } else if(source === "turbine" && action === "pressed") {
      setAction(false,0,0)
      dialog.activateMessage(["The circle gets green in places you can build the tower."])
    } else if(source === "turbine" && action === "entityBuilt") {
      if(position) {
        towerPosition = position
      }

      dialog.activateMessage(["Kill every Squaby type instantly with the power of Turbines!"])
      activateSquabyCreation(true)
    } else if(source === "squabyBlue" && action === "died") {
      dialog.activateMessage(["But be aware of the cooldown time of Turbines!"])
    } else if(source === "squabyGrey" && action === "died") {
      blackSquabyCount++
      if(blackSquabyCount == 1) {
        activateSquabyCreation(false)
        dialog.activateMessage(["Each Turbine can be used twice and needs to be repaired then!"])
        if(!towerRangeCurrentlyVisible) {
          waitingForClick = true
          setAction(true,towerPosition.x,towerPosition.y,true)
        } else {
          activateUpgradeMenuStatus()
        }
      }
    } else if(source === "turbine" && action === "clicked" && waitingForClick) {
      waitingForClick = false
      activateUpgradeMenuStatus()
    } else if(source === "upgradeButton" && action === "repair"  ) {
      activateSquabyCreation(true)
      setAction(false,0,0)
      dialogBox.visible = false
    } else if(source === "upgradeButton" && (action === "sold" || action === "range" || action === "shootDelay")) {
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

  function activateUpgradeMenuStatus() {
    if(player.gold >= 60) {
      setAction(true,deltaX+(developerBuild ? 0 : 32)+227,deltaY+242)
      dialog.activateMessage(["Upgrading does NOT repair a Turbine! Keep an eye on your gold reserves!"])
    } else {
      dialog.activateMessage(["You have not enough gold reserves to repair the tower!"])
      activateSquabyCreation(true)
      setAction(false,0,0)
    }
  }

  MultiResolutionImage {
    id: dialogBox
    width: dialog.width
    height: dialog.height
    x: 300
    y: 30
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
            player.gold = 10
            setRangeUpgrade()
          } else if(waitForFireUpgrade) {
            player.gold = 15
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

