import { getDatabase } from "firebase-admin/database";
import { PostCreateEvent, PostSummary, Post, PostSummaryAll, PostSummaryUpdateEvent } from "./forum.interface";
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
     * Updating Summary
     */
    static updateSummary(
        originalPost: Post,
        updatedPost: Post,
        category: string,
        id: string,
    ) {
        const updatedSummary = this._getUpdatedFields(originalPost, updatedPost);
        console.log("Post updates summary: ", updatedSummary);
        if (Object.keys(updatedSummary).length === 0) return;
        const db = getDatabase();
        db.ref(`${Config.postAllSummaries}/${id}`).update(updatedSummary);
        db.ref(`${Config.postSummaries}/${category}/${id}`).update(updatedSummary);
        return;
    }

    /**
     * Get the updated fields from original to updated
     *
     * To get ONLY the updated field.
     * NOTE: This doesn't check when we have Map Fields
     */
    static _getUpdatedFields(originalPost: Post, updatedPost: Post): Partial<PostSummaryUpdateEvent> {
        const updatedData: Partial<PostSummaryUpdateEvent> = {};
        if (originalPost.title !== updatedPost.title) {
            updatedData.title = updatedPost.title ?? null;
        }
        if (originalPost.content !== updatedPost.content) {
            updatedData.content = updatedPost.content ?? null;
        }
        if (originalPost.urls?.[0] !== updatedPost.urls?.[0]) {
            updatedData.url = updatedPost.urls?.[0] ?? null;
        }
        if (originalPost.deleted !== updatedPost.deleted) {
            updatedData.deleted = updatedPost.deleted ?? null;
        }
        return updatedData;
    }
}
