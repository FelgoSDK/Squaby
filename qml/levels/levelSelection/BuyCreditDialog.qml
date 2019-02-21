import QtQuick 2.0
import Felgo 3.0
import "../../common"

Item {
  id: buyCreditDialog
  width: levelScene.gameWindowAnchorItem.width
  height: levelScene.gameWindowAnchorItem.height
  anchors.centerIn: parent

  visible: opacity === 0 ? false : true
  enabled: visible

  signal cancelClicked()

  Behavior on opacity {
    NumberAnimation { duration: 150}
  }

  MouseArea {
    anchors.fill: parent
  }

  Rectangle {
    color: "black"
    anchors.fill: parent
    opacity: 0.9
  }

  Column {
    id: col
    spacing: 10
    anchors.centerIn: parent

    Text {
      text: "Unlock Achievements or buy credit packs to get more Levels!"
      anchors.horizontalCenter: parent.horizontalCenter
      color: "white"
      font.family: hudFont.name
    }

    Rectangle {
      height: 40
      width: buyCreditDialog.width*2
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#405e83"
      opacity: 0.8
      Text {
        text: "Buy 5 Credits"
        anchors.centerIn: parent
        font.pixelSize: 21
        font.family: hudFont.name
        color: "white"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("IAP.Buy5Credits")
          levelStore.buyItem(levelStore.money5Pack.itemId)
          buyCreditDialog.opacity = 0
          parent.scale = 1.0
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
    Rectangle {
      height: 40
      width: buyCreditDialog.width*2
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#405e83"
      opacity: 0.8
      Text {
        text: "Buy 10 Credits"
        anchors.centerIn: parent
        font.pixelSize: 21
        font.family: hudFont.name
        color: "white"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("IAP.Buy10Credits")
          levelStore.buyItem(levelStore.money10Pack.itemId)
          buyCreditDialog.opacity = 0
          parent.scale = 1.0
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
    Rectangle {
      height: 40
      width: buyCreditDialog.width*2
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#405e83"
      opacity: 0.8
      Text {
        text: "Buy 50 Credits"
        anchors.centerIn: parent
        font.pixelSize: 21
        font.family: hudFont.name
        color: "white"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("IAP.Buy50Credits")
          levelStore.buyItem(levelStore.money50Pack.itemId)
          buyCreditDialog.opacity = 0
          parent.scale = 1.0
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
  }

  MainMenuButton {
    id: backButton

    text: ""

    offsetX: -120

    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10

    onClicked: {
      menuImage.scale = 1.0
      buyCreditDialog.opacity = 0
      cancelClicked()
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
      source: "../../../assets/img/menu-back.png"
      anchors.right: parent.right
      anchors.rightMargin: 10
    }

    Component.onCompleted: backButton.slideIn()
  }
}
