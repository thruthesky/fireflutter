"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Messaging = void 0;
const admin = require("firebase-admin");
const event_name_1 = require("../utils/event-name");
const ref_1 = require("../utils/ref");
const library_1 = require("../utils/library");
const comment_model_1 = require("../models/comment.model");
const user_model_1 = require("./user.model");
const post_model_1 = require("./post.model");
const chat_model_1 = require("./chat.model");
class Messaging {
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
    static async sendMessage(data) {
        if (data.action) {
            return this.sendMessageByAction(data);
        }
        else if (data.topic) {
            return this.sendMessageToTopic(data.topic, data);
        }
        else if (data.tokens) {
            return this.sendMessageToTokens(data.tokens, data);
        }
        else if (data.uids) {
            const tokens = await this.getTokensFromUids(data.uids);
            return this.sendMessageToTokens(tokens, data);
        }
        else {
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
    static async sendMessageToTopic(topic, data) {
        // Only admin can sent message to topic `allUsers`.
        const payload = this.topicPayload(topic, data);
        try {
            const res = await admin.messaging().send(payload);
            return { messageId: res };
        }
        catch (e) {
            throw Error("Topic send error " + e.message);
        }
    }
    // / Prepare topic payload
    static topicPayload(topic, data) {
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
    static async sendMessageByAction(data) {
        console.log(`sendMessageByAction(${JSON.stringify(data)})`);
        if (!data.action) {
            console.log("---> no action. throw error.");
            throw Error("No action on data.");
        }
        let uids = [];
        // commentCreate get post and patch data with category and title.
        if (data.action == event_name_1.EventName.commentCreate && data.postId) {
            const post = await post_model_1.Post.get(data.postId);
            uids.push(post.uid); // post owner
            data.categoryId = post.categoryId;
            data.title = post.title;
            console.log("comment::post::", JSON.stringify(post));
            console.log("comment::data::", JSON.stringify(data));
        }
        console.log("action:: ", data.action, "categoryId:: ", data.categoryId);
        // post and comment
        if (data.categoryId) {
            const snap = await ref_1.Ref.usersSettingsSearch({ action: data.action, categoryId: data.categoryId })
                .get();
            console.log("snap.size", snap.size);
            // get uids
            if (snap.size != 0) {
                for (const doc of snap.docs) {
                    const s = doc.data();
                    const uid = s.uid;
                    if (uid != data.senderUid)
                        uids.push(uid);
                }
            }
            //
        }
        // Get ancestor's uid
        if (data.action == event_name_1.EventName.commentCreate && data.id) {
            const ancestors = await comment_model_1.Comment.getAncestorsUid(data.id, data.uid);
            // Remove ancestors who didn't subscribe for new comment.
            const subscribers = await this.getNewCommentNotificationUids(ancestors);
            uids = [...uids, ...subscribers];
        }
        if (data.action == event_name_1.EventName.chatCreate && data.roomId && uids.length) {
            const snap = await ref_1.Ref.userSettingGroup.where("action", "==", event_name_1.EventName.chatDisabled).where("roomId", "==", data.roomId)
                .get();
            console.log("snap.size", snap.size);
            // get uids of chat disable user
            const pusDisableUid = [];
            if (snap.size != 0) {
                for (const doc of snap.docs) {
                    const s = doc.data();
                    pusDisableUid.push(s.uid);
                }
                // filter user with chatDisabled
                uids = uids.filter((uid) => !pusDisableUid.includes(uid));
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
    static async sendMessageToTokens(tokens, data) {
        // console.log(`sendMessageToTokens() token.length: ${tokens.length}`);
        // make it list of string if it is string
        const _tokens = typeof data.tokens == "string" ? data.tokens.split(",") : tokens;
        if (tokens.length == 0) {
            console.log("sendMessageToTokens() no tokens. so, just return results.");
            return { success: 0, error: 0 };
        }
        // add login user uid
        // data.senderUid = data.uid; // already inside the completePayload
        const payload = this.completePayload(data);
        // sendMulticast() supports 500 tokens at a time. Chunk and send by batches.
        const chunks = library_1.Library.chunk(_tokens, 500);
        // console.log(`sendMessageToTokens() chunks.length: ${chunks.length}`);
        const multicastPromise = [];
        // Save [sendMulticast()] into a promise.
        for (const _500Tokens of chunks) {
            const newPayload = Object.assign({}, { tokens: _500Tokens }, payload);
            multicastPromise.push(admin.messaging().sendEachForMulticast(newPayload));
        }
        const failedTokens = [];
        let successCount = 0;
        let failureCount = 0;
        try {
            // Send all the push messages in the promise with [Promise.allSettle].
            const settled = await Promise.allSettled(multicastPromise);
            // Returns are in array
            for (let settledIndex = 0; settledIndex < settled.length; settledIndex++) {
                console.log(`settled[${settledIndex}]`, settled[settledIndex]);
                /* eslint-disable-next-line  @typescript-eslint/no-explicit-any */
                const value = settled[settledIndex].value;
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
            const results = { success: successCount, error: failureCount };
            // console.log(`sendMessageToTokens() results: ${JSON.stringify(results)}`);
            return results;
        }
        catch (e) {
            console.log("---> caught on sendMessageToTokens() await Promise.allSettled()", e);
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
    static async removeTokens(tokens) {
        /* eslint-disable-next-line  @typescript-eslint/no-explicit-any */
        const promises = [];
        for (const token of tokens) {
            promises.push(
            // Get the document of the token
            ref_1.Ref.db
                .collectionGroup("fcm_tokens")
                .where("fcm_token", "==", token)
                .get()
                .then(async (snapshot) => {
                for (const doc of snapshot.docs) {
                    await doc.ref.delete();
                }
            }));
        }
        await Promise.all(promises);
    }
    /**
     * Return true if the token is invalid.
     *  So it can be removed from database.
     * There are many error codes. see
     * https://firebase.google.com/docs/cloud-messaging/send-message#admin
     */
    static isInvalidTokenErrorCode(code) {
        if (code === "messaging/invalid-registration-token" ||
            code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-argument") {
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
    static async getTokensFromUids(uids) {
        if (!uids)
            return [];
        const promises = [];
        const _uids = typeof uids == "string" ? uids.split(",") : uids;
        _uids.forEach((uid) => promises.push(this.getTokens(uid)));
        return (await Promise.all(promises)).flat();
    }
    /**
     * Returns tokens of a user.
     *
     * @param uid user uid
     * @return array of tokens
     */
    static async getTokens(uid) {
        if (!uid)
            return [];
        const snapshot = await ref_1.Ref.tokenCol(uid).get();
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
    static completePayload(query) {
        // console.log(`completePayload(${JSON.stringify(query)})`);
        var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _o, _p;
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
            console.log(`completePayload() throws error: body-is-empty: (${JSON.stringify(query)})`);
            throw Error("body-is-empty");
        }
        // if postId exist change the payload id.
        if (query.postId) {
            query.id = query.postId;
        }
        const res = {
            data: {
                id: (_a = query.id) !== null && _a !== void 0 ? _a : "",
                type: (_b = query.type) !== null && _b !== void 0 ? _b : "",
                senderUid: (_c = query.senderUid) !== null && _c !== void 0 ? _c : "",
                roomId: (_d = query.roomId) !== null && _d !== void 0 ? _d : "",
                badge: (_e = query.badge) !== null && _e !== void 0 ? _e : "",
            },
            notification: {
                title: (_f = query.title) !== null && _f !== void 0 ? _f : "",
                body: (_g = query.body) !== null && _g !== void 0 ? _g : "",
            },
            webpush: {
                notification: {
                    title: (_h = query.title) !== null && _h !== void 0 ? _h : "",
                    body: (_j = query.body) !== null && _j !== void 0 ? _j : "",
                    icon: (_k = query.icon) !== null && _k !== void 0 ? _k : "",
                    click_action: (_l = query.clickAction) !== null && _l !== void 0 ? _l : "/",
                },
                fcm_options: {
                    link: (_m = query.clickAction) !== null && _m !== void 0 ? _m : "/",
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
                (_o = library_1.Library.removeHtmlTags(res.notification.body)) !== null && _o !== void 0 ? _o : "";
            res.notification.body =
                (_p = library_1.Library.decodeHTMLEntities(res.notification.body)) !== null && _p !== void 0 ? _p : "";
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
    static async getNewCommentNotificationUids(uids) {
        if (uids.length === 0)
            return [];
        const promises = [];
        for (const uid of uids) {
            promises.push(user_model_1.User.commentNotification(uid));
        }
        const results = await Promise.all(promises);
        const re = [];
        // dont add user who has turn off subscription
        for (let i = 0; i < results.length; i++) {
            if (results[i])
                re.push(uids[i]);
        }
        return re;
    }
    /**
     *
     * @param data
     * @returns
     */
    static async sendChatNotificationToOtherUsers(data) {
        var _a;
        const user = await user_model_1.User.get(data.uid);
        const messageData = Object.assign(Object.assign({}, data), { type: event_name_1.EventType.chat, action: event_name_1.EventName.chatCreate, title: `${(_a = user === null || user === void 0 ? void 0 : user.display_name) !== null && _a !== void 0 ? _a : ""} send you a message.`, body: data.text, uids: await chat_model_1.Chat.getOtherUserUidsFromChatMessageDocument(data), id: data.roomId, senderUid: data.uid });
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
    static async saveToken(data) {
        return await ref_1.Ref.tokenDoc(data.uid, data.fcm_token).set(data);
    }
    /**
     * Returns the document document (Not the token as string) under the user's fcm_tokens collection.
     *
     * @param uid uid
     * @param token token
     * @param device_type device type
     * @returns Promise<WriteResult>
     */
    static async getToken(data) {
        return (await ref_1.Ref.tokenDoc(data.uid, data.fcm_token).get()).data();
    }
}
exports.Messaging = Messaging;
//# sourceMappingURL=messaging.model.js.map