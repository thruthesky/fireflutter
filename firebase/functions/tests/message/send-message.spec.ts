import * as admin from "firebase-admin";
import { MessagingService } from "../../src/messaging/messaging.service";
import { describe, it } from 'mocha';
var assert = require('assert');

if (admin.apps.length === 0) {
    admin.initializeApp();
}


/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Send message", () => {
    it("Check invalid tokens", async () => {

        const res = await MessagingService.sendNotificationToTokens([
            /// iPhone11ProMax
            // "fVWDxKs1kEzxhtV9ElWh-5:APA91bE_rN_OBQF3KwAdqd6Ves18AnSrCovj3UQyoLHvRwp0--1BRyo9af8EDEWXEuzBneknEFFuWZ7Lq2VS-_MBRY9vbRrdXHEIAOtQ0GEkJgnaJqPYt7TQnXtci3s0hxn34MBOhwSK",
            /// andriod with initail uid of W7a
            "c9OPdjOoRtqCOXVG7HLpSI:APA91bFJ9VshAvx-mQ4JsIpFmkljnA4XZtE8LDw6JYtIWSJwSxnuJsHt0XtlHKy4wuRcttIzqPQckfAwX_baurPfiJuFFNS6ioD50X9ks5eeyi5Pl40vMWmCpNpgCVxg92CjRe5S51Ja",
            /// Android in MacOS
            "e66JGEFqRWOuictuIH8pnk:APA91bEPzpJI1IzfWs-A1UO13Mly3YQU07kpQZyl5KVXYowKts_ILI6l624ZtSk2wljVaY62xXHJNFvLKvfCNvzUI9QjEygKPjC0NROBnKQ3P__LZU2d5fd2-jdlUosOwoViLnUEaADN",
            // TEST empty token
            "",
            // TEST invalid token
            "This-is-invalid-token"
        ], "Hello, from test",
            "How are you?",
            {
                score: '30',
                time: "10:24",
                title: 'score on test'
            }
        );
        console.log('res', res);

        assert.ok(Object.keys(res).length == 2, "length of invalid tokens must be [x]. but it is " + Object.keys(res).length);
    });
});
