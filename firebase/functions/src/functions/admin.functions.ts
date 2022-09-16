import * as functions from "firebase-functions";
import { User } from "../classes/user";

export const enableUser = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    try {
      await User.enableUser(context.auth!.uid, data.uid);
    } catch (e: any) {
      throw new functions.https.HttpsError("unknown", e.message, data);
    }
  });

export const disableUser = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    try {
      await User.disableUser(context.auth!.uid, data.uid);
    } catch (e: any) {
      throw new functions.https.HttpsError("unknown", e.message, data);
    }
  });
