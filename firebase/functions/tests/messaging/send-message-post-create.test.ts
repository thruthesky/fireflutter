import "mocha";

import "../firebase.init";
import * as admin from "firebase-admin";

import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";

import { User } from "../../src/models/user.model";
import { Test } from "../test";
import { Ref } from "../../src/utils/ref";
// import { Ref } from "../../src/utils/ref";



const action = "comment-create-test";
const categoryId = "qna-test";
const type = "test-subscription";

const userId = "mhwOLEX0YxZa1m2G3dvSu1zQMZz2";


describe("Send message by actions", () => {
    it("Send message by action", async () => {

        const user = await User.get(userId);

        // subscribe to given topic
        const settings = await User.setUserSettingsSubscription(user!.uid, { action: action, categoryId: categoryId, type: type });
        console.log(settings)

        Ref.postCol.add({
            title: 'aaa  this is post test notification ' + Test.id(),
            content: 'content of push',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            categoryId: "qna"
        })

        try {

            const res = await Ref.postCol.add({
                title: 'this is post test notification ' + Test.id(),
                content: 'content of push',
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                categoryId: "qna"
            })
            console.log("res::", res);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });
});
