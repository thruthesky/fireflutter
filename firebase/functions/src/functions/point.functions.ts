import * as functions from "firebase-functions";
import { Point } from "../classes/point";
import { CommentDocument } from "../interfaces/comment.interface";
import { PostDocument } from "../interfaces/post.interface";

export const pointIncreaseOnPostCreate = functions
    .region("asia-northeast3")
    .firestore.document("/posts/{postId}")
    .onCreate((snapshot, context) => {
      return Point.postCreate(snapshot.data() as PostDocument, context.params.postId);
    });

export const pointIncreaseOnCommentCreate = functions
    .region("asia-northeast3")
    .firestore.document("/comments/{commentId}")
    .onCreate((snapshot, context) => {
      return Point.commentCreate(snapshot.data() as CommentDocument, context.params.commentId);
    });
