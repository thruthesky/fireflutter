import * as admin from "firebase-admin";
import { InitializeFirebaseWonderfulKoreaProject } from "../initialize-firebase-wonderful-korea-project";

// new InitializeFirebaseTestProject();
new InitializeFirebaseWonderfulKoreaProject();

port_user_data().then(() => {
  process.exit();
});

async function port_user_data() {
  const snapshot = await admin.firestore().collection("posts").get();

  for (const doc of snapshot.docs) {
    const data: any = doc.data();
    const newData: any = {};
    if (
      data.createdAt &&
      data.createdAt._seconds &&
      data.createdAt._seconds > -62135596800 &&
      data.createdAt._seconds < 253402300799
    ) {
      newData.createdAt = data.createdAt._seconds;
      newData.updatedAt = data.updatedAt._seconds;
      console.log(newData);
      await admin.firestore().collection("posts").doc(doc.id).set(newData, { merge: true });
    }

    // console.log(doc.id, data.createdAt, data.updatedAt);
  }
}
