import QtQuick 1.1


Row {
  id: modifyEntityRow


  // also a RotateButton could be added here, or a scale button - but since this is not allowed for squaby yet, dont add it

  // this is only used for the turbine
  DestroyEntityButton {
    onClicked: {
      console.debug("destroyEntityButton clicked, remove entity");
      entityManager.removeEntityById(selectedEntity.entityId);
      // switch the state afterwards, otherwise selectedEntity would not be known!
      hud.state = "levelEditing";
    }

  }

}

