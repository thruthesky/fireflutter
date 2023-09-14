import { QueryDocumentSnapshot } from "firebase-admin/firestore";
import { FirestoreEvent, onDocumentCreated } from "firebase-functions/v2/firestore";

exports.messagingOnPostCreate = onDocumentCreated("chats/{chatId}/messages/{messageId}",
    async (event: FirestoreEvent<QueryDocumentSnapshot | undefined, { chatId: string; messageId: string; }>): Promise<void> => {
        if (event === void 0) return undefined;
        console.log(event.params.chatId);



        return undefined;
    });