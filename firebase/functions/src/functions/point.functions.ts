import * as functions from "firebase-functions";
import { Point } from "../classes/point";

export const pointOnPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot, context) => {
      return Point.postCreate(snapshot.data(), context.params.postId);
    });

export const pointOnCommentCreate = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot, context) => {
      return Point.postCreate(snapshot.data(), context.params.commentId);
    });
