
import { DataSnapshot, getDatabase } from "firebase-admin/database";

import * as test from "firebase-functions-test";
import { Config } from "../../src/config";

import { sendMessagesToCommentSubscribers } from "../../src/forum/forum.functions";
import { firebaseWithcenterTest2OnlineInit } from "../firebase-withcenter-test-2-online.init";
import { createTestComment, createTestPost, createTestUser } from "../test-functions";

import * as assert from "assert";

firebaseWithcenterTest2OnlineInit();

/**
 * This test is not reliable because the tokens may be invalid after a while.
 * TODO : 테스트가 끝났다. 문서 정리하고, 플러터에서, 설정에서 코멘트 알림 on/off 를 해서, 테스트 해 본다. 그리고 기본적으로 on 이 되도록 한다.
 */
describe("Push notification for new comment", () => {
    it("Trigger background function", async () => {
        // Create user A
        const a = await createTestUser({ tokens: ["a1", "a2"] });
        // A creates a post - P1
        const p1 = await createTestPost({ uid: a });
        // A creates a comment - C1 under P1
        const c1 = await createTestComment({ uid: a, postId: p1 });


        // Create user B and enable comment notification
        const b = await createTestUser({ tokens: ["b1", "b2"], commentNotification: true });
        // ? B creates a comment - right under P1 - So, B will be excluded from the notification !!!!
        await createTestComment({ uid: b, postId: p1 });

        // Create user C
        const c = await createTestUser({ tokens: ["c1", "c2"] });
        // C creates a comment - C3 under C1
        const c3 = await createTestComment({ uid: c, postId: p1, parentId: c1 });

        // Create user D wiith comment notification on
        const d = await createTestUser({ tokens: ["d1", "d2"], commentNotification: true });
        // D creates a comment - C4 under C3
        const c4 = await createTestComment({ uid: d, postId: p1, parentId: c3 });


        // Create user E
        const e = await createTestUser();
        // E creates a comment - C5 under C4
        const c5 = await createTestComment({ uid: e, postId: p1, parentId: c4 });
        // Create user F with comment notification on
        const f = await createTestUser({ tokens: ["f1", "f2", "f3", "f4"], commentNotification: true });
        // F creates a comment - C6 under C5
        const c6 = await createTestComment({ uid: f, postId: p1, parentId: c5 });

        // Create user G
        const g = await createTestUser({ tokens: ["g1"], commentNotification: true });
        // G creates a comment - C7 under C6
        const c7 = await createTestComment({ uid: g, postId: p1, parentId: c6 });
        // Create user H with comment notification on but without token
        const h = await createTestUser({ commentNotification: true });
        // H creates a comment - C8 under C7
        const c8 = await createTestComment({ uid: h, postId: p1, parentId: c7 });
        // Create user I
        const i = await createTestUser();
        // I creates a comment - C9 under C8
        const c9 = await createTestComment({ uid: i, postId: p1, parentId: c8 });

        // Create user J with notification on
        const j = await createTestUser({ tokens: ["j1"], commentNotification: true });
        // J creates a comment - C10 under C9
        const c10 = await createTestComment({ uid: j, postId: p1, parentId: c9 });

        // Create user K
        const k = await createTestUser();
        // K creates a comment - C11 under C10
        const c11 = await createTestComment({ uid: k, postId: p1, parentId: c10 });

        // k 가 코멘트를 쓴다. 여기에 넣어주는 snapshot 의 값은 실제 DB 에 존재하는 값이 아니라, 생성/수정을 할 때, 저장하는 값이다.
        const snap = test().database.makeDataSnapshot({
            category: "test",
            parentId: c10,
            postId: p1,
            uid: k,
        }, `${Config.commands}/${p1}/${c11}`) as DataSnapshot;

        const wrapped = test().wrap(sendMessagesToCommentSubscribers);
        const re = await wrapped({
            data: snap, // data 필드에, RTDB 데이터 snapshot 을 넣어준다. 이 값은 실제 DB 에 존재하는 값이 아니다.
            params: { // 이 params 값은 Background Trigger 함수에서 /comments/{postId}/{commentId} 에서 postId 와 commentId 에 해당하는 값을 넣어준다.
                postId: p1,
                commentId: c11,
            },
        });

        // 결과는 d1, d2, f1, f2, f3, f4, g1, j1 이어야 한다. B 는 제외되어야 한다.
        console.log("re: ", re);
        const logData = (await getDatabase().ref(`${Config.pushNotificationLogs}/${re}`).get()).val();
        console.log("logData: ", logData);
        assert.ok(logData.tokens.every((v: string) => ["d1", "d2", "f1", "f2", "f3", "f4", "g1", "j1"].includes(v)));


        // B 가 맨 아래에 코멘트를 달도록 한다. 그러면 코멘트 작성자 B 는 제외되고, k 가 추가되어야 한다. 하지만, k 는 new comment 알림을 하지 않았다. 그래서 결과는 동일하다.
        const c12 = await createTestComment({ uid: b, postId: p1, parentId: c11 });
        const snap2 = test().database.makeDataSnapshot({
            category: "test",
            parentId: c11,
            postId: p1,
            uid: b,
        }, `${Config.commands}/${p1}/${c12}`) as DataSnapshot;
        const re2 = await wrapped({
            data: snap2,
            params: {
                postId: p1,
                commentId: c12,
            },
        });
        const logData2 = (await getDatabase().ref(`${Config.pushNotificationLogs}/${re2}`).get()).val();
        console.log("logData2: ", logData2);
        assert.ok(logData2.tokens.every((v: string) => ["d1", "d2", "f1", "f2", "f3", "f4", "g1", "j1"].includes(v)));


        // 다시 맨 아래에 k 가 코멘트를 단다. 이제는 b 의 b1, b2 가 추가되어야 한다.
        const c13 = await createTestComment({ uid: k, postId: p1, parentId: c12 });
        const snap3 = test().database.makeDataSnapshot({
            category: "test",
            parentId: c12,
            postId: p1,
            uid: k,
        }, `${Config.commands}/${p1}/${c13}`) as DataSnapshot;
        const re3 = await wrapped({
            data: snap3,
            params: {
                postId: p1,
                commentId: c13,
            },
        });
        const logData3 = (await getDatabase().ref(`${Config.pushNotificationLogs}/${re3}`).get()).val();
        console.log("logData3: ", logData3, re3);
        assert.ok(logData3.tokens.every((v: string) => ["d1", "d2", "f1", "f2", "f3", "f4", "g1", "j1", "b1", "b2"].includes(v)));
    });
});

