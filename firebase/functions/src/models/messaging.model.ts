import * as admin from "firebase-admin";
import {AdminNotificationOptions, EventName, EventType} from "../utils/event-name";
import {
  FcmToken,
  MessagePayload,
  SendMessage,
  SendMessageResult,
} from "../interfaces/messaging.interface";
import {Ref} from "../utils/ref";
import {Library} from "../utils/library";

import {Comment} from "../models/comment.model";
import {User} from "./user.model";
import {Post} from "./post.model";
import {UserSettingsDocument} from "../interfaces/user.interface";
import {ChatMessageDocument} from "../interfaces/chat.interface";
import {Chat} from "./chat.model";

import {MulticastMessage} from "firebase-admin/lib/messaging/messaging-api";

export class Messaging {
  /**
   * Send push messages
   *
   * For forum category subscription,
   *  'data.action' and 'data.category' has the information.
   *
   *      will follow on next version.
   *
   * @param data information of sending message
   * @return results
   */
  static async sendMessage(data: SendMessage): Promise<SendMessageResult> {
    // console.log('sendMessage::data:: ', data)
    if (data.action) {
      console.log("sendMessage::action");
      return this.sendMessageByAction(data);
    } else if (data.topic) {
      console.log("sendMessage::topics");
      return this.sendMessageToTopic(data.topic, data);
    } else if (data.tokens) {
      console.log("sendMessage::tokens");
      return this.sendMessageToTokens(data.tokens, data);
    } else if (data.uids) {
      console.log("sendMessage::uids", data.uids);
      const tokens = await this.getTokensFromUids(data.uids);
      console.log("sendMessage::tokens", tokens);
      return this.sendMessageToTokens(tokens, data);
    } else {
      throw Error("One of uids, tokens, topic must be present");
    }
  }

  /**
   *
   * @param topic topics like `allUsers`, `webUsers`, `androidUsers`, `iosUsers`
   * @param data information message to send
   * @returns Promise<SendMessageResult>
   *    { messageId: <string> }
   */
  static async sendMessageToTopic(topic: string, data: SendMessage): Promise<SendMessageResult> {
    // Only admin can sent message to topic `allUsers`.
    const payload = this.topicPayload(topic, data);
    try {
      const res = await admin.messaging().send(payload as admin.messaging.TopicMessage);
      return {messageId: res};
    } catch (e) {
      throw Error("Topic send error " + (e as Error).message);
    }
  }

  // / Prepare topic payload
  static topicPayload(topic: string, data: SendMessage): MessagePayload {
    const payload = this.completePayload(data);
    payload.topic = "/topics/" + topic;
    return payload;
  }


  /**
   *
   * @param data
   *  'action' can be one of 'post-create', 'comment-create',
   *  'uid' is the uid of the user
   *  'category' is the category of the post.
   * @returns
   */
  static async sendMessageByAction(data: SendMessage): Promise<SendMessageResult> {
    console.log(`sendMessageByAction(${JSON.stringify(data)})`);

    if (!data.action) {
      console.log("---> no action. throw error.");
      throw Error("No action on data.");
    }

    let uids: string[] = [];

    // commentCreate get post and patch data with category and title.
    if (data.action == EventName.commentCreate && data.postId) {
      const post = await Post.get(data.postId);
      uids.push(post.uid); // post owner
      data.categoryId = post.categoryId;
      data.title = post.deleted == true ? "Deleted post..." : post.title ?? "Comment on post...";
      console.log("comment::post::", JSON.stringify(post));
      console.log("comment::data::", JSON.stringify(data));
    }


    // console.log("action:: ", data.action, "categoryId:: ", data.categoryId);
    // post and comment
    if (data.categoryId) {
      const snap = await Ref.usersSettingsSearch({action: data.action, categoryId: data.categoryId})
        .get();
      console.log("data.categoryId::snap.size::", snap.size);

      // get uids
      if (snap.size != 0) {
        for (const doc of snap.docs) {
          const s = doc.data() as UserSettingsDocument;
          const uid = s.uid;
          if (uid != data.senderUid) uids.push(uid);
        }
      }
      //
    }


    // Get ancestor's uid
    if (data.action == EventName.commentCreate && data.id) {
      const ancestors = await Comment.getAncestorsUid(data.id, data.uid);

      // Remove ancestors who didn't subscribe for new comment.
      const subscribers = await this.getNewCommentNotificationUids(ancestors);

      uids = [...uids, ...subscribers];
    }

    // console.log("action:: ", data.action, "data.roomId:: ", data.roomId, 'data.uids.lenght::', data.uids?.length);
    if (data.action == EventName.chatCreate && data.roomId && data.uids?.length) {
      uids = [...uids, ...data.uids];
      const snap = await Ref.usersSettingsSearch({action: EventName.chatDisabled, roomId: data.roomId})
        .get();
      console.log("EventName.chatCreate::snap.size::", snap.size);

      // get uids of chat disable user
      const pushDisableUid: string[] = [];
      if (snap.size != 0) {
        for (const doc of snap.docs) {
          const s = doc.data() as UserSettingsDocument;
          pushDisableUid.push(s.uid);
        }
        // filter user with chatDisabled
        uids = uids.filter(
          (uid) => !pushDisableUid.includes(uid)
        );
      }
    }

    // remove uid if admin disable the notification new users
    if (data.action == EventName.userCreate) {
      const admins = await User.getAdminsUid();
      uids = [...uids, ...admins];
      const snap = await Ref.usersSettingsSearch({
        action: EventName.userCreate,
        categoryId: AdminNotificationOptions.notifyOnNewUser,
      }).get();

      const pushDisableUid: string[] = [];
      if (snap.size != 0) {
        for (const doc of snap.docs) {
          const s = doc.data() as UserSettingsDocument;
          pushDisableUid.push(s.uid);
        }
        // filter user with Messaging Option Disabled
        uids = uids.filter(
          (uid) => !pushDisableUid.includes(uid)
        );
      }
    }

    // remove uid if admin disable the notification for new reports
    if (data.action == EventName.reportCreate) {
      const admins = await User.getAdminsUid();
      uids = [...uids, ...admins];
      const snap = await Ref.usersSettingsSearch({
        action: EventName.reportCreate,
        categoryId: AdminNotificationOptions.notifyOnNewReport,
      }).get();

      const pushDisableUid: string[] = [];
      if (snap.size != 0) {
        for (const doc of snap.docs) {
          const s = doc.data() as UserSettingsDocument;
          pushDisableUid.push(s.uid);
        }
        // filter user with Messaging Option Disabled
        uids = uids.filter(
          (uid) => !pushDisableUid.includes(uid)
        );
      }
    }

    // / remove duplicates
    uids = [...new Set(uids)];

    //
    console.log("uids::", uids);
    const tokens = await this.getTokensFromUids(uids.join(","));

    return this.sendMessageToTokens(tokens, data);
  }

