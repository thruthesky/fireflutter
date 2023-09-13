import "mocha";

import "../firebase.init";

import { expect } from "chai";
import { HttpsError } from "firebase-functions/v1/auth";

// import { User } from "../../src/models/user.model";
import { Test } from "../test";
import { Ref } from "../../src/utils/ref";
import { SendMessage } from "../../src/interfaces/messaging.interface";
import { Library } from "../../src/utils/library";
// import { User } from "../../src/models/user.model";



const userIdA = "mhwOLEX0YxZa1m2G3dvSu1zQMZz2"; // valid test user id
const userAToken = "fQCpkXq5TqG5_VPHJmJtPQ:APA91bEL114Rt1_hD4xlL5SShs-Nr0q06bT82bLK0cEPWt0GycudJnB0lEo0MOqoRUMCU8vs_ttGbu7r29jZ7mZ_bX0BqUNrDHSdYVyo9vQxKRgTFXZAz2D5km19C_OcKhOWptOmU8mH"; // valid test user token
// const userIdB = "ZhiuNFzR4BNULdY2XvWSx5RaxGl1"; // valid test user id





describe("send message on queue", () => {
    it("send message via allUsers topic", async () => {
        const userC = await Test.createUser();
        const post = await Test.createPost();
        const data: SendMessage = {
            title: 'Notification title allUsers',
            body: 'Notification body',
            id: post.id,
            type: 'post',
            senderUid: userC.uid,
            topic: 'allUsers'
        }

        try {
            const res = await Ref.pushNotificationQueue.add(data);
            await Library.delay(2000);
            const after = await res.get()
            expect(after.data()!.messageId).to.be.include('projects/');
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });
    it("send message via androidUsers topic", async () => {
        const userC = await Test.createUser();
        const post = await Test.createPost();
        const data: SendMessage = {
            title: 'Notification title androidUsers',
            body: 'Notification body',
            id: post.id,
            type: 'post',
            senderUid: userC.uid,
            topic: 'androidUsers'
        }

        try {
            const res = await Ref.pushNotificationQueue.add(data);
            await Library.delay(2000);
            const after = await res.get()
            expect(after.data()!.messageId).to.be.include('projects/');
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });


    it("send message via iosUsers topic", async () => {
        const userC = await Test.createUser();
        const post = await Test.createPost();
        const data: SendMessage = {
            title: 'Notification title iosUsers',
            body: 'Notification body',
            id: post.id,
            type: 'post',
            senderUid: userC.uid,
            topic: 'iosUsers'
        }

        try {
            const res = await Ref.pushNotificationQueue.add(data);
            await Library.delay(2000);
            const after = await res.get()
            expect(after.data()!.messageId).to.be.include('projects/');
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });

    it("send message via iosUsers topic", async () => {
        const userC = await Test.createUser();
        const post = await Test.createPost();
        const data: SendMessage = {
            title: 'Notification title webUsers',
            body: 'Notification body',
            id: post.id,
            type: 'post',
            senderUid: userC.uid,
            topic: 'webUsers'
        }

        try {
            const res = await Ref.pushNotificationQueue.add(data);
            await Library.delay(2000);
            const after = await res.get()
            expect(after.data()!.messageId).to.be.include('projects/');
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("Must success on sending a message to a token");
        }
    });


    it("send message via users uid", async () => {
        const userC = await Test.createUser();
        const post = await Test.createPost();
        const data: SendMessage = {
            title: 'Notification title',
            body: 'Notification body',
            id: post.id,
            type: 'post',
            senderUid: userC.uid,
            uids: userIdA
        }

        try {
            const res = await Ref.pushNotificationQueue.add(data);
            await Library.delay(2000);
            const after = await res.get();
            expect(after.data()!.success).to.be.equal(1);
            expect(after.data()!.error).to.be.equal(0);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("success with 1 success 0 error user must have 1 token only");
        }
    });

    it("send message via users token", async () => {

        const userC = await Test.createUser();
        const post = await Test.createPost();
        const data: SendMessage = {
            title: 'Notification title',
            body: 'Notification body',
            id: post.id,
            type: 'post',
            senderUid: userC.uid,
            tokens: userAToken
        }

        try {
            const res = await Ref.pushNotificationQueue.add(data);
            await Library.delay(2000);
            const after = await res.get();

            expect(after.data()!.success).to.be.equal(1);
            expect(after.data()!.error).to.be.equal(0);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("1 success and 0 error");
        }
    });

    it("send message via users token", async () => {

        const userC = await Test.createUser();
        const post = await Test.createPost();
        const data: SendMessage = {
            title: 'Notification title',
            body: 'Notification body',
            id: post.id,
            type: 'post',
            senderUid: userC.uid,
            tokens: [userAToken, 'abced-' + Test.id()]
        }

        try {
            const res = await Ref.pushNotificationQueue.add(data);
            await Library.delay(2000);
            const after = await res.get();
            expect(after.data()!.success).to.be.equal(1);
            expect(after.data()!.error).to.be.equal(1);
        } catch (e) {
            console.log((e as HttpsError).code, (e as HttpsError).message);
            expect.fail("1 error 1 succcess");
        }
    });
});
