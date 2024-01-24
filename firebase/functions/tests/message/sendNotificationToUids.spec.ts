import * as admin from "firebase-admin";
import { MessagingService } from "../../src/messaging/messaging.service";
import { describe, it } from "mocha";
import assert = require("assert");
import { getDatabase } from "firebase-admin/database";

if (admin.apps.length === 0) {
    admin.initializeApp(
        {
            databaseURL: "https://withcenter-test-3-default-rtdb.firebaseio.com",
        }
    );
}

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("sendNotificationToUids.spec", () => {
    // 빈 uids 를 보내면 빈 토큰을 받아야 한다.
    it("getTokensOfUsers with empty uids", async () => {
        const tokens = await MessagingService.getTokensOfUsers([]);
        assert.ok(tokens.length === 0, "No of tokens must be 0.");
    });
    // 2개의 토큰을 2개의 uid 생성. 즉, 총 4개의 토큰을 받아야 한다.
    it("getTokensOfUsers with right uids", async () => {
        // Generate 2 tokens under 2 uids
        const db = getDatabase();
        await db.ref("user-fcm-tokens/uid-1").set({
            "uid-1-token-1": { uid: "uid-1" },
            "uid-1-token-2": { uid: "uid-1" },
        });
        await db.ref("user-fcm-tokens/uid-2").set({
            "uid-2-token-1": { uid: "uid-2" },
            "uid-2-token-2": { uid: "uid-2" },
        });
        const tokens = await MessagingService.getTokensOfUsers(["uid-1", "uid-2"]);
        assert.ok(tokens.length === 4, "No of tokens must be 4.");
    });


    // it("getTokensOfUsers with wrong uids", async () => {
    //     const res = await MessagingService.sendNotificationToUids(['wrong-uid-a'], "title", "body");
    //     assert.ok(Object.keys(res).length == 3, "length of invalid tokens must be [x]. but it is " + Object.keys(res).length);
    //     assert.ok(res["This-is-invalid-token"] == "messaging/invalid-argument", "invalid token must be [messaging/invalid-argument]. but it is " + res["This-is-invalid-token"]);
    // });
});
