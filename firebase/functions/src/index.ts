
import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging/messaging.service";
import { initializeApp } from "firebase-admin/app";
import { logger } from "firebase-functions/v1";
import { onValueWritten } from "firebase-functions/v2/database";


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


// Listens for new messages added to /messages/:pushId/original and creates an
// uppercase version of the message to /messages/:pushId/uppercase
// for all databases in 'us-central1'
export const typesenseUserIndexing = onValueWritten(
  "/users/{uid}",
  (event) => {
    // Edit data if the document exists.
    if (event.data.before.exists()) {
      // Do something here for updated users
      // This is an update action. When user updates his profile(document), it comes here.
      const data = event.data.after.val();
      return null;
    }
    // Exit when the data is deleted.
    if (!event.data.after.exists()) {
      // Do something here for deleted users
      return null;
    }

    // It comes here when the user document is newly created.
    // Do something when a new user is created.
    // [data] is the user document when it is first created.
    const data = event.data.after.val();


    return null;
  },
);

