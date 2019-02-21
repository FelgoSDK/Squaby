import QtQuick 2.0
import Felgo 3.0

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
  property int __outslidedX:  slideInFromRight ? -outslidedXBase * (1  + delay / slideDuration) : outslidedXBase * (1  + delay / slideDuration)
  property int outslidedXBase:  384
  property bool slideInFromRight: true

  property alias textItem: textItem

  // Emitted when the button is clicked
  signal clicked
  signal pressed
  signal released
  signal canceled
  property bool slidedOut: false

  MultiResolutionImage {
    id: mainMenuButtonImage
    transformOrigin: Item.TopLeft
    opacity: 0.75

    source: "../../assets/img/menuBar.png"

    MouseArea {
      id: mouseArea
      anchors.fill: parent
      onClicked: {
        textItem.font.pixelSize = 42
        mainMenuButton.clicked()
      }

      onPressed: {
        textItem.font.pixelSize = 38
        mainMenuButton.pressed()
        mainMenuButtonImage.opacity = 0.9
      }
      onReleased: {
        textItem.font.pixelSize = 42
        mainMenuButton.released()
        mainMenuButtonImage.opacity = 0.75
      }
      onCanceled: {
        textItem.font.pixelSize = 42
        mainMenuButton.canceled()
      }
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
    mainMenuButton.slidedOut = false
    if(slideInFromRight) {
      x = -200 + offsetX
    } else {
      x = __outslidedX+200-offsetX-384
    }
  }

  function slideOut() {
    mainMenuButton.slidedOut = true
    if(slideInFromRight) {
      x = __outslidedX
    } else {
      x = __outslidedX
    }
  }

}
