"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const admin = require("firebase-admin");
const ref_1 = require("../utils/ref");
const messaging_model_1 = require("./messaging.model");
/**
 * user_settings field name that will holds the boolean value
 * when user want to get notified if new comments
 *  is created under user created posts/comments
 */
const notifyNewComments = "notify-new-comments";
/**
 * User class
 *
 * It supports user management for cloud functions.
 */
class User {
    static publicDoc(uid) {
        return ref_1.Ref.publicDoc(uid);
    }
    /**
     * Create the user documment under /users collection
     *
     *
     * @param uid uid of the user
     * @param data data to update as the user profile
     *
     * @return UserDocument - it does not return null.
     *
     */
    /* eslint-disable-next-line  @typescript-eslint/no-explicit-any */
    static async create(uid, data) {
        data.created_time = admin.firestore.FieldValue.serverTimestamp();
        const user = await this.get(uid);
        if (user)
            throw Error("user-exists");
        data["uid"] = uid;
        await ref_1.Ref.userDoc(uid).set(data);
        return this.get(uid);
    }
    static async get(uid) {
        const snapshot = await ref_1.Ref.userDoc(uid).get();
        if (snapshot.exists === false)
            return null;
        return snapshot.data();
    }
    // / Returns user's point. 0 if it's not exists.
    static async point(uid) {
        var _a;
        const data = (await ref_1.Ref.userDoc(uid).collection("user_meta").doc("point").get()).data();
        return (_a = data === null || data === void 0 ? void 0 : data.point) !== null && _a !== void 0 ? _a : 0;
    }
    /**
     * Returns true if the user has subscribed to the
     * notification when there is a new comment under his post or comment.
     * @param uid user uid
     * @return boolean
     */
    static async commentNotification(uid) {
        const querySnapshot = await ref_1.Ref.userSettings(uid)
            // .where("userDocumentReference", "==", userPath)
            .where("type", "==", "settings")
            .where(notifyNewComments, "==", true)
            .limit(1)
            .get();
        if (querySnapshot.size == 0)
            return false;
        // const data = querySnapshot.docs[0].data();
        // if (data === void 0) return false;
        // return data[notifyNewComments] ?? false;
        return true;
    }
    // /**
    //  * Returns true if the user has subscribed to the
    //  notification when there is a new comment under his post or comment.
    //  * @param uid user uid
    //  * @returns boolean
    //  */
    // static async chatOtherUserNotification(uid: string, otherUid: string):
    // Promise<boolean> {
    //   const snapshot = await Ref.userSettingsDoc(uid).get();
    //   if (snapshot.exists === false) return false;
    //   const data = snapshot.data();
    //   if (data === void 0) return false;
    //   return data["chatNotify." + otherUid] ?? false;
    // }
    static async getUserByPhoneNumber(phoneNumber) {
        try {
            const UserRecord = await ref_1.Ref.auth.getUserByPhoneNumber(phoneNumber);
            return UserRecord;
        }
        catch (e) {
            return null;
        }
    }
    /**
     * Return true if the user of the uid is an admin.
     *  Otherwise false will be returned.
     *
     *
     * @param uid
     */
    static async isAdmin(uid) {
        if (!uid)
            return false;
        const doc = await ref_1.Ref.adminDoc.get();
        const admins = doc.data();
        if (!admins)
            return false;
        if (!admins[uid])
            return false;
        return true;
    }
    /**
     * Check admin. If the user is not admin,
     *  then thow an exception of `ERROR_YOU_ARE_NOT_ADMIN`.
     * @param uid the user uid
     * throws error object if there is any error. Or it will return true.
     */
    static async checkAdmin(uid) {
        if (typeof uid === "undefined")
            throw Error("uid is undefined.");
        if (await this.isAdmin(uid)) {
            return true;
        }
        else {
            throw Error("You are not an admin.");
        }
    }
    /**
     * Disable a user.
     *
     * @param adminUid is the admin uid.
     * @param otherUid is the user uid to be disabled.
     */
    static async disableUser(adminUid, otherUid) {
        this.checkAdmin(adminUid);
        const user = await ref_1.Ref.auth.updateUser(otherUid, { disabled: true });
        if (user.disabled == true) {
            await ref_1.Ref.userDoc(otherUid).set({ disabled: true }, { merge: true });
        }
        return user;
    }
    static async enableUser(adminUid, otherUid) {
        this.checkAdmin(adminUid);
        const user = await ref_1.Ref.auth.updateUser(otherUid, { disabled: false });
        if (user.disabled == false) {
            await ref_1.Ref.userDoc(otherUid).set({ disabled: false }, { merge: true });
        }
        return user;
    }
    /**
     * Delete the user account.
     * @param uid uid of the user
     */
    static async deleteAccount(uid) {
        try {
            await ref_1.Ref.auth.deleteUser(uid);
        }
        catch (e) {
            //
        }
        try {
            await ref_1.Ref.userDoc(uid).delete();
        }
        catch (e) {
            console.log(e);
        }
        try {
            await ref_1.Ref.publicDoc(uid).delete();
        }
        catch (e) {
            console.log(e);
        }
        // under users collection
        // try {
        //   await Ref.userSettingDoc(uid).delete();
        // } catch (e) {
        //   console.log(e);
        // }
    }
    /**
     * Update user public data document.
     * @param uid user uid
     * @param data user document in /users/{uid}
     * @return promise of write result
     */
    static updatePublicData(uid, data) {
        const hasPhoto = !!data.photo_url;
        let complete = false;
        if (data.display_name && data.email && hasPhoto) {
            complete = true;
        }
        //
        delete data.email;
        delete data.phone_number;
        delete data.blockedUserList;
        return User.publicDoc(uid).set(Object.assign(Object.assign({}, data), { isProfileComplete: complete, userDocumentReference: ref_1.Ref.userDoc(uid), hasPhoto: hasPhoto, updatedAt: admin.firestore.FieldValue.serverTimestamp() }), { merge: true });
    }
    /**
     * Run user command.
     * @param uid user uid
     * @param data user document
     *
     * If the command is `delete`, then the user's account will be deleted.
     */
    static command(uid, data) {
        if (data.command == "delete") {
            this.deleteAccount(uid);
        }
    }
    static increaseNoOfComments(userDocumentReference) {
        return userDocumentReference.update({
            noOfComments: admin.firestore.FieldValue.increment(1),
        });
    }
    /**
     *
     * @param data user
     * @returns
     */
    static async SetFcmToken(data) {
        return await messaging_model_1.Messaging.saveToken(data);
    }
    /**
     *
     * @param data user
     * @returns
     */
    static async GetFcmToken(data) {
        return await messaging_model_1.Messaging.getToken(data);
    }
    /* eslint-disable-next-line  @typescript-eslint/no-explicit-any */
    static async setUserSettingsSubscription(uid, data) {
        var _a;
        data["uid"] = uid;
        const settingName = (_a = (data.action ? data.action + "." : "") + data.categoryId) !== null && _a !== void 0 ? _a : "";
        return ref_1.Ref.userSettingDoc(uid, settingName).set(data, { merge: true });
    }
    /**
     * Update users no of posts.
     * @param userDocumentReference
     *  the user document reference of the user
     *  who posted the post  in /users collection.
     * @returns
     */
    static increaseNoOfPosts(userDocumentReference) {
        return userDocumentReference.update({
            noOfPosts: admin.firestore.FieldValue.increment(1),
        });
    }
    /**
     * Update the post meta data of the user in /users_public_data/{uid}
     *
     * - It updates;
     *   - posts of the user in /users_public_data/{uid}/recentPosts.
     *   - No of posts
     * @param userDocumentReference
     *   the user document reference of the user
     *   who posted the post  in /users collection.
     * @return Promise
     */
    static async updateUserPostMeta(userDocumentReference) {
        // get the last 20 post documents
        // from /posts collection order by createdAt descending.
        const snapshot = await ref_1.Ref.postCol
            .where("userDocumentReference", "==", userDocumentReference)
            .orderBy("createdAt", "desc")
            .limit(20)
            .get();
        // return if there is no post document.
        if (snapshot.empty)
            return;
        const recentPosts = [];
        for (const doc of snapshot.docs) {
            const data = doc.data();
            recentPosts.push({ id: doc.id, timestamp: data.createdAt.seconds });
        }
        // update the recentPosts field in /users_public_data/{uid} document.
        await ref_1.Ref.publicDoc(userDocumentReference.id).update({
            noOfPosts: admin.firestore.FieldValue.increment(1),
            recentPosts,
            lastPostCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return;
    }
}
exports.User = User;
//# sourceMappingURL=user.model.js.map