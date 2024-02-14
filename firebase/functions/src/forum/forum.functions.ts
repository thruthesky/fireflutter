import { getDatabase } from "firebase-admin/database";
import { onValueCreated, onValueDeleted, onValueWritten } from "firebase-functions/v2/database";
import { PostService } from "./post.service";
import { Config } from "../config";

/**
 * managePostsSummary
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
export const managePostsSummaryDeleted = onValueDeleted(
    `${Config.postSummaries}/{category}/{postId}`,
    (event) => {
        // Data deleted
        const db = getDatabase();
        db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).remove();
        db.ref(`${Config.postAllSummaries}/${event.params.postId}`).remove();
    },
);

/**
 * postSummaryTitle
 *
 * This function is triggered when the title of a post is updated in the path under `/posts` in RTDB.
 */
export const postSummaryTitle = onValueWritten(
    `${Config.posts}/{category}/{postId}/title`,
    (event) => {
        const db = getDatabase();
        const updatedTitle = event.data.after.val() ?? null;
        db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).update({ title: updatedTitle });
        db.ref(`${Config.postAllSummaries}/${event.params.postId}`).update({ title: updatedTitle });
    }
);

/**
 * postSummaryContent
 *
 * This function is triggered when the content of a post is updated in the path under `/posts` in RTDB.
 *
 */
export const postSummaryContent = onValueWritten(
    `${Config.posts}/{category}/{postId}/content`,
    (event) => {
        const db = getDatabase();
        const updatedContent = event.data.after.val() ?? null;
        db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).update({ content: updatedContent });
        db.ref(`${Config.postAllSummaries}/${event.params.postId}`).update({ content: updatedContent });
    }
);

/**
 * postSummaryUrl
 *
 * This function is triggered when the urls of a post is updated in the path under `/posts` in RTDB.
 */
export const postSummaryUrl = onValueWritten(
    `${Config.posts}/{category}/{postId}/urls`,
    (event) => {
        const db = getDatabase();
        const updatedUrl = event.data.after.val()?.[0] ?? null;
        db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).update({ url: updatedUrl });
        db.ref(`${Config.postAllSummaries}/${event.params.postId}`).update({ url: updatedUrl });
    }
);

/**
 * postSummaryDeleted
 */
export const postSummaryDeleted = onValueWritten(
    `${Config.posts}/{category}/{postId}/deleted`,
    (event) => {
        const db = getDatabase();
        const updatedDeleted = event.data.after.val() ?? null;
        db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).update({ deleted: updatedDeleted });
        db.ref(`${Config.postAllSummaries}/${event.params.postId}`).update({ deleted: updatedDeleted });
    }
);
