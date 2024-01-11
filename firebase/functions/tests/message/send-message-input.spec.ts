import * as admin from "firebase-admin";
import {MessagingService} from "../../src/messaging/messaging.service";
import {describe, it} from "mocha";
import assert = require("assert");

if (admin.apps.length === 0) {
  admin.initializeApp();
}


/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Send message", () => {
  it("Check if not an array of string", async () => {
    try {
      const res = await MessagingService.sendNotificationToTokens(
        {
          tokens:
                    ["fVWDxKs1kEzxhtV9ElWh-5:APA91bE_rN_OBQF3KwAdqd6Ves18AnSrCovj3UQyoLHvRwp0--1BRyo9af8EDEWXEuzBneknEFFuWZ7Lq2VS-_MBRY9vbRrdXHEIAOtQ0GEkJgnaJqPYt7TQnXtci3s0hxn34MBOhwSK",
                      "",
                      // TEST invalid token
                      "This-is-invalid-token",
                      0 as any,
                    ],
          title: "Test Title",
          body: "Test Body",
        }
      );
      res["status"] = "passed";
      console.log("res", res);
    } catch (e) {
      assert((e as any).message == "tokens must be an array of string", "tokens must be an array of string");
    }
  });
  it("Check if Empty tokens", async () => {
    try {
      const res = await MessagingService.sendNotificationToTokens(
        {tokens: [] as any, title: "hello", body: "hello"}
      );
      console.log("res", res);
    } catch (e) {
      assert((e as any).message == "tokens must not be empty", "tokens must be an array of string");
    }
  });

  it("Check Empty title", async () => {
    try {
      const res = await MessagingService.sendNotificationToTokens(
        {tokens: ["asd"] as any, title: "", body: "hello"}
      ); res["status"] = "passed";
      console.log("res", res);
    } catch (e) {
      assert((e as any).message == "title must not be empty", "Titile must not be empty");
    }
  });

  it("Check Empty Body", async ()=>{
    try {
      const res = await MessagingService.sendNotificationToTokens(
        {tokens: ["some token"] as any, title: "hello", body: ""}
      );
      res["status"] = "passed";
      console.log("res", res);
    } catch (e) {
      assert((e as any).message == "body must not be empty", "Body must not be empty");
    }
  });
});
