import QtQuick 2.0
import VPlay 2.0
import "../common"

Item {
  id: ratingDialog
  width: levelScene.gameWindowAnchorItem.width
  height: levelScene.gameWindowAnchorItem.height
  anchors.centerIn: parent

  visible: opacity === 0 ? false : true
  enabled: visible

  Behavior on opacity {
    NumberAnimation { duration: 150}
  }

  // rateValue is between 1-5
  signal levelRated(int rateValue)

  property int currentRating : 0

  onLevelRated: {
    opacity = 0
  }

  MouseArea {
    anchors.fill: parent
  }

  Rectangle {
    color: "black"
    anchors.fill: parent
    opacity: 0.9
  }

  Text {
    text: qsTr("Please rate:")

    font.family: jellyFont.name
    color: "white"
    font.pixelSize: 60

    anchors.bottom: ratingRow.top
    anchors.bottomMargin: 20
    anchors.horizontalCenter: parent.horizontalCenter
  }

  Row {
    id: ratingRow
    anchors.centerIn: parent
    spacing: 5

    Item {
      width: 50
      height: 50
      visible: currentRating >= 1
      MultiResolutionImage {
        source: "../../assets/img/star-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.1")
          levelRated(1)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating >= 2
      MultiResolutionImage {
        source: "../../assets/img/star-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.2")
          levelRated(2)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating >= 3
      MultiResolutionImage {
        source: "../../assets/img/star-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.3")
          levelRated(3)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating >= 4
      MultiResolutionImage {
        source: "../../assets/img/star-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.4")
          levelRated(4)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating >= 5
      MultiResolutionImage {
        source: "../../assets/img/star-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.5")
          levelRated(5)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating < 1
      MultiResolutionImage {
        source: "../../assets/img/star-no-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.1")
          levelRated(1)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating < 2
      MultiResolutionImage {
        source: "../../assets/img/star-no-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.2")
          levelRated(2)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating < 3
      MultiResolutionImage {
        source: "../../assets/img/star-no-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.3")
          levelRated(3)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating < 4
      MultiResolutionImage {
        source: "../../assets/img/star-no-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.4")
          levelRated(4)
        }
      }
    }
    Item {
      width: 50
      height: 50
      visible: currentRating < 5
      MultiResolutionImage {
        source: "../../assets/img/star-no-big.png"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          flurry.logEvent("Rating.5")
          levelRated(5)
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
      ratingDialog.opacity = 0
      flurry.logEvent("Rating.Cancled")
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

    Component.onCompleted: backButton.slideIn()
  }
}
