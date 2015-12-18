import QtQuick 2.0
import VPlay 2.0

Item {
  property int score: 0
  property int gold: 0
  property int health: 100
  property real damageMultiplicatorNailgun: 0
  property real damageMultiplicatorFlamethrower: 0
  property real damageMultiplicatorTaser: 0
  property real damageMultiplicatorTesla: 0

  //completePathAnimationDuration: 15000
  // speed of 70 will lead to about 15 seconds pathDuration
  property int pathMovementPixelsPerSecond: 0

  // this is used to separate the squaby groups, and must be set from BalancingSettings
  property string variationType: "squabyYellow"

  EditableComponent {
    id: editableEditorComponent

    editableType: "SquabySettings"
    // this is needed, because all EditableComponents for type "SquabySettings" have the same property names - this would not work without the defaultGroup set
    defaultGroup: variationType

    properties: {
      "score": {"min": 0, "max": 100, "stepsize": 5, "label": "Score"},
      "gold": {"minm": 0, "max": 100, "stepsize": 5, "label": "Gold"},
      //"health": {"min": 0, "max": 100, "stepsize": 5, "label": "Health"}, // always 100 anyway because it is based on the damage multiplicators
      "pathMovementPixelsPerSecond": {"min": 0, "max": 1000, "stepsize": 5, "label": "Speed"},
      "damageMultiplicatorNailgun": {"min": 0, "max": 5, "stepsize": 0.01, "label": "DMG Nailgun"},
      "damageMultiplicatorFlamethrower": {"min": 0, "max": 5, "stepsize": 0.01, "label": "DMG Flamethrower"},
      //"damageMultiplicatorTaser": {"min": 0, "max": 5, "stepsize": 0.01, "label": "DMG Taser"},
      //"damageMultiplicatorTesla": {"min": 0, "max": 5, "stepsize": 0.01, "label": "DMG Tesla"}
    }
    // To enable new towers add lines in MyLevel.json:
    // ,{"checked":false,"name":"tesla"},{"checked":false,"name":"turbine"}
    // add lines in LevelEmpfty.qml
    //{checked: false, name: "taser"},
    //{checked: false, name: "tesla"},
    // and add buttons in BuyTowersHUD.qml
    // add lines in SquabyBalacingSettings.qml
  }
}
