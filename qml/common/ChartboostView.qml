import QtQuick 2.0
import VPlay 2.0
import VPlayPlugins.chartboost 1.1

Chartboost {
  id: chartboost

  // the licenseKey of this plugin only works with this demo game; you get licenseKeys for your games for free with a V-Play license (www.v-play.net/license/plugins)
  licenseKey: "1802219D9DB5B476BA12870EB3692921CF8F51009303CD091C54CAE8FB7526677E5F7F23036FE80846B992824FC2DFFEAA50A62B2B4447FE4A5D9CF784D8FFDFE768ADA878E5DFDD878EC58C8F0DED2F6E60C8E93DA0087962C9E075E79070D51C76F628B2B9C2F7B4B30A9FEBD4DA2D1BC905D845C418ABFB2B702198685071D60961785CB719C0E7A866C050FFDAD9C3BE26DBB035224571620CB037DAAC22"

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
