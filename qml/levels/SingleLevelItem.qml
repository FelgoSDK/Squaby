import QtQuick 1.1
import VPlay 1.0

// this item is displayed in the LevelSelectionScene for each level available in the game - when it is clicked, the level is loaded
Item {
  id: levelItem

  width: 97
  height: 97

  property string itemLevelName

  // either levelData or levelUrl may be set
  property variant levelData
  property url itemLevelUrl

  property int maxScoreInLevel
  // who made the level
  property string author
  // an optional description about the level
  property string description
  // may be between 0 and 5, in future versions - can be used to display the stars
  property real rating: Math.random() * 5 + 0.5

  // this gets set at level loading from dynamic levels - could also set as type int?
  property string itemLevelId

  // Emitted when the button is clicked
  signal clicked

  // this may be used for testing the values of the internal properties
//  Text {
//    text: "Id:" + itemLevelId + "\nUrl:" + itemLevelUrl
//    color: "white"
//    font.family: hudFont.name
//    font.pixelSize: 10
//  }

  MultiResolutionImage {
    id: backImage
    source: "../img/menuSquare-sd.png"
    opacity: 0.75
  }

  Text {
    text: itemLevelName
    color: "white"
    font.family: hudFont.name
    font.pixelSize: 13    
    anchors.horizontalCenter: parent.horizontalCenter
    y: levelItem.height/2-15
  }

  Text {
    text: "Score: " + maxScoreInLevel
    color: "white"
    font.family: hudFont.name
    font.pixelSize: 10
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    visible: maxScoreInLevel >= 0
  }

  // comment at the moment, as rating is not implemented yet as no userGeneratedLevels are available yet
//  Row {
//    spacing: 2
//    anchors.horizontalCenter: parent.horizontalCenter
//    anchors.top: parent.top
//    anchors.topMargin: 10

//    visible: rating >= 0

//    Repeater {
//      model: Math.round(rating)
//      MultiResolutionImage {
//        source: "../img/star-sd.png"
//      }
//    }
//  }

  MouseArea {
    anchors.fill: parent

    onPressed: backImage.opacity = 1
    onReleased: backImage.opacity = 0.75
    onCanceled: backImage.opacity = 0.75

    onClicked: levelItem.clicked()
  }
}
