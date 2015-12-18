import QtQuick 2.0
import VPlay 2.0
import VPlayPlugins.soomla 1.2

LevelStore {

  // the licenseKey of this plugin only works with this demo game; you get licenseKeys for your games for free with a V-Play license (www.v-play.net/license/plugins)
  licenseKey: "1802219D9DB5B476BA12870EB3692921CF8F51009303CD091C54CAE8FB7526673B8AA76D37D2D47381BAE0501054C292BFFB388539A557EB6E02E0E8B0C4AD0E94A1FF80B56F577E4CFA9785CA3B9735B705B20A9B59B65B8E1520BC31F662203354DA5471D0A31FF5F41C4755DE2322FE9F47C423C116B28A27183BB8AF36222DD9174E1FEF3ECD3D84FDFA5AA4098E"

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
    //nativeUtils.displayMessageBox("Not enough Credits", "You do not have enough credits to purchase this level. You can buy more credits by clicking on the \"Credits\" text top right. \nOr earn more credits by unlocking achievements (see the V-Play Game Network from the main menu).", 1)
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
