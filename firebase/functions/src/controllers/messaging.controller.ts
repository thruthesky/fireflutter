import * as admin from "firebase-admin";
// import * as functions from "firebase-functions";
// import { RuntimeOptions } from "firebase-functions";
import { ChatMessageDocument } from "../interfaces/chat.interface";
import { CommentDocument, PostDocument } from "../interfaces/forum.interface";
import { SendMessage, SendMessageResult } from "../interfaces/messaging.interface";
import { Messaging } from "../models/messaging.model";
import { EventName, EventType } from "../utils/event-name";

import { onDocumentCreated, FirestoreEvent }
  from "firebase-functions/v2/firestore";

import { QueryDocumentSnapshot } from "firebase-admin/firestore";


exports.messagingOnPostCreate = onDocumentCreated("posts/{postId}",
  async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>): Promise<SendMessageResult | undefined> => {
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
  });


exports.messagingOnCommentCreate = onDocumentCreated("comments/{commentId}",
  async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>): Promise<SendMessageResult | undefined> => {
    if (event === void 0) return undefined;

    const comment: CommentDocument = event.data?.data() as CommentDocument;
    const data: SendMessage = {
      ...comment,
      id: event.data?.id,
      action: EventName.commentCreate,
      type: EventType.post,
      senderUid: comment.uid,
    };
    return await Messaging.sendMessage(data);
  });


exports.pushNotificationQueue =
  onDocumentCreated("push_notifications_queue/{docId}",
    async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>): Promise<admin.firestore.WriteResult | undefined> => {
      if (event === void 0) return undefined;
      const re = await Messaging
        .sendMessage(event.data?.data() as SendMessage);
      console.log("re::", re);


      return await event.data?.ref.update({
        // ...re,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });


exports.messagingOnChatMessageCreate =
  onDocumentCreated("chat_room_messages/{documentId}",
    async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>) => {
      if (event === void 0) return;

      const futures = [];

      futures.push(
        Messaging.sendChatNotificationToOtherUsers(
          event.data?.data() as ChatMessageDocument
        )
      );
      return await Promise.all(futures);
    });


exports.sendPushNotificationsOnCreate =
  onDocumentCreated("push_notifications/{documentId}",
    async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>): Promise<void> => {
      if (event === void 0) return void 0;

      try {
        if (event.data) {
          await Messaging.sendPushNotifications(event.data);
        }
      } catch (e) {
        console.log(`Error: ${e}`);
        await event.data?.ref.update({ status: "failed", error: `${e}` });
      }
    });
