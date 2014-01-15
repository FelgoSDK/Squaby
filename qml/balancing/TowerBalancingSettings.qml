import QtQuick 1.1

QtObject {
  property int cost: 20
  property int saleRevenue: 5
  property variant upgradeLevels/*: {
      // the status field for the upgrade is only needed for turbine upgrade!
      "range": [{"level": 1, "cost": 10, "value": 5*scene.gridSize, "additionalSaleRevenue": 5}],
      "shootDelay": [{"level": 1, "cost": 15, "value": 400, "additionalSaleRevenue": 10}]
  }*/
  property int shootDelayInMilliSeconds: 600
}
