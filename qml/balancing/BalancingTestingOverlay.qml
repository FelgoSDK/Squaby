import QtQuick 1.1
import VPlay 1.0

// this is only visible for debugging, when the different squaby types are getting balanced
Row {
  property int w: 25
  SimpleButton {
    color: "yellow"
    width: w
    onClicked: {
      entityManager.createEntityFromComponent(level.sy);
    }
  }

  SimpleButton {
    color: "orange"
    width: w
    onClicked: {
      entityManager.createEntityFromComponent(level.so);
    }
  }

  SimpleButton {
    color: "red"
    width: w
    onClicked: {
      entityManager.createEntityFromComponent(level.sr);
    }
  }

  SimpleButton {
    color: "green"
    width: w
    onClicked: {
      entityManager.createEntityFromComponent(level.sgreen);
    }
  }

  SimpleButton {
    color: "blue"
    width: w
    onClicked: {
      entityManager.createEntityFromComponent(level.sblue);
    }
  }

  SimpleButton {
    color: "grey"
    width: w
    onClicked: {
      entityManager.createEntityFromComponent(level.sgrey);
    }
  }

}
