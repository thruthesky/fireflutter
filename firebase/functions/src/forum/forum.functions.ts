
import { onValueCreated, onValueWritten } from "firebase-functions/v2/database";
import { PostService } from "./post.service";
import { Config } from "../config";
import { PostCreateEvent } from "./forum.interface";
import { PostCreateEventMessage } from "../messaging/messaging.interface";
import { MessagingService } from "../messaging/messaging.service";
import { isCreate, isDelete, isUpdate } from "../library";

/**
 * managePostsSummary
 *
 * function will be triggered upon create, update or delete.
 */
export const managePostsSummary = onValueWritten(
    `${Config.posts}/{category}/{postId}`,
    async (event) => {
        if (isCreate(event) || isUpdate(event)) {
            await PostService.setSummary(event.data.after.val(), event.params.category, event.params.postId);
        } else if (isDelete(event)) {
            await PostService.deleteSummary(event.params.category, event.params.postId);
        }

        // if (!event.data.after.exists()) {
        //     // Data deleted
        //     const db = getDatabase();
        //     db.ref(`${Config.postSummaries}/${event.params.category}/${event.params.postId}`).remove();
        //     db.ref(`${Config.postAllSummaries}/${event.params.postId}`).remove();
        // }
        // // Data created/updated
        // return PostService.setSummary(event.data.after.val(), event.params.category, event.params.postId);
    },
);

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

        const post: PostCreateEventMessage = {
            id: event.params.id,
            category: event.params.category,
            title: data.title ?? "",
            body: data.content ?? "",
            uid: data.uid,
            image: data.urls?.[0] ?? "",
        };

        await MessagingService.sendMessagesToCategorySubscribers(post);
    });
