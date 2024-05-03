
import { onValueCreated, onValueWritten } from "firebase-functions/v2/database";
import { PostService } from "./post.service";
import { Config } from "../config";
import { PostCreateEvent } from "./forum.interface";
import { CommentCreateEventMessage, PostCreateEventMessage } from "../messaging/messaging.interface";
import { MessagingService } from "../messaging/messaging.service";
import { isCreate, isDelete, isUpdate, strcut } from "../library";
import { CommentCreateEvent } from "../mirror/firestore.interface";

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
    },
);

/**
 * 게시판(카테고리) 구독자들에게 메시지 전송
 *
 * 새 글이 작성되면 메시지를 전송한다.
 */
export const sendMessagesToCategorySubscribers = onValueCreated(
    `${Config.posts}/{category}/{id}`,
    async (event) => {
        // Grab the current value of what was written to the Realtime Database.
        const data = event.data.val() as PostCreateEvent;

        const post: PostCreateEventMessage = {
            id: event.params.id,
            category: event.params.category,
            title: strcut(data.title ?? "", 64),
            body: strcut(data.content ?? "", 100),
            uid: data.uid,
            image: data.urls?.[0] ?? "",
        };

        return await MessagingService.sendMessagesToCategorySubscribers(post);
    });


/**
 * 새 코멘트가 작성되면 푸시 알림(메시지)를 전송한다.
 *
 * @return {Promise<string>} 푸시 알림 전송 후, 그 기록으로 생성된 키를 리턴한다. 이 키는 테스트 할 때 사용 할 수 있다.
 */
export const sendMessagesToCommentSubscribers = onValueCreated(
    "/comments/{postId}/{commentId}",
    async (event) => {
        // Grab the current value of what was written to the Realtime Database.
        const data = event.data.val() as CommentCreateEvent;

        const comment: CommentCreateEventMessage = {
            id: event.params.commentId,
            category: data.category!,
            postId: event.params.postId,
            parentId: data.parentId ?? "",
            title: "New comment ...",
            body: strcut(data.content ?? "", 100),
            uid: data.uid!,
            image: data.urls?.[0] ?? "",
        };

        console.log("sendMessagesToCommentSubscribers: ", comment);
        return await MessagingService.sendMessagesToNewCommentSubscribers(comment);
    });

