import * as admin from "firebase-admin";
import { MessagingService } from "../../src/messaging/messaging.service";
import { describe, it } from "mocha";
import assert = require("assert");

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// const params = {  tokens : [ "fVWDxKs1kEzxhtV9ElWh-5:APA91bE_rN_OBQF3KwAdqd6Ves18AnSrCovj3UQyoLHvRwp0--1BRyo9af8EDEWXEuzBneknEFFuWZ7Lq2VS-_MBRY9vbRrdXHEIAOtQ0GEkJgnaJqPYt7TQnXtci3s0hxn34MBOhwSK",
//         // / andriod with initail uid of W7a
//         "c9OPdjOoRtqCOXVG7HLpSI:APA91bFJ9VshAvx-mQ4JsIpFmkljnA4XZtE8LDw6JYtIWSJwSxnuJsHt0XtlHKy4wuRcttIzqPQckfAwX_baurPfiJuFFNS6ioD50X9ks5eeyi5Pl40vMWmCpNpgCVxg92CjRe5S51Ja",
//         //
//         "df06WGOxSJCJLwciBcbO_D:APA91bH1kAm1MFsCCWkPutbqmt95Xl0xg7poQNSUjlaCAXeM4hERN2toI94yzDoIMW4b1lyNGQRcc3uFkSmptWRXGGADzQjNXQt-2WPI9GoQ08AiXCmGoYhXmWWNntlDHE92jQ_ojuhW",
//         // / Android in MacOS
//         "e66JGEFqRWOuictuIH8pnk:APA91bEPzpJI1IzfWs-A1UO13Mly3YQU07kpQZyl5KVXYowKts_ILI6l624ZtSk2wljVaY62xXHJNFvLKvfCNvzUI9QjEygKPjC0NROBnKQ3P__LZU2d5fd2-jdlUosOwoViLnUEaADN",
//         "fcdQ2VoVdUG9qDojHO7pH4:APA91bEYC0CczH6uOTBVtytw7g-9F52852WKsp7wldrK_NxrQR9-6PITKp8A0Qi3zFtnMDdm1lZGmSXloDMo5heTCq6SbN5SEqOGz5gvHJTxwo9j8ykY5vixFatommFsbsqavI0AHA9C",
//         // TEST empty token
//         "",
//         // TEST invalid token
//         "This-is-invalid-token",],
//         title : 'Test Title',
//         body:'Test Body',

// data : { key: 'value' },
// image: 'https://firebasestorage.googleapis.com/v0/b/philgo.appspot.com/o/users%2Fw7aw7KhiNPX6Rq0vGGr4XfLYWKe2%2Fimage_picker_3EBCD9C6-3E15-410F-BF65-4258C7A72674-90669-00001667661BEFFA.jpg?alt=media&token=acb9e1ac-e4e1-4999-8f4a-adf38430df50'
//       };

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Send message", () => {
  it("Check invalid tokens", async () => {
    const res = await MessagingService.sendNotificationToTokens(
      {
        tokens:

          [
            "fVWDxKs1kEzxhtV9ElWh-5:APA91bE_rN_OBQF3KwAdqd6Ves18AnSrCovj3UQyoLHvRwp0--1BRyo9af8EDEWXEuzBneknEFFuWZ7Lq2VS-_MBRY9vbRrdXHEIAOtQ0GEkJgnaJqPYt7TQnXtci3s0hxn34MBOhwSK",
            // / andriod with initail uid of W7a
            "c9OPdjOoRtqCOXVG7HLpSI:APA91bFJ9VshAvx-mQ4JsIpFmkljnA4XZtE8LDw6JYtIWSJwSxnuJsHt0XtlHKy4wuRcttIzqPQckfAwX_baurPfiJuFFNS6ioD50X9ks5eeyi5Pl40vMWmCpNpgCVxg92CjRe5S51Ja",
            //
            "df06WGOxSJCJLwciBcbO_D:APA91bH1kAm1MFsCCWkPutbqmt95Xl0xg7poQNSUjlaCAXeM4hERN2toI94yzDoIMW4b1lyNGQRcc3uFkSmptWRXGGADzQjNXQt-2WPI9GoQ08AiXCmGoYhXmWWNntlDHE92jQ_ojuhW",
            // / Android in MacOS
            "e66JGEFqRWOuictuIH8pnk:APA91bEPzpJI1IzfWs-A1UO13Mly3YQU07kpQZyl5KVXYowKts_ILI6l624ZtSk2wljVaY62xXHJNFvLKvfCNvzUI9QjEygKPjC0NROBnKQ3P__LZU2d5fd2-jdlUosOwoViLnUEaADN",
            "fcdQ2VoVdUG9qDojHO7pH4:APA91bEYC0CczH6uOTBVtytw7g-9F52852WKsp7wldrK_NxrQR9-6PITKp8A0Qi3zFtnMDdm1lZGmSXloDMo5heTCq6SbN5SEqOGz5gvHJTxwo9j8ykY5vixFatommFsbsqavI0AHA9C",
            // TEST empty token
            "",
            // TEST invalid token
            "This-is-invalid-token"],

        title: "Test Title",
        body: "Test Body",

        data: { key: "value" },
        image: "https://firebasestorage.googleapis.com/v0/b/philgo.appspot.com/o/users%2Fw7aw7KhiNPX6Rq0vGGr4XfLYWKe2%2Fimage_picker_3EBCD9C6-3E15-410F-BF65-4258C7A72674-90669-00001667661BEFFA.jpg?alt=media&token=acb9e1ac-e4e1-4999-8f4a-adf38430df50",
      }
    );
    console.log("res", res);

    assert.ok(Object.keys(res).length == 3, "length of invalid tokens must be [x]. but it is " + Object.keys(res).length);
    assert.ok(res["This-is-invalid-token"] == "messaging/invalid-argument", "invalid token must be [messaging/invalid-argument]. but it is " + res["This-is-invalid-token"]);
  });
});
