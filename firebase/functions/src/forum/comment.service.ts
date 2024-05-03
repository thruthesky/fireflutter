import { getDatabase, Reference, ServerValue } from "firebase-admin/database";
import { Comment } from "./forum.interface";
import { Config } from "../config";


/**
 * CommentService
 */
export class CommentService {
    /**
     * Get the comment data from the comment id.
     * @param postId post id of the comment
     * @param commentId comment id to get the comment
     * @return Returns the comment data. If the comment is not found, then return null.
     *
     * 코멘트를 가져오기 위해서는 postId 가 필요하다.
     */
    static async get(postId: string, commentId: string): Promise<Comment | null> {
        const db = getDatabase();
        const data = (await db.ref(`${Config.comments}/${postId}/${commentId}`).get()).val();
        return data as Comment;
    }


    /**
     * Create a comment.
     * @param postId post id of the comment
     * @param data the comment data
     * @return Returns the reference of the comment.
     */
    static async create(postId: string, data: Comment): Promise<Reference> {
        if (!data.uid) {
            throw new Error("uid is required");
        }
        if (!data.category) {
            throw new Error("category is required");
        }
        data.createdAt = data.createdAt || ServerValue.TIMESTAMP;
        const db = getDatabase();
        const ref = db.ref(`${Config.comments}/${postId}`).push() as Reference;
        await ref.set(data);
        return ref;
    }


    /**
     * Return an array of user uid of the ancestors of the comments.
     * 마지막 코멘트의 상위 코멘트들의 uid 를 리턴한다. 단, 글 uid 는 리턴 값에 포함되지 않는다.
     *
     * @param commentId comment id to get the ancestor's uid. 마지막 코멘트의 id.
     * @param authorUid the user uid of the comment id. 코멘트를 쓴 사람의 uid. 이 값이 지정되면 이 uid 를 제외하고 리턴한다.
     * @return Returns the uid of ancestors.
     *
     * UID 가 저장되는 순서는 [맨 아래의 위 댓글 ID, 그 위 댓글 ID, ..., 글 ID] 이다.
     * 중간에 코멘트의 UID 가 authorUid 와 같은 경우는 제외한다.
     * 예를 들어, A 가 글 쓰고 그 아래에 B 가 댓글을 쓰고, 그 아래에 C 가 댓글을 쓰고, 그 아래에 B 가 쓰고,
     * 그 아래에 D 가 쓰고, 그 아래에 B 가 쓴 경우, 역순으로 [D, C] 가 리턴된다. 맨 마지막 글 쓴이가 B 이므로,
     * B 는 제외된다.
     *
     */
    static async getAncestorsUid(
        postId: string,
        commentId: string,
        authorUid?: string
    ): Promise<string[]> {
        const uids = [];
        let comment = await this.get(postId, commentId);
        if (comment == null) return [];
        uids.push(comment.uid);

        while (comment != null &&
            comment.parentId &&
            comment.parentId !=
            comment.postId
        ) {
            comment = await this.get(postId, comment.parentId);
            if (comment == null) break;
            uids.push(comment.uid);
        }
        // return uids.filter((v, i, a) => a.indexOf(v) === i); // remove duplicate

        // remove duplicates and remove authorUid
        return [...new Set(uids)].filter((v) => v != authorUid) as string[];
    }
}
