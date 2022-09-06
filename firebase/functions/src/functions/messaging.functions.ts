import * as functions from "firebase-functions";
import { Messaging } from "../classes/messaging";
export const sendMessage = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    return Messaging.sendMessage(data, context);
  });
