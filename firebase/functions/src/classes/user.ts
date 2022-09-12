import * as admin from "firebase-admin";
import { Ref } from "../utils/ref";

export class User {
  /**
   * Create the profile document.
   * @param uid uid of the user
   * @param data data to update as the user profile
   *
   */
  static async create(
    uid: string,
    data: any
  ): Promise<admin.firestore.WriteResult> {
    data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    const user = await this.get(uid);
    if (user) throw "user-exists";
    return Ref.userDoc(uid).set(data);
  }

  static async get(uid: string) {
    const snapshot = await Ref.userDoc(uid).get();
    return snapshot.data();
  }

  static async setSettings(
    uid: string,
    docId: string,
    data: {
      [key: string]: any;
    }
  ): Promise<admin.firestore.WriteResult> {

    return Ref.userSettingsDoc(uid, docId).set(data, { merge: true });
  }

  static async setToken(data: {
    fcm_token: string;
    device_type: string;
    uid: string;
  }): Promise<admin.firestore.WriteResult> {
    return Ref.tokenDoc(data.uid, data.fcm_token).set(data);
  }
}
