import QtQuick 2.0
import Felgo 3.0
import "AchievementQueue.js" as AchievementQueue
import "../otherScenes"

SquabySceneBase {
  id: achievementOverlay

  // make opacity changes smooth
  Behavior on opacity {
    NumberAnimation { duration: 150}
  }

  // the achievement that is currently displayed gets stored here
  property variant achievement

  // this is called if a new achievement should be shown
  function showAchievement(ach) {
    // push the new achievement to the queue
    AchievementQueue.push(ach)
    // if no achievement is currently shown, display it
    if(!hideAfterDelay.running) display()
  }

  // this is called to actually display the first achievement in the queue
  function display() {
    // take the achievement from the queue and
    achievement = AchievementQueue.take()
    opacity = 1
    hideAfterDelay.start()
  }

  // this either hides the overlay if no more achievements are in the queue, or displays the next one
  function hide() {
    hideAfterDelay.stop()
    if(AchievementQueue.size() > 0) display()
    else opacity = 0
  }

  // the achievement is shown until the player presses it or this timer runs out
  Timer {
    id: hideAfterDelay
    interval: 10000
    onTriggered: achievementOverlay.hide()
  }

  // this is the visual representation of the achievement
  Item {
    // it needs fill the whole screen horizontally, therefore make as big as the gameWindow so it works on every display ratio
    width: parent.gameWindowAnchorItem.width
    height: 130
    anchors.left: parent.gameWindowAnchorItem.left
    anchors.top: parent.gameWindowAnchorItem.top

    // if the player presses the overlay, hide it
    MouseArea {
      anchors.fill: parent
      onClicked: achievementOverlay.hide()
    }

    // the background of the overlay
    Rectangle {
      color: "black"
      anchors.fill: parent
      opacity: 0.8
    }

    Text {
      text: "Congratulations! You just unlocked the achievement:"
      color: "white"
      font.pixelSize: 12
      font.family: hudFont.name
      anchors.horizontalCenter: parent.horizontalCenter
      y: 8
    }

    Text {
      text:  achievement ? achievement.name : ""
      color: "white"
      font.pixelSize: 21
      font.family: hudFont.name
      anchors.horizontalCenter: parent.horizontalCenter
      y: 36
    }

    Text {
      text: achievement ? achievement.description : ""
      color: "white"
      font.pixelSize: 8
      font.family: hudFont.name
      anchors.horizontalCenter: parent.horizontalCenter
      y: 60
    }

    Text {
      text: achievement ? "You earned " + achievement.points + " new credits!" : ""
      color: "white"
      font.pixelSize: 12
      font.family: hudFont.name
      anchors.horizontalCenter: parent.horizontalCenter
      y: 75
    }

    Text {
      text: "Keep on unlocking new achievements to get even more credits..."
      color: "white"
      font.pixelSize: 10
      font.family: hudFont.name
      anchors.horizontalCenter: parent.horizontalCenter
      y: 108
    }

    // display a dummy close sign, just to give the player a hint that he can close the achievement by pressing
    Text {
      text: "X"
      color: "#444444"
      font.pixelSize: 30
      anchors.right: parent.right
      font.family: hudFont.name
      anchors.rightMargin: 8
    }
  }
}
