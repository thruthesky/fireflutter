
import { MessagingService } from "../messaging/messaging.service";

import { ChatCreateEvent } from "../chat/chat.interface";
import { onValueCreated } from "firebase-functions/v2/database";

/**
 * 새로운 채팅 메시지가 작성되면(전송되면) 해당 채팅방 사용자에게 메시지를 전송한다.
 *
 */
export const sendMessagesToChatRoomSubscribers = onValueCreated(
    "/chat-messages/{room}/{id}",
    async (event) => {
        // Grab the current value of what was written to the Realtime Database.
        const data: ChatCreateEvent = {
            ...event.data.val(),
            id: event.params.id,
            roomId: event.params.room,
        };

        await MessagingService.sendMessagesToChatRoomSubscribers(data);
    });
