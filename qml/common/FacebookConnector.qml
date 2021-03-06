import Felgo 3.0

Facebook {
  id: facebook

  appId: "1514388122117426" // Felgo Test App 2, created by Chris

  readPermissions: ["email", "read_friendlists"]
  publishPermissions: ["publish_actions"]
//    publishPermissions: ["publish_stream"]
  // publish_stream should not be used, as it contains a lot of permissions and users might deny it - publish_actions is a part of publish_stream permission
  // NOTE: if posting to a friend's wall secretly, the publish_stream permission is needed! for posting with the dialog, publish_actions is sufficient

  // liking and posting to a wall is only possible for a page, not to a native mobile app!
  // for now, we post the comments on the vplay side, because the squaby page is not online yet
  // the facebook id of the vplay engine facebook page is: 392046547517903
  // get the id with the following link: graph.facebook.com/felgo
  // to open the page with the native facebook app, use the following format on iOS: fb://profile/pageId
  // even though a page is not a profile, this has been changed by facebook: http://stackoverflow.com/questions/13222898/direct-linking-to-page-in-native-facebook-app-ios6
  // TODO: if no native fb app is installed, it should fall back to the normal browser link!
  // we do not have a way yet to check if openUrl succeeded in Felgo
  property string vplayPageLink: system.isPlatform(System.IOS) ? "fb://profile/392046547517903" : "http://www.facebook.com/felgo"
  property string squabyPageLink: "http://www.facebook.com/squabydefense"

  onSessionStateChanged: {
    console.log("Facebook: New Facebook Session state: ", sessionState);

    /*if (sessionState === Facebook.SessionOpened) {
      showResult("Facebook: Session opened.");
    }
    else if (sessionState === Facebook.SessionClosed) {
      showResult("Facebook: Session closed.");
    }
    else if (sessionState === Facebook.SessionFailed) {
      showResult("Facebook: Session failed.");
    }*/
  }

  onGetGraphRequestFinished: {
    //showResult("Facebook: onGetGraphRequestFinished: graphPath:" + graphPath + ", resultState:" + resultState + ", result:" + result);

    // Check for the request result state
    if (resultState === Facebook.ResultOk) {
      // here, something could be done with the result... for example:
      // We can match the request according to the graphPath
//        if (graphPath === "me/friends") {
//          var friends = JSON.parse(result);
//          console.debug("Facebook: Friend request finished, got ", friends["data"].length, "friends");
//        }
    }
    else if (resultState === Facebook.ResultInvalidSession) {
      console.debug("Facebook: No active session, call openSession beforehand.");
    }
    else {
      console.debug("Facebook: There was an error retrieving the friend list.");
    }

  }

  onPostGraphRequestFinished: {
    console.debug("Facebook: onPostGraphRequestFinished: graphPath:" + graphPath + ", resultState:" + resultState + ", result:" + result);
  }

  // this is called whenever a new highscore is reached from Player.qml
  function sendNewHighscoreToUserWall(newHighscore) {
     // secretly (i.e. without user interaction) post to the own user wall about the highscore
     facebook.postGraphRequest( "me/feed",
                               {          "link" : vplayPageLink,
                                          "name" : "New Squaby highscore",
                                    "description": "Squaby is a tower defense game for iOS & Android - you can download it from the App Store!",
                                       "message" : "I just got a new highscore in Squaby: " + newHighscore + " points! Can you beat me?"
                               } )
  }

  // this is called whenever a new highscore is reached
  function postOpinionToUserWall() {


  }

  // opens the Felgo facebook page in the browser (only there liking is possible, currently not from OpenGraph API!) - liking only available for objects
  // see these resources: https://developers.facebook.com/docs/opengraph/actions/builtin/likes/ and http://stackoverflow.com/questions/3061054/like-a-page-using-facebook-graph-api
  function openVPlayFacebookSite() {
    nativeUtils.openUrl(vplayPageLink)
  }
}