  /**
   * Send push notifications with the tokens and returns the result.
   *
   * @param tokens array of tokens.
   * @param data data to send push notification.
   */
  static async sendMessageToTokens(
    tokens: string[] | string,
    data: SendMessage
  ): Promise<SendMessageResult> {
    // console.log(`sendMessageToTokens() token.length: ${tokens.length}`);
    // make it list of string if it is string
    const _tokens: string[] = typeof data.tokens == "string" ? data.tokens.split(",") : tokens as string[];

    if (tokens.length == 0) {
      console.log("sendMessageToTokens() no tokens. so, just return results.");
      return {success: 0, error: 0};
    }

    // add login user uid
    // data.senderUid = data.uid; // already inside the completePayload

    const payload = this.completePayload(data);

    // sendMulticast() supports 500 tokens at a time. Chunk and send by batches.
    const chunks = Library.chunk(_tokens, 500);

    // console.log(`sendMessageToTokens() chunks.length: ${chunks.length}`);

    const multicastPromise = [];
    // Save [sendMulticast()] into a promise.
    for (const _500Tokens of chunks) {
      const newPayload: MulticastMessage = Object.assign(
        {},
        {tokens: _500Tokens},
        payload
      );
      multicastPromise.push(admin.messaging().sendEachForMulticast(newPayload));
    }

    const failedTokens = [];
    let successCount = 0;
    let failureCount = 0;
    try {
      // Send all the push messages in the promise with [Promise.allSettle].
      const settled = await Promise.allSettled(multicastPromise);
      // Returns are in array
      for (
        let settledIndex = 0;
        settledIndex < settled.length;
        settledIndex++
      ) {
        console.log(`settled[${settledIndex}]`, settled[settledIndex]);
        /* eslint-disable-next-line  @typescript-eslint/no-explicit-any */
        const value = (settled[settledIndex] as any).value;
        successCount += value.successCount;
        failureCount += value.failureCount;

        for (let i = 0; i < value.responses.length; i++) {
          // const i = parseInt(idx);
          const res = value.responses[i];
          if (res.success == false) {
            // Delete tokens that failed.
            // If res.success == false, then the token failed, anyway.
            // But check if the error message
            // to be sure that the token is not being used anymore.
            if (this.isInvalidTokenErrorCode(res.error.code)) {
              failedTokens.push(chunks[settledIndex][i]);
            }
          }
        }
      }

      // Batch delte of failed tokens
      await this.removeTokens(failedTokens);

      // 결과 리턴
      const results = {success: successCount, error: failureCount};
      // console.log(`sendMessageToTokens() results: ${JSON.stringify(results)}`);
      return results;
    } catch (e) {
      console.log(
        "---> caught on sendMessageToTokens() await Promise.allSettled()",
        e
      );
      throw e;
    }
  }

  /**
   * Remove tokens from user token documents
   *  `/users/<uid>/fcm_tokens/<docId>`
   *
   * @param tokens tokens to remove
   *
   * Use this method to remove tokens that failed to be sent.
   *
   * Test, tests/messaging/remove-tokens.spec.ts
   */
  static async removeTokens(tokens: string[]) {
    /* eslint-disable-next-line  @typescript-eslint/no-explicit-any */
    const promises: Promise<any>[] = [];
    for (const token of tokens) {
      promises.push(
        // Get the document of the token
        Ref.db
          .collectionGroup("fcm_tokens")
          .where("fcm_token", "==", token)
          .get()
          .then(async (snapshot) => {
            for (const doc of snapshot.docs) {
              await doc.ref.delete();
            }
          })
      );
    }
    await Promise.all(promises);
  }

