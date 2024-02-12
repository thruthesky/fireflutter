import { getDatabase } from "firebase-admin/database";
import { onValueWritten, onValueDeleted } from "firebase-functions/v2/database";
import { PostService } from "./post.service";
import { Config } from "../config";

/**
 * managePostsSummary
 *
 * This function is triggered when a new post(post summary) is created/updated/deleted in the path under `/posts-summary` in RTDB.
 *
 */
export const managePostsSummary = onValueWritten(
    `${Config.posts}/{category}/{postId}`,
    (event) => {
        const db = getDatabase();
        if (!event.data.after.exists()) {
            // Data deleted
            // Remove on postSummaries
            db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).remove();
            // Remove on postAllSummaries
            db.ref(`${Config.postAllSummaries}/${event.params.postId}`).remove();
            return;
        }
        // Data has created or updated
        // Update on postSummaries
        PostService.setSummary(event.data.after.val(), event.params.category, event.params.postId);
        return;
    },
);

/**
 * postSummaryRemoveField
 *
 * PostService.setSummary will not be able to remove specific fields.
 */
export const postSummaryRemoveField = onValueDeleted(
    `${Config.postSummaries}/{category}/{postId}/{field}`,
    (event) => {
        const db = getDatabase();
        db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}/${event.params.field}`).remove();
        db.ref(`${Config.postAllSummaries}/${event.params.postId}/${event.params.field}`).remove();
    }
);
