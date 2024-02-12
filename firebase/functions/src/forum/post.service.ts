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
     * Sets the summary of the post
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
        return db.ref(`${Config.postSummaries}/${category}/${id}`).update(summary);
    }

    /**
     * Sets `post-all-summaries`
     *
     * @param post post data of the doc
     * @param category category
     * @param id post Id
     * @returns
     */
    static setAllSummaries(post: PostCreateEvent, category: string, id: string,) {
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
        return db.ref(`${Config.postAllSummaries}/${id}`).update(summary);
    }
}
