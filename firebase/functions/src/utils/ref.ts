import * as admin from "firebase-admin";
export class Ref {
  static get db() {
    return admin.firestore();
  }

  static get rdb() {
    return admin.database();
  }

  static get settingsCol() {
    return this.db.collection("settings");
  }

  static get users() {
    return this.rdb.ref("users");
  }

  static get adminDoc() {
    return this.settingsCol.doc("admins");
  }

  /** ****************************** MESSAGING References ****************************/

  static get messageTokens() {
    return this.db.collection("fcm-tokens");
  }
  //   static token(id: string) {
  //     return this.messageTokens.child(id);
  //   }
}
