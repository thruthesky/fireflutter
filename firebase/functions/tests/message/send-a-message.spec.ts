import * as admin from "firebase-admin";
import { describe, it } from "mocha";
import assert = require("assert");
import { getMessaging } from "firebase-admin/messaging";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Send message", () => {
  it("Check invalid tokens", async () => {
    const message = {
      notification: {
        title: "Sparky says hello! 3",
      },
      android: {
        notification: {
          imageUrl: "https://picsum.photos/400/400",
        },
      },
      apns: {
        payload: {
          aps: {
            "mutable-content": 1,
          },
        },
        fcm_options: {
          image: "https://picsum.photos/400/400",
        },
      },
      webpush: {
        headers: {
          image: "https://picsum.photos/400/400",
        },
      },

      token: "eKi_y9DTRUQ_gzbFcH1AxZ:APA91bHxHJQ2kWrMjK5q8FZgQq6ntFHi6k7_CdB-bANHU6OlcTQ_ayIg_Y7tw7uM2QQuCy8lAuLPQvElVZn2n_MP8VipmNbfz9zegloJBP-NOnPjVrnMZTefEUV3ArdzJJR3Onp4eoQA",

    };

    console.log("message", message);
    try {
      await getMessaging().send(message);
      assert.ok(true);
    } catch (e) {
      console.log(e);
      assert.ok(false);
    }
  });
});




