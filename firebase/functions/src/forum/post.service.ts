import { getDatabase } from "firebase-admin/database";
import { PostCreateEvent, PostSummary, Post, PostSummaryAll } from "./forum.interface";
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
        const db = getDatabase();
        db.ref(`${Config.postAllSummaries}/${id}`).update(updatedSummary);
        db.ref(`${Config.postSummaries}/${category}/${id}`).update(updatedSummary);
        return;
    }

    /**
     * Get the difference of the two objects
     *
     * To get ONLY the updated field.
     * NOTE: This doesn't check when we have Map Fields
     */
    static _getUpdatedFields(originalPost: Post, updatedPost: Post): Partial<PostSummary> {
        // get all the combined keys without duplicate
        const keys = [...new Set([...Object.keys(originalPost), ...Object.keys(updatedPost)])];

        // get the keys that have values different between originalPost and updatedPost
        const keysUpdated = keys.filter((key) => {
            // NOTE: This case is only for arrays
            if (Array.isArray(Object(originalPost)[key]) || Array.isArray(Object(updatedPost)[key])) {
                // Automatically, there was an update when this original or updated field is null
                if (!Object.prototype.hasOwnProperty.call(originalPost, key)) return true;
                if (!Object.prototype.hasOwnProperty.call(updatedPost, key)) return true;
                // There was a change in type, therefore there's an update.
                if (typeof Object(originalPost)[key] !== typeof Object(updatedPost)[key]) return true;
                return JSON.stringify(Object(originalPost)[key]) !== JSON.stringify(Object(updatedPost)[key]);
            }
            // This doesn't check for Objects/Maps. Since we don't have record with objects,
            // it is not included here
            // Other than Arrays, simply compare here
            return Object(originalPost)[key] !== Object(updatedPost)[key];
        });

        // get the updated fields only
        const updatedData = keysUpdated.reduce((acc, key) => {
            if (key === "urls") {
                // Urls is only url in summary
                Object(acc)["url"] = Object(updatedPost)[key]?.[0] ?? null;
            } else {
                Object(acc)[key] = Object(updatedPost)[key] ?? null;
            }
            return acc;
        }, {} as Partial<PostSummary>);

        return updatedData;
    }
}
