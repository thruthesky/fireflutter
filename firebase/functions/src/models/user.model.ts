import * as admin from "firebase-admin";
import {DocumentReference} from "firebase-admin/firestore";
import {UserRecord} from "firebase-functions/v1/auth";
import {PostDocument} from "../interfaces/forum.interface";
import {UserDocument} from "../interfaces/user.interface";
import {Ref} from "../utils/ref";
import {Messaging} from "./messaging.model";
import {FcmToken} from "../interfaces/messaging.interface";


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
export class User {
  static publicDoc(
    uid: string
  ): admin.firestore.DocumentReference<admin.firestore.DocumentData> {
    return Ref.publicDoc(uid);
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
  static async create(uid: string, data: any): Promise<UserDocument> {
    data.created_time = admin.firestore.FieldValue.serverTimestamp();
    const user = await this.get(uid);
    if (user) throw Error("user-exists");
    data["uid"] = uid;
    await Ref.userDoc(uid).set(data);
    return this.get(uid) as Promise<UserDocument>;
  }

  static async get(uid: string): Promise<UserDocument | null> {
    const snapshot = await Ref.userDoc(uid).get();
    if (snapshot.exists === false) return null;
    return snapshot.data() as UserDocument;
  }

  // / Returns user's point. 0 if it's not exists.
  static async point(uid: string): Promise<number> {
    const data = (
      await Ref.userDoc(uid).collection("user_meta").doc("point").get()
    ).data();
    return data?.point ?? 0;
  }

  /**
   * Returns true if the user has subscribed to the
   * notification when there is a new comment under his post or comment.
   * @param uid user uid
   * @return boolean
   */
  static async commentNotification(uid: string): Promise<boolean> {
    const querySnapshot = await Ref.userSettings(uid)
      // .where("userDocumentReference", "==", userPath)
      .where("type", "==", "settings")
      .where(notifyNewComments, "==", true)
      .limit(1)
      .get();

    if (querySnapshot.size == 0) return false;
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

  static async getUserByPhoneNumber(
    phoneNumber: string
  ): Promise<UserRecord | null> {
    try {
      const UserRecord = await Ref.auth.getUserByPhoneNumber(phoneNumber);
      return UserRecord;
    } catch (e) {
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
  static async isAdmin(uid: string): Promise<boolean> {
    if (!uid) return false;

    const doc = await Ref.adminDoc.get();
    const admins = doc.data();
    if (!admins) return false;
    if (!admins[uid]) return false;
    return true;
  }

  /**
   * Check admin. If the user is not admin,
   *  then thow an exception of `ERROR_YOU_ARE_NOT_ADMIN`.
   * @param uid the user uid
   * throws error object if there is any error. Or it will return true.
   */
  static async checkAdmin(uid?: string): Promise<boolean> {
    if (typeof uid === "undefined") throw Error("uid is undefined.");
    if (await this.isAdmin(uid)) {
      return true;
    } else {
      throw Error("You are not an admin.");
    }
  }

  /**
   * Disable a user.
   *
   * @param adminUid is the admin uid.
   * @param otherUid is the user uid to be disabled.
   */
  static async disableUser(
    adminUid: string,
    otherUid: string
  ): Promise<UserRecord> {
    this.checkAdmin(adminUid);
    const user = await Ref.auth.updateUser(otherUid, {disabled: true});
    if (user.disabled == true) {
      await Ref.userDoc(otherUid).set({disabled: true}, {merge: true});
    }
    return user;
  }

  static async enableUser(adminUid: string, otherUid: string) {
    this.checkAdmin(adminUid);
    const user = await Ref.auth.updateUser(otherUid, {disabled: false});
    if (user.disabled == false) {
      await Ref.userDoc(otherUid).set({disabled: false}, {merge: true});
    }
    return user;
  }

  /**
   * Delete the user account.
   * @param uid uid of the user
   */
  static async deleteAccount(uid: string) {
    try {
      await Ref.auth.deleteUser(uid);
    } catch (e) {
      //
    }
    try {
      await Ref.userDoc(uid).delete();
    } catch (e) {
      console.log(e);
    }
    try {
      await Ref.publicDoc(uid).delete();
    } catch (e) {
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
  static updatePublicData(
    uid: string,
    data: UserDocument
  ): Promise<admin.firestore.WriteResult> {
    const hasPhoto = !!data.photo_url;
    let complete = false;

    if (data.display_name && data.email && hasPhoto) {
      complete = true;
    }
    //
    delete data.email;
    delete data.phone_number;
    delete data.blockedUserList;
    return User.publicDoc(uid).set(
      {
        ...data,
        isProfileComplete: complete,
        userDocumentReference: Ref.userDoc(uid),
        hasPhoto: hasPhoto,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
  }

  /**
   * Run user command.
   * @param uid user uid
   * @param data user document
   *
   * If the command is `delete`, then the user's account will be deleted.
   */
  static command(uid: string, data: UserDocument) {
    if (data.command == "delete") {
      this.deleteAccount(uid);
    }
  }

  static increaseNoOfComments(
    userDocumentReference: DocumentReference
  ): Promise<admin.firestore.WriteResult> {
    return userDocumentReference.update({
      noOfComments: admin.firestore.FieldValue.increment(1),
    });
  }


  /**
   *
   * @param data user
   * @returns
   */
  static async SetFcmToken(data: FcmToken): Promise<admin.firestore.WriteResult> {
    return await Messaging.saveToken(data);
  }

  /**
   *
   * @param data user
   * @returns
   */
  static async GetFcmToken(data: Partial<FcmToken>): Promise<FcmToken> {
    return await Messaging.getToken(data as FcmToken);
  }


  static async setUserSettingsSubscription(
    uid: string,
    data: {
      action?: string;
      categoryId?: string;
      type?: string;
      /* eslint-disable-next-line  @typescript-eslint/no-explicit-any */
      [key: string]: any;
    }
  ): Promise<admin.firestore.WriteResult> {
    data["uid"] = uid;
    const settingName = (data.action ? data.action + "." : "") + data.categoryId ?? "";
    return Ref.userSettingDoc(uid, settingName).set(data, {merge: true});
  }

  /**
   * Update users no of posts.
   * @param userDocumentReference
   *  the user document reference of the user
   *  who posted the post  in /users collection.
   * @returns
   */
  static increaseNoOfPosts(
    userDocumentReference: DocumentReference
  ): Promise<admin.firestore.WriteResult> {
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
  static async updateUserPostMeta(
    userDocumentReference: DocumentReference
  ): Promise<undefined> {
    // get the last 20 post documents
    // from /posts collection order by createdAt descending.
    const snapshot = await Ref.postCol
      .where("userDocumentReference", "==", userDocumentReference)
      .orderBy("createdAt", "desc")
      .limit(20)
      .get();

    // return if there is no post document.
    if (snapshot.empty) return;

    const recentPosts = [];
    for (const doc of snapshot.docs) {
      const data = doc.data() as PostDocument;
      recentPosts.push({id: doc.id, timestamp: data.createdAt.seconds});
    }

    // update the recentPosts field in /users_public_data/{uid} document.
    await Ref.publicDoc(userDocumentReference.id).update({
      noOfPosts: admin.firestore.FieldValue.increment(1),
      recentPosts,
      lastPostCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return;
  }
}
