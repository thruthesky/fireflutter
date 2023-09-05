"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const messaging_model_1 = require("../models/messaging.model");
const event_name_1 = require("../utils/event-name");
const firestore_1 = require("firebase-functions/v2/firestore");
exports.messagingOnPostCreate = (0, firestore_1.onDocumentCreated)("posts/{postId}", async (event) => {
    var _a, _b;
    if (event === void 0)
        return null;
    const post = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    const data = Object.assign(Object.assign({}, post), { id: (_b = event.data) === null || _b === void 0 ? void 0 : _b.id, action: event_name_1.EventName.postCreate, type: event_name_1.EventType.post, senderUid: post.uid });
    return await messaging_model_1.Messaging.sendMessage(data);
});
exports.messagingOnCommentCreate = (0, firestore_1.onDocumentCreated)("comments/{commentId}", async (event) => {
    var _a;
    const comment = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    const data = Object.assign(Object.assign({}, comment), { id: event.data.id, action: event_name_1.EventName.commentCreate, type: event_name_1.EventType.post, senderUid: comment.uid });
    return messaging_model_1.Messaging.sendMessage(data);
});
exports.pushNotificationQueue =
    (0, firestore_1.onDocumentCreated)("push-notifications-queue/{docId}", async (event) => {
        var _a, _b;
        const re = await messaging_model_1.Messaging
            .sendMessage((_a = event.data) === null || _a === void 0 ? void 0 : _a.data());
        console.log("re::", re);
        return (_b = event.data) === null || _b === void 0 ? void 0 : _b.ref.update({
            // ...re,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    });
exports.messagingOnChatMessageCreate =
    (0, firestore_1.onDocumentCreated)("chat_room_messages/{documentId}", async (event) => {
        if (event === undefined ||
            typeof event === "undefined" ||
            event.data === undefined ||
            typeof event.data === "undefined") {
            return;
        }
        const futures = [];
        futures.push(messaging_model_1.Messaging.sendChatNotificationToOtherUsers(event.data.data()));
        return Promise.all(futures);
    });
exports.sendPushNotificationsOnCreate =
    (0, firestore_1.onDocumentCreated)("push_notifications/{documentId}", async (event) => {
        var _a;
        if (event === void 0)
            return;
        try {
            await messaging_model_1.Messaging.sendPushNotifications(event.data);
        }
        catch (e) {
            console.log(`Error: ${e}`);
            await ((_a = event.data) === null || _a === void 0 ? void 0 : _a.ref.update({ status: "failed", error: `${e}` }));
        }
    });
//# sourceMappingURL=messaging.controller.js.map