
import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging/messaging.service";
import { initializeApp } from "firebase-admin/app";
import { logger } from "firebase-functions/v1";
import { onValueCreated, onValueUpdated, onValueWritten } from "firebase-functions/v2/database";
import { getDatabase } from "firebase-admin/database";
import { TypesenseService } from "./typesense/typesense.service";
import { TypesenseDoc } from "./typesense/typesense.interface";


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
    const data = event.data.after.val();
    console.log("Created/Updated User in RTDB: ", data);
    return TypesenseService.upsert(data);
  },
);


/**
 * Indexing for Posts and Comments
 */
export const typesensePostIndexing = onValueCreated(
  "/posts/{category}/{id}/*",
  (event) => {
    console.log(`event.params`, event.params);
    const data = event.data.after.val() as TypesenseDoc;
    if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
      // Supposedly !event.data.after.exists() should not happen naturally, unless admins deleted the actual record directly to RTDB.
      // Logic will also go here if the RTDB Doc is updated and deleted = true
      // Do something here for deleted posts
      const data = event.data.before.val() as TypesenseDoc;
      const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
      console.log("Deleted Post in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }

    // It comes here when the user document is newly created.
    // Or the document is updated and delete is not == true
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
    console.log("Created/Updated Post in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);

export const typesensePostIndexing = onValueUpdated(
  "/posts/{category}/{id}/title",
  (event) => {
    console.log(`event.params`, event.params);
    const data = event.data.after.val() as TypesenseDoc;
    if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
      // Supposedly !event.data.after.exists() should not happen naturally, unless admins deleted the actual record directly to RTDB.
      // Logic will also go here if the RTDB Doc is updated and deleted = true
      // Do something here for deleted posts
      const data = event.data.before.val() as TypesenseDoc;
      const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
      console.log("Deleted Post in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }

    // It comes here when the user document is newly created.
    // Or the document is updated and delete is not == true
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
    console.log("Created/Updated Post in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);
export const typesensePostIndexing = onValueUpdated(
  "/posts/{category}/{id}/content",
  (event) => {
    console.log(`event.params`, event.params);
    const data = event.data.after.val() as TypesenseDoc;
    if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
      // Supposedly !event.data.after.exists() should not happen naturally, unless admins deleted the actual record directly to RTDB.
      // Logic will also go here if the RTDB Doc is updated and deleted = true
      // Do something here for deleted posts
      const data = event.data.before.val() as TypesenseDoc;
      const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
      console.log("Deleted Post in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }

    // It comes here when the user document is newly created.
    // Or the document is updated and delete is not == true
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
    console.log("Created/Updated Post in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);

export const typesensePostIndexing = onValueUpdated(
  "/posts/{category}/{id}/urls",
  (event) => {
    console.log(`event.params`, event.params);
    const data = event.data.after.val() as TypesenseDoc;
    if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
      // Supposedly !event.data.after.exists() should not happen naturally, unless admins deleted the actual record directly to RTDB.
      // Logic will also go here if the RTDB Doc is updated and deleted = true
      // Do something here for deleted posts
      const data = event.data.before.val() as TypesenseDoc;
      const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
      console.log("Deleted Post in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }

    // It comes here when the user document is newly created.
    // Or the document is updated and delete is not == true
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
    console.log("Created/Updated Post in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);
export const typesensePostIndexing = onValueUpdated(
  "/posts/{category}/{id}/deleted",
  (event) => {
    console.log(`event.params`, event.params);
    const data = event.data.after.val() as TypesenseDoc;
    if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
      // Supposedly !event.data.after.exists() should not happen naturally, unless admins deleted the actual record directly to RTDB.
      // Logic will also go here if the RTDB Doc is updated and deleted = true
      // Do something here for deleted posts
      const data = event.data.before.val() as TypesenseDoc;
      const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
      console.log("Deleted Post in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }

    // It comes here when the user document is newly created.
    // Or the document is updated and delete is not == true
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    const postData = { ...data, id: event.params.id, category: event.params.category } as TypesenseDoc;
    console.log("Created/Updated Post in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);


export const typesenseCommentIndexing = onValueWritten(
  "/posts/{category}/{postId}/comments/{id}",
  (event) => {
    console.log(`/posts/{$category}/{$postId}/comments/{$id} - event.params`, event.params);
    const data = event.data.after.val() as TypesenseDoc;
    if (!event.data.after.exists() || (event.data.before.exists() && data.deleted == true)) {
      // Supposedly !event.data.after.exists() should not happen naturally, unless admins deleted the actual record directly to RTDB.
      // Logic will also go here if the RTDB Doc is updated and deleted = true
      // Do something here for deleted Comments
      const data = event.data.before.val() as TypesenseDoc;
      const postData = { ...data, id: event.params.id, category: event.params.category, postId: event.params.postId } as TypesenseDoc;
      console.log("Deleted Comment in RTDB: ", postData);
      return TypesenseService.delete(event.params.id);
    }

    // It comes here when the user document is newly created.
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    // const data = event.data.after.val() as TypesenseDoc;
    const postData = { ...data, id: event.params.id, category: event.params.category, postId: event.params.postId } as TypesenseDoc;
    console.log("Created/Updated Comment in RTDB: ", postData);
    return TypesenseService.upsert(postData);
  },
);
