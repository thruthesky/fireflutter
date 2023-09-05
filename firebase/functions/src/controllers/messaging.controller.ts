import * as admin from "firebase-admin";
// import * as functions from "firebase-functions";
// import { RuntimeOptions } from "firebase-functions";
import {ChatMessageDocument} from "../interfaces/chat.interface";
import {CommentDocument, PostDocument} from "../interfaces/forum.interface";
import {SendMessage, SendMessageResult} from "../interfaces/messaging.interface";
import {Messaging} from "../models/messaging.model";
import {EventName, EventType} from "../utils/event-name";

import {onDocumentCreated, FirestoreEvent}
  from "firebase-functions/v2/firestore";

import {QueryDocumentSnapshot} from "firebase-admin/firestore";


exports.messagingOnPostCreate = onDocumentCreated("posts/{postId}",
  async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>): Promise<SendMessageResult | null> => {
    if (event === void 0) return null;


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
  async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>): Promise<SendMessageResult> => {
    const comment: CommentDocument = event.data?.data() as CommentDocument;
    const data: SendMessage = {
      ...comment,
      id: event.data!.id,
      action: EventName.commentCreate,
      type: EventType.post,
      senderUid: comment.uid,
    };
    return Messaging.sendMessage(data);
  });


exports.pushNotificationQueue =
  onDocumentCreated("push-notifications-queue/{docId}",
    async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>) => {
      const re = await Messaging
        .sendMessage(event.data?.data() as SendMessage);
      console.log("re::", re);


      return event.data?.ref.update({
        // ...re,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });


exports.messagingOnChatMessageCreate =
  onDocumentCreated("chat_room_messages/{documentId}",
    async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>) => {
      if (event === undefined ||
        typeof event === "undefined" ||
        event.data === undefined ||
        typeof event.data === "undefined") {
        return;
      }

      const futures = [];

      futures.push(
        Messaging.sendChatNotificationToOtherUsers(
          event.data.data() as ChatMessageDocument
        )
      );
      return Promise.all(futures);
    });


exports.sendPushNotificationsOnCreate =
  onDocumentCreated("push_notifications/{documentId}",
    async (event: FirestoreEvent<QueryDocumentSnapshot | undefined>) => {
      if (event === void 0) return;

      try {
        await Messaging.sendPushNotifications(event.data!);
      } catch (e) {
        console.log(`Error: ${e}`);
        await event.data?.ref.update({status: "failed", error: `${e}`});
      }
    });
