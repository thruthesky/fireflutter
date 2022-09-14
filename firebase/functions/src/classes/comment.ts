import { CommentDocument } from "../interfaces/comment.interface";
import { Ref } from "../utils/ref";

export class Comment {
  static async get(id: string): Promise<CommentDocument | null> {
    const snapshot = await Ref.commentDoc(id).get();
    if (snapshot.exists === false) return null;
    const data = snapshot.data() as CommentDocument;
    data.id = id;
    return data;
  }

  // get comment ancestor by getting parent comment until it reach the root comment
  // return the uids of the author

  /**
   * Return an array of user uid of the ancestors of the comment id.
   * @param commentId comment id to get the ancestor's uid
   * @param authorUid the user uid of the comment id. If it is set, then the anotherUid will not be included in the result uid array. It should be the author uid of the commentId. But It can be any uid.
   * @returns Returns the uid of ancestors.
   */
  static async getAncestorsUid(commentId: string, authorUid?: string): Promise<string[]> {
    let comment = await Comment.get(commentId);
    const uids = [comment?.uid];
    while (comment?.parentId && comment.postId != comment.parentId) {
      comment = await Comment.get(comment!.parentId);
      if (comment == null) break;
      uids.push(comment?.uid);
    }
    // return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate

    // remove duplicates and remove authorUid
    return [...new Set(uids)].filter((v) => v != authorUid) as string[];
  }
}
