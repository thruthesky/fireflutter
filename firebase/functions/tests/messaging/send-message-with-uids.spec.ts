import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
// import { Test } from "../test";
import { HttpsError } from "firebase-functions/v1/auth";

new FirebaseAppInitializer();

describe("Send message to token", () => {
  it("Send a message with tokens", async () => {
    try {
      const res = await Messaging.sendMessage(
        {
          title: "from cli",
          body: "to iphone. is that so?",
          uids: ["oings9FJQlgVkpkzQO8Q9XymHzA2", "qtOSsVx4vVPGtf1rDIRwx3M0JJk1"].join(","),
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
