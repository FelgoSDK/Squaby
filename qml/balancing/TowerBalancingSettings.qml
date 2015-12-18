import QtQuick 2.0
import VPlay 2.0

// use Item instead of QtObject or it won't work correctly with EditableComponents
Item {
  property int cost: 20
  property int saleRevenue: 5
  property variant upgradeLevels/*: {
      // the status field for the upgrade is only needed for turbine upgrade!
      "range": [{"level": 1, "cost": 10, "value": 5*scene.gridSize, "additionalSaleRevenue": 5}],
      "shootDelay": [{"level": 1, "cost": 15, "value": 400, "additionalSaleRevenue": 10}]
  }*/
  property int shootDelayInMilliSeconds: 600

  property string variationType: "nailgun"
  property bool useShootDelayInMilliSeconds: false

  /*function updateUpgradeLevels() {
    if(upgradeLevels === undefined)
      return

    var newUpgradeLevels = upgradeLevels
    newUpgradeLevels["range"] = [{"level": rangeLevel, "cost": rangeCost, "value": rangeValue, "additionalSaleRevenue": rangeAdditionalSaleRevenue}]
    newUpgradeLevels[useShootDelayInMilliSeconds?"shootDelay":"damagePerSecond"] = [{"level": shootDelayLevel, "cost": shootDelayCost, "value": shootDelayValue, "additionalSaleRevenue": shootDelayAdditionalSaleRevenue}]
    upgradeLevels = newUpgradeLevels
  }

  //Range Settings
  property int rangeLevel: 1
  onRangeLevelChanged: {
    updateUpgradeLevels()
  }
  property int rangeCost: 10
  onRangeCostChanged: {
    updateUpgradeLevels()
  }
  property int rangeValue: 5*scene.gridSize
  onRangeValueChanged: {
    updateUpgradeLevels()
  }
  property int rangeAdditionalSaleRevenue: 5
  onRangeAdditionalSaleRevenueChanged: {
    updateUpgradeLevels()
  }
  //Shoot Delay Settings
  property int shootDelayLevel: 1
  onShootDelayLevelChanged: {
    updateUpgradeLevels()
  }
  property int shootDelayCost: 15
  onShootDelayCostChanged: {
    updateUpgradeLevels()
  }
  property int shootDelayValue: 450
  onShootDelayValueChanged: {
    updateUpgradeLevels()
  }
  property int shootDelayAdditionalSaleRevenue: 10
  onShootDelayAdditionalSaleRevenueChanged: {
    updateUpgradeLevels()
  }

  EditableComponent {
    editableType: "TowerSettings"
    defaultGroup: variationType

    properties: {
      "cost": {"min": 0, "max": 95, "stepsize": 5, "label": "Cost"},
      "saleRevenue": {"minm": 0, "max": 100, "stepsize": 5, "label": "Revenue"},
      "shootDelayInMilliSeconds": {"min": 0, "max": 1000, "stepsize": 5, "label": useShootDelayInMilliSeconds?"Speed":"Damage"},

      //"upgradeLevels": {},
      "rangeLevel": {"min": 1, "max": 5, "stepsize": 1, "label": "Range Level"},
      "rangeCost": {"min": 0, "max": 95, "stepsize": 5, "label": "Range Cost"},
      "rangeValue": {"min": 0, "max": 1000, "stepsize": 5, "label": "Range Value"},
      "rangeAdditionalSaleRevenue": {"min": 0, "max": 100, "stepsize": 5, "label": "Range Revenue"},
      "shootDelayLevel": {"min": 1, "max": 5, "stepsize": 1, "label": (useShootDelayInMilliSeconds?"Shoot Delay":"Damage p.s")+" Level"},
      "shootDelayCost": {"min": 0, "max": 95, "stepsize": 5, "label": (useShootDelayInMilliSeconds?"Shoot Delay":"Damage p.s")+" Cost"},
      "shootDelayValue": {"min": 0, "max": 1000, "stepsize": 5, "label": (useShootDelayInMilliSeconds?"Shoot Delay":"Damage p.s")+" Value"},
      "shootDelayAdditionalSaleRevenue": {"min": 0, "max": 100, "stepsize": 5, "label": (useShootDelayInMilliSeconds?"Shoot Delay":"Damage p.s")+" Revenue"}
    }
  }*/
}
