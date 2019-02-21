import QtQuick 2.0
import Felgo 3.0
import "../otherScenes"

SquabySceneBase {
  id: scene

  // needs to be accessed assigned to the FelgoGameNetwork, so it can show it
  property alias gameNetworkView: gameNetworkView

  property string cameFromScene

  GameNetworkView {
    id: gameNetworkView
    anchors.fill: scene.gameWindowAnchorItem

    // this is only used temporarily, until the font issue is fixed

    onBackClicked: {
      scene.backButtonPressed()
    }
  }
}
