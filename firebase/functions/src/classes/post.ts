import * as admin from "firebase-admin";
import { PostDocument, PostListOptions } from "../interfaces/post.interface";
import { Ref } from "../utils/ref";

export class Post {
  /**
   * Returns the post document in `PostDocument` format.
   *
   * If the post does not exist, it will return an empty object.
   *
   * @param id post id
   * @returns data object of the post document
   */
  static async get(id: string): Promise<PostDocument> {
    const snapshot = await Ref.postDoc(id).get();
    if (snapshot.exists == false) return {} as PostDocument;
    const data = snapshot.data() as PostDocument;
    data.id = id;
    return data;
  }

  /**
   *
   * @see README.md for details.
   * @param options options for getting post lists
   * @returns
   * - list of post documents. Empty array will be returned if there is no posts by the options.
   * - Or it will throw an exception on failing post creation.
   * @note exception will be thrown on error.
   */
  static async posts(options: PostListOptions): Promise<Array<PostDocument>> {
    const posts: Array<PostDocument> = [];

    let q: admin.firestore.Query = Ref.postCol;

    if (options.category) {
      q = q.where("category", "==", options.category);
    }

    if (options.photo === "Y") {
      q = q.where("hasPhoto", "==", true);
    }

    if (options.order) {
      q = q.orderBy("createdAt", options.order);
    } else {
      q = q.orderBy("createdAt", "desc");
    }

    if (options.startAfter) {
      const startAfter: admin.firestore.Timestamp = admin.firestore.Timestamp.fromMillis(
          parseInt(options!.startAfter) * 1000
      );

      q = q.startAfter(startAfter);
    }

    const limit = options.limit ? parseInt(options.limit) : 10;
    q = q.limit(limit);

    const snapshot = await q.get();

    if (snapshot.size > 0) {
      const docs = options.order === "asc" ? snapshot.docs.reverse() : snapshot.docs;
      for (const doc of docs) {
        const post = doc.data() as PostDocument;
        post.id = doc.id;

        if (options.content === "N") delete post.content;

        posts.push(post);
      }
    }

    return posts;
  }
}
