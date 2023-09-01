import "mocha";

import "../firebase.init";
import * as admin from "firebase-admin";




import { Messaging } from "../../src/models/messaging.model";
import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";


import { Ref } from "../../src/utils/ref";


describe("sending push notification", () => {
  it("Send push notification to user_refs", async () => {

    const snap = await Ref.db.collection('send_push_notifications').doc('K3Y4alPY25WASyBsQvb3').get();

    try {
      Messaging.sendPushNotifications(snap as admin.firestore.QueryDocumentSnapshot);
    } catch (e) {
      console.log((e as HttpsError).code, (e as HttpsError).message);
      expect.fail("Must succeed on sending a message to a token");
    }
  });
});
