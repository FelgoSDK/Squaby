import QtQuick 2.0
import VPlay 2.0

LevelGrid {
  id: levelSelection
  clip: true

  // don't make pageSize too big, to avoid long time for creating the items of the levelSelection
  pageSize: 10
  // if the last page is shown, the next page button will not emit a nextPageClicked signal
  //pageCount: levelEditor.userGeneratedLevelsPageMetaData ? levelEditor.userGeneratedLevelsPageMetaData.pageCount : 1


  onNextPageClicked: {
    flurry.logEvent("LevelSelection.NextPage")
    reloadLevels()
  }

  onPrevPageClicked: {
    flurry.logEvent("LevelSelection.PrevPage")
    reloadLevels()
  }
}
