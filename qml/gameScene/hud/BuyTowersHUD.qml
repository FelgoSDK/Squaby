import QtQuick 2.0

Row {
  id: weaponsRow

  BuyTowerButton {
    id: nailgun
    source: "../../../assets/img/menu_labels/nailgun.png"
    toCreateEntityType: "../../entities/Nailgun.qml"
    visible: level.towerPermissions ? level.towerPermissions[0].checked : false
  }
  BuyTowerButton {
    id: flamethrower
    source: "../../../assets/img/menu_labels/flamethrower.png"
    toCreateEntityType: "../../entities/Flamethrower.qml"
    visible: level.towerPermissions ? level.towerPermissions[1].checked : false
  }
  // To enable new towers add lines in MyLevel.json:
  // ,{"checked":false,"name":"tesla"},{"checked":false,"name":"turbine"}
  // add lines in LevelEmpfty.qml
  //{checked: false, name: "taser"},
  //{checked: false, name: "tesla"},
  // and add buttons in BuyTowersHUD.qml
  // add lines in SquabyBalacingSettings.qml
  /*BuyTowerButton {
    id: taser
    source: "taser.png"
    toCreateEntityType: "../../entities/Taser.qml"
    visible: level.towerPermissions ? level.towerPermissions[2].checked : false
  }
  BuyTowerButton {
    id: tesla
    source: "tesla.png"
    toCreateEntityType: "../../entities/Tesla.qml"
    visible: level.towerPermissions ? level.towerPermissions[3].checked : false
  }*/
  // these buttons are used as dragging the tower and the initial versions of the tower in the default state
  BuyTowerButton {
    id: turbine
    source: "../../../assets/img/menu_labels/turbine.png"
    toCreateEntityType: "../../entities/Turbine.qml"
    visible: level.towerPermissions ? level.towerPermissions[2].checked : false
  }

} // end of buyTowerButtons row
