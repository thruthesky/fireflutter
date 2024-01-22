
import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging/messaging.service";
import { initializeApp } from "firebase-admin/app";
import { logger } from "firebase-functions/v1";
import { onValueWritten } from "firebase-functions/v2/database";
import { getDatabase } from "firebase-admin/database";
import { TypesenseService } from "./typesense/typesense.service";
import { TypesenseDoc } from "./typesense/typesense.interface";


// / initialize firebase app
initializeApp({
  // Must change Database URL when publishing
  databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
});

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
    const data = event.data.after.val();
    console.log("Created/Updated User in RTDB: ", data);
    return TypesenseService.upsert(data);
  },
);


export const typesensePostIndexing = onValueWritten(
  "/posts/{category}/{id}",
  (event) => {
    const data = event.data.after.val() as TypesenseDoc;
    if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
      // Supposedly !event.data.after.exists() should not happen naturally, unless admins deleted the actual record directly to RTDB.
      // Logic will also go here if the RTDB Doc is updated and deleted = trueZ
      // Do something here for deleted posts
      const data = event.data.before.val();
      const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
      console.log("Deleted Post in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }

    // It comes here when the user document is newly created.
    // Or the document is updated and delete is not == true
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    // const data = event.data.after.val() as TypesenseDoc;

    const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
    console.log("Created Post in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);

export const typesenseCommentIndexing = onValueWritten(
  "/posts/{category}/{postId}/comments/{id}",
  (event) => {
    if (!event.data.after.exists()) {
      // Supposedly this should not happen naturally, unless admins deleted the actual record directly to RTDB.
      // Do something here for deleted Comments
      const data = event.data.before.val() as TypesenseDoc;
      const postData = { ...data, id: event.params.id, category: event.params.category, postId: event.params.postId } as TypesenseDoc;
      console.log("Deleted Comment in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }
    // Edit data if the document exists.
    if (event.data.before.exists()) {
      // Do something here for updated Comment
      // This is an update action. When user updates his profile(document), it comes here.
      const data = event.data.after.val() as TypesenseDoc;

      // Check if the post is deleted
      console.log("Checking if deleted:" + data.deleted);
      const postData = { ...data, id: event.params.id, category: event.params.category, postId: event.params.postId } as TypesenseDoc;
      if (data.deleted == true) {
        // means the data has been tagged as deleted.
        console.log("Updated Comment as deleted in RTDB: ", postData);
        return TypesenseService.delete(event.params.id);
      }
      console.log("Updated Comment in RTDB: ", postData);
      return TypesenseService.upsert(postData);
    }
    // It comes here when the user document is newly created.
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    const data = event.data.after.val() as TypesenseDoc;
    const postData = { ...data, id: event.params.id, category: event.params.category, postId: event.params.postId } as TypesenseDoc;
    console.log("Created Comment in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);
