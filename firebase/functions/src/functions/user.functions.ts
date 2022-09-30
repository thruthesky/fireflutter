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
      delete data.uid;
      delete data.email;
      delete data.phone_number;
      data.hasPhoto = data.photoURL != null;
      return Ref.publicDoc(context.params.uid).set(data);
    });
