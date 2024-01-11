
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
  logger.info("request.query of sendPushNotifications", request.body);
  try {
    const res = await MessagingService.sendNotificationToTokens(request.body);
    response.send(res);
  } catch (e) {
    logger.error(e);
   if(e instanceof Error){
    response.send({error: e.message})
   }
  }
});
