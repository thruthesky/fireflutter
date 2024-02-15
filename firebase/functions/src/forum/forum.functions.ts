import { getDatabase } from "firebase-admin/database";
import { onValueWritten } from "firebase-functions/v2/database";
import { PostService } from "./post.service";
import { Config } from "../config";

/**
 * managePostsSummary
 *
 * function will be triggered upon create, update or delete.
 */
export const managePostsSummary = onValueWritten(
    `${Config.posts}/{category}/{postId}`,
    (event) => {
        if (!event.data.after.exists()) {
            // Data deleted
            const db = getDatabase();
            db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).remove();
            db.ref(`${Config.postAllSummaries}/${event.params.postId}`).remove();
        }
        // Data created/updated
        return PostService.setSummary(event.data.after.val(), event.params.category, event.params.postId);
    },
);
