import QtQuick 2.0

//Image {
Item {
    id: upgradeWeapon


    // this can be handled by the hud, especially for the sell button to change the upgradeState of the hud back to the buy state
    signal clicked

    property string toDestroyEntityId;

    // is needed, otherwise anchoring the UpgradeWeapon-Buttons in a Row wouldnt work!
    width: upgradeWeaponSprite.width
    height: upgradeWeaponSprite.height


    SingleSquabySprite {
        id: upgradeWeaponSprite
        source: "../../../assets/img/menu_labels/sell.png"
    }


    MouseArea {
        anchors.fill: parent

        onClicked: {
            // emit the clicked signal only when the operation is available successful! the clicked signal gets used in the HUD to play the sound effects
            upgradeWeapon.clicked();
            //entityManager.removeEntityById(toDestroyEntityId);
        }
    }
}
