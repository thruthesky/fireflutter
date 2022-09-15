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
      const res = await Messaging.sendMessage({
        title: "from cli - android (12)",
        content: "to iphone. is that so?",
        tokens: [
          "d0E3XJUaTiG2yzPiJBqXIu:APA91bGyNzZEQrwJBKYM31liTXOnujGkzKW8akmfG55f146DtM2Rx61IaAnyTGvENsXrM9V69tPlknA1e4tRZcSvxlntAjDVBQXvmzaQVzJXWOwiWOIz9tE2kMoiuiABQsttoC-fEZZx",
          "e7aDJhxtQRq0DOCKbhVR3b:APA91bEp82cV0YBpIQscegkexGKDbMqM7nxrcAiOaH5AXV_YEcISGg0er9fiFeDMA4KYbEspT8KQyTzsmpOLpFZrRaFcdovTwwV-W9ePEFdhK6TmJMvzy0N3bfWDhSox4A9iQK00luT8",
          "cy-4z6EBQKKcC3PW4dfAj_:APA91bGTnRlmXIU6aJRpLJvpAXbVXhUUWT4i9JQzArqXc5wjzoS0ngnECMuVrxf-l9s1ei3P6cxlBTdPSgJRWYH9ggvQKAweKufOjTmMDR56UnmHLm3W4NxUI42RwxtHPZQ8u4E2_9c6",
          "cHa2hawxTyKIMO1aOcToJk:APA91bE_UoXKBY9fKP2sV9Yu4edPZJEiSbL4ruBe_jwgr0BYMt3YsduYkfIvIjPgVbpI5o7PbsMnmCdZ0H2TMbE81oYvT6u-qBhRUUGfNAnBaFXYUlYpkEj_910RguQnQg0LfF-q_o-T",
          "ehZTS_4ETICyLDr-pL5l4f:APA91bGepNBvbXdu8gKJXSxRJ3UU2oU6dZTRzo_O5rkxISb9bvqo5ptCp1fOkLjUCMLeTI0Mi5Bi2HvLQSsr-4pflW6Q_Ho1aCY4nXLL3xjCwcI3c6LpQ0fW4OxwWir_YnUKf6a7OfQe",
          "d-RUY7gztE1wnheilIWUYC:APA91bE_owxgKAYy7808o5EFFSKhyle5jpv9-tcfX2_KPh1rgrzh58K4erUwO1mk7bea6FVoksyH7ouACZjr0kA_kYe0X8uUergnAeS85UEBL3u7CxEC4sg3jRXLhGu2FdRKnqfuV0Ya",
          "fBI1f2ACSnyMnXGQxpdxwo:APA91bEqJ_ZHSif6w0ZAhdvF85k4TnWdmZ13KQQ42BSN9HUx1jlcJSxcx5nTG784bwZb5yGSihlM9hQuUM28gT4c84l3w8nzmhc1O06kUe47mSu4r3r3b3Uj2eafhuY_lG-K2sSeWmUA",
          "fObBpoLPQ_Sl9rtPDY0sjZ:APA91bEexSOdRcfwL6FToTbDTjCH_Sry9eFmRYAGzupgfqUC2DGbOOrdLiLtLj53oG9PXl1ufPDrP4k256Syfj-4LpggETdjhdoM6N_QJWM0pkksVX92pVpZZFd6yYsU1RhjvYUhOVsN",
          "d1cBU6UuR9KqYtyeIVimFA:APA91bHlC2l_Crl_twwq8JRZIwnFtsTZKec6RYkoupJwnu3P5ZfuTo7qFrWBptGJKtvxqIuWAIxZOZGTDWL7GTcUhkWXsrHW0k824ara8G6ZJnK4Q61hlXO7x4pJ0kVJiaXPWQQuqG9Z",
          Test.token,
          Test.jaehoSimulatorToken,
        ].join(","),
      });
      expect(res).to.be.an("object");
    } catch (e) {
      console.log((e as HttpsError).code, (e as HttpsError).message);
      expect.fail("Must succeed on sending a message to a token");
    }
  });
});
