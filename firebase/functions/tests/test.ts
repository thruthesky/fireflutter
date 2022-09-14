import * as amdin from "firebase-admin";
import { User } from "../src/classes/user";
import { UserDocument } from "../src/interfaces/user.interface";
import { PostDocument } from "../src/interfaces/post.interface";
import { CommentDocument } from "../src/interfaces/comment.interface";
import { Comment } from "../src/classes/comment";

import { Ref } from "../src/utils/ref";

import { Post } from "../src/classes/post";

export class Test {
  static testCount = 0;

  // one push token.
  static token =
    "d-RUY7gztE1wnheilIWUYC:APA91bE_owxgKAYy7808o5EFFSKhyle5jpv9-tcfX2_KPh1rgrzh58K4erUwO1mk7bea6FVoksyH7ouACZjr0kA_kYe0X8uUergnAeS85UEBL3u7CxEC4sg3jRXLhGu2FdRKnqfuV0Ya";

  static jaehoSimulatorToken =
    "cVdUO22hkEd-rhGvagjHMJ:APA91bG5656PPaKawRSIQsN_gfqUqTd4CFCxmF7RcdvTlwqHjejCVTcILZMnl_RepEpg6mJn2MTc4dBAncv7bMB4Y5cEkqVCXH3ybgObsPlcoOJAqsz1xxoe_qR57t3gaN6ssDhKAmP3";
  // three push tokens. two are real. one is fake.
  static tokens = ["fake-token"];

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
  static async createUser(uid?: string, data?: any): Promise<UserDocument | null> {
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

  static async createPost(uid?: string, category?: string, data?: any): Promise<PostDocument> {
    if (uid === void 0) {
      const user = await User.create("test" + Test.id(), {
        createdAt: amdin.firestore.FieldValue.serverTimestamp(),
      });
      uid = user!.id;
    }
    const postRef = await Ref.postCol.add({
      uid: uid,
      category: category ?? "qna",
      createdAt: amdin.firestore.FieldValue.serverTimestamp(),
      ...data,
    });
    return Post.get(postRef.id);
  }
  static async createComment(
    uid?: string,
    category?: string,
    data?: any
  ): Promise<CommentDocument> {
    if (uid === void 0) {
      const user = await User.create("test" + Test.id(), {
        createdAt: amdin.firestore.FieldValue.serverTimestamp(),
      });
      uid = user!.id;
    }
    const postRef = await Ref.postCol.add({
      uid: uid,
      category: category ?? "qna",
      createdAt: amdin.firestore.FieldValue.serverTimestamp(),
      ...data,
    });
    const post = await Post.get(postRef.id);

    const ref = await Ref.commentCol.add({
      uid: uid,
      postId: post.id,
      createdAt: amdin.firestore.FieldValue.serverTimestamp(),
    });

    return await Comment.get(ref.id); // (await ref.get()).data() as CommentDocument;
  }
}
