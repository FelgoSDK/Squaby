import QtQuick 1.1
import VPlay 1.0

Row {
    anchors.bottom: parent.bottom

    signal menuButtonClicked

    // cant load font in png format
    //FontLoader { id: tuffy; source: "img/tuffy_bold_italic-charmap.png" }

    Item {
        // this item is only needed, because the MouseArea must not be a child of Row, because anchoring is used there
        width: menuButton.width
        height: menuButton.height

        //Image { // use a res-independent spritesheet instead
        SingleSquabySprite {
            id: menuButton
            source: "menuIconMenuButton.png"
        }
        // the MouseArea must not be a child of SingleSquabySprite, as all the children get overwritten there!
        MouseArea {
            // the anchors.fill: menuButton causes the following QML error: "QML Row: Cannot specify left, right, horizontalCenter, fill or centerIn anchors for items inside Row"
            // it does work though, so leave it
            anchors.fill: menuButton
            onClicked: {                
                menuButtonClicked();
            }
        }
    }

    Item {
        id: waveItem
        width: 64
        height: 64

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // a check might be added her, to only create a new squaby when the squabyCreator is in state "waitingForNextWave"!
                squabyCreator.createNextSquabyImmediately();
            }
        }

        SingleSquabySprite {
            id: waveButton
            source: "labelWave.png"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            // the button else is too far on the bottom and doesnt look good
            anchors.bottomMargin: 2

            //source: "img/StartWaveButton_filled.png"
        }

        /* this is confusing for users, dont display the waves with a healthbar!
          *
        Healthbar {            
            id: waveProgressIndicator
            width: waveButton.width-5
            height: 3
            anchors.bottom: waveButton.top
            anchors.horizontalCenter: parent.horizontalCenter
            y: -4
            property real percentDecreasePerTick: 1

            property real vertexZ: 5 // ATTENTION: this must be set higher than the vertexZ of the HUD, otherwise the background will be drawn on top, as spritesheet is drawn after the label

            // this wouldnt work smoothly then, so no animation would be used!
            //percent: squabyCreator.percentageCreatedInWave

            NumberAnimation on percent {
                id: percentAnimation
                running: false
                from: 1
                to: 0
            }

            Connections {
                target: squabyCreator
                onStateChanged: {
                    if(squabyCreator.state === "waitingForNextWave") {
                        // reduce the time of the animation to guarantee the animation will be finished when
                        // TODO: the timing does not match! the onTriggered in squabyCreator is called sooner than the set interval!? thus it looks jumpy, especially at more squabies in the scene
                        // fix this issue!
                        percentAnimation.duration = squabyCreator.currentPauseBetweenWaves;
                        percentAnimation.start();
                    }
                }
                onPercentageCreatedInWaveChanged: {
                    // if an animation was running, stop it, otherwise it would finish the animation and the new percent value would be overwritten
                    percentAnimation.stop();
                    waveProgressIndicator.percent = squabyCreator.percentageCreatedInWave;

                }
            }

            // no timer needed, an animation is better, although it updates it with 60Hz which might be costly for that
//            Timer {
//                id: waveProgressTimer
//                running: false
//                interval: 100 // trigger every 100 ms, do not set the interval too low as low animation update will cause reduced performance and this is not as visually important
//                repeat: true
//                onTriggered: {
//                    // it is mapped to 0 as minimum value automatically
//                    waveProgressIndicator.percent-=waveProgressIndicator.percentDecreasePerTick;
//                }
//            }
        } */

        Text {
            id: waveTextItem
            text: player.wave
            color: "white"
            font.pixelSize: 20
            font.family: hudFont.name
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -15

            property real vertexZ: 5 // ATTENTION: this must be set higher than the vertexZ of the HUD, otherwise the background will be drawn on top, as spritesheet is drawn after the label
        }

        // this text item shows the currently created squabies, and the total amount available
        Text {
            text: squabyCreator.squabiesBuiltInCurrentWave + " | " + squabyCreator.amountSquabiesInCurrentWave
            color: "white"
            font.pixelSize: 10
            font.family: hudFont.name
            anchors.top: waveTextItem.bottom
            anchors.topMargin: 1
            anchors.horizontalCenter: parent.horizontalCenter


            property real vertexZ: 5 // ATTENTION: this must be set higher than the vertexZ of the HUD, otherwise the background will be drawn on top, as spritesheet is drawn after the label
        }
    }

    Item {
        id: goldItem
        width: 64
        height: 64

        SingleSquabySprite {
            id: goldImage
            source: "menuIconGold.png"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            //source: "img/iMenuIconGold.png"

        }

        Text {
            id: goldTextItem
            text: player.gold
            color: "white"
            font.pixelSize: 20
            font.family: hudFont.name
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -12

            property real vertexZ: 5 // ATTENTION: this must be set higher than the vertexZ of the HUD, otherwise the background will be drawn on top, as spritesheet is drawn after the label
        }

    }

    states: State {
        name: "menuOnly"
        PropertyChanges { target: waveItem; visible: false }
        PropertyChanges { target: goldItem; visible: false }
        }
} // Row
