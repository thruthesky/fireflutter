import "mocha";

import "../firebase.init";
import * as admin from "firebase-admin";




import { Messaging } from "../../src/models/messaging.model";
import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";


import { User } from "../../src/models/user.model";
import { Test } from "../test";

// This is a real token.
const token =
  "d1cBU6UuR9KqYtyeIVimFA:APA91bHlC2l_Crl_twwq8JRZIwnFtsTZKec6RYkoupJwnu3P5ZfuTo7qFrWBptGJKtvxqIuWAIxZOZGTDWL7GTcUhkWXsrHW0k824ara8G6ZJnK4Q61hlXO7x4pJ0kVJiaXPWQQuqG9Z";
const userB = "user-b-" + Test.id();


describe("Send message to users", () => {
  it("Send a message to users", async () => {
    const userA = "user-a-" + Test.id();
    await User.create(userA, {});
    await User.setToken({
      fcm_token: "token-a-1",
      device_type: "android",
      uid: userA,
    });
    await User.setToken({
      fcm_token: "token-a-2",
      device_type: "android",
      uid: userA,
    });


    // Delete all existing real token, so the test will be match to 1.
    let snap = await admin
      .firestore()
      .collectionGroup("fcm_tokens")
      .where("fcm_token", "==", token)
      .get();
    for (const doc of snap.docs) {
      await doc.ref.delete();
    }

    //
    await User.create(userB, {});
    await User.setToken({
      fcm_token: "token-b-1",
      device_type: "android",
      uid: userB,
    });
    await User.setToken({
      fcm_token: token,
      device_type: "android",
      uid: userB,
    });

    try {
      const res = await Messaging.sendMessage({
        title: "from cli",
        body: "to iphone. is that so?",
        uids: `${userA},${userB}`,
      });
      // expect(res.success).equals(1);
      // expect(res.error).equals(3);


      expect(res.success).equals(0);
      expect(res.error).equals(4);

      const group = admin.firestore().collectionGroup("fcm_tokens");

      let snapshot = await group.where("fcm_token", "==", "token-a-1").get();
      expect(snapshot.docs.length).equals(0);
      snapshot = await group.where("fcm_token", "==", "token-a-2").get();
      expect(snapshot.docs.length).equals(0);
      snapshot = await group.where("fcm_token", "==", "token-b-1").get();
      expect(snapshot.docs.length).equals(0);

      snapshot = await group.where("fcm_token", "==", token).get();
      expect(snapshot.docs.length).equals(1);
    } catch (e) {
      console.log((e as HttpsError).code, (e as HttpsError).message);
      expect.fail("Must succeed on sending a message to a token");
    }
  });
});
