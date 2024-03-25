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

      token: "eEvWRLMg_0Sppg6ZxaBtQI:APA91bEMWBwALRi-KWXOlmIpRvY5MAqiO9_Bw9gQVvFAM0YiLszYbuyPGNy1vGvev-OjmkmCI5-1tsq0Wrd73lRSRP_1s_sHOX64Uhrw8YscwQEo5R4d1-INBJtERwWmIetPNldkwa1f",

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


