
import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging/messaging.service";
import { initializeApp } from "firebase-admin/app";
import { logger } from "firebase-functions/v1";


// / initialize firebase app
initializeApp();

/**
 * sending messages to tokens
 */
export const sendPushNotifications = onRequest(async (request, response) => {
  logger.info("request.query of sendPushNotifications", request.query);
  response.send(
    await MessagingService.sendNotificationToTokens(
      request.query["tokens"] as string[],
      request.query["title"] as string,
      request.query["body"] as string,
      request.query["data"] as { [key: string]: string }
    )
  );
});
