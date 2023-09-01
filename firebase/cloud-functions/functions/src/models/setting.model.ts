import * as admin from "firebase-admin";
import {SystemDocument} from "../interfaces/setting.interface";

/**
 * User class
 *
 * It supports user management for cloud functions.
 */
export class Setting {
  static get counters() {
    return admin.firestore().collection("settings").doc("counters");
  }

  /**
   * update noOfUsers field in the document of /settings/counters in firestore
   * @return promise of write result
   */
  static increaseNoOfUsers(): Promise<admin.firestore.WriteResult> {
    return this.counters.set(
      {
        noOfUsers: admin.firestore.FieldValue.increment(1),
      },
      {merge: true}
    );
  }
  /**
   * update noOfPosts field in the document of /settings/counters in firestore
   * @return promise of write result
   */
  static increaseNoOfPosts(): Promise<admin.firestore.WriteResult> {
    return this.counters.set(
      {
        noOfPosts: admin.firestore.FieldValue.increment(1),
      },
      {merge: true}
    );
  }

  static increaseNoOfComments(): Promise<admin.firestore.WriteResult> {
    return this.counters.set(
      {
        noOfComments: admin.firestore.FieldValue.increment(1),
      },
      {merge: true}
    );
  }

  static async getSystemSettings(): Promise<SystemDocument> {
    const data = await admin
      .firestore()
      .collection("settings")
      .doc("system")
      .get();
    return data.data() as SystemDocument;
  }
}
