import * as functions from "firebase-functions";
import { Messaging } from "../classes/messaging";
import { EventName } from "../event-name";
export const sendMessage = functions.region("asia-northeast3").https.onCall(async (data) => {
  return Messaging.sendMessage(data);
});

export const messagingOnPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot) => {
      const data = snapshot.data();
      data.action = EventName.postCreate;
      return Messaging.sendMessage(data);
    });

export const messagingOnCommentCreate = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot) => {
      const data = snapshot.data();
      data.action = EventName.commentCreate;
      return Messaging.sendMessage(data);
    });
