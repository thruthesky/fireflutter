import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(
      "../service-account.json"
    ),
    databaseURL: "https://withcenter-test-2-default-rtdb.asia-southeast1.firebasedatabase.app",
    storageBucket: "gs://withcenter-test-2.appspot.com",
  });
}
