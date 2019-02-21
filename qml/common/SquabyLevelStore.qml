import QtQuick 2.0
import Felgo 3.0

LevelStore {

  // only needed when creating the iap in iTunes & Google Play
  //Component.onCompleted: printStoreProductLists()

  version: 1
  // Replace with your own custom secret
  secret: ""
  // From Google Play Developer Console
  androidPublicKey: ""

  property alias noAdsGood : noAdsGood
  property alias money5Pack: money5Pack
  property alias money10Pack: money10Pack
  property alias money50Pack: money50Pack

  goods: [
    LifetimeGood {
      id: noAdsGood
      itemId: "no_ads_id_sq"
      name: "No Ads"
      description: "Remove the ads"
      purchaseType: StorePurchase { id: noAdsPurchase; productId: noAdsGood.itemId; price: 0.89; }
    }
  ]

  currencies: [
    Currency { id: moneyCurrency; itemId: "currency_money_id"; name: "money"; }
  ]

  currencyPacks: [
    CurrencyPack {
      id: money5Pack
      itemId: "money_pack_5_id_sq"
      name: "5 Credits"
      description: "05 credits"
      currencyId: moneyCurrency.itemId // The currency you want to offer with this pack
      currencyAmount: 5
      purchaseType:  StorePurchase { id: money2Purchase; productId: money5Pack.itemId; price: 0.89;}
    },
    CurrencyPack {
      id: money10Pack
      itemId: "money_pack_10_id_sq"
      name: "10 Credits"
      description: "10 credits"
      currencyId: moneyCurrency.itemId // The currency you want to offer with this pack
      currencyAmount: 10
      purchaseType:  StorePurchase { id: money10Purchase; productId: money10Pack.itemId; price: 1.79; }
    },
    CurrencyPack {
      id: money50Pack
      itemId: "money_pack_50_id_sq"
      name: "50 Credits"
      description: "50 credits"
      currencyId: moneyCurrency.itemId // The currency you want to offer with this pack
      currencyAmount: 50
      purchaseType:  StorePurchase { id: money50Purchase; productId: money50Pack.itemId; price: 2.69; }
    }
  ]

  onInsufficientFundsError: {
    flurry.logEvent("Store.Purchase","InsufficientFunds")
    // this is handled in LevelScene - the buyCreditDialog is shown
    console.debug("SquabyLevelStore: insufficientFunds")
    //nativeUtils.displayMessageBox("Not enough Credits", "You do not have enough credits to purchase this level. You can buy more credits by clicking on the \"Credits\" text top right. \nOr earn more credits by unlocking achievements (see the Felgo Game Network from the main menu).", 1)
  }

  onStorePurchased: {
      flurry.logEvent("Store.Purchase","Purchased")
  }
  onStorePurchaseCancelled: {
      flurry.logEvent("Store.Purchase","Cancelled")
  }
  onStorePurchaseStarted: {
      flurry.logEvent("Store.Purchase","Started")
  }
}
