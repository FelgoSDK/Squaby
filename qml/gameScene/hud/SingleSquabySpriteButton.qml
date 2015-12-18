import QtQuick 2.0

Item {
  id: button

  // this is the only required property of this component!
  // with this component a general button, with an image from the sprite sheet could be achieved!
  property string spriteInSpriteSheetSource

  // can be handled by the calling component
  signal clicked

  // is needed, otherwise anchoring the buttons in a Row wouldnt work!
  width: sprite.width
  height: sprite.height

  property alias mouseArea: mouseArea

  SingleSquabySprite {
    id: sprite
    source: spriteInSpriteSheetSource !== "" ? "../../../assets/img/" + spriteInSpriteSheetSource : spriteInSpriteSheetSource
  }
  MouseArea {
    id: mouseArea
    anchors.fill: parent

    onClicked: {
      button.clicked()
      parent.scale = 0.9
    }
    onPressed: {
      parent.scale = 0.75
    }
    onReleased: {
      parent.scale = 0.9
    }
    onCanceled: {
      parent.scale = 0.9
    }
  }
}
