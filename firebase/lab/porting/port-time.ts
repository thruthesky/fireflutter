import * as admin from "firebase-admin";
import { InitializeFirebaseWonderfulKoreaProject } from "../initialize-firebase-wonderful-korea-project";

// new InitializeFirebaseTestProject();
new InitializeFirebaseWonderfulKoreaProject();

port_time().then(() => {
  process.exit();
});

async function port_time() {
  const time = admin.firestore.Timestamp.fromMillis(new Date("9/19/22").getTime());
  console.log("time", time.toDate(), time);
  const snapshot = await admin.firestore().collection("posts").where("createdAt", ">", time).get();

  for (const doc of snapshot.docs) {
    const data: any = doc.data();
    const newData: any = {};
    newData.createdAt = data.createdAt._seconds;
    newData.updatedAt = data.createdAt._seconds;
    await admin.firestore().collection("posts").doc(doc.id).set(newData, { merge: true });

    console.log(
      doc.id,
      data.title,
      data.createdAt,
      data.updatedAt,
      new Date(Math.round(data.createdAt._seconds / 1000))
    );
  }
}
