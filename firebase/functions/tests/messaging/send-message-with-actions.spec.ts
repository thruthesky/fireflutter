import "mocha";
// import * as admin from "firebase-admin";
import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
// import { Test } from "../test";
import { HttpsError } from "firebase-functions/v1/auth";
import { Test } from "../test";
import { User } from "../../src/classes/user";

new FirebaseAppInitializer();

describe("Send message by actions", () => {
  it("Send message by action", async () => {
    const userA = "user-a-" + Test.id();
    const action = "comment-create";
    const category = "qna";
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
