import * as admin from "firebase-admin";
import { UserDocument } from "../interfaces/user.interface";
import { Ref } from "../utils/ref";

/**
 * User class
 *
 * It supports user management for cloud functions.
 */
export class User {
  /**
   * Create the profile document.
   * @param uid uid of the user
   * @param data data to update as the user profile
   *
   */
  static async create(uid: string, data: any): Promise<UserDocument | null> {
    data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    const user = await this.get(uid);
    if (user) throw Error("user-exists");
    await Ref.userDoc(uid).set(data);
    return this.get(uid);
  }

  static async get(uid: string): Promise<UserDocument | null> {
    const snapshot = await Ref.userDoc(uid).get();
    if (snapshot.exists === false) return null;
    const data = snapshot.data() as UserDocument;
    data.id = uid;
    return data;
  }

  /**
   * Save settings
   * @param uid uid of user
   * @param docId key of the settings
   * @param data data of the settings
   * @returns void
   *
   * @example
   *  await User.setSettings(userA, "abc", { "def": true });
   */
  static async setSettings(
      uid: string,
      docId: string,
      data: {
      [key: string]: any;
    }
  ): Promise<admin.firestore.WriteResult> {
    return Ref.userSettingsDoc(uid, docId).set(data, { merge: true });
  }

  static async setSubscription(
      uid: string,
      subscriptionId: string,
      data: {
      [key: string]: any;
    }
  ): Promise<admin.firestore.WriteResult> {
    return Ref.userSubscriptionsDoc(uid, subscriptionId).set(data, { merge: true });
  }

  static async setToken(data: {
    fcm_token: string;
    device_type: string;
    uid: string;
  }): Promise<admin.firestore.WriteResult> {
    return Ref.tokenDoc(data.uid, data.fcm_token).set(data);
  }

  // / Returns user's point. 0 if it's not exists.
  static async point(uid: string): Promise<number> {
    const data = (await Ref.userDoc(uid).collection("user_meta").doc("point").get()).data();
    return data?.point ?? 0;
  }

  /**
   * Returns true if the user has subscribed to the notification when there is a new comment under his post or comment.
   * @param uid user uid
   * @returns boolean
   */
  static async commentNotification(uid: string): Promise<boolean> {
    const snapshot = await Ref.userSettingsDoc(uid).get();
    if (snapshot.exists === false) return false;
    const data = snapshot.data();
    if (data === void 0) return false;
    return data["notify-new-comment-under-my-posts-and-comments"] ?? false;
  }
}
