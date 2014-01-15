import QtQuick 1.1
import VPlay 1.0
import "../../levels" // for the MenuButton, which is also used for the level laoding

Item {
    anchors.fill: parent
    anchors.centerIn: parent
    id: performanceOverlay
    opacity: 0.7

    // ATTENTION: flickable does not automatically clip its contents! so always use it as fullscreen item at the moment!
    Flickable {
        id: flickable
        //anchors.fill: parent
        anchors.centerIn: parent
        // never make the flickable bigger than the parent, if the columns is smaller (so less items), the flickable should not be as big as the item!
        width: (column.width<parent.width) ? column.width : parent.width
        height: (column.height<parent.height) ? column.height : parent.height

        contentWidth: column.width
        contentHeight: column.height
        flickableDirection: Flickable.VerticalFlick

        Column {
            id: column
            spacing: 2
            anchors.centerIn: parent
    //        MenuButton {
    //            color: "red"
    //            text: "Animations"
    //            onClicked: entityManager.toggleAnimations();
    //        }
            MenuButton {
                color: "darkorange"
                text: "Level Mode"
                onClicked: scene.state = "levelEditing"
            }
            MenuButton {
                color: "green"
                text: "Healthbar"
                onClicked: entityManager.toggleHealthbar();
            }
            // PathMovement cant be toggled any more - this was only used for sprite testing, see spriteManager.js in performanceTests for testing the impact of that!
//            MenuButton {
//                color: "blue"
//                text: "PathMovement"
//                onClicked: entityManager.togglePathMovement();
//            }
            MenuButton {
                color: "black"
                text: "Toggle Raster"
                onClicked:  {
                    raster.visible = !raster.visible
                }
            }

            // toggles the visibility e.g. of the HUD, frontObjects, etc.
            MenuButton {
                color: "brown"
                text: "Toggle visibilities"
                onClicked:  {

                    var sceneState = scene.state;
                    if(sceneState === "ingameMenuPerformanceTesting") {
                        scene.state = "hideObstacles";
                    } else if(sceneState === "hideObstacles") {
                        scene.state = "hideHUD";
                    } else if(sceneState === "hideHUD") {
                        // reset here again
                        scene.state = "hideHUDAndObstacles";
                    } else if(sceneState === "hideHUDAndObstacles") {
                        // reset here again
                        scene.state = "hideAll";
                    } else {
                        // reset here again
                        scene.state = "ingameMenuPerformanceTesting";
                    }
                }
            }

            MenuButton {
                color: "cyan"
                text: "Toggle Wave"
                onClicked:  {
                    squabyCreator.enabled = !squabyCreator.enabled
                }
            }

            MenuButton {
                color: "orange"
                text: "Toggle Physics"
                onClicked:  {
                    physicsWorld.debugDrawVisible = !physicsWorld.debugDrawVisible
                }
            }

            MenuButton {
                color: "darkcyan"
                text: "Toggle Sounds"
                onClicked:  {
                    settings.soundEnabled = !settings.soundEnabled

                    if(!settings.soundEnabled) {
                        backgroundMusic.stop();
                    } else {
                        backgroundMusic.play();
                    }
                }
            }

            MenuButton {
                color: "darkgreen"
                text: "Toggle Particles"
                onClicked:  {
                    settings.particlesEnabled = !settings.particlesEnabled
                }
            }

            MenuButton {
                color: "darkblue"
                text: "Toggle TestSquaby"
                onClicked:  {
                    // this can be used to test performance with a strong squaby that does not get killed that easily
                    level.createYellowSquaby = !level.createYellowSquaby
                }
            }

            MenuButton {
                color: "darkgrey"
                text: "Toggle Pooling"
                onClicked:  {
                    entityManager.poolingEnabled = !entityManager.poolingEnabled;
                }
            }
        }

    } // end of Flickable

}
