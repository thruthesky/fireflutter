import "mocha";

// import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";

// new FirebaseAppInitializer();

describe("Messaging Payload", () => {
  it("create payload", async () => {
    try {
      Messaging.completePayload({});
      expect.fail("no title");
    } catch (err) {
      const e = err as HttpsError;
      expect(e.message).equals("title-is-empty");
    }
  });
});
