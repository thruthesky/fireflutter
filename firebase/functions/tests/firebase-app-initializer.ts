import * as admin from "firebase-admin";
import { ServiceAccount } from "firebase-admin";
import credentials from "../credentials/flutterkorea.service-account.json";

export class FirebaseAppInitializer {
  constructor() {
    try {
      admin.initializeApp({
        credential: admin.credential.cert(credentials as ServiceAccount),
      });

      admin.firestore().settings({ ignoreUndefinedProperties: true });

      // console.log("admin; ", admin.firestore());
    } catch (e) {
      // console.error("initialization failed; ", e);
    }
  }
}
