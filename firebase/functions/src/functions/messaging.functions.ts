import * as functions from "firebase-functions";
import { Messaging } from "../classes/messaging";
export const sendMessage = functions.region("asia-northeast3").https.onCall(async (data) => {
  return Messaging.sendMessage(data);
});

export const messagingOnPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot) => {
      const data = snapshot.data();
      data.action = "post-create";
      return Messaging.sendMessage(data);
    });
