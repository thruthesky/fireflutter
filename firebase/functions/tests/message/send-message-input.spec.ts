import * as admin from "firebase-admin";
import { MessagingService } from "../../src/messaging/messaging.service";
import { describe, it } from "mocha";
import assert = require("assert");

if (admin.apps.length === 0) {
    admin.initializeApp();
}


/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Send message", () => {
    it("Check invalid tokens", async () => {
        try {
            const res = await MessagingService.sendNotificationToTokens(
                {
                    tokens: [
                        "e66JGEFqRWOuictuIH8pnk:APA91bEPzpJI1IzfWs-A1UO13Mly3YQU07kpQZyl5KVXYowKts_ILI6l624ZtSk2wljVaY62xXHJNFvLKvfCNvzUI9QjEygKPjC0NROBnKQ3P__LZU2d5fd2-jdlUosOwoViLnUEaADN",
                        // TEST empty token
                        "",
                        // TEST invalid token
                        "This-is-invalid-token",
                        true as any,
                        5 as any,
                        0 as any,
                    ]
                } as any
            );
            console.log("res", res);
        } catch (e) {
            assert((e as any).message == "tokens must be an array of string", "tokens must be an array of string");
        }
    });

    it("Check invalid title", async () => {
        try {
            const res = await MessagingService.sendNotificationToTokens(
                {
                    tokens: [
                        "e66QjEygKPjC0NROBnKQ3P__LZU2d5fd2-jdlUosOwoViLnUEaADN",
                    ],
                    title: '',
                } as any,
            );
            console.log("res", res);
        } catch (e) {
            assert((e as any).message == "tokens must be an array of string", "tokens must be an array of string");
        }
    });
});
