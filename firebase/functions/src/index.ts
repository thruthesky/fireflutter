
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { MessagingService } from "./messaging/messaging.service";
import { initializeApp } from "firebase-admin/app";


/// initialize firebase app
initializeApp();

/**
 * sending messages to tokens
 */
export const sendPushNotifications = onRequest(async (request, response) => {
  logger.info("Hello logs!", { structuredData: true });
  response.send(
    response.send(
      await MessagingService.sendNotificationToTokens(
        request.query["tokens"] as string[],
        request.query['title'] as string,
        request.query['body'] as string,
      )
    )
  );
});

