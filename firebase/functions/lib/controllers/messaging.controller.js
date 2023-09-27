"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
const messaging_model_1 = require("../models/messaging.model");
const event_name_1 = require("../utils/event-name");
const firestore_1 = require("firebase-functions/v2/firestore");
exports.messagingOnPostCreate = (0, firestore_1.onDocumentCreated)("posts/{postId}", async (event) => {
    var _a, _b;
    if (event === void 0)
        return undefined;
    const post = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    const data = Object.assign(Object.assign({}, post), { id: (_b = event.data) === null || _b === void 0 ? void 0 : _b.id, action: event_name_1.EventName.postCreate, type: event_name_1.EventType.post, senderUid: post.uid });
    return await messaging_model_1.Messaging.sendMessage(data);
});
exports.messagingOnCommentCreate = (0, firestore_1.onDocumentCreated)("comments/{commentId}", async (event) => {
    var _a, _b;
    if (event === void 0)
        return undefined;
    const comment = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    const data = Object.assign(Object.assign({}, comment), { id: (_b = event.data) === null || _b === void 0 ? void 0 : _b.id, action: event_name_1.EventName.commentCreate, type: event_name_1.EventType.post, senderUid: comment.uid });
    return await messaging_model_1.Messaging.sendMessage(data);
});
exports.pushNotificationQueue = (0, firestore_1.onDocumentCreated)("push_notification_queue/{docId}", async (event) => {
    var _a, _b;
    if (event === void 0)
        return undefined;
    const result = await messaging_model_1.Messaging.sendMessage((_a = event.data) === null || _a === void 0 ? void 0 : _a.data());
    console.log("result::", result);
    return await ((_b = event.data) === null || _b === void 0 ? void 0 : _b.ref.update(Object.assign(Object.assign({}, result), { sentAt: admin.firestore.FieldValue.serverTimestamp() })));
});
exports.messagingOnChatMessageCreate = (0, firestore_1.onDocumentCreated)("chats/{chatId}/messages/{messageId}", async (event) => {
    var _a;
    if (event === void 0)
        return undefined;
    console.log(event.params);
    const chatData = (_a = event.data) === null || _a === void 0 ? void 0 : _a.data();
    chatData.roomId = event.params.chatId;
    return messaging_model_1.Messaging.sendChatNotificationToOtherUsers(chatData);
});
//# sourceMappingURL=messaging.controller.js.map