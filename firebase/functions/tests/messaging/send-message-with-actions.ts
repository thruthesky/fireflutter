import "mocha";

import "../firebase.init";
import * as admin from "firebase-admin";




import { Messaging } from "../../src/models/messaging.model";
import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";


import { User } from "../../src/models/user.model";
import { Test } from "../test";

const userA = "user-a-" + Test.id();

const action = "comment-create-test";
const category = "qna-test";
const type = "test-subscription";

describe("Send message by actions", () => {
  it("delete user subcription action test", async () => {
    // Delete all existing token, so the test will be match to 1.
    let snap = await admin
      .firestore()
      .collection("user_settings")
      .where("action", "==", action)
      .where("category", "==", category)
      .where("type", "==", type)
      .get();
    for (const doc of snap.docs) {
      await doc.ref.delete();
    }
  });

  it("Send message by action", async () => {
    await User.create(userA, {});
    await User.setUserSettingsSubscription(userA, { action: action, category: category, type: type });

    // expired token 
    await User.setToken({
      fcm_token:
        "d1cBU6UuR9KqYtyeIVimFA:APA91bHlC2l_Crl_twwq8JRZIwnFtsTZKec6RYkoupJwnu3P5ZfuTo7qFrWBptGJKtvxqIuWAIxZOZGTDWL7GTcUhkWXsrHW0k824ara8G6ZJnK4Q61hlXO7x4pJ0kVJiaXPWQQuqG9Z",
      device_type: "android",
      uid: userA,
    });


    // invalid token
    await User.setToken({
      fcm_token: "invalid-tokens",
      device_type: "android",
      uid: userA,
    });


    // @TODO add valid token

    try {
      const res = await Messaging.sendMessage({
        title: "from cli via action",
        body: "using action and category",
        action: action, // post-create
        category: category,
      });
      console.log("res::", res);
      expect(res.success).equals(0);
      expect(res.error).equals(2);
    } catch (e) {
      console.log((e as HttpsError).code, (e as HttpsError).message);
      expect.fail("Must succeed on sending a message to a token");
    }
  });
});
