import { getDatabase } from "firebase-admin/database";
import { PostCreateEvent, PostSummary, PostSummaryAll } from "./forum.interface";
import { Config } from "../config";

/**
 * PostService
 *
 */
export class PostService {
    /**
     * Sets the summary of the post in `post-summaries` and `post-all-summary`
     *
     * @param post post data from the event
     * @param category category of the post
     * @param id id of the post
     * @returns the promise of the operation
     */
    static async setSummary(post: PostCreateEvent, category: string, id: string,) {
        const summary = {
            uid: post.uid,
            createdAt: post.createdAt,
            order: -post.createdAt,
            title: post.title ?? null,
            content: post.content ?? null,
            url: post.urls?.[0] ?? null,
            deleted: post.deleted ?? null,
        } as PostSummary;

        const db = getDatabase();
        await db.ref(`${Config.postSummaries}/${category}/${id}`).update(summary);
        const summaryAll: PostSummaryAll = {
            ...summary,
            category,
        };
        await db.ref(`${Config.postAllSummaries}/${id}`).update(summaryAll);
        return;
    }


    static async deleteSummary(category: string, postId: string) {
        const db = getDatabase();
        await db.ref(`${Config.postSummaries}/${category}/${postId}`).remove();
        await db.ref(`${Config.postAllSummaries}/${postId}`).remove();
    }
}
