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
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("게시판 카테고리 푸시 알림", () => {

    it("qna 게시판", async () => {

        await MessagingService.sendNotificationToForumCategorySubscribers({
            id: 'post-id-1',
            category: 'qna',
            title: 'title',
            body: 'body',
            image: '',
            uid: 'author-uid',
        });

        assert.ok(true);

    });

});
