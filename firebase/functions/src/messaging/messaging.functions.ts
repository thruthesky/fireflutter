

import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging.service";
import { logger } from "firebase-functions/v1";
// import { onValueCreated } from "firebase-functions/v2/database";


// import * as functions from "firebase-functions";
// import { Config } from "../config";
// import * as admin from "firebase-admin";


/**
 * 토큰을 입력받아서 메시지를 전송한다.
 */
export const sendPushNotifications = onRequest(async (request, response) => {
    // logger.info("request.query of sendPushNotifications", request.body);
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
