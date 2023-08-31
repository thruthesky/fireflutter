import * as admin from "firebase-admin";
import {EventName, EventType} from "../utils/event-name";
import {
  MessagePayload,
  SendMessage,
  SendMessageToDocument,
} from "../interfaces/messaging.interface";
import {Ref} from "../utils/ref";
import {Library} from "../utils/library";

import {Comment} from "../models/comment.model";
import {User} from "./user.model";
import {Post} from "./post.model";
import {UserSettingsDocument} from "../interfaces/user.interface";
import {ChatMessageDocument} from "../interfaces/chat.interface";
import {Chat} from "./chat.model";

import * as functions from "firebase-functions";
import {MulticastMessage} from "firebase-admin/lib/messaging/messaging-api";

export class Messaging {
  /**
             * Send push messages
             *
             * For forum category subscription,
             *  'data.action' and 'data.category' has the information.
             * For topics like
             *  `allUsers`, `webUsers`, `androidUsers`, `iosUsers`
             *      will follow on next version.
             *
             * @param data information of sending message
             * @return results
             */
  static async sendMessage(data: SendMessage): Promise<any> {
    if (data.topic) {
      // / see TODO in README.md
    } else if (data.tokens) {
      return this.sendMessageToTokens(data.tokens.split(","), data);
    } else if (data.uids) {
      const tokens = await this.getTokensFromUids(data.uids);
      return this.sendMessageToTokens(tokens, data);
    } else if (data.action) {
      return this.sendMessageByAction(data);
    } else {
      throw Error("One of uids, tokens, topic must be present");
    }
  }

