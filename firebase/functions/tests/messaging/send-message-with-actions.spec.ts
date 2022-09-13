import "mocha";
import * as admin from "firebase-admin";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";
import { User } from "../../src/classes/user";

import { Test } from "../test";

new FirebaseAppInitializer();

const userA = "user-a-" + Test.id();

const action = "comment-create-test";
const category = "qna-test";

describe("Send message by actions", () => {
  it("delete user subcription action test", async () => {
    // Delete all existing token, so the test will be match to 1.
    let snap = await admin
      .firestore()
      .collectionGroup("user_subscriptions")
      .where("action", "==", action)
      .where("category", "==", category)
      .get();
    for (const doc of snap.docs) {
      await doc.ref.delete();
    }
  });

  it("Send message by action", async () => {
    await User.create(userA, {});
    await User.setSubscription(userA, "forum", { action: action, category: category });

    await User.setToken({
      fcm_token:
        "d1cBU6UuR9KqYtyeIVimFA:APA91bHlC2l_Crl_twwq8JRZIwnFtsTZKec6RYkoupJwnu3P5ZfuTo7qFrWBptGJKtvxqIuWAIxZOZGTDWL7GTcUhkWXsrHW0k824ara8G6ZJnK4Q61hlXO7x4pJ0kVJiaXPWQQuqG9Z",
      device_type: "android",
      uid: userA,
    });

    await User.setToken({
      fcm_token: "invalid-tokens",
      device_type: "android",
      uid: userA,
    });

    try {
      const res = await Messaging.sendMessage(
        {
          title: "from cli",
          body: "to iphone. is that so?",
          action: action, // post-create
          category: category,
        },
        {} as any
      );
      console.log("res::", res);
    } catch (e) {
      console.log((e as HttpsError).code, (e as HttpsError).message);
      expect.fail("Must succeed on sending a message to a token");
    }
  });
});
