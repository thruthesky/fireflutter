

import { onRequest } from "firebase-functions/v2/https";
import { MessagingService } from "./messaging.service";
import { logger } from "firebase-functions/v1";
// import { onValueCreated } from "firebase-functions/v2/database";
import { PostCreateEvent } from "../forum/forum.interface";
import { PostCreateMessage } from "./messaging.interface";
import { ChatCreateEvent } from "../chat/chat.interface";


// import * as functions from "firebase-functions";
import { onValueCreated } from "firebase-functions/v2/database";
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


/**
 * 게시판(카테고리) 구독자들에게 메시지 전송
 *
 * 새 글이 작성되면 메시지를 전송한다.
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

        await MessagingService.sendMessagesToCategorySubscribers(post);
    });

/**
 * 새로운 채팅 메시지가 작성되면(전송되면) 해당 채팅방 사용자에게 메시지를 전송한다.
 * 
 */
export const sendMessagesToChatRoomSubscribers = onValueCreated(
    "/chats/{room}/{id}",
    async (event) => {
        // Grab the current value of what was written to the Realtime Database.
        const data: ChatCreateEvent = {
            ...event.data.val(),
            id: event.params.id,
            room: event.params.room,
        }

        await MessagingService.sendMessagesToChatRoomSubscribers(data);
    });
