import * as functions from "firebase-functions";
import { User } from "../classes/user";
import { cors } from "../utils/cors";

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
