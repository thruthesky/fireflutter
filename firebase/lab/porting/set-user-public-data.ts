import * as admin from "firebase-admin";
// import { InitializeFirebaseTestProject } from "../initialize-firebase-test-project";
import { InitializeFirebaseWonderfulKoreaProject } from "../initialize-firebase-wonderful-korea-project";

// new InitializeFirebaseTestProject();
new InitializeFirebaseWonderfulKoreaProject();


port_user_data().then(() => {
  process.exit();
});

async function port_user_data() {
  const snapshot = await admin.firestore().collection("users").get();
  const docs = snapshot.docs;

  for (const doc of docs) {
    const data: any = doc.data();

    if (data.level === void 0) continue;
    if (data.point === void 0) continue;
    if (data.firstName === void 0) continue;
    if (data.email != void 0 && data.email.indexOf("test") != -1) continue;


    console.log(data.firstName);

    

          // UID 의 값을 그대로 둔다. FlutterFlow 에서는 필요하다.
          // delete data.uid;
    
          delete data.email;
          delete data.phone_number;
    
          // 사진이 있으면 hasPhoto 를 true 로 설정한다.
          // FirebaseAuth.User 에서는 photoURL 이고, FireFlutter.User 에서는 photoUrl 이고, FlutterFlow 에는 photo_url 이다.
          // 주의, 아래 3 개의 필드 중 하나 만 사용되어야 한다. 그래야 아래의 코드가 올바로 수행된다.
          const url = data.photoURL ?? data.photoUrl ?? data.photo_url ?? "";
          data.hasPhoto = !!url;
    
    await admin
      .firestore()
      .collection("users_public_data")
      .doc(doc.id)
      .set(data);
  }
}
