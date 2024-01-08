
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
         * @param {any} data message data
         *
         *
         * It returns the error results of push notification in a map like
         * below. And it only returns the tokens that has error results.
         * The tokens that succeed (without error) will not be returned.
         *
         * ```
         * {
         *   'fVWDxKs1kEzx...Lq2Vs': '',
         *   'wrong-token': 'messaging/invalid-argument',
         * }
         * ```
         *
         * If there is no error with the token, the value will be empty
         * string. Otherwise, there will be a error message.
         */
  static async sendNotificationToTokens(
    tokens: string[],
    title: string,
    body: string,
    data: { [key: string]: string }
  ) {
    const promises = [];

    if (typeof tokens != "object") {
      throw new Error("tokens must be an array of string");
    }

    // remove empty tokens
    tokens = tokens.filter((token) => !!token);

    // send the notification message to the list of tokens
    for (const token of tokens) {
      const message = {
        notification: { title, body },
        data: data,
        token: token,
      };
      promises.push(getMessaging().send(message));
    }

    const res = await Promise.allSettled(promises);


    const responses: { [token: string]: string; } = {};

    for (let i = 0; i < res.length; i++) {
      const status: string = res[i].status;
      if (status == "fulfilled") {
        continue;
      }

      const reason = (res[i] as PromiseRejectedResult).reason;
      responses[tokens[i]] = reason["errorInfo"]["code"];
    }
    return responses;
  }
}
