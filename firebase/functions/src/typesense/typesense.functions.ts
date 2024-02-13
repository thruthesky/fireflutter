
import { onValueWritten } from "firebase-functions/v2/database";
import { TypesenseService } from "./typesense.service";
import { TypesenseDoc } from "./typesense.interface";

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
    "/comments/{postId}/{id}",
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
            // category is included in data
            postId: event.params.postId,
            url: data.urls?.[0],
        } as TypesenseDoc;
        console.log("Created/Updated Comment in RTDB: ", commentData);
        return TypesenseService.upsert(commentData);
    },
);

/**
 * Indexing for post
 */
export const typesensePostIndexing = onValueWritten(
    "/posts/{category}/{id}",
    (event) => {
        const data = event.data.after.val() as TypesenseDoc;
        if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
            console.log("Deleted Post in RTDB: ", data);
            // means deleted
            return TypesenseService.delete(event.params.id);
        }
        // means created or updated
        const post = {
            ...data,
            category: event.params.category,
            id: event.params.id,
            type: "post",
            url: data.urls?.[0],
        } as TypesenseDoc;
        console.log("Created/Updated Post in RTDB: ", post);
        return TypesenseService.upsert(post);
    }
);
