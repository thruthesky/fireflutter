import * as admin from "firebase-admin";
import { CallableContext } from "firebase-functions/v1/https";
import { MessagePayload, SendMessage } from "../interfaces/messaging.interface";
import { invalidArgument } from "../utils/library";
import { Ref } from "../utils/ref";
import { Utils } from "../utils/utils";

export class Messaging {
  static async sendMessage(data: any, context: CallableContext): Promise<any> {
    if (data.uids || data.tokens) {
      return this.sendMessageToTokens(data, context);
    } else {
      return this.sendMessageToTopic(data, context);
    }
  }

  private static async sendMessageToTopic(data: any, context: CallableContext) {}

  private static async sendMessageToTokens(data: any, context: CallableContext) {
    const payload = this.preMessagePayload(data);

    let tokens;
    if (data.uids) {
      tokens = await this.getTokensFromUids(data.uids);
    } else if (data.tokens) {
      tokens = data.tokens.split(",");
    }
    if (tokens.length == 0) return { success: 0, error: 0 };

    // / sendMulticast supports 500 token per batch only.
    const chunks = Utils.chunk(tokens, 500);

    const sendToDevicePromise = [];
    for (const c of chunks) {
      // Send notifications to all tokens.
      const newPayload: admin.messaging.MulticastMessage = Object.assign(
        { tokens: c },
        payload as any
      );
      sendToDevicePromise.push(admin.messaging().sendMulticast(newPayload));
    }
    const sendDevice = await Promise.all(sendToDevicePromise);

    const tokensToRemove: Promise<any>[] = [];
    let successCount = 0;
    let errorCount = 0;
    sendDevice.forEach((res, i) => {
      successCount += res.successCount;
      errorCount += res.failureCount;

      res.responses.forEach((result, index) => {
        const error = result.error;
        if (error) {
          // Cleanup the tokens who are not registered anymore.
          if (this.isInvalidTokenErrorCode(error.code)) {
            tokensToRemove.push(Ref.messageTokens.doc(chunks[i][index]).delete());
          }
        }
      });
    });
    await Promise.all(tokensToRemove);
    return { success: successCount, error: errorCount };
  }

  private static isInvalidTokenErrorCode(code: string) {
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
   * @returns array of tokens
   */
  private static async getTokensFromUids(uids: string) {
    if (!uids) return [];
    const promises: Promise<string[]>[] = [];
    uids.split(",").forEach((uid) => promises.push(this.getTokens(uid)));
    return (await Promise.all(promises)).flat();
  }

  /**
   * Returns tokens of a user.
   *
   * @param uid user uid
   * @returns array of tokens
   */
  private static async getTokens(uid: string): Promise<string[]> {
    if (!uid) return [];
    const snapshot = await Ref.messageTokens.where("uid", "==", uid).get();

    if (snapshot.empty) {
      return [];
    }
    return snapshot.docs.map((doc) => doc.id);

    // console.log("snapshot.exists()", snapshot.exists(), snapshot.val());

    // const val = snapshot.val();
    // return Object.keys(val);
  }

  private static preMessagePayload(query: SendMessage) {
    // query = this.checkQueryPayload(query);
    if (!query.title) throw invalidArgument("Title is empty");
    if (!query.body) throw invalidArgument("Body is empty");
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
