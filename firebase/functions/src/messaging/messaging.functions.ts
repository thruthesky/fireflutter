

import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging.service";
import { logger } from "firebase-functions/v1";
import { onValueCreated } from "firebase-functions/v2/database";
import { PostCreateEvent } from "../forum/forum.interface";
import { PostCreateMessage } from "./messaging.interface";


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

export const sendMessagesToCategorySubscribers = onValueCreated(
    "/posts/{category}/{id}",
    async (event) => {
        // Grab the current value of what was written to the Realtime Database.
        const data = event.data.val() as PostCreateEvent;

        const post: PostCreateMessage = {
            id: event.params.id,
            category: event.params.category,
            title: data.title ?? "",
            body: data.content ?? "",
            uid: data.uid,
            image: data.urls?.[0] ?? "",
        };


        await MessagingService.sendNotificationToForumCategorySubscribers(post);
    });
