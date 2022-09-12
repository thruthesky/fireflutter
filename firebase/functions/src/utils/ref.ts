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

  static userSettingsCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection('user_settings');
  }
  static userSettingsGroupCol(uid: string): admin.firestore.CollectionGroup {
    return this.db.collectionGroup('user_settings');
  }

  static userSettingsDoc(uid: string, docId: string): admin.firestore.DocumentReference {
    return this.userSettingsCol(uid).doc(docId);
  }

  /** ****************************** MESSAGING References ****************************/

  static tokenCol(uid: string): admin.firestore.CollectionReference {
    return this.userDoc(uid).collection("fcm_tokens");
  }
  static tokenDoc(uid: string, token: string): admin.firestore.DocumentReference {
    return this.tokenCol(uid).doc(token);
  }
}
