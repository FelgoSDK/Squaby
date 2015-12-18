import QtQuick 2.0
import VPlay 2.0

Row {
    anchors.bottom: parent.bottom

    Item {
        id: waveItem
        width: 64
        height: 64

        MouseArea {
            anchors.fill: parent
            onClicked: {
              // a check might be added her, to only create a new squaby when the squabyCreator is in state "waitingForNextWave"!
              var extraPoints = squabyCreator.createNextSquabyImmediately();
              if(extraPoints>0 && !scene.endlessGameAllowed) {
                pointsMessage.show(extraPoints)
              }
            }
        }

        SingleSquabySprite {
            id: waveButton
            source: "../../../assets/img/menu_labels/labelWave.png"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            // the button else is too far on the bottom and doesn't look good
            anchors.bottomMargin: 2
        }

        Text {
            id: waveTextItem
            text: player.wave
            color: "white"
            font.pixelSize: 20
            font.family: hudFont.name
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -15
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
        }

        Text {
          id: pointsMessage
          x: parent.width/2-text.pointsMessage/2
          y: -pointsMessage.height
          text: ""
          color: "white"
          opacity: 0

          function show(points) {
            pointsMessage.opacity = 1
            pointsMessage.text = "+"+(points/100).toFixed(0)+" points"
            player.instantBonus+= points/100
            if(!hideMessage.running)
              hideMessage.start()
          }

          Behavior on opacity {
            // the cross-fade animation should last 350ms
            NumberAnimation { duration: 350 }
          }

          Timer {
            id: hideMessage
            interval: 650
            repeat: false
            onTriggered: {
              pointsMessage.opacity = 0
            }
          }
        }
    }

    Item {
        id: goldItem
        width: 64
        height: 64

        SingleSquabySprite {
            id: goldImage
            source: "../../../assets/img/menu_labels/menuIconGold.png"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
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
        }
    }
} // Row
