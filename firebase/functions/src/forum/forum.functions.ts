import { getDatabase } from "firebase-admin/database";
import { onValueCreated, onValueDeleted, onValueWritten } from "firebase-functions/v2/database";
import { PostCreateEvent } from "./forum.interface";
import { PostService } from "./post.service";

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



///

/**
 * Indexing for post created
 *
 */
export const postSetSummary = onValueCreated(
    "/posts/{category}/{id}",
    async (event) => {
        const data = event.data.val() as PostCreateEvent;
        return PostService.setSummary(data, event.params.category, event.params.id);

    },
);

/**
 * Indexing for post update for title
 * 
 * 글 생성시, 제목 필드가 없을 수 있고, 글 수정할 때, 제목이 생성될 수 있다. 따라서 여기서 제목 생성/수정/삭제를 모두 핸들링한다.
 */
export const postUpdateSummaryTitle = onValueWritten(
    "/posts/{category}/{id}/title",
    (event) => {
        const category = event.params.category;
        const id = event.params.id;
        const db = getDatabase();
        const ref = db.ref(`posts-summary/${category}/${id}/title`);
        return ref.set(event.data.after?.val() ?? null);

        // if (event.data.after.exists()) {
        //     // Created || Updated
        //     const afterValue = event.data.after.val();
        //     return ref.set({ title: afterValue });
        // }
        // return ref.set({ title: null });
    },
);

/**
 * Indexing for post update for content
 *
 * **NOTE!**:
 * * In case when post document is not in Typesense yet but already created,
 *   then user deleted the content, this will be trigerred. However, it will
 *   not be inserted in Typesense since it doesn't exist in Typesense and we
 *   are using `Typesense.update`. Please re-index the post, instead.
 * * In case that post document is not in Typesense yet but already created,
 *   then user updated this, this will be trigerred. However, `createdAt`, `uid`
 *   will not, be added. Please re-index the post, instead.
 */
export const postUpdateSummaryContent = onValueWritten(
    "/posts/{category}/{id}/content",
    (event) => {
        const category = event.params.category;
        const id = event.params.id;
        const ref = getDatabase().ref(`posts-summary/${category}/${id}/content`);
        return ref.set(event.data.after?.val() ?? null);


        // if (event.data.after.exists()) {
        //     // Created || Updated
        //     const afterValue = event.data.after.val();
        //     return ref.set({ content: afterValue });
        // }
        // return ref.set({ content: null });
    },
);

/**
 * Indexing for post update for urls
 *
 * **NOTE!**:
 * * In case when post document is not in Typesense yet but already created,
 *   then user deleted the content, this will be trigerred. However, it will
 *   not be inserted in Typesense since it doesn't exist in Typesense and we
 *   are using `Typesense.update`. Please re-index the post, instead.
 * * In case that post document is not in Typesense yet but already created,
 *   then user updated this, this will be trigerred. However, `createdAt`, `uid`
 *   will not, be added. Please re-index the post, instead.
 */
export const postUpdateSummaryUrl = onValueWritten(
     "/posts/{category}/{id}/urls",
    (event) => {
        
        const category = event.params.category;
        const id = event.params.id;
        const ref = getDatabase().ref(`posts-summary/${category}/${id}/url`);
        return ref.set(event.data.after?.val()?.[0] ?? null);

        // if (event.data.after.exists()) {
        //     // Created || Updated
        //     const afterValue = event.data.after.val();
        //     if ( afterValue?.[0] ) {
        //         return db.ref(`posts-summary/${category}/${id}`).set({ url: afterValue[0] });
        //     }
        // }
        // // Deleted
        // return db.ref(`posts-summary/${category}/${id}`).set({ url: null });
    },
);

/**
 * Indexing for post update for deleted
 *
 * When the value for deleted becomes true, the
 * Typesense document should be deleted in the
 * collection.
 */
export const postUpdateSummaryDeleted = onValueWritten(
    "/posts/{category}/{id}/deleted",
    (event) => {
        const category = event.params.category;
        const id = event.params.id;
        const ref = getDatabase().ref(`posts-summary/${category}/${id}/deleted`);
        const deletedValue: boolean | undefined = event.data.after?.val() ?? null;
        
        return ref.set(deletedValue);
   
        // console.log("A post's `deleted` is created/updated/deleted in RTDB", event.params, deletedValue);
        // if (deletedValue == true) {
        //     return TypesenseService.delete(id);
        // } else {
        //     // do nothing, we don't care if it's false or null
        //     return;
        // }
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
        const ref = getDatabase().ref(`posts-summary/${category}/${id}`);
        return ref.remove();
    },
);

