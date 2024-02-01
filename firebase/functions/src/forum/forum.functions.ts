import { getDatabase } from "firebase-admin/database";
import { onValueWritten } from "firebase-functions/v2/database";

/**
 * managePostsAllSummary
 *
 * This function is triggered when a new post(post summary) is created/updated/deleted in the path under `/posts-summary` in RTDB.
 *
 */
export const managePostsAllSummary = onValueWritten(
    "/posts-summary/{category}/{postId}",
    (event) => {
        const db = getDatabase();
        if (!event.data.after.exists()) {
            // Data deleted
            // const data = event.data.before.val();
            return db.ref(`posts-all-summary/${event.params.postId}`).remove();
        }

        // Data has created or updated
        const data = {
            ...event.data.after.val(),
            category: event.params.category,
        };
        return db.ref(`posts-all-summary/${event.params.postId}`).set(data);
    },
);
