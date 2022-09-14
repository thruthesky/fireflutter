import * as admin from "firebase-admin";

export interface PostDocument {
  uid: string;
  category: string;
  id: string;
  title: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;

  point?: number;
}
