import QtQuick 2.0
import Felgo 3.0

Chartboost {
  id: chartboost

  appId: ""
  appSignature: ""
  shouldDisplayInterstitial: true
  shouldDisplayLoadingViewForMoreApps: false
  shouldDisplayMoreApps: false
  shouldRequestInterstitial: true
  shouldRequestInterstitialsInFirstSession: true
  shouldRequestMoreApps: false

  property bool showAdvert: false

  onInterstitialCached: {
    console.debug("[chartboost] onInterstitialCached")
  }

  onMoreAppsCached: {
    console.debug("[chartboost] onMoreAppsCached")
  }

  onInterstitialFailedToLoad: {
    console.debug("[chartboost] onInterstitialFailedToLoad")
  }

  onMoreAppsFailedToLoad: {
    console.debug("[chartboost] onMoreAppsFailedToLoad")
  }

  function showAdvertIfAvailable() {
    chartboost.shouldDisplayInterstitial = true
    chartboost.showInterstitial()
  }

  function doNotShowAdvert() {
    chartboost.cacheInterstitial()
    chartboost.shouldDisplayInterstitial = false
  }

  Component.onCompleted: chartboost.cacheInterstitial()
}
