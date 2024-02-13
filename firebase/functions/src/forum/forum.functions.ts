import { getDatabase } from "firebase-admin/database";
import { onValueWritten } from "firebase-functions/v2/database";
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
        if (event.data.before.exists()) {
            // Data updated
            // Update on postSummaries
            return PostService.updateSummary(event.data.before.val(), event.data.after.val(), event.params.category, event.params.postId);
        }
        // Data created
        return PostService.setSummary(event.data.after.val(), event.params.category, event.params.postId);
    },
);
