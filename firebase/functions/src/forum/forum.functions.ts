import { getDatabase } from "firebase-admin/database";
import { onValueCreated, onValueDeleted, onValueUpdated } from "firebase-functions/v2/database";
import { PostService } from "./post.service";
import { Config } from "../config";

/**
 * managePostsSummaryCreated
 *
 * This function is triggered when a new post
 *
 */
export const managePostsSummaryCreated = onValueCreated(
    `${Config.posts}/{category}/{postId}`,
    (event) => {
        // Data created
        return PostService.setSummary(event.data.val(), event.params.category, event.params.postId);
    },
);

/**
 * managePostsSummaryDeleted
 *
 * This function is triggered when a post(post summary) is deleted
 */
export const managePostsSummaryUpdated = onValueUpdated(
    `${Config.posts}/{category}/{postId}`,
    (event) => {
        return PostService.setSummary(event.data.after.val(), event.params.category, event.params.postId);
    },
);

/**
 * managePostsSummaryDeleted
 *
 * This function is triggered when a post(post summary) is deleted
 */
export const managePostsSummaryDeleted = onValueDeleted(
    `${Config.posts}/{category}/{postId}`,
    (event) => {
        // Data deleted
        const db = getDatabase();
        db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).remove();
        db.ref(`${Config.postAllSummaries}/${event.params.postId}`).remove();
    },
);