  /**
   * Return true if the token is invalid.
   *  So it can be removed from database.
   * There are many error codes. see
   * https://firebase.google.com/docs/cloud-messaging/send-message#admin
   */
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
  static async getTokensFromUids(uids: string | string[]): Promise<string[]> {
    if (!uids) return [];
    const promises: Promise<string[]>[] = [];

    const _uids: string[] = typeof uids == "string" ? uids.split(",") : uids as string[];

    _uids.forEach((uid) => promises.push(this.getTokens(uid)));
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

    // return snapshot.docs.map((doc) => doc.id);
    return snapshot.docs.map((doc) => doc.get("fcm_token"));
  }


  /**
   * Returns complete payload from the query data from client.
   *
   * @param query query data that has payload information
   * @return an object of payload
   */
  static completePayload(query: SendMessage): MessagePayload {
    // console.log(`completePayload(${JSON.stringify(query)})`);

    if (!query.title) {
      console.log("completePayload() throws error: title-is-empty.)");
      throw Error("title-is-empty");
    }

    // If body is empty and content has value, then use content as body.
    // This may help on event trigger of `post create` and `comment create`.
    if (!query.body && query.content) {
      query.body = query.content;
    }

    if (!query.body) {
      console.log(
        `completePayload() throws error: body-is-empty: (${JSON.stringify(
          query
        )})`
      );
      throw Error("body-is-empty");
    }

    // if postId exist change the payload id.
    if (query.postId) {
      query.id = query.postId;
    }

    const res: MessagePayload = {
      data: {
        id: query.id ?? "",
        type: query.type ?? "",
        senderUid: query.senderUid ?? "",
        roomId: query.roomId ?? "",
        badge: query.badge ?? "",
        action: query.action ?? "",
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
          sound: "default",
          channel_id: "DEFAULT_CHANNEL",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
          },
        },
      },
    };

    if (res.notification.title != "" && res.notification.title.length > 64) {
      res.notification.title = res.notification.title.substring(0, 64);
    }

    if (res.notification.body != "") {
      res.notification.body =
        Library.removeHtmlTags(res.notification.body) ?? "";
      res.notification.body =
        Library.decodeHTMLEntities(res.notification.body) ?? "";
      if (res.notification.body.length > 255) {
        res.notification.body = res.notification.body.substring(0, 255);
      }
    }

    if (query.badge != null) {
      res.apns.payload.aps.badge = parseInt(query.badge);
    }

    if (query.channelId != null) {
      res.android.notification.channel_id = query.channelId;
    }

    if (query.sound != null) {
      res.apns.payload.aps.sound = query.sound;
      res.android.notification.sound = query.sound;
    }

    // console.log(`--> completePayload() return value: ${JSON.stringify(res)}`);

    return res;
  }

  /**
   * Returns an array of uid of the users
   *  (from the input uids) who has subscribed for new comment.
   * The uids of the users who didn't subscribe
   *  will be removed on the returned array.
   * @param uids array of uid
   * @return array of uid
   */
  static async getNewCommentNotificationUids(
    uids: string[]
  ): Promise<string[]> {
    if (uids.length === 0) return [];
    const promises: Promise<boolean>[] = [];
    for (const uid of uids) {
      promises.push(User.commentNotification(uid));
    }
    const results = await Promise.all(promises);

    const re = [];
    // dont add user who has turn off subscription
    for (let i = 0; i < results.length; i++) {
      if (results[i]) re.push(uids[i]);
    }
    return re;
  }

  /**
   *
   * @param data
   * @returns
   */
  static async sendChatNotificationToOtherUsers(data: ChatMessageDocument): Promise<SendMessageResult | undefined> {
    const user = await User.get(data.uid);

    const messageData: SendMessage = {
      ...data,
      type: EventType.chat,
      action: EventName.chatCreate,
      title: `${user?.display_name ?? user?.name ?? ""} send you a message.`,
      body: data.text,
      uids: await Chat.getOtherUserUidsFromChatMessageDocument(data),
      id: data.roomId,
      senderUid: data.uid,
    };
    return this.sendMessage(messageData);
  }


  /**
   * Save a token under the user's fcm_tokens collection.
   *
   * @param uid uid
   * @param token token
   * @param device_type device type
   * @returns Promise<WriteResult>
   */
  static async saveToken(data: FcmToken): Promise<admin.firestore.WriteResult> {
    return await Ref.tokenDoc(data.uid, data.fcm_token).set(data);
  }
  /**
   * Returns the document document (Not the token as string) under the user's fcm_tokens collection.
   *
   * @param uid uid
   * @param token token
   * @param device_type device type
   * @returns Promise<WriteResult>
   */
  static async getToken(data: FcmToken): Promise<FcmToken> {
    return (await Ref.tokenDoc(data.uid, data.fcm_token).get()).data() as FcmToken;
  }
}
