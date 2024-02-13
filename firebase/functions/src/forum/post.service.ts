import { getDatabase } from "firebase-admin/database";
import { PostCreateEvent, PostSummary, Post } from "./forum.interface";
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
        db.ref(`${Config.postAllSummaries}/${id}`).update(summary);
        db.ref(`${Config.postSummaries}/${category}/${id}`).update(summary);
        return;
    }

    /**
     * Updating Summary
     */
    static updateSummary(originalPost: Post, updatedPost: Post, category: string, id: string) {
        // To get ONLY the updated field.
        const [larger, smaller] = Object.keys(originalPost).length > Object.keys(updatedPost).length ? [originalPost, updatedPost] : [updatedPost, originalPost];
        const keysUpdated = Object.keys(larger).filter((key) => {
            // NOTE: This case is only for arrays
            if (Array.isArray(Object(larger)[key]) || Array.isArray(Object(smaller)[key])) {
                // Automatically, there was an update when this original or updated field is null
                if (!Object.prototype.hasOwnProperty.call(larger, key)) return true;
                if (!Object.prototype.hasOwnProperty.call(smaller, key)) return true;
                // There was a change in type, therefore there's an update.
                if (typeof Object(larger)[key] !== typeof Object(smaller)[key]) return true;
                return JSON.stringify(Object(larger)[key]) !== JSON.stringify(Object(smaller)[key]);
            }
            // This doesn't check for Objects. Since we don't have record with objects,
            // it is not included here
            // Other than Arrays, simply compare here
            return Object(larger)[key] !== Object(smaller)[key];
        });
        console.log("Post update keys: ", keysUpdated);
        const updatedSummary = keysUpdated.reduce((acc, key) => {
            if (key === "urls") {
                // Urls is only url in summary
                Object(acc)["url"] = Object(updatedPost)[key]?.[0] ?? null;
            } else {
                Object(acc)[key] = Object(updatedPost)[key] ?? null;
            }
            return acc;
        }, {} as PostSummary);
        console.log("Post updates summary: ", updatedSummary);
        const db = getDatabase();
        db.ref(`${Config.postAllSummaries}/${id}`).update(updatedSummary);
        db.ref(`${Config.postSummaries}/${category}/${id}`).update(updatedSummary);
        return;
    }
}
