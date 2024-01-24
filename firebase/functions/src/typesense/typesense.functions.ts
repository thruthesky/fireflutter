
import { onValueWritten } from "firebase-functions/v2/database";
import { TypesenseService } from "./typesense.service";
import { TypesenseDoc, TypesensePostCreate, TypesensePostUpdate } from "./typesense.interface";
import { PostCreateEvent, PostUpdateEvent } from "../forum/forum.interface";

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
            // Supposedly !event.data.after.exists() should not happen naturally, unless admins deleted the actual record directly to RTDB.
            // Logic will also go here if the RTDB Doc is updated and deleted = true
            // Do something here for deleted Comments
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
 * Indexing for post
 *
 * **Attention**: read the cloud_functions.md for the post indexing issue.
 */
export const typesensePostIndexing = onValueWritten(
    "/posts/{category}/{id}",
    async (event) => {
        // Attention: delete event must come first (before update).
        if (!event.data.after.exists()) {
            // Deleted.
            return await TypesenseService.delete(event.params.id);
        }
        if (event.data.before.exists()) {
            // Update
            const data = event.data.after.val() as PostUpdateEvent;
            if (data.deleted) {
                return await TypesenseService.delete(event.params.id);
            }
            const postData: TypesensePostUpdate = {
                title: data.title ?? "",
                content: data.content ?? "",
                url: data.urls?.[0] ?? "",
            };
            return await TypesenseService.update(event.params.id, postData);
        }
        // Created
        const data = event.data.after.val() as PostCreateEvent;
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
 * /posts/{category}/title
/posts/{category}/content
/posts/{category}/urls
/posts/{category}/deleted

onValueCreated()
onValueDeleted()
 */