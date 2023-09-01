import * as admin from "firebase-admin";
export interface PostDocument {
  id: string;
  categoryId: string;
  title: string;
  content: string;
  uid: string;
  urls: string[];
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
  likes: Array<string>;
  deleted: boolean;
  noOfComments: number;
  //
  noOfLikes: number;
}

export interface CommentDocument {
  id: string;
  postId: string;
  content: string;
  uid: string;
  files: string[];
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
  likes: Array<string>;
  deleted?: boolean;

  // Parent ID is the comment ID of the comment this comment is replying to.
  // null if this comment is not a reply (or the first level of comment)
  parentId: string;
  sort: string;
  depth: number;

  //
  noOfLikes: number;
}

export interface CategoryDocument {
  id: string;
  name: string;
  description: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
  uid: string;

  noOfPosts: number;
  noOfComments: number;
}
