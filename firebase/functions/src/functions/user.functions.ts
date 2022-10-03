import * as functions from "firebase-functions";
import { User } from "../classes/user";
import { cors } from "../utils/cors";
import { Ref } from "../utils/ref";

/**
 * 자세한 설명은 README.md 참고
 */
export const getUserUidFromPhoneNumber = functions
    .region("asia-northeast3")
    .https.onRequest((req, res) => {
      cors({ req, res }, async (data) => {
        res
            .status(200)
            .send({ uid: (await User.getUserByPhoneNumber(data["phoneNumber"]))?.uid ?? "" });
      });
    });

/**
 *  자세한 설명은 README.me 참고
 *
 */
export const setUsersPublicData = functions
    .region("asia-northeast3")
    .firestore.document("/users/{uid}")
    .onWrite((snapshot, context) => {
      // 사용자 문서가 삭제되었나?
      if (snapshot.after.data() == null) {
        return Ref.publicDoc(context.params.uid).delete();
      }

      // 사용자 문서가 생성 또는 수정 되었나?
      const data: any = snapshot.after.data();

      // UID 의 값을 그대로 둔다. FlutterFlow 에서는 필요하다.
      // delete data.uid;

      delete data.email;
      delete data.phone_number;

      // 사진이 있으면 hasPhoto 를 true 로 설정한다.
      // FirebaseAuth.User 에서는 photoURL 이고, FireFlutter.User 에서는 photoUrl 이고, FlutterFlow 에는 photo_url 이다.
      // 주의, 아래 3 개의 필드 중 하나 만 사용되어야 한다. 그래야 아래의 코드가 올바로 수행된다.
      const url = data.photoURL ?? data.photoUrl ?? data.photo_url ?? "";
      data.hasPhoto = !!url;
      return Ref.publicDoc(context.params.uid).set(data);
    });
