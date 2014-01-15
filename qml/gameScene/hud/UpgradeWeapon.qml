import QtQuick 1.0

//Image {
Item {
    id: upgradeWeapon
    // can be range or shootDelay or repair
    property string upgradeType: ""

    // this lets the outside component set the cost of this upgrade or tower
    property alias cost:costTag.cost

    // affordable should change with the player gold - if the player has more gold than the tower costs, it is affordable; if non-affordable, opacity will be set to 0.5
    // it is set to true explicitly for the sell button!
    property bool affordable: player.gold>=cost
    opacity: affordable && !fullyUpgraded ? 1 : 0.5


    property bool fullyUpgraded: false
    property int upgradeLevel: 0
    property string selectedTowerId: "undefined"
    property string selectedTowerType: "undefined"

    property alias source: upgradeWeaponSprite.source

    // this can be handled by the hud, especially for the sell button to change the upgradeState of the hud back to the buy state
    signal clicked

    // is needed, otherwise anchoring the UpgradeWeapon-Buttons in a Row wouldnt work!
    width: upgradeWeaponSprite.width
    height: upgradeWeaponSprite.height

    function setUpgradeButtonFromEvent(event) {


        var rangeUpgrade;
        var shootDelayUpgrade;
        var activeUpgrade;
        for(var i=0;i<event.upgrades.length;i++) {
            var upgrade = event.upgrades[i];
            if(upgrade.type === "range")
                rangeUpgrade = upgrade;
            else if(upgrade.type === "shootDelay" || upgrade.type === "damagePerSecond")
                shootDelayUpgrade = upgrade;

            if(upgrade.type === upgradeType)
                activeUpgrade = upgrade;
        }

        if(!activeUpgrade || !rangeUpgrade || !shootDelayUpgrade) {
            console.log("WARNING: one of the necessary upgrades range or shootDelay not found, this should never happen!");
            console.log("UpgradeWeapon: activeUpgrade: " + activeUpgrade + ", rangeUpgrade: " + rangeUpgrade + ", shootDelayUpgrade: " + shootDelayUpgrade + ", upgradeType of QML object: " + upgradeType);
            return;
        }
        console.log("UpgradeWeapon: active upgrade is " + activeUpgrade.type);

        cost = activeUpgrade.cost;

        selectedTowerId = event.entityId;
        selectedTowerType = event.entityType;

        // fullyUpgraded modification is not only useful for range and shootDelay upgrade
        // also with the repair upgrade can be determined if the repair upgrade was used (then it should not be available)
        if(activeUpgrade.upgradeLevel === activeUpgrade.currentPlayerUpgradeLevel) {
            console.debug("UpgradeWeapon: upgrade of type " + upgradeType + " is fully upgraded");
            fullyUpgraded = true;
        } else {
            console.debug("UpgradeWeapon: upgrade of type " + upgradeType + " is not fully upgraded");
            fullyUpgraded = false;
        }

        console.log("UpgradeWeapon: activeUpgrade.currentPlayerUpgradeLevel: " + activeUpgrade.currentPlayerUpgradeLevel + ", activeUpgrade.upgradeLevel: " + activeUpgrade.upgradeLevel + ", selectedTowerType: " + selectedTowerType);

        if(activeUpgrade.type === "range") {
            if(activeUpgrade.upgradeLevel === 1)
                if(selectedTowerType === "nailgun")
                    source = "nailgunUpgradeRange.png";
                else if(selectedTowerType === "flamethrower")
                    source = "flamethrowerUpgradeRange.png";
                else if(selectedTowerType === "turbine")
                    source = "turbineUpgradeRange.png"
            // if other upgrade is at level 1 and this upgrade is not fully built, this image needs to be replaced with full upgrade one
            if(shootDelayUpgrade.currentPlayerUpgradeLevel === 1 && !fullyUpgraded)
                if(selectedTowerType === "nailgun")
                    source = "nailgunUpgradeBoth.png";
                else if(selectedTowerType === "flamethrower")
                    source = "flamethrowerUpgradeBoth.png";
                else if(selectedTowerType === "turbine")
                    source = "turbineUpgradeBoth.png"
        } else if(activeUpgrade.type === "shootDelay" || activeUpgrade.type === "damagePerSecond" ) {
            // use the same images for shootDelayUpgrade (nailgun & turbine) and damagePerSecond (flamethrower)
            if(upgrade.upgradeLevel === 1)
                if(selectedTowerType === "nailgun")
                    source = "nailgunUpgradeFire.png";
                else if(selectedTowerType === "flamethrower")
                    source = "flamethrowerUpgradeFire.png";
                else if(selectedTowerType === "turbine")
                    source = "turbineUpgradeFire.png"
            // if other upgrade is at level 1 and this upgrade is not fully built, this image needs to be replaced with full upgrade one
            if(rangeUpgrade.currentPlayerUpgradeLevel === 1 && !fullyUpgraded)
                if(selectedTowerType === "nailgun")
                    source = "nailgunUpgradeBoth.png";
                else if(selectedTowerType === "flamethrower")
                    source = "flamethrowerUpgradeBoth.png";
                else if(selectedTowerType === "turbine")
                    source = "turbineUpgradeBoth.png"
        }

        console.log("UpgradeWeapon: selected source: " + source);

    }

    SingleSquabySprite {
        id: upgradeWeaponSprite
        // the source gets set in setUpgradeButtonFromEvent()

    }

    PriceTag {
        id: costTag
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            // this isnt needed - the function upgradeTower() can be called directly on the tower!
//            var guiEvent = {
//                eventType: "upgrade_selected",
//                towerId: selectedTowerId,
//                upgradeType: upgradeWeapon.upgradeType
//            }
            //engine.createGuiEvent(guiEvent);            

            // check if the player has enough money, and this upgrade is not fully used
            // this gets also checked in upgradeTower() though, but it can be checked here already to avoid checking again in upgradeTower()
            if(affordable && !fullyUpgraded) {
                var selectedTower = entityManager.getEntityById(selectedTowerId);

                if(!selectedTower) {
                    console.debug("UpgradeWeapon: WARNING: the tower with id '", selectedTowerId, "' was not found in the entity array! no upgrade possible!")
                    return;
                }
                selectedTower.upgradeTower(upgradeType);

                // decrease the player gold by the cost of this upgrade
                // this is done in TowerBase!
                //player.gold -= cost;

                // emit the clicked signal only when the operation is available successful! the clicked signal gets used in the HUD to play the sound effects
                upgradeWeapon.clicked();
            }
        }
    }
}
