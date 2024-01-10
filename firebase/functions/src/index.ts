
import {onRequest} from "firebase-functions/v2/https";
import {MessagingService} from "./messaging/messaging.service";
import {initializeApp} from "firebase-admin/app";
import {logger} from "firebase-functions/v1";


// / initialize firebase app
initializeApp();

/**
 * sending messages to tokens
 */
export const sendPushNotifications = onRequest(async (request, response) => {
  logger.info("request.query of sendPushNotifications", request.body);
  const requestBody = request.body;
  const {tokens, title, body, data, image } =  requestBody;
  response.send(
    await MessagingService.sendNotificationToTokens(
      tokens,
      title,
      body,
      data,
      image,
    )
  );
});