  /**
             *
             * @param data
             *  'action' can be one of 'post-create', 'comment-create',
             *  'uid' is the uid of the user
             *  'category' is the category of the post.
             * @returns
             */
  static async sendMessageByAction(data: SendMessage) {
    console.log(`sendMessageByAction(${JSON.stringify(data)})`);

    if (!data.action) {
      console.log("---> no action. throw error.");
      throw Error("No action on data.");
    }

    let uids: string[] = [];

    // commentCreate get post and patch data with category and title.
    if (data.action == EventName.commentCreate) {
      const post = await Post.get(data.postId!);
      uids.push(post.uid); // post owner
      data.categoryId = post.categoryId;
      data.title = post.title;
      // data.postId = post.id; //  already exist on comment
      console.log("comment::post::", JSON.stringify(post));
      console.log("comment::data::", JSON.stringify(data));
    }

    // Get users who subscribed the subscription
    // TODO make this a function.
    const snap = await Ref.db
      .collection("user_settings")
      .where("action", "==", data.action)
      .where("category", "==", data.categoryId)
      .get();

    console.log("snap.size", snap.size);

    // get uids
    if (snap.size != 0) {
      for (const doc of snap.docs) {
        const s = doc.data() as UserSettingsDocument;
        const uid = s.userDocumentReference.id;
        if (uid != data.senderUid) uids.push(uid);
      }
    }
    //

    // Get ancestor's uid
    if (data.action == EventName.commentCreate) {
      const ancestors = await Comment.getAncestorsUid(data.id!, data.uid);

      // Remove ancestors who didn't subscribe for new comment.
      const subscribers = await this.getNewCommentNotificationUids(ancestors);

      uids = [...uids, ...subscribers];
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
    tokens: string[],
    data: any
  ): Promise<{ success: number; error: number }> {
    console.log(`sendMessageToTokens() token.length: ${tokens.length}`);
    if (tokens.length == 0) {
      console.log("sendMessageToTokens() no tokens. so, just return results.");
      return {success: 0, error: 0};
    }

    // add login user uid
    // data.senderUid = data.uid; // already inside the completePayload

    const payload = this.completePayload(data);

    // sendMulticast() supports 500 tokens at a time. Chunk and send by batches.
    const chunks = Library.chunk(tokens, 500);

    console.log(`sendMessageToTokens() chunks.length: ${chunks.length}`);

    const multicastPromise = [];
    // Save [sendMulticast()] into a promise.
    for (const _500Tokens of chunks) {
      const newPayload: admin.messaging.MulticastMessage = Object.assign(
        {},
        {tokens: _500Tokens},
                payload as any
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
      console.log(`sendMessageToTokens() results: ${JSON.stringify(results)}`);
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
    console.log(`completePayload(${JSON.stringify(query)})`);

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
        chatRoomId: query.chatRoomId ?? "",
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
          sound: "default",
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
      res.apns.payload.aps["badge"] = parseInt(query.badge);
    }

    console.log(`--> completePayload() return value: ${JSON.stringify(res)}`);

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
  static async sendChatNotificationToOtherUsers(data: ChatMessageDocument) {
    const user = await User.get(data.senderUserDocumentReference.id);
    const messageData: SendMessage = {
      ...data,
      type: EventType.chat,
      title: `${user?.display_name ?? ""} send you a message.`,
      body: data.text,
      uids: await Chat.getOtherUserUidsFromChatMessageDocument(data),
      chatRoomId: data.chatRoomDocumentReference.id,
      senderUid: data.senderUserDocumentReference.id,
    };
    return this.sendMessage(messageData);
  }

  static async sendPushNotifications(
    snapshot: functions.firestore.QueryDocumentSnapshot
  ) {
    const data = snapshot.data() as SendMessageToDocument;
    const title = data.title || "";
    const body = data.body || "";
    const imageUrl = data.image_url || "";
    const sound = data.sound || "";
    const parameterData = data.parameter_data || "";
    const targetAudience = data.target_audience || "";
    const initialPageName = data.initial_page_name || "";
    const status = data.status || "";

    //
    if (status !== "" && status !== "started") {
      console.log(`Already processed ${snapshot.ref.path}. Skipping...`);
      return;
    }

    if (title === "" || body === "") {
      console.log(`Title: ${title} or Body: ${body} are empty`);
      await snapshot.ref.update({
        status: "failed",
        error: `Title: ${title} or Body: ${body} are empty`,
      });
      return;
    }

    const tokens = new Set();

    // Send message to specific users by `user_refs` option.
    // Note, that we don't use `user_refs` option anymore,
    // but we keep it here for the posibility to enable in the future.

    // Send message to all user
    // Note, we don't send by `batch` while FF deos it.

    // Get tokens of all users.
    const userTokens: admin.firestore
            .QuerySnapshot<admin.firestore.DocumentData> =
            await Ref.tokenCollectionGroup.get();

    userTokens.docs.forEach((token) => {
      const data = token.data();
      const audienceMatches =
                targetAudience === "All" || data.device_type === targetAudience;
      if (audienceMatches || typeof data.fcm_token !== undefined) {
        tokens.add(data.fcm_token);
      }
    });

    const tokensArr = Array.from(tokens);
    const messageBatches = [];
    for (let i = 0; i < tokensArr.length; i += 500) {
      const tokensBatch = tokensArr.slice(
        i,
        Math.min(i + 500, tokensArr.length)
      );
      const messages = {
        notification: {
          title,
          body,
          ...(imageUrl && {imageUrl: imageUrl}),
        },
        data: {
          initialPageName,
          parameterData,
        },
        android: {
          notification: {
            ...(sound && {sound: sound}),
          },
        },
        apns: {
          payload: {
            aps: {
              ...(sound && {sound: sound}),
            },
          },
        },
        tokens: tokensBatch,
      };
      messageBatches.push(messages);
    }

    let numSent = 0;
    await Promise.all(
      messageBatches.map(async (messages) => {
        const response = await admin
          .messaging()
        // .sendMulticast(messages as MulticastMessage); // deprecated
          .sendEachForMulticast(messages as MulticastMessage);
        numSent += response.successCount;
      })
    );

    await snapshot.ref.update({status: "succeeded", num_sent: numSent});
  }
}
