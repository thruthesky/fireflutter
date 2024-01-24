

import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging.service";
import { logger } from "firebase-functions/v1";
import { onValueCreated } from "firebase-functions/v2/database";
import { MessageNotification } from "./messaging.interface";


/**
 * Sending messages to tokens
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


/**
 * Sending messages to forum category subscribers
 */

export const sendPushNotificationsToForumCategorySubscribers = onValueCreated(
    "/posts/{category}/{id}",
    async (event) => {
        // const data = event.data.val();
        // const { category, id } = event.params;
        // const { title, content } = data;

        // const tokens = await MessagingService.getTokensForForumCategorySubscribers(category);
        // const message = {
        //     title: title,
        //     body: content,
        //     data: {
        //         category: category,
        //         postId: id,
        //     },
        // };

        // const res = await MessagingService.sendNotificationToTokens({
        //     tokens,
        //     title,
        //     body: content,
        // });
        // logger.info("sendPushNotificationsToForumCategorySubscribers", res);
        // response.send(res);
    });