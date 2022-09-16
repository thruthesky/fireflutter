import * as functions from "firebase-functions";
import { Messaging } from "../classes/messaging";
import { User } from "../classes/user";

export const sendToChatUser = functions.region("asia-northeast3").https.onCall(async (data, context) => {
  const notifyUser = await User.chatOtherUserNotification(data.senderUid, data.uid);

  return Messaging.sendMessage(data);
});
