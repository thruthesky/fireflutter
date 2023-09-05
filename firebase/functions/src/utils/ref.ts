import * as admin from "firebase-admin";
export class Ref {
  static get auth(): admin.auth.Auth {
    return admin.auth();
  }

  static get db(): admin.firestore.Firestore {
    return admin.firestore();
  }

  static get rdb(): admin.database.Database {
    return admin.database();
  }

  static get settingsCol() {
    return this.db.collection("settings");
  }

  static get adminDoc() {
    return this.settingsCol.doc("admins");
  }

  static get users() {
    return this.db.collection("users");
  }

  static userDoc(
    uid: string
  ): admin.firestore.DocumentReference<admin.firestore.DocumentData> {
    return this.users.doc(uid);
  }

  static userSettings(uid: string): admin.firestore.CollectionReference {
    return this.users.doc(uid).collection("user_settings");
  }

  static userSettingDoc(
    uid: string,
    docId: string
  ): admin.firestore.DocumentReference<admin.firestore.DocumentData> {
    return this.userSettings(uid).doc(docId);
  }

  static usersSettingsSearch(action: string, categoryId: string) {
    return this.db.collectionGroup("user_settings").where("action", "==", action)
      .where("categoryId", "==", categoryId);
  }

  static get usersPublicDataCol() {
    return this.db.collection("users_public_data");
  }

  // Returns user public data document path
  static publicDoc(
    uid: string
  ): admin.firestore.DocumentReference<admin.firestore.DocumentData> {
    return this.usersPublicDataCol.doc(uid);
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

  static get chatRoomsCol() {
    return this.db.collection("chat_rooms");
  }

  static chatRoomsDoc(
    docId: string
  ): admin.firestore.DocumentReference<admin.firestore.DocumentData> {
    return this.chatRoomsCol.doc(docId);
  }
  static chatRoomDoc(
    docId: string
  ): admin.firestore.DocumentReference<admin.firestore.DocumentData> {
    return this.chatRoomsDoc(docId);
  }

  static get chatRoomMessagesCol() {
    return this.db.collection("chat_room_messages");
  }

  /** *************** MESSAGING References **************/
  static get tokenCollectionGroup() {
    return Ref.db.collectionGroup("fcm_tokens");
  }

  static tokenCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection("fcm_tokens");
  }
  static tokenDoc(
    uid: string,
    token: string
  ): admin.firestore.DocumentReference {
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
}
