import * as admin from "firebase-admin";
export class Ref {
  static get db(): admin.firestore.Firestore {
    return admin.firestore();
  }
  static get rdb(): admin.database.Database {
    return admin.database();
  }

  static get users() {
    return this.db.collection("users");
  }
  static userDoc(uid: string) {
    return this.users.doc(uid);
  }

  static userMetaCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection("user_meta");
  }

  static userSettingsCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection("user_settings");
  }
  static userSettingsGroupCol(): admin.firestore.CollectionGroup {
    return this.db.collectionGroup("user_settings");
  }

  static userSettingsDoc(uid: string, docId = "settings"): admin.firestore.DocumentReference {
    return this.userSettingsCol(uid).doc(docId);
  }

  static userSubscriptionsCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection("user_subscriptions");
  }

  static userSubscriptionsDoc(
    uid: string,
    subscriptionId: string
  ): admin.firestore.DocumentReference {
    return this.userSubscriptionsCol(uid).doc(subscriptionId);
  }

  static get categoryCol() {
    return this.db.collection("categories");
  }

  /**
   * Returns category referrence
   *
   * @param {*} id Category id
   * @return reference
   */
  static categoryDoc(id: string) {
    return this.categoryCol.doc(id);
  }

  static get postCol() {
    return this.db.collection("posts");
  }

  /**
   * Returns post reference
   * @param id post id
   * @return reference
   */
  static postDoc(id: string) {
    return this.postCol.doc(id);
  }

  static get commentCol() {
    return this.db.collection("comments");
  }
  static commentDoc(commentId: string): admin.firestore.DocumentReference {
    return this.commentCol.doc(commentId);
  }
  /** ****************************** MESSAGING References ****************************/

  static tokenCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection("fcm_tokens");
  }
  static tokenDoc(uid: string, token: string): admin.firestore.DocumentReference {
    return this.tokenCol(uid).doc(token);
  }

  /** Point */

  static pointHistoryCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection("point_history");
  }

  // Point history folder for post point events.
  static pointLastHistory(
    uid: string,
    eventName: string
  ): admin.firestore.Query<admin.firestore.DocumentData> {
    // console.log(this.pointHistoryCol(uid).path, eventName);
    return this.pointHistoryCol(uid)
      .where("eventName", "==", eventName)
      .orderBy("createdAt", "desc")
      .limit(1);
  }

  static userMetaPointDoc(uid: string): admin.firestore.DocumentReference {
    return this.userMetaCol(uid).doc("point");
  }
}
