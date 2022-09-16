import * as functions from "firebase-functions";
import { User } from "../classes/user";
import * as lib from "../utils/library";

export const enableUser = functions
    .region("asia-northeast3")
    .https.onCall(async (data, context) => {
      try {
        await User.enableUser(context.auth!.uid, data);
      } catch (e: any) {
        throw lib.callableError(lib.CallableError.unknown, e.message, data);
      }
    });

export const disableUser = functions
    .region("asia-northeast3")
    .https.onCall(async (data, context) => {
      try {
        await User.disableUser(context.auth!.uid, data.otherUid);
      } catch (e: any) {
        throw lib.callableError(lib.CallableError.unknown, e.message, data);
      }
    });
