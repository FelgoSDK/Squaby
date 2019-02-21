import QtQuick 2.0
import Felgo 3.0

BuildEntityButton {
    id: buyTowerButton

    width: 50
    height: hud.height

    toCreateEntityType: "../../entities/Obstacle.qml"

    // is needed to set the source for DragWeapon, which is the name of the png in the spritesheet json file
    // has e.g. the value "nailgun.png" - mention that the path is irrelevant, as the image is looked up in the json file
    property alias source: buttonSprite.source

    SingleSquabySprite {
        id: buttonSprite

        anchors.centerIn: parent
    }
}
