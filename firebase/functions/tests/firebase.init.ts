import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(
      "../service-account.json"
    ),
    databaseURL: "https://grc-30ca7-default-rtdb.firebaseio.com",
    storageBucket: "gs://grc-30ca7.appspot.com",
  });
}
