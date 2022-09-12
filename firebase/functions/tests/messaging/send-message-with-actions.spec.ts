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
    await User.create(userA, {});
    await User.setSettings(userA, "subscriptions", { "comment-create.qna": true });

    try {
      const res = await Messaging.sendMessage(
        {
          title: "from cli",
          body: "to iphone. is that so?",
          action: "comment-create", // post-create
          category: "qna",
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
