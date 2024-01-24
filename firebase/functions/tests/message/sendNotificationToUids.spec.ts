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
describe("sendNotificationToUids 기능 테스트", () => {




    it("진짜 토큰과 가짜 토큰을 섞어, 총 11개의 토큰을 chunk 로 나누어 저장 한 5개 단위 전송 테스트", async () => {
        // 가짜 토큰 10 개 생성
        const n = 10;
        const db = getDatabase();
        const promises = [];
        const uids = [];
        await db.ref("user-fcm-tokens").set({});
        for (let i = 0; i < n; i++) {
            const uid = `uid-${i}`;
            uids.push(uid);
            const token = `token-${i}`;
            promises.push(db.ref(`user-fcm-tokens/${uid}-${token}`).set({
                'uid': uid,
            }));
        }
        await Promise.all(promises);

        // 진짜 토큰을 첫번째 uid 에 1개 추가
        await db.ref(`user-fcm-tokens/${uids[0]}-real-token`).set({
            'uid': uids[0],
        });

        // 토큰 5개 단위, 가져오기
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

});
