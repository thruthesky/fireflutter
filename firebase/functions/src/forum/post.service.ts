import { getDatabase } from "firebase-admin/database";
import { PostCreateEvent, PostSummary } from "./forum.interface";
import { Config } from "../config";

/**
 * Typesense Service
 *
 * This service is responsible for all the Typesense related operations.
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
        const summary: PostSummary = {
            uid: post.uid,
            createdAt: post.createdAt,
            order: -post.createdAt,
            title: post.title ?? "",
            content: post.content ?? "",
            url: post.urls?.[0] ?? "",
            deleted: post.deleted ?? false,
        };
        const db = getDatabase();
        db.ref(`${Config.postAllSummaries}/${id}`).update(summary);
        db.ref(`${Config.postSummaries}/${category}/${id}`).update(summary);
        return;
    }
}
