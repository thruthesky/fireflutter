import { getMessaging } from "firebase-admin/messaging";
import { getDatabase } from "firebase-admin/database";
import { MessageNotification, MessageRequest } from "./messaging.interface";
import { chunk } from "../library";

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
    console.log("tokens", tokens);

  }

  /**
   * Returns the list of tokens under '/user-fcm-tokens/{uid}'.
   *
   * @param uids uids of users
   * @param chunkSize chunk size - default 500. sendAll() 로 한번에 보낼 수 있는 최대 메세지 수는 500 개 이다.
   * chunk 가 500 이고, 총 토큰의 수가 501 이면, 첫번째 배열에 500개의 토큰 두번째 배열에 1개의 토큰이 들어간다.
   * 
   * @returns Array<Array<string>> - Array of tokens. Each array contains 500 tokens.
   * 리턴 값은 2차원 배열이다. 각 배열은 최대 [chunkSize] 개의 토큰을 담고 있다.
   */
  static async getTokensOfUsers(uids: Array<string>, chunkSize = 500): Promise<Array<Array<string>>> {
    const promises = [];

    if (uids.length == 0) return [];

    const db = getDatabase();

    // uid 사용자 별 모든 토큰을 가져온다.
    for (const uid of uids) {
      promises.push(db.ref("/user-fcm-tokens/${uid}").orderByChild("uid").equalTo(uid).get());
    }
    const settled = await Promise.allSettled(promises);


    // 토큰을 배열에 담는다.

    const tokens: Array<string> = [];
    for (const res of settled) {
      if (res.status == "fulfilled") {
        res.value.forEach((token) => {
          tokens.push(token.key!);
        });
      }
    }

    return chunk(tokens, chunkSize);

  }
}
