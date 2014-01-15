import QtQuick 1.1
import VPlay 1.0

Item {

  MultiResolutionImage {
    id: backImage
    source: "../../img/menuSquare-sd.png"

    scale: 0.45
    opacity: 0.2

    anchors.centerIn: pathCreationButton

    visible: scene.pathCreationMode
  }

  Text {
    text: qsTr("Drag your path from the green to the red spot\nClick on the Path button again to stop path creation")
    font.family: hudFont.name
    font.pixelSize: 10
    color: "white"
    anchors.verticalCenter: backImage.verticalCenter
    anchors.left: backImage.right

    visible: scene.pathCreationMode
  }

  // DONE: add a nicer image instead of this ugly button
  //SimpleButton {
  ToggleGameModeButton {
    // otherwise 2 white borders from the menu button and the obrder from this button would overlap
    x: 5
    text: "Game\nMode"
    onClicked: {
      // start playing the game
      scene.startGameFromLevelEditingMode();
    }
  }

  SingleSquabySpriteButton {
    id: pathCreationButton
    anchors.right: obstaclesRow.left
    anchors.verticalCenter: parent.verticalCenter

    spriteInSpriteSheetSource: "steps-6-straight.png"

    onClicked: {
      // TODO: change the button source here, make it shine so it is marked as active!
      scene.pathCreationMode = !scene.pathCreationMode
    }
  }

  Row {
    id: obstaclesRow
    anchors.right: parent.right

    // dont display, when pathCreationMode is true!
    visible: !scene.pathCreationMode

    BuildObstacleButton {
      toCreateEntityType: "../../entities/Obstacle.qml"
      variationType: "teddy"
      source: "teddy.png"
    }
    BuildObstacleButton {
      toCreateEntityType: "../../entities/Obstacle.qml"
      variationType: "choco"
      source: "choco-right.png"
    }
    BuildObstacleButton {
      toCreateEntityType: "../../entities/Obstacle.qml"
      variationType: "pillow"
      source: "pillow.png"
    }
    BuildObstacleButton {
      toCreateEntityType: "../../entities/Obstacle.qml"
      variationType: "soccerball"
      source: "soccerball-left.png"
    }
    BuildObstacleButton {
      toCreateEntityType: "../../entities/Obstacle.qml"
      variationType: "toyblocks"
      source: "toyblocks-left.png"
    }
    BuildObstacleButton {
      toCreateEntityType: "../../entities/Obstacle.qml"
      variationType: "book"
      source: "book-left.png"
    }

  } // end of obstacles row
}
