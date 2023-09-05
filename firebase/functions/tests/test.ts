import * as amdin from "firebase-admin";
import { CommentDocument, PostDocument } from "../src/interfaces/forum.interface";
import { UserDocument } from "../src/interfaces/user.interface";
import { Comment } from "../src/models/comment.model";
import { Post } from "../src/models/post.model";
import { User } from "../src/models/user.model";
import { Ref } from "../src/utils/ref";


export class Test {
  static testCount = 0;

  // one push token.
  static token =
    "d-RUY7gztE1wnheilIWUYC:APA91bE_owxgKAYy7808o5EFFSKhyle5jpv9-tcfX2_KPh1rgrzh58K4erUwO1mk7bea6FVoksyH7ouACZjr0kA_kYe0X8uUergnAeS85UEBL3u7CxEC4sg3jRXLhGu2FdRKnqfuV0Ya";

  static jaehoSimulatorToken =
    "cVdUO22hkEd-rhGvagjHMJ:APA91bG5656PPaKawRSIQsN_gfqUqTd4CFCxmF7RcdvTlwqHjejCVTcILZMnl_RepEpg6mJn2MTc4dBAncv7bMB4Y5cEkqVCXH3ybgObsPlcoOJAqsz1xxoe_qR57t3gaN6ssDhKAmP3";
  // three push tokens. two are real. one is fake.
  static tokens = ["fake-token"];


  /**
   * Get a test uid
   * 
   * @returns Returns a test uid
   */
  static id(): string {
    return new Date().getTime() + "-" + this.testCount++;
  }

  /**
   * Create a user for test
   *
   * It creates a user document under /users/<uid> with user data and returns user ref.
   *
   * @param {*} uid
   * @return - reference of newly created user's document.
   *
   * @example create a user.
   * test.createTestUser(userA).then((v) => console.log(v));
   */
  static async createUser(uid?: string, data?: any): Promise<UserDocument> {
    // check if the user of uid exists, then return null

    const timestamp = new Date().getTime();

    const userData = {
      firstName: "firstName" + timestamp,
      lastName: "lastName" + timestamp,
      createdAt: amdin.firestore.FieldValue.serverTimestamp(),
    };

    if (data !== null) {
      Object.assign(userData, data);
    }

    if (uid === void 0) uid = "a" + Test.id();
    // console.log(uid);

    return await User.create(uid, userData);
  }

  static async createPost(uid?: string, categoryId?: string, data?: any): Promise<PostDocument> {
    if (uid === void 0) {
      const user = await User.create("test" + Test.id(), {
        createdAt: amdin.firestore.FieldValue.serverTimestamp(),
      });
      uid = user!.uid;
    }
    const postRef = await Ref.postCol.add({
      uid: uid,
      categoryId: categoryId ?? "qna",
      createdAt: amdin.firestore.FieldValue.serverTimestamp(),
      ...data,
    });
    return Post.get(postRef.id);
  }
  /**
   * Creates a comment
   * @param uid user uid
   * @param categoryId forum categoryId
   * @param data data to create
   * @returns comment document
   *
   * @example Creating a comment under a randomly generated post.
   * ```
   * const commentA = await Test.createComment(undefined, "qna");
   * ```
   *
   * @example Creating a comment under another comment
   * ```
   * const commentAA = await Test.createComment(undefined, "qna", {
   *   postId: commentA.postId,
   *   parentId: commentA.id,
   * });
   * ```
   *
   * @example Create a comment under a post
   * ```
   * await Test.createComment(undefined, "qna", { postId: commentA.postId });
   * ```
   */
  static async createComment(
    uid?: string,
    categoryId?: string,
    data?: any
  ): Promise<CommentDocument> {
    if (uid === void 0) {
      const user = await User.create("test" + Test.id(), {});
      uid = user!.uid;
    }

    // console.log("uid", uid);
    const postRef = await Ref.postCol.add({
      uid: uid,
      categoryId: categoryId ?? "qna",
      createdAt: amdin.firestore.FieldValue.serverTimestamp(),
      ...data,
    });
    const post = await Post.get(postRef.id);

    const ref = await Ref.commentCol.add({
      uid: uid,
      postId: post.id,
      createdAt: amdin.firestore.FieldValue.serverTimestamp(),
      ...data,
    });

    return (await Comment.get(ref.id)) as CommentDocument;
  }
}
