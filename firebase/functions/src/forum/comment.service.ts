import { getDatabase } from "firebase-admin/database";
import { Comment } from "./forum.interface";
import { Config } from "../config";


export class CommentService {


    /**
     * Get the comment data from the comment id.
     * @param postId post id of the comment
     * @param commentId comment id to get the comment
     * @return Returns the comment data. If the comment is not found, then return null.
     */
    static async get(postId: string, commentId: string): Promise<Comment | null> {
        // TODO 여기서 부터 유닛 테스트 - 총체적으로 sendMessagesToNewCommentSubscribers 를 background trigger unit test 를 할 것.
        const db = getDatabase();
        const data = (await db.ref(`${Config.comments}/${postId}/${commentId}`).get()).val();
        return data as Comment;
    }

    /**
     * Return an array of user uid of the ancestors of the comment id.
     * @param commentId comment id to get the ancestor's uid
     * @param authorUid the user uid of the comment id. If it is set,
     *  then the anotherUid will not be included in the result uid array.
     *  It should be the author uid of the commentId. But It can be any uid.
     * @return Returns the uid of ancestors.
     */
    static async getAncestorsUid(
        postId: string,
        commentId: string,
        authorUid?: string
    ): Promise<string[]> {
        // TODO 여기서 부터 유닛 테스트 - 총체적으로 sendMessagesToNewCommentSubscribers 를 background trigger unit test 를 할 것.
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