
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

/**
 * sending messages to tokens
 */
export const sendPushNotifications = onRequest(async (request, response) => {
  logger.info("request.query of sendPushNotifications", request.body);
  try {
    const res = await MessagingService.sendNotificationToTokens(request.body);
    response.send(res);
  } catch (e) {
    logger.error(e);
    if (e instanceof Error) {
      response.send({ error: e.message });
    } else {
      response.send({ error: "unknown error" });
    }
  }
});

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
 * Indexing for post created
 */
export const typesensePostCreatedIndexing = onValueCreated(
  "/posts/{category}/{id}",
  (event) => {
    const data = event.data.val();
    const postData = {
      ...data,
      id: event.params.id,
      category: event.params.category,
      type: "post",
    } as TypesenseDoc;
    console.log("Created Post in RTDB: ", postData);
    // There might be a possibility that the document is already at the Typesense
    // Upsert I think is okay. (compare to Create)
    return TypesenseService.upsert(postData);
  },
);

/**
 * Indexing for post update for title
 */
export const typesensePostUpdateTitleIndexing = onValueUpdated(
  "/posts/{category}/{id}/title",
  (event) => {
    const afterValue = event.data.after.val();
    console.log("A post's `title` is updated in RTDB", event.params, afterValue);
    // TODO review what will happen if document doesn't exist. Will it still continue?
    return TypesenseService.update(event.params.id, { title: afterValue });
  },
);

/**
 * Indexing for post update for content
 *
 * TODO need to review this scenario:
 * There can be an instance, upon creation of post,
 * we only have title and content without urls in RTDB.
 * If that happens, then suddenly, user attached a url,
 * It will be considered as value created for urls and
 * we don't have the update for that yet.
 */
export const typesensePostUpdateContentIndexing = onValueUpdated(
  "/posts/{category}/{id}/content",
  (event) => {
    const afterValue = event.data.after.val();
    console.log("A post's `content` is updated in RTDB", event.params, afterValue);
    return TypesenseService.update(event.params.id, { content: afterValue });
  },
);

/**
 * Indexing for post update for urls
 */
export const typesensePostUpdateUrlsIndexing = onValueUpdated(
  "/posts/{category}/{id}/urls",
  (event) => {
    // after value will never be null because this is onValueUpdated
    // if it's deleted, onValueDeleted is called instead.
    // there can also be a case when urls becomes empty []
    const afterValue = event.data.after.val() as Array<string>;
    // const firstUrl = afterValue?.[0];
    console.log("A post's `urls` is updated in RTDB", event.params, afterValue);
    // TODO
    // return TypesenseService.update(event.params.id, { url: afterValue });
  },
);

/**
 * Indexing for post update for deleted
 */
export const typesensePostUpdateDeleteIndexing = onValueWritten(
  "/posts/{category}/{id}/deleted",
  (event) => {
    const data = event.data.after.val() as boolean;
    if (data == true) {
      console.log("A post's `deleted` is updated as true in RTDB: ", event.params, data);
      return TypesenseService.delete(event.params.id);
    } else {
      console.log("A post's `deleted` is updated in RTDB: ", event.params, data);
      // deleted in typesense will have no meaning anyway. (Will remove the field from the collection)
      // return TypesenseService.update(event.params.id, { deleted: data });
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
 * TODO Check if we need this
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
    console.log("/posts/{$category}/{$postId}/comments/{$id} - event.params", event.params);
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
