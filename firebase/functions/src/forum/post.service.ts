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
    static setSummary(post: PostCreateEvent, category: string, id: string,) {
        const summary = {
            uid: post.uid,
            createdAt: post.createdAt,
            order: -post.createdAt,
        } as PostSummary;
        if (post.title) {
            summary.title = post.title;
        }
        if (post.content) {
            summary.content = post.content;
        }
        if (post.urls?.[0]) {
            summary.url = post.urls[0];
        }
        if (post.deleted) {
            summary.deleted = post.deleted;
        }
        const db = getDatabase();
        db.ref(`${Config.postSummaries}/${category}/${id}`).update(summary);
        const summaryAll: PostSummaryAll = {
            ...summary,
            category,
        };
        db.ref(`${Config.postAllSummaries}/${id}`).update(summaryAll);
        return;
    }

    /**
     * Check if createdAt Exist
     *
     * This is used to check if record is already exisiting
     */
    static async checkCreatedAtExists(category: string, id: string): Promise<boolean> {
        const db = getDatabase();
        const snapshot = await db.ref(`${Config.postSummaries}/${category}/${id}/createdAt`).get();
        return snapshot.exists();
    }
}
