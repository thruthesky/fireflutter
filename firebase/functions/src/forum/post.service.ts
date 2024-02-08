import { getDatabase } from "firebase-admin/database";
import { PostCreateEvent, PostSummary } from "./forum.interface";
import { Config } from "../config";

/* eslint linebreak-style: ["error", "windows"] */
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
        };

        if ( post.title ) {
            summary.title = post.title;
        }
        if ( post.content ) {
            summary.content = post.content;
        }
        if ( post.urls ) {
            summary.url = post.urls[0];
        }

        const db = getDatabase();
        return db.ref(`${Config.postSummaries}/${category}/${id}`).set(summary);
    }
}
