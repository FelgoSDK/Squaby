import QtQuick 1.1

Row {
  id: weaponsRow


  BuyTowerButton {
    id: nailgun
    source: "nailgun.png"
    toCreateEntityType: "../../entities/Nailgun.qml"
  }
  BuyTowerButton {
    id: flamethrower
    source: "flamethrower.png"
    toCreateEntityType: "../../entities/Flamethrower.qml"
  }
  // these buttons are used as dragging the tower and the initial versions of the tower in the default state
  BuyTowerButton {
    id: turbine
    source: "turbine.png"
    toCreateEntityType: "../../entities/Turbine.qml"
  }

} // end of buyTowerButtons row
