
import {getMessaging} from "firebase-admin/messaging";


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

    // / remove empty tokens from tokens and save it to newTokens
    const newTokens = Array.isArray(tokens) ? tokens.filter((token) => !!token): [];

    for (const token of newTokens) {
      const message = {
        notification: {title, body},
        data: data,
        token: token,
      };
      console.log("message", message);
      promises.push(getMessaging().send(message));
    }

    const res = await Promise.allSettled(promises);

    if (res.length != newTokens.length) {
      console.log("res", res);
      console.log("tokens", tokens);
      console.log("newTokens", newTokens);
      throw new Error("The number of tokens and the number of responses are not equal");
    }

    const newResponses: { [token: string]: string; } = {};

    for (let i = 0; i < res.length; i++) {
      const status: string = res[i].status;
      if (status == "fulfilled") {
        continue;
      }
      const reason = (res[i] as PromiseRejectedResult).reason;
      newResponses[newTokens[i]] = reason["errorInfo"]["code"];
    }
    return newResponses;
  }
}
