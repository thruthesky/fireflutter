import * as functions from "firebase-functions";
import { Point } from "../classes/point";

export const pointOnPostCreate = functions
  .region("asia-northeast3")
  .firestore.document("/posts/{postId}")
  .onCreate((snapshot, context) => {
    // return Post.sendMessageOnCreate(snapshot.data(), context.params.postId);
    return Point.postCreatePoint(snapshot.data(), context.params.postId);
  });
