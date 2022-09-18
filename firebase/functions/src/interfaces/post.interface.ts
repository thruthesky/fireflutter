import * as admin from "firebase-admin";

export interface PostDocument {
  uid: string;
  category: string;
  id: string;
  title: string;
  content?: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;

  point?: number;
}

/**
 * if [content] is 'Y', then it will return content. By default, it is 'Y'.
 * if [photo] is 'Y', then it will return posts with photos only. By default, it is 'N'.
 */
export interface PostListOptions {
  category?: string;
  limit?: string;
  order?: "asc" | "desc";
  startAfter?: string;
  content?: "Y" | "N";
  photo?: "Y" | "N";
}
