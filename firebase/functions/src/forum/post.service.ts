import { getDatabase } from "firebase-admin/database";
import { PostCreateEvent, PostSummary } from "./forum.interface";
import { Config } from "../config";

/**
 * Typesense Service
 *
 * This service is responsible for all the Typesense related operations.
 */
export class PostService {
    static setSummary(post: PostCreateEvent, category: string, id: string) {

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
