import QtQuick 1.1
import VPlay 1.0

Item {
  property int score: 5
  property int gold: 5
  property int health: 100
  property real damageMultiplicatorNailgun: 1
  property real damageMultiplicatorFlamethrower: 1

  //completePathAnimationDuration: 15000
  // speed of 70 will lead to about 15 seconds pathDuration
  property int pathMovementPixelsPerSecond: 70

  // this is used to separate the squaby groups, and must be set from BalancingSettings
  property string variationType: "squabyYellow"

  // commented at the moment as it is in active development
  /*EditableComponent {
    id: editableEditorComponent

    editableType: "SquabySettings"
    // this is needed, because all EditableComponents for type "SquabySettings" have the same property names - this would not work without the defaultGroup set
    defaultGroup: variationType

    properties: {
        "score": {"min": 1, "max": 500, "label": "Score"},
        "gold": {"minm": 1, "max": 500, "label": "Gold"},
        "health": {"min": 1, "max": 1000, "label": "Health"},
        "pathMovementPixelsPerSecond": {"min": 1, "max": 1000, "label": "Speed"}
    }
  }*/
}
