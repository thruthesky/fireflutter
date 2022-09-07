import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
import { Test } from "../test";
import { HttpsError } from "firebase-functions/v1/auth";

new FirebaseAppInitializer();

describe("Send message to token", () => {
  it("Send a message with tokens", async () => {
    try {
      const res = await Messaging.sendMessage(
        {
          title: "from cli (silent)",
          body: "to iphone. is that so?",
          tokens: [
            "e7aDJhxtQRq0DOCKbhVR3b:APA91bEp82cV0YBpIQscegkexGKDbMqM7nxrcAiOaH5AXV_YEcISGg0er9fiFeDMA4KYbEspT8KQyTzsmpOLpFZrRaFcdovTwwV-W9ePEFdhK6TmJMvzy0N3bfWDhSox4A9iQK00luT8",
            "cy-4z6EBQKKcC3PW4dfAj_:APA91bGTnRlmXIU6aJRpLJvpAXbVXhUUWT4i9JQzArqXc5wjzoS0ngnECMuVrxf-l9s1ei3P6cxlBTdPSgJRWYH9ggvQKAweKufOjTmMDR56UnmHLm3W4NxUI42RwxtHPZQ8u4E2_9c6",
            Test.token,
            Test.jaehoSimulatorToken,
          ].join(","),
        },
        {} as any
      );
      console.log(JSON.stringify(res));
      expect("0").to.be.an("string");
    } catch (e) {
      console.log((e as HttpsError).code, (e as HttpsError).message);
      expect.fail("Must succeed on sending a message to a token");
    }
  });
});
