import "mocha";

import "../firebase.init";
import * as admin from "firebase-admin";




import { Messaging } from "../../src/models/messaging.model";
import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";


import { User } from "../../src/models/user.model";
import { Test } from "../test";
// import { Ref } from "../../src/utils/ref";



const action = "comment-create-test";
const categoryId = "qna-test";
const type = "test-subscription";

const validToken = "fQCpkXq5TqG5_VPHJmJtPQ:APA91bEL114Rt1_hD4xlL5SShs-Nr0q06bT82bLK0cEPWt0GycudJnB0lEo0MOqoRUMCU8vs_ttGbu7r29jZ7mZ_bX0BqUNrDHSdYVyo9vQxKRgTFXZAz2D5km19C_OcKhOWptOmU8mH";

describe("Send message by actions", () => {
    it("Send message by action", async () => {
        // Delete all existing token, so the test will be match to 1.
        let res = await admin
            .firestore()
            .collectionGroup("user_settings")
            .where("action", "==", action)
            .where("categoryId", "==", categoryId)
            // .where("type", "==", type)
            .get();
        for (const doc of res.docs) {
            await doc.ref.delete();
        }

        const user = await Test.createUser();

        const settings = await User.setUserSettingsSubscription(user.uid, { action: action, categoryId: categoryId, type: type });
        console.log(settings)

        // expired token 
        await User.SetFcmToken({
            fcm_token:
                "d1cBU6UuR9KqYtyeIVimFA:APA91bHlC2l_Crl_twwq8JRZIwnFtsTZKec6RYkoupJwnu3P5ZfuTo7qFrWBptGJKtvxqIuWAIxZOZGTDWL7GTcUhkWXsrHW0k824ara8G6ZJnK4Q61hlXO7x4pJ0kVJiaXPWQQuqG9Z",
            device_type: "android",
            uid: user.uid,
        });


        // invalid token
        await User.SetFcmToken({
            fcm_token: "invalid-tokens",
            device_type: "android",
            uid: user.uid,
        });


        // add valid token
        await User.SetFcmToken({
            fcm_token:
                validToken,
            device_type: "ios",
            uid: user.uid,
        });


        // console.log("USER ID:::: ", user.uid, action, categoryId);
        // const snap = await Ref.usersSettingsSearch(action, categoryId)
        //     .get();
        // console.log("snap.size", snap.size);

        try {
            const res = await Messaging.sendMessage({
                title: "from cli via action",
                body: "using action and categoryId",
                action: action, // post-create
                categoryId: categoryId,
            });
            // console.log("res::", res);
            expect(res.success).equals(1);
            expect(res.error).equals(2);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });
});
