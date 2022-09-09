import * as admin from "firebase-admin";
import { CallableContext } from "firebase-functions/v1/https";
import { MessagePayload, SendMessage } from "../interfaces/messaging.interface";
import { invalidArgument } from "../utils/library";
import { Ref } from "../utils/ref";
import { Utils } from "../utils/utils";

export class Messaging {
  static async sendMessage(data: any, context: CallableContext): Promise<any> {
    console.log(data);
    if (data.uids) {
      const tokens = await this.getTokensFromUids(data.uids);
      return this.sendMessageToTokens(tokens, data, context);
    } else if (data.tokens) {
      return this.sendMessageToTokens(data.tokens.split(","), data, context);
    } else if (data.topic) {
      return this.sendMessageToTopic(data, context);
    } else {
      throw invalidArgument("One of uids, tokens, topic must be present");
    }
  }

  static async sendMessageToTopic(data: any, context: CallableContext) {
    console.log(data, context);
  }

  /**
   * Send push notifications with the tokens and returns the result.
   * 
   * @param tokens array of tokens.
   * @param data data to send push notification.
   * @param context Cloud Functions Callable context
   */
  static async sendMessageToTokens(
    tokens: string[],
    data: any,
    context: CallableContext
  ): Promise<{ success: number; error: number }> {
    // console.log("check user auth with context", context);
    const payload = this.completePayload(data);
    if (tokens.length == 0) return { success: 0, error: 0 };

    // sendMulticast() 는 오직 500 개 까지만 지원. 그래서 500 개 단위로 쪼개서 batch 처리.
    const chunks = Utils.chunk(tokens, 500);

    const multicastPromise = [];
    // 토큰 500개 단위로 푸시 알림 전송하는 Promise 를 배열에 담는다.
    for (const _500_tokens of chunks) {
      const newPayload: admin.messaging.MulticastMessage = Object.assign(
        {},
        { tokens: _500_tokens },
        payload as any
      );
      multicastPromise.push(admin.messaging().sendMulticast(newPayload));
    }


    try {
      // 전체 토큰을 한번에 전송
      const settled = await Promise.allSettled(multicastPromise);
      // 결과는 배열로
      const value = (settled[0] as any).value;
      // 결과는 1차원 배열은 토큰의 500개 chunks 단위.
      // 2차원 배열은 각 토큰을 성공/실패 결과
      const failedTokens = [];
      for (const ci in settled) {
        for (const idx in value.responses) {
          const i = parseInt(idx);
          const res = value.responses[i];
          if (res.success == false ) {
            // Delete tokens that failed.
            // If res.success == false, then the token failed, anyway.
            // But check if the error message to be sure that the token is not being used anymore.
            if (this.isInvalidTokenErrorCode(res.error.code)) {
              failedTokens.push(chunks[ci][i]);
            }
          }
        }
      }

      // Batch delte of failed tokens
      await this.removeTokens(failedTokens);

      // 결과 리턴
      return { success: value.successCount, error: value.failureCount };
    } catch (e) {
      console.log("---> caught on sendMessageToTokens() await Promise.all()", e);
      throw e;
    }
  }

  /**
   * Removes the tokens from /users/<uid>/fcm_tokens/<tokenDocId>
   * 
   * @param tokens tokens to remove
   * 
   * Use this method to remove tokens that failed to be sent.
   * 
   * Test, tests/messaging/remove-tokens.spec.ts
   */
  static async removeTokens(tokens: string[]) {
    const promises: Promise<any>[] = [];
    for( const token of tokens) {
      promises.push(
        // Get the document of the token
        Ref.db.collectionGroup('fcm_tokens').where('fcm_token', '==', token).get().then( async (snapshot) => {
          for(const doc of snapshot.docs) {
            await doc.ref.delete();
          }
          //  docs.forEach(async (doc) => {
          //   // and delete
          //   await doc.ref.delete();
          // });
        })
      );
    }
    await Promise.all(promises);
  }

  static isInvalidTokenErrorCode(code: string) {
    if (
      code === "messaging/invalid-registration-token" ||
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-argument"
    ) {
      return true;
    }
    return false;
  }

  /**
   * Returns tokens of multiple users.
   *
   * @param uids array of user uid
   * @return array of tokens
   */
  static async getTokensFromUids(uids: string): Promise<string[]> {
    if (!uids) return [];
    const promises: Promise<string[]>[] = [];
    uids.split(",").forEach((uid) => promises.push(this.getTokens(uid)));
    return (await Promise.all(promises)).flat();
  }

  /**
   * Returns tokens of a user.
   *
   * @param uid user uid
   * @return array of tokens
   */
  static async getTokens(uid: string): Promise<string[]> {
    if (!uid) return [];
    const snapshot = await Ref.tokenCol(uid).get();
    if (snapshot.empty) {
      return [];
    }

    return snapshot.docs.map((doc) => doc.id);
  }

  /**
   * Returns complete payload from the query data from client.
   *
   * @param query query data that has payload information
   * @returns an object of payload
   */
  static completePayload(query: SendMessage) {
    // query = this.checkQueryPayload(query);
    if (!query.title) throw invalidArgument("title-is-empty");
    if (!query.body) throw invalidArgument("body-is-empty");
    const res: MessagePayload = {
      data: {
        id: query.id ?? "",
        type: query.type ?? "",
        senderUid: query.senderUid ?? query.uid ?? "",
        badge: query.badge ?? "",
      },
      notification: {
        title: query.title ?? "",
        body: query.body ?? "",
      },
      webpush: {
        notification: {
          title: query.title ?? "",
          body: query.body ?? "",
          icon: query.icon ?? "",
          click_action: query.clickAction ?? "/",
        },
        fcm_options: {
          link: query.clickAction ?? "/",
        },
      },
      android: {
        notification: {
          channel_id: "PUSH_NOTIFICATION",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          sound: "default_sound.wav",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default_sound.wav",
          },
        },
      },
    };

    if (res.notification.title != "" && res.notification.title.length > 64) {
      res.notification.title = res.notification.title.substring(0, 64);
    }

    if (res.notification.body != "") {
      res.notification.body = Utils.removeHtmlTags(res.notification.body) ?? "";
      res.notification.body = Utils.decodeHTMLEntities(res.notification.body) ?? "";
      if (res.notification.body.length > 255) {
        res.notification.body = res.notification.body.substring(0, 255);
      }
    }

    if (query.badge != null) {
      res.apns.payload.aps["badge"] = parseInt(query.badge);
    }

    return res;
  }
}
