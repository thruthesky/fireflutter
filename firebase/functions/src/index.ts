
import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging/messaging.service";
import { initializeApp } from "firebase-admin/app";
import { logger } from "firebase-functions/v1";
import { onValueCreated, onValueDeleted, onValueUpdated, onValueWritten } from "firebase-functions/v2/database";
import { getDatabase } from "firebase-admin/database";
import { TypesenseService } from "./typesense/typesense.service";
import { TypesenseDoc } from "./typesense/typesense.interface";
// import { event } from "firebase-functions/v1/analytics";


// / initialize firebase app
initializeApp();

export * from "./messaging/messaging.functions";



export const createTestNode = onRequest(async (request, response) => {
  await getDatabase().ref("/test").set({ test: "test" });
  response.send({ ok: true });
});


// Listens for new messages added to /messages/:pushId/original and creates an
// uppercase version of the message to /messages/:pushId/uppercase
// for all databases in 'us-central1'
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
 * Indexing after creating post's uid
 */
export const typesensePostCreatedUidIndexing = onValueCreated(
  "/posts/{category}/{id}/uid",
  (event) => {
    const uid = event.data.val();
    const postData = {
      uid: uid,
      id: event.params.id,
      category: event.params.category,
      type: "post",
    } as TypesenseDoc;
    console.log("Created Post in RTDB (triggered by uid creation): ", postData);
    return TypesenseService.emplace(postData);
  },
);

/**
* Indexing after creating post's createdAt
*/
export const typesensePostCreatedCreatedAtIndexing = onValueCreated(
 "/posts/{category}/{id}/createdAt",
 (event) => {
  const createdAt = event.data.val();
    const postData = {
      createdAt: createdAt,
      id: event.params.id,
      category: event.params.category,
      type: "post",
    } as TypesenseDoc;
  console.log("Created Post in RTDB (triggered by createdAt creation): ", postData);
  return TypesenseService.emplace(postData);
 },
);


/**
 * Indexing for post write for title
 */
export const typesensePostWriteTitleIndexing = onValueWritten(
  "/posts/{category}/{id}/title",
  (event) => {
    const afterValue = event.data.after.val();
    const id = event.params.id;
    if (!event.data.after.exists() || event.data.before.exists()) {
      // `!event.data.after.exists()` means, title is deleted
      // `event.data.before.exists()` means, title already existed, it's being updated
      // using update instead of emplace so in case
      // that typesensePostUpdateDeleteIndexing
      // or typesensePostDeleteIndexing already
      // handled it, it will fail and not create the doc
      console.log("A post's `title` is updated/deleted in RTDB", event.params, afterValue);
      return TypesenseService.update(id, { title: afterValue });
    }
    // if it comes here, it means it is just created
    const postData = {
      title: afterValue,
      id: id,
      type: "post",
    } as TypesenseDoc;
    console.log("A post's `title` is created in RTDB", event.params, afterValue);
    return TypesenseService.emplace(postData);
  },
);

/**
 * Indexing for post write for content
 */
export const typesensePostWriteContentIndexing = onValueWritten(
  "/posts/{category}/{id}/content",
  (event) => {
    const afterValue = event.data.after.val();
    const id = event.params.id;
    if (!event.data.after.exists() || event.data.before.exists()) {
      // `!event.data.after.exists()` means, title is deleted
      // `event.data.before.exists()` means, title already existed, it's being updated
      // using update instead of emplace so in case
      // that typesensePostUpdateDeleteIndexing
      // or typesensePostDeleteIndexing already
      // handled it, it will fail and not create the doc
      console.log("A post's `content` is updated/deleted in RTDB", event.params, afterValue);
      return TypesenseService.update(id, { content: afterValue });
    }
    // if it comes here, it means it is just created
    const postData = {
      content: afterValue,
      id: id,
      type: "post",
    } as TypesenseDoc;
    console.log("A post's `content` is created in RTDB", event.params, afterValue);
    return TypesenseService.emplace(postData);
  },
);


/**
 * Indexing for post write for urls
 *
 * **NOTE!**: We are only saving the first url
 */
export const typesensePostWriteUrlsIndexing = onValueWritten(
  "/posts/{category}/{id}/urls",
  (event) => {
    // after value will never be null because this is onValueUpdated
    // if it's deleted, onValueDeleted is called instead.
    // there can also be a case when urls becomes empty []
    const afterValue = event.data.after.val();
    const id = event.params.id;
    let url: string | null = null;
    if ( Array.isArray(afterValue) && afterValue.length > 0) {
      url = afterValue[0];
    }
    if (!event.data.after.exists() || event.data.before.exists()) {
      // `!event.data.after.exists()` means, title is deleted
      // `event.data.before.exists()` means, title already existed, it's being updated
      // using update instead of emplace so in case
      // that typesensePostUpdateDeleteIndexing
      // or typesensePostDeleteIndexing already
      // handled it, it will fail and not create the doc
      console.log("A post's `urls` is updated/deleted in RTDB", event.params, url);
      return TypesenseService.update(id, { url: url });
    }
    const postData = {
      url: url,
      id: event.params.id,
      type: "post",
    } as TypesenseDoc;
    console.log("A post's `urls` is created in RTDB", event.params, afterValue);
    return TypesenseService.emplace(postData);
  },
);

/**
 * Indexing for post write for deleted
 */
export const typesensePostWriteDeleteIndexing = onValueWritten(
  "/posts/{category}/{id}/deleted",
  (event) => {
    const data = event.data.after.val() as boolean;
    if (data == true) {
      console.log("A post's `deleted` is updated as true in RTDB: ", event.params, data);
      return TypesenseService.delete(event.params.id);
    } else {
      console.log("A post's `deleted` is updated in RTDB: ", event.params, data);
      // deleted in typesense will have no meaning anyway. No need to update Typesense
      return;
    }
  },
);


/**
 * Removing index for post when it is manually deleted in RTDB
 *
 * This will not naturally happen because we don't really hard delete
 * on our system. However, in case admins deleted the record, it
 * should reflect properly in Typesense with less effort.
 *
 * Check if we need this. Please confirm
 */
export const typesensePostDeleteIndexing = onValueDeleted(
  "/posts/{category}/{id}",
  (event) => {
    const deletedData = event.data.val() as TypesenseDoc;
    console.log("Deleted Post in RTDB. This is a hard delete which means the node is completely removed in RTDB ", event.params, deletedData);
    return TypesenseService.delete(event.params.id);
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
      const postData = {
        ...data,
        id: event.params.id,
        type: "comment",
        category: event.params.category,
        postId: event.params.postId,
        url: data.urls?.[0],
      } as TypesenseDoc;
      console.log("Deleted Comment in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }

    // It comes here when the user document is newly created.
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    // const data = event.data.after.val() as TypesenseDoc;
    const postData = {
      ...data,
      id: event.params.id,
      type: "comment",
      category: event.params.category,
      postId: event.params.postId,
      url: data.urls?.[0],
    } as TypesenseDoc;
    console.log("Created/Updated Comment in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);
