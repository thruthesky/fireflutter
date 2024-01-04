
import { getMessaging } from "firebase-admin/messaging";

/**
 * MessagingService
 *
 *
 */
export class MessagingService {
    /**
             * Send messages
             *
             * @param {Array<string>} tokens array of tokens
             * @param {string} title message title
             * @param {string} body message body
             */
    static async sendNotificationToTokens(
        tokens: string[],
        title: string,
        body: string
    ) {


        const promises = [];

        for (const token of tokens) {

            const message = {
                notification: { title, body },
                data: {
                    score: '850',
                    time: '2:45'
                },
                token: token,
            };

            console.log('message', message);
            promises.push(getMessaging().send(message));
        }


        return Promise.allSettled(promises);
    }
}
