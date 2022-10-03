import * as admin from "firebase-admin";
import { InitializeFirebaseWonderfulKoreaProject } from "../initialize-firebase-wonderful-korea-project";

// new InitializeFirebaseTestProject();
new InitializeFirebaseWonderfulKoreaProject();


port_user_data().then(() => {
  process.exit();
});

async function port_user_data() {
  const snapshot = await admin.database().ref("users").get();
  const val = snapshot.val();

  for (const key of Object.keys(val)) {
    const data: any = val[key];

    if (data.level === void 0) continue;
    if (data.point === void 0) continue;
    if (data.firstName === void 0) continue;
    if (data.email != void 0 && data.email.indexOf("test") != -1) continue;

    const newData: any = {};
    if (data.registeredAt && data.registeredAt > -62135596800 && data.registeredAt < 253402300799 )
      newData.createdAt = admin.firestore.Timestamp.fromMillis(
        data.registeredAt * 1000
      );
    else newData.createdAt = admin.firestore.FieldValue.serverTimestamp();

    if ( data.updatedAt && data.updatedAt > -62135596800 && data.updatedAt < 253402300799 )
      newData.updatedAt = admin.firestore.Timestamp.fromMillis(
        data.updatedAt * 1000
      );

    if (data.disabled) newData.disabled = data.disabled;

    if (data.level) newData.level = data.level;
    if (data.point) newData.point = data.point;
    if (data.birthday) newData.birthday = data.birthday;
    if (data.email) newData.email = data.email;
    if (data.gender) newData.gender = data.gender;
    if (data.firstName) newData.firstName = data.firstName;
    if (data.lastName) newData.lastName = data.lastName;
    if (data.middleName) newData.middleName = data.middleName;
    if (data.photoUrl) newData.photoUrl = data.photoUrl;
    if (data.isAdmin) newData.admin = data.isAdmin;

    await admin
      .firestore()
      .collection("users")
      .doc(key)
      .set(newData, { merge: true });
  }
}
