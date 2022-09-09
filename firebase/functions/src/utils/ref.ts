import * as admin from "firebase-admin";
export class Ref {
  static get db(): admin.firestore.Firestore {
    return admin.firestore();
  }

  
  
  static get users() {
    return this.db.collection("users");
  }
  static userDoc(uid: string) {
    return this.users.doc(uid);
  }

  /** ****************************** MESSAGING References ****************************/

  static tokenCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection("fcm_tokens");
  }
  static tokenDoc(uid: string, token: string): admin.firestore.DocumentReference {
    return this.tokenCol(uid).doc(token);
  }
}
