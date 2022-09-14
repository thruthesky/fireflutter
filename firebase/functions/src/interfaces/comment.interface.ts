import * as admin from "firebase-admin";

export interface CommentDocument {
  uid: string;
  id: string;
  postId: string;
  parentId: string;
  content: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;

  point?: number;
}
