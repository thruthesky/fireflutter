import * as admin from "firebase-admin";
import { MessagingService } from "../../src/messaging/messaging.service";
import { describe, it } from "mocha";
import assert = require("assert");


if (admin.apps.length === 0) {
    admin.initializeApp(
        {
            databaseURL: "https://philgo-default-rtdb.asia-southeast1.firebasedatabase.app",
        }
    );
}

/**
 * 게시판 카테고리 푸시 알림
 *
 * 실제로 메시지가 핸드폰에 전달된다. 그래서, 테스트를 할 때는, 핸드폰에 메시지가 전달되는지 확인해야 하고,
 * 실제 사용자들에게 메시지가 전달될 수 있으므로 주의한다.
 */
describe("게시판 카테고리 푸시 알림", () => {
    it("qna 게시판", async () => {
        await MessagingService.sendMessagesToCategorySubscribers({
            id: "post-id-1",
            category: "discussion",
            title: "(2) Post - kim",
            body: "(2) Post Body. Hi there. How are you? Are you having fun? Oops..",
            image: "",
            uid: "23TE0SWd8Mejv0Icv6vhSDRHe183",
        });
        assert.ok(true);
    });
});

