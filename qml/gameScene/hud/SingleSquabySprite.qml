import QtQuick 1.0
import VPlay 1.0

/// A convenience-component for all non-entity sprites in the Squaby project, setting translateToCenter to false and preloaded with the currently single available Spritesheet containing all lables, buttons, etc.
SingleSpriteFromFile {
    filename: "../../img/all-sd.json"
    translateToCenterAnchor: false
}
