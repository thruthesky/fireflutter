import * as functions from "firebase-functions";
export function invalidArgument(message: string) {
  return new functions.https.HttpsError("failed-precondition", message);
}
