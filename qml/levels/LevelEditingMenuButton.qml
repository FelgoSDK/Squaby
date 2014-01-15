import QtQuick 1.1
import VPlay 1.0
import "../gameScene/hud"

ToggleGameModeButton {
  width: 100
  height: 40

  // make slightly opaque to see the obstacles behind
  // when pressed, make it look darker
  opacity: pressed ? 0.95 : 0.85
}
