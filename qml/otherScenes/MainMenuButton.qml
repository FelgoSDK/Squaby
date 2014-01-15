import QtQuick 1.1
import VPlay 1.0

Item {
  id: mainMenuButton

  x: __outslidedX
  width: mainMenuButtonImage.width
  height: mainMenuButtonImage.height

  // This is used for providing a delay while fading in, it's currently no real delay, but the from will be adjusted
  property int delay: 0

  // The text that should on the button
  property string text

  // Add an additional offset to slightly displace the buttons
  property int offsetX: 0

  // The duration of the slide animation for this button
  property int slideDuration: 800

  // Save the x position when the button is slided out completely (including a delay)
  // 384 is the menubar image width
  property int __outslidedX:  -384 * (1  + delay / slideDuration)

  property alias textItem: textItem

  // Emitted when the button is clicked
  signal clicked

  MultiResolutionImage {
    id: mainMenuButtonImage
    transformOrigin: Item.TopLeft
    opacity: 0.75

    source: "../img/menuBar-sd.png"

    MouseArea {
      id: mouseArea
      anchors.fill: parent
      onClicked: mainMenuButton.clicked()
      onPressed: mainMenuButtonImage.opacity = 0.9
      onReleased: mainMenuButtonImage.opacity = 0.75
    }
  }

  Text {
    id: textItem
    text: mainMenuButton.text
    color: "white"
    font.family: jellyFont.name
    font.pixelSize: 42

    anchors.right: mainMenuButton.right
    anchors.rightMargin: 15
    anchors.verticalCenter: mainMenuButton.verticalCenter
  }

  Behavior on x {
    SmoothedAnimation { duration: slideDuration; easing.type: Easing.InOutQuad }
  }

  function slideIn() {
    x = -200 + offsetX
  }

  function slideOut() {
    x = __outslidedX
  }

}
