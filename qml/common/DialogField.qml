import QtQuick 2.0
import Felgo 3.0

Item {
  id: dialogField

  width: 200
  height: 200

  property bool styledDialog: false

  anchors.centerIn: parent

  visible: opacity === 0 ? false : true
  enabled: visible

  signal option1Pressed
  onOption1Pressed: {
    opacity = 0
  }

  signal option2Pressed
  onOption2Pressed: {
    opacity = 0
  }

  signal option3Pressed
  onOption3Pressed: {
    opacity = 0
  }

  property alias options1Text: options1Text.text
  property alias options2Text: options2Text.text
  property alias options3Text: options3Text.text
  property alias descriptionText: descriptionText.text

  Behavior on opacity {
    NumberAnimation { duration: 150}
  }

  MouseArea {
    anchors.fill: parent
  }

  Rectangle {
    color: "black"
    anchors.fill: parent
    opacity: 0.9
  }

  Column {
    id: col
    spacing: 10
    width: parent.width
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: 20
    visible: !styledDialog

    Item {
      width: parent.width
      height: 90

      Text {
        id: descriptionText
        width: parent.width/2
        height: parent.height
        text: ""
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
        font.family: hudFont.name
      }
    }

    Rectangle {
      height: 40
      width: dialogField.width*2
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#405e83"
      opacity: 0.8
      visible: options1Text.text != ""
      Text {
        id: options1Text
        text: ""
        anchors.centerIn: parent
        font.pixelSize: 21
        font.family: hudFont.name
        color: "white"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          option1Pressed()
          parent.scale = 1.0
        }
        onPressed: {
          parent.scale = 0.85
        }
        onReleased: {
          parent.scale = 1.0
        }
        onCanceled: {
          parent.scale = 1.0
        }
      }
    }
    Rectangle {
      height: 40
      width: dialogField.width*2
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#405e83"
      opacity: 0.8
      visible: options2Text.text != ""
      Text {
        id: options2Text
        text: ""
        anchors.centerIn: parent
        font.pixelSize: 21
        font.family: hudFont.name
        color: "white"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          option2Pressed()
          parent.scale = 1.0
        }
        onPressed: {
          parent.scale = 0.85
        }
        onReleased: {
          parent.scale = 1.0
        }
        onCanceled: {
          parent.scale = 1.0
        }
      }
    }
    Rectangle {
      height: 40
      width: dialogField.width*2
      anchors.horizontalCenter: parent.horizontalCenter
      color: "#405e83"
      opacity: 0.8
      visible: options3Text.text != ""
      Text {
        id: options3Text
        text: ""
        anchors.centerIn: parent
        font.pixelSize: 21
        font.family: hudFont.name
        color: "white"
      }
      MouseArea {
        anchors.fill: parent
        onClicked: {
          option3Pressed()
          parent.scale = 1.0
        }
        onPressed: {
          parent.scale = 0.85
        }
        onReleased: {
          parent.scale = 1.0
        }
        onCanceled: {
          parent.scale = 1.0
        }
      }
    }
  }

  MultiResolutionImage {
    id: menuBox
    anchors.centerIn: parent
    source: "../../assets/img/menu-box.png"
    visible: styledDialog

    Text {
      width: parent.width-20
      height: parent.height-dialogButton.height
      text: descriptionText.text
      anchors.horizontalCenter: parent.horizontalCenter
      color: "white"
      font.family: hudFont.name
    }


    MultiResolutionImage {
      id: dialogButton
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter
      source: "../../assets/img/menu-box-base.png"
      Text {
        text: options1Text.text
        anchors.centerIn: parent
        font.pixelSize: 21
        font.family: hudFont.name
        color: "white"
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          option1Pressed()
        }
        onPressed: {
          parent.scale = 0.85
        }
        onReleased: {
          parent.scale = 1.0
        }
        onCanceled: {
          parent.scale = 1.0
        }
      }
    }
  }


  MainMenuButton {
    id: backButton
    visible: !styledDialog

    text: ""

    offsetX: -120

    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10

    onClicked: {
      menuImage.scale = 1.0
      dialogField.opacity = 0
    }
    onPressed: {
      menuImage.scale = 0.85
    }
    onReleased: {
      menuImage.scale = 1.0
    }
    onCanceled: {
      menuImage.scale = 1.0
    }

    MultiResolutionImage {
      id: menuImage
      source: "../../assets/img/menu-back.png"
      anchors.right: parent.right
      anchors.rightMargin: 10
    }

    Component.onCompleted: backButton.slideIn()
  }
}
