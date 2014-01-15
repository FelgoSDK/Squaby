import QtQuick 1.1

Item {
  id: button

  // this is the only required property of this component!
  // with this component a general button, with an image from the sprite sheet could be achieved!
  property alias spriteInSpriteSheetSource: sprite.source

  // can be handled by the calling component
  signal clicked

  // is needed, otherwise anchoring the buttons in a Row wouldnt work!
  width: sprite.width
  height: sprite.height

  property alias mouseArea: mouseArea

  SingleSquabySprite {
    id: sprite    
  }
  MouseArea {
    id: mouseArea
    anchors.fill: parent

    onClicked: {
      button.clicked();
    }
  }
}
