import VPlay 1.0
import QtQuick 1.1

Scene {
  id: squabySceneBase
  // this would be the default size anyway
  width: 480
  height: 320

  // by default, set the opacity to 0 - this is changed from the SquabyMain with PropertyChanges
  opacity: 0

  // this is an important performance improvement, as renderer can skip invisible items (and all its children)
  // this is done automatically in scene, however, and is not need to be set explicitly here
  //visible: opacity>0

  // handle this signal in each Scene
  signal backPressed

  Component.onCompleted: console.debug("Scene.onCompleted, focus is", focus, "of scene", squabySceneBase)

  // NOTE: setting the focus to activeScene === squabySceneBase is not sufficient when the scene gets loaded dynamically!
  // reason is, that only the Scene (which is a child of the Loader) gets focus, but not the Loader itself! so the MainMenuScene still has focus, but not the child scene here!
  // thus forceActiveFocus() must be called whenever the activeScene changes, which is done in GameWindow automatically!
  // only when focus is true the key will be handled in this scene
  // so only handle the key press in the active (visible) scene
  //focus: activeScene === squabySceneBase
  // a focus-change is never received for scenes that are not loaded dynamically!?
  //onFocusChanged: console.debug("focus of scene changed to", focus, "for scene", squabySceneBase)
  //onActiveFocusChanged: console.debug("activeFocus changed to", focus, "for scene", squabySceneBase)


  Keys.onPressed: {
    //console.debug("pressed key id: ", event.key)

    // only simulate on desktop platforms!
    if(event.key === Qt.Key_Backspace && system.desktopPlatform) {
      console.debug("backspace key pressed - simulate a back key pressed on desktop platforms for debugging the user flow of Android on windows!")
      backPressed()
    }
  }

  Keys.onBackPressed: {
    //console.debug("the back button was pressed on Android, handle the signal in the scene")
    backPressed()
  }
}
