import * as admin from "firebase-admin";
// import * as functions from "firebase-functions";
// import { RuntimeOptions } from "firebase-functions";
import {ChatMessageDocument} from "../interfaces/chat.interface";
import {CommentDocument, PostDocument} from "../interfaces/forum.interface";
import {SendMessage, SendMessageResult} from "../interfaces/messaging.interface";
import {Messaging} from "../models/messaging.model";
import {EventName, EventType} from "../utils/event-name";

import {onDocumentCreated, FirestoreEvent} from "firebase-functions/v2/firestore";

import {QueryDocumentSnapshot} from "firebase-admin/firestore";
import {UserDocument} from "../interfaces/user.interface";
import {ReportDocument} from "../interfaces/report.interface";

exports.messagingOnPostCreate = onDocumentCreated(
  "posts/{postId}",
  async (
    event: FirestoreEvent<QueryDocumentSnapshot | undefined>
  ): Promise<SendMessageResult | undefined> => {
    if (event === void 0) return undefined;

    const post: PostDocument = event.data?.data() as PostDocument;
    const data: SendMessage = {
      ...post,
      id: event.data?.id,
      action: EventName.postCreate,
      type: EventType.post,
      senderUid: post.uid,
    };
    return await Messaging.sendMessage(data);
  }
);

exports.messagingOnCommentCreate = onDocumentCreated(
  "comments/{commentId}",
  async (
    event: FirestoreEvent<QueryDocumentSnapshot | undefined>
  ): Promise<SendMessageResult | undefined> => {
    if (event === void 0) return undefined;

    const comment: CommentDocument = event.data?.data() as CommentDocument;
    const data: SendMessage = {
      ...comment,
      id: event.data?.id,
      postId: comment.postId,
      action: EventName.commentCreate,
      type: EventType.post,
      senderUid: comment.uid,
    };
    return await Messaging.sendMessage(data);
  }
);

exports.pushNotificationQueue = onDocumentCreated(
  "push_notification_queue/{docId}",
  async (
    event: FirestoreEvent<QueryDocumentSnapshot | undefined>
  ): Promise<admin.firestore.WriteResult | undefined> => {
    if (event === void 0) return undefined;
    const result = await Messaging.sendMessage(event.data?.data() as SendMessage);
    console.log("result::", result);

    return await event.data?.ref.update({
      ...result,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
);

exports.messagingOnChatMessageCreate = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (
    event: FirestoreEvent<QueryDocumentSnapshot | undefined, { chatId: string; messageId: string }>
  ): Promise<SendMessageResult | undefined> => {
    if (event === void 0) return undefined;
    console.log(event.params);

    const chatData = event.data?.data() as ChatMessageDocument;
    chatData.roomId = event.params.chatId;
    return Messaging.sendChatNotificationToOtherUsers(chatData);
  }
);


exports.messagingOnUserCreate = onDocumentCreated(
  "users/{userUid}",
  async (
    event: FirestoreEvent<QueryDocumentSnapshot | undefined>
  ): Promise<SendMessageResult | undefined> => {
    if (event === void 0) return undefined;

    const user: UserDocument = event.data?.data() as UserDocument;
    const data: SendMessage = {
      ...user,
      title: "New Registration",
      content: "New User " + event.data?.id,
      id: event.data?.id,
      action: EventName.userCreate,
      type: EventType.user,
      senderUid: event.data?.id,
    };
    return await Messaging.sendMessage(data);
  }
);

exports.messagingOnReportCreate = onDocumentCreated(
  "reports/{reportId}",
  async (
    event: FirestoreEvent<QueryDocumentSnapshot | undefined>
  ): Promise<SendMessageResult | undefined> => {
    if (event === void 0) return undefined;

    const report: ReportDocument = event.data?.data() as ReportDocument;
    const data: SendMessage = {
      ...report,
      title: "Report: " + report.type,
      body: report.reason,
      id: event.data?.id,
      action: EventName.reportCreate,
      type: EventType.report,
      senderUid: report.uid,
    };
    return await Messaging.sendMessage(data);
  }
);
