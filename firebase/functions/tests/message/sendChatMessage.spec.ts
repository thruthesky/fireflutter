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
 * 채팅 메시지 전송 테스트
 *
 */
describe("채팅 메시지 전송 알림", () => {
    it("채팅 메시지 전송", async () => {
        await MessagingService.sendMessagesToChatRoomSubscribers({
            createdAt: 0,
            id: "chat-id-1",
            roomId: "-NoB4KHlTeKJ593hUyHL",
            text: "3 - Chat. Hi there. How are you? Are you having fun? Oops..",
            order: -1,
            uid: "23TE0SWd8Mejv0Icv6vhSDRHe183",
        });
        assert.ok(true);
    });
});
