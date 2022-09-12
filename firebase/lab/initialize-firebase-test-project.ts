import * as admin from "firebase-admin";
import credentials from "../credentials/test.service-account.json";

export class InitializeFirebaseTestProject {
  constructor() {
    try {
      admin.initializeApp({
        credential: admin.credential.cert(credentials as admin.ServiceAccount),
        databaseURL:
          "https://withcenter-test-project-default-rtdb.asia-southeast1.firebasedatabase.app/",
      });
      // console.log("admin; ", admin.firestore());
    } catch (e) {
      console.error("initialization failed; ", e);
    }
  }
}
