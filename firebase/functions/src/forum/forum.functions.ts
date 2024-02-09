import { getDatabase } from "firebase-admin/database";
import { onValueCreated, onValueDeleted, onValueUpdated, onValueWritten } from "firebase-functions/v2/database";
import { PostService } from "./post.service";
import { Config } from "../config";

/**
 * managePostsAllSummary
 *
 * This function is triggered when a new post(post summary) is created/updated/deleted in the path under `/posts-summary` in RTDB.
 *
 */
export const managePostsAllSummary = onValueWritten(
    `${Config.postSummaries}/{category}/{postId}`,
    (event) => {
        const db = getDatabase();
        if (!event.data.after.exists()) {
            // Data deleted
            // const data = event.data.before.val();
            return db.ref(`${Config.postAllSummaries}/${event.params.postId}`).remove();
        }

        // Data has created or updated
        const data = {
            ...event.data.after.val(),
            category: event.params.category,
        };
        return db.ref(`${Config.postAllSummaries}/${event.params.postId}`).set(data);
    },
);

/**
 * Indexing for post created
 *
 */
export const postSetSummary = onValueCreated(
    "/posts/{category}/{id}",
    async (event) => {
        return PostService.setSummary(event.data.val(), event.params.category, event.params.id);
    },
);

/**
 * Indexing for post update for title
 *
 * 글 생성시, 제목 필드가 없을 수 있고, 글 수정할 때, 제목이 생성될 수 있다. 따라서 여기서 제목 생성/수정/삭제를 모두 핸들링한다.
 */
export const postUpdateSummaryTitle = onValueUpdated(
    "/posts/{category}/{id}/title",
    (event) => {
        const category = event.params.category;
        const id = event.params.id;
        const db = getDatabase();
        const ref = db.ref(`${Config.postSummaries}/${category}/${id}/title`);
        return ref.set(event.data.after?.val() ?? null);
    },
);

/**
 * Indexing for post update for content
 */
export const postUpdateSummaryContent = onValueUpdated(
    "/posts/{category}/{id}/content",
    (event) => {
        const category = event.params.category;
        const id = event.params.id;
        const ref = getDatabase().ref(`${Config.postSummaries}/${category}/${id}/content`);
        return ref.set(event.data.after?.val() ?? null);
    },
);

/**
 * Indexing for post update for urls
 */
export const postUpdateSummaryUrl = onValueUpdated(
     "/posts/{category}/{id}/urls",
    (event) => {
        console.log("postUpdateSummaryUrl is triggered");
        const category = event.params.category;
        const id = event.params.id;
        const ref = getDatabase().ref(`${Config.postSummaries}/${category}/${id}/url`);
        return ref.set(event.data.after?.val()?.[0] ?? null);
    },
);

/**
 * Indexing for post update for deleted
 */
export const postUpdateSummaryDeleted = onValueWritten(
    "/posts/{category}/{id}/deleted",
    (event) => {
        const category = event.params.category;
        const id = event.params.id;
        const ref = getDatabase().ref(`${Config.postSummaries}/${category}/${id}/deleted`);
        return ref.set(event.data.after?.val() ?? null);
    },
);

/**
 * 글 삭제시, summary 에서도 삭제한다.
 */
export const postDeleteSummary = onValueDeleted(
    "/posts/{category}/{id}",
    (event) => {
        const category = event.params.category;
        const id = event.params.id;
        const ref = getDatabase().ref(`${Config.postSummaries}/${category}/${id}`);
        return ref.remove();
    },
);

