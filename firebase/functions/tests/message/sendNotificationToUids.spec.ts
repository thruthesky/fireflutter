import * as admin from "firebase-admin";
import { MessagingService } from "../../src/messaging/messaging.service";
import { describe, it } from "mocha";
import assert = require("assert");
import { getDatabase } from "firebase-admin/database";
import { Config } from "../../src/config";

if (admin.apps.length === 0) {
    admin.initializeApp(
        {
            databaseURL: "https://philgo-default-rtdb.asia-southeast1.firebasedatabase.app",
        }
    );
}

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("sendNotificationToUids 기능 테스트", () => {
    it("진짜 토큰과 가짜 토큰을 섞어, 총 502개의 토큰을 chunk 로 나누어 저장 500개 단위 전송 테스트", async () => {
        // 가짜 토큰 501 개 생성
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

        // 진짜 토큰을 첫번째 uid 에 1개 추가
        await db.ref(`${Config.userFcmTokens}/dRx8UpLwt0EUtcK0kpkDme:APA91bF6gHUfRs4J6nc4xnRvEhE85uFeuOZwrxyD0lqgfhccLhnw_zpVB4UouPXJvIlAaKmzDQoqI2VxpZNnjdZlqSRBoYCTrxl2oXVSxqYoqYdMxNKgZUwhKAlVhpkPFw5r2pq1wWfm`).set({
            uid: uids[0],
        });
        // 진짜 토큰을 두번째 uid 에 1개 추가
        await db.ref(`${Config.userFcmTokens}/dsV6a4_XRiGWq5Fxq_f-jH:APA91bFtB98IC06Y6SOBz6OFmNCKeCoDJQ2X72k3Taw3UaO8cwaPdcI9jDq3oWllqmMmGhnd0uuZXwRrXs3gXBnsNdyIbBF3xmQgvMDBV8LW_cM0VNmJt3UBxtKMgnFqjw2q-aanGKWH`).set({
            uid: uids[0],
        });

        // 토큰 기본 500 개 단위, 가져오기
        // const tokensChunk = await MessagingService.getTokensOfUsers(uids);
        // console.log("tokensChunk", tokensChunk);
        // assert.ok(tokensChunk.length === 2, "No of chunks must be 2, result: " + tokensChunk.length);
        // // 첫번째 chunk 에는 5개의 토큰이 있어야 한다.
        // assert.ok(tokensChunk[0].length === 500, "No of tokens must be " + 500 + ". result: " + tokensChunk[0].length);
        // // 두번째 chunk 에도 5개의 토큰이 있어야 한다.
        // assert.ok(tokensChunk[1].length === 3, "No of tokens must be " + 3 + ". result: " + tokensChunk[1].length);


        // 전송
        await MessagingService.sendNotificationToUids({
            uids: uids,
            title: "title",
            body: "body",
            action: "test",
            targetId: "",

        });


        // 잘못된 토큰이 삭제 되었는지 확인. 501 개 삭제되어야함.
        // 올바른 토큰이 남아 있는지 확인. 2 개가 남아 있어야함.
        const tokens = await db.ref(Config.userFcmTokens).get();
        assert.ok(tokens.numChildren() === 2, "No of tokens must be " + 2 + ". result: " + tokens.numChildren());
    });
});
