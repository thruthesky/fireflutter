
import { onValueCreated, onValueDeleted, onValueUpdated, onValueWritten } from "firebase-functions/v2/database";
import { TypesenseService } from "./typesense.service";
import { PostCreateEvent, TypesenseDoc, TypesensePostCreate } from "./typesense.interface";

/**
 * Indexing for users
 * Listens for new messages added to /messages/:pushId/original and creates an
 * uppercase version of the message to /messages/:pushId/uppercase
 * for all databases in 'us-central1'
 */
export const typesenseUserIndexing = onValueWritten(
    "/users/{uid}",
    (event) => {
        if (!event.data.after.exists()) {
            // Do something here for deleted users
            const data = event.data.before.val();
            console.log("Deleted User in RTDB: ", data);
            return TypesenseService.delete(event.data.before.key as string);
        }

        // no need to check this event.data.before.exists() -> because update and create has same logic here
        // It comes here when the user document is newly created or updated.
        // Do something when a new user is created/updated.
        // [data] is the user document when it is first created.
        const data = {
            ...event.data.after.val(),
            type: "user",
            uid: event.params.uid,
            id: event.params.uid,
        } as TypesenseDoc;
        console.log("Created/Updated User in RTDB: ", data);
        return TypesenseService.upsert(data);
    },
);

/**
 * Indexing for comments
 */
export const typesenseCommentIndexing = onValueWritten(
    "/posts/{category}/{postId}/comments/{id}",
    (event) => {
        const data = event.data.after.val() as TypesenseDoc;
        if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
            // when deleted becomes == true
            // or when comment node is removed
            const data = event.data.before.val() as TypesenseDoc;
            const commentData = {
                ...data,
                id: event.params.id,
                type: "comment",
                category: event.params.category,
                postId: event.params.postId,
                url: data.urls?.[0],
            } as TypesenseDoc;
            console.log("Deleted Comment in RTDB: ", commentData);
            return TypesenseService.delete(event.params.id);
        }

        // It comes here when the user document is newly created.
        // Do something when a new user is created.
        // [data] is the user document when it is first created.
        // const data = event.data.after.val() as TypesenseDoc;
        const commentData = {
            ...data,
            id: event.params.id,
            type: "comment",
            category: event.params.category,
            postId: event.params.postId,
            url: data.urls?.[0],
        } as TypesenseDoc;
        console.log("Created/Updated Comment in RTDB: ", commentData);
        return TypesenseService.upsert(commentData);
    },
);

/**
 * Indexing for post created
 *
 */
export const typesensePostCreatedIndexing = onValueCreated(
    "/posts/{category}/{id}",
    async (event) => {
        const data = event.data.val() as PostCreateEvent;
        // Created
        const postData: TypesensePostCreate = {
            id: event.params.id,
            type: "post",
            category: event.params.category,
            title: data.title,
            content: data.content,
            uid: data.uid,
            url: data.urls?.[0],
            createdAt: data.createdAt,
        };
        return await TypesenseService.upsert(postData);
    },
);

/**
 * Indexing for post update for title
 */
export const typesensePostUpdateTitleIndexing = onValueUpdated(
    "/posts/{category}/{id}/title",
    (event) => {
        const afterValue = event.data.after.val();
        const id = event.params.id;
        const postData = {
            title: afterValue,
            id: id,
            type: "post",
        } as TypesenseDoc;
        console.log("A post's `title` is updated in RTDB", event.params, afterValue);
        return TypesenseService.emplace(postData);
    },
);

/**
 * Indexing for post update for content
 */
export const typesensePostUpdateContentIndexing = onValueUpdated(
    "/posts/{category}/{id}/content",
    (event) => {
        const afterValue = event.data.after.val();
        const id = event.params.id;
        const postData = {
            content: afterValue,
            id: id,
            type: "post",
        } as TypesenseDoc;
        console.log("A post's `content` is updated in RTDB", event.params, afterValue);
        return TypesenseService.emplace(postData);
    },
);

/**
 * Indexing for post update for urls
 */
export const typesensePostUpdateUrlIndexing = onValueUpdated(
    "/posts/{category}/{id}/urls",
    (event) => {
        const afterValue = event.data.after.val();
        const id = event.params.id;
        const postData = {
            url: afterValue?.[0] ?? "",
            id: id,
            type: "post",
        } as TypesenseDoc;
        console.log("A post's `urls` is updated in RTDB", event.params, afterValue);
        return TypesenseService.emplace(postData);
    },
);

/**
 * Indexing for post update for deleted
 *
 * When the value for deleted becomes true, the
 * Typesense document should be deleted in the
 * collection.
 */
export const typesensePostUpdateDeleted = onValueUpdated(
    "/posts/{category}/{id}/deleted",
    (event) => {
        const deletedValue: boolean | undefined = event.data.after.val();
        const id = event.params.id;
        console.log("A post's `deleted` is updated in RTDB", event.params, deletedValue);
        if (deletedValue == true) {
            return TypesenseService.delete(id);
        } else {
            // do nothing, we don't care if it's false or null
            return;
        }
    },
);

/**
 * Removing index for post when it is hard deleted in RTDB
 *
 * Upon deleting the post, it should reflect properly
 * in Typesense.
 */
export const typesensePostDeleteIndexing = onValueDeleted(
    "/posts/{category}/{id}",
    (event) => {
      const deletedData = event.data.val() as TypesenseDoc;
      console.log("Deleted Post in RTDB. This is a hard delete which means the node is completely removed in RTDB ", event.params, deletedData);
      return TypesenseService.delete(event.params.id);
    },
);
