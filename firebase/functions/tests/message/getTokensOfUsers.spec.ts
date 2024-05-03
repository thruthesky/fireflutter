import * as admin from "firebase-admin";
import { MessagingService } from "../../src/messaging/messaging.service";
import { describe, it } from "mocha";
import assert = require("assert");
import { getDatabase } from "firebase-admin/database";
import { Config } from "../../src/config";

if (admin.apps.length === 0) {
    admin.initializeApp(
        {
            databaseURL: "http://127.0.0.1:6004/?ns=withcenter-silvers",
        }
    );
}

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("getTokensOfUsers 기능 테스트", () => {
    // 빈 uids 를 보내면 빈 토큰을 받아야 한다.
    it("getTokensOfUsers with empty uids", async () => {
        const tokens = await MessagingService.getTokensOfUsers([]);
        assert.ok(tokens.length === 0, "No of tokens must be 0.");
    });

    // 2개의 토큰을 2개의 uid 생성. 즉, 총 4개의 토큰을 받아야 한다.
    it("getTokensOfUsers with right uids", async () => {
        // Generate 2 tokens under 2 uids
        const db = getDatabase();
        await db.ref(Config.userFcmTokens).set({
            "uid-1-token-1": { uid: "uid-1" },
            "uid-1-token-2": { uid: "uid-1" },
            "uid-2-token-1": { uid: "uid-2" },
            "uid-2-token-2": { uid: "uid-2" },
        });
        const tokens = await MessagingService.getTokensOfUsers(["uid-1", "uid-2"]);
        assert.ok(tokens[0].length === 4, "No of tokens must be 4.");
    });


    // 3 개의 uid 에 총 5개의 토큰 생성 즉, 총 5개의 토큰을 받아야 한다.
    // 그런데 잘못된 uid 를 집어 넣어서 테스틀 한다.
    it("잘못된 UID 를 섞어서 토큰 5개 가져오기", async () => {
        // Generate 2 tokens under 2 uids
        const db = getDatabase();
        await db.ref(Config.userFcmTokens).set({
            "uid-1-token-1": { uid: "uid-1" },
            "uid-1-token-2": { uid: "uid-1" },
            "uid-2-token-1": { uid: "uid-2" },
            "uid-2-token-2": { uid: "uid-2" },
            "uid-3-token-1": { uid: "uid-3" },
        });
        // uid 1, 2, 3 로 부터 토큰 5개 가져오기
        const tokens5 = await MessagingService.getTokensOfUsers(["uid-1", "uid-2", "uid-3", "uid-x-1", "uid-x-2"]);
        assert.ok(tokens5[0].length === 5, "No of tokens must be 5.");


        // uid 1, 3 로 부터 토큰 3개 가져오기
        const tokens3 = await MessagingService.getTokensOfUsers(["uid-1", "uid-3", "uid-x-1", "uid-x-2"]);
        assert.ok(tokens3[0].length === 3, "No of tokens must be 3.");
    });


    it("토큰을 chunk 로 나누기 - 11개의 토큰을 5개로 나누어 가져옴", async () => {
        // 토큰 n 개 생성
        const n = 11;
        const db = getDatabase();
        const promises = [];
        const uids = [];
        await db.ref(Config.userFcmTokens).set({});
        for (let i = 0; i < n; i++) {
            const uid = `uid-${i}`;
            uids.push(uid);
            const token = `token-${i}`;
            promises.push(db.ref(`${Config.userFcmTokens}/${uid}-${token}`).set({
                uid: uid,
            }));
        }
        await Promise.all(promises);


        const tokens = await MessagingService.getTokensOfUsers(uids);
        assert.ok(tokens[0].length === n, "No of tokens must be " + n + ". result: " + tokens[0].length);

        const chunkSize = 5;
        const tokensChunk = await MessagingService.getTokensOfUsers(uids, chunkSize);
        assert.ok(tokensChunk.length === 3, "No of tokens must be " + Math.ceil(n / chunkSize) + ". result: " + tokensChunk.length);

        // 첫번째 chunk 에는 5개의 토큰이 있어야 한다.
        assert.ok(tokensChunk[0].length === chunkSize, "No of tokens must be " + chunkSize + ". result: " + tokensChunk[0].length);
        // 두번째 chunk 에도 5개의 토큰이 있어야 한다.
        assert.ok(tokensChunk[1].length === chunkSize, "No of tokens must be " + chunkSize + ". result: " + tokensChunk[1].length);
        // 세번째 chunk 에는 1개의 토큰이 있어야 한다.
        assert.ok(tokensChunk[2].length === 1, "No of tokens must be 1. result: " + tokensChunk[2].length);
    });

    it("토큰을 chunk 로 나누기 - 501개의 토큰을 500개로 나누어 가져옴", async () => {
        // 토큰 n 개 생성
        const n = 501;
        const db = getDatabase();
        const promises = [];
        const uids = [];
        await db.ref(Config.userFcmTokens).set({});
        for (let i = 0; i < n; i++) {
            const uid = `uid-${i}`;
            uids.push(uid);
            const token = `token-${i}`;
            promises.push(db.ref(`${Config.userFcmTokens}/${uid}-${token}`).set({
                uid: uid,
            }));
        }
        await Promise.all(promises);


        const tokens = await MessagingService.getTokensOfUsers(uids);

        // 총 chunk 는 2개가 나와야 한다.
        assert.ok(tokens.length === 2, "No of tokens must be 2. result: " + tokens.length);

        // 첫번째 chunk 에는 500개의 토큰이 있어야 한다.
        assert.ok(tokens[0].length === 500, "No of tokens must be " + n + ". result: " + tokens[0].length);

        // 두번째 chunk 에는 1개의 토큰이 있어야 한다.
        assert.ok(tokens[1].length === 1, "No of tokens must be 1. result: " + tokens[1].length);
    });


    // it("getTokensOfUsers with wrong uids", async () => {
    //     const res = await MessagingService.sendNotificationToUids(['wrong-uid-a'], "title", "body");
    //     assert.ok(Object.keys(res).length == 3, "length of invalid tokens must be [x]. but it is " + Object.keys(res).length);
    //     assert.ok(res["This-is-invalid-token"] == "messaging/invalid-argument", "invalid token must be [messaging/invalid-argument]. but it is " + res["This-is-invalid-token"]);
    // });
});
