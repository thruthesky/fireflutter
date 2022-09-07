import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";
// import { Test } from "../../src/classes/test";
// import { Utils } from "../../src/classes/utils";

import { Messaging } from "../../src/classes/messaging";
import { expect } from "chai";
import { Test } from "../test";
import { HttpsError } from "firebase-functions/v1/auth";

new FirebaseAppInitializer();

//
describe("Send message to token", () => {
  it("Send a message with tokens", async () => {
    try {
      const res = await Messaging.sendMessage(
        {
          title: "from cli - android (11)",
          body: "to iphone. is that so?",
          tokens: [
            "d0E3XJUaTiG2yzPiJBqXIu:APA91bGyNzZEQrwJBKYM31liTXOnujGkzKW8akmfG55f146DtM2Rx61IaAnyTGvENsXrM9V69tPlknA1e4tRZcSvxlntAjDVBQXvmzaQVzJXWOwiWOIz9tE2kMoiuiABQsttoC-fEZZx",
            "e7aDJhxtQRq0DOCKbhVR3b:APA91bEp82cV0YBpIQscegkexGKDbMqM7nxrcAiOaH5AXV_YEcISGg0er9fiFeDMA4KYbEspT8KQyTzsmpOLpFZrRaFcdovTwwV-W9ePEFdhK6TmJMvzy0N3bfWDhSox4A9iQK00luT8",
            "cy-4z6EBQKKcC3PW4dfAj_:APA91bGTnRlmXIU6aJRpLJvpAXbVXhUUWT4i9JQzArqXc5wjzoS0ngnECMuVrxf-l9s1ei3P6cxlBTdPSgJRWYH9ggvQKAweKufOjTmMDR56UnmHLm3W4NxUI42RwxtHPZQ8u4E2_9c6",
            "cHa2hawxTyKIMO1aOcToJk:APA91bE_UoXKBY9fKP2sV9Yu4edPZJEiSbL4ruBe_jwgr0BYMt3YsduYkfIvIjPgVbpI5o7PbsMnmCdZ0H2TMbE81oYvT6u-qBhRUUGfNAnBaFXYUlYpkEj_910RguQnQg0LfF-q_o-T",
            "ehZTS_4ETICyLDr-pL5l4f:APA91bGepNBvbXdu8gKJXSxRJ3UU2oU6dZTRzo_O5rkxISb9bvqo5ptCp1fOkLjUCMLeTI0Mi5Bi2HvLQSsr-4pflW6Q_Ho1aCY4nXLL3xjCwcI3c6LpQ0fW4OxwWir_YnUKf6a7OfQe",
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
