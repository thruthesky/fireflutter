import * as functions from "firebase-functions";
import * as lib from "../utils/library";

export const invalidArgument = functions.region("asia-northeast3").https.onCall(async () => {
  return lib.invalidArgument("invalid argument", { a: "apple", b: "banana" });
});

export const throwInvalidArgument = functions.region("asia-northeast3").https.onCall(async () => {
  throw lib.invalidArgument("invalid argument", { a: "apple", b: "banana" });
});
export const success = functions.region("asia-northeast3").https.onCall(async () => {
  return { a: "apple", b: "banana" };
});
