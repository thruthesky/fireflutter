import * as admin from "firebase-admin";
import credentials from "../credentials/wonderful-korea.service-account.json";

export class InitializeFirebaseWonderfulKoreaProject {
  constructor() {
    try {
      admin.initializeApp({
        credential: admin.credential.cert(credentials as admin.ServiceAccount),
        databaseURL:
          "https://wonderful-korea-default-rtdb.asia-southeast1.firebasedatabase.app/",
      });
    } catch (e) {
      console.error("initialization failed; ", e);
    }
  }
}
