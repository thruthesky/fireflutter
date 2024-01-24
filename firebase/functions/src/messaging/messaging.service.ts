import { getMessaging } from "firebase-admin/messaging";
import { getDatabase } from "firebase-admin/database";
import { MessageNotification, MessageRequest } from "./messaging.interface";

/**
 * MessagingService
 *
 *
 */
export class MessagingService {
  /**
         * Send messages
         *
         * @param {MessageRequest} params - The parameters for sending messages.
         * params.tokens - The list of tokens to send the message to.
         * params.title - The title of the message.
         * params.body - The body of the message.
         * params.image - The image of the message.
         * params.data - The extra data of the message.
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
  static async sendNotificationToTokens(params: MessageRequest): Promise<{ [token: string]: string; }> {
    const promises = [];

    if (typeof params.tokens != "object") {
      throw new Error("tokens must be an array of string");
    }
    if (params.tokens.length == 0) {
      throw new Error("tokens must not be empty");
    }
    if (!params.title) {
      throw new Error("title must not be empty");
    }
    if (!params.body) {
      throw new Error("body must not be empty");
    }


    // remove empty tokens
    const tokens = params.tokens.filter((token) => !!token);


    // image is optional
    const notification: MessageNotification = { title: params.title, body: params.body };
    if (params.image) {
      notification["image"] = params.image;
    }

    // send the notification message to the list of tokens
    for (const token of tokens) {
      const message = {
        notification: notification,
        data: params.data,
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

  /**
   * Send message to users
   *
   * 1. This gets the user tokens from '/user-fcm-tokens/{uid}'.
   * 2. Then it chunks the tokens into 500 tokens per chunk.
   * 3. Then delete the tokens that are not valid.
   *
   * @param {Array<string>} uids - The list of user uids to send the message to.
   */
  static async sendNotificationToUids(
    uids: Array<string>,
    title: string,
    body: string,
    image?: string,
    data?: { [key: string]: string },
  ) {
    const tokens = await this.getTokensOfUsers(uids);
    return this.sendNotificationToTokens({ tokens, title, body, image, data });
  }

  /**
   * Returns the list of tokens under '/user-fcm-tokens/{uid}'.
   *
   * @param uids uids of users
   */
  static async getTokensOfUsers(uids: Array<string>): Promise<Array<string>> {
    const promises = [];
    const tokens: string[] = [];

    if (uids.length == 0) return tokens;

    const db = getDatabase();
    for (const uid of uids) {
      promises.push(db.ref("/user-fcm-tokens/${uid}").orderByChild("uid").equalTo(uid).get());
    }
    const res = await Promise.allSettled(promises);

    console.log(res);

    for (const r of res) {
      if (r.status == "fulfilled") {
        tokens.push(...Object.keys(r.value.val()));
      }
    }
    return tokens;
  }
}
