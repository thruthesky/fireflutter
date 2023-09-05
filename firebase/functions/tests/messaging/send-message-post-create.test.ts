import "mocha";

import "../firebase.init";
// import * as admin from "firebase-admin";

import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";

import { User } from "../../src/models/user.model";
import { Test } from "../test";
// import { Ref } from "../../src/utils/ref";
// import { Ref } from "../../src/utils/ref";



const action = "post-create";
const categoryId = "qna-test";
const type = "test-subscription";

const userIdA = "mhwOLEX0YxZa1m2G3dvSu1zQMZz2"; // valid test user id
const userIdB = "ZhiuNFzR4BNULdY2XvWSx5RaxGl1"; // valid test user id




describe("Send message by actions", () => {
    it("Send message by action", async () => {

        const userA = await User.get(userIdA);
        const userB = await User.get(userIdB);
        const userC = await Test.createUser();

        // subscribe to given topic
        const settings = await User.setUserSettingsSubscription(userA!.uid, { action: action, categoryId: categoryId, type: type });
        console.log(settings)
        await User.setUserSettingsSubscription(userB!.uid, { action: action, categoryId: categoryId, type: type });


        // Ref.postCol.add({
        //     title: 'aaa  this is post test notification ' + Test.id(),
        //     content: 'content of push',
        //     createdAt: admin.firestore.FieldValue.serverTimestamp(),
        //     categoryId: "qna"
        // })

        try {

            // const res = await Ref.postCol.add({
            //     title: 'this is post test notification ' + Test.id(),
            //     content: 'content of push',
            //     createdAt: admin.firestore.FieldValue.serverTimestamp(),
            //     categoryId: categoryId,
            //     uid: userB
            // })

            const res = await Test.createPost(userC.uid, categoryId, {
                title: 'this is post test notification ' + Test.id(),
                content: 'content of push, under:: ' + categoryId,
            })
            console.log("res::createPost", res);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });
});
