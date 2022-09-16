import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { Messaging } from "../classes/messaging";
import { EventName, EventType } from "../event-name";
export const sendMessage = functions.region("asia-northeast3").https.onCall(async (data) => {
  return Messaging.sendMessage(data);
});

export const messagingOnPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot) => {
      const data = snapshot.data();
      data.id = snapshot.id;
      data.action = EventName.postCreate;
      data.type = EventType.post;
      return Messaging.sendMessage(data);
    });

export const messagingOnCommentCreate = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot) => {
      const data = snapshot.data();
      data.id = snapshot.id;
      data.action = EventName.commentCreate;
      data.type = EventType.post;
      return Messaging.sendMessage(data);
    });

export const pushNotificationQueue = functions
    .region("asia-northeast3")
    .firestore.document("/push-notifications-queue/{docId}")
    .onCreate(async (snapshot) => {
      console.log("pushNotificationQueue::", JSON.stringify(snapshot));
      const re = await Messaging.sendMessage(snapshot.data());
      console.log("re::", re);
      return admin
          .firestore()
          .collection("push-notifications-queue")
          .doc(snapshot.id)
          .update({
            ...re,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
          });
    });
