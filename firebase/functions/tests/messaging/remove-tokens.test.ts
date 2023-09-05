import "mocha";
import "../firebase.init";


import * as admin from "firebase-admin";


import { Test } from "../test";
import { User } from "../../src/models/user.model";

import { expect } from "chai";


import { Messaging } from "../../src/models/messaging.model";


describe("Messaging tokens", () => {
    it("Remove a tokens under /users/fcm_tokens/{tokenId}", async () => {

        const tokenA1 = "token-a-1" + Test.id();
        const tokenA2 = "token-a-2" + Test.id();
        const tokenB1 = "token-b-1" + Test.id();
        const tokenB2 = "token-b-2" + Test.id();

        const userA = await Test.createUser();
        await User.SetFcmToken({
            fcm_token: tokenA1,
            device_type: "android",
            uid: userA.uid,
        });
        await User.SetFcmToken({
            fcm_token: tokenA2,
            device_type: "android",
            uid: userA.uid,
        });

        const userB = await Test.createUser();
        await User.SetFcmToken({
            fcm_token: tokenB1,
            device_type: "android",
            uid: userB.uid,
        });
        await User.SetFcmToken({
            fcm_token: tokenB2,
            device_type: "android",
            uid: userB.uid,
        });

        let snapshot = await admin
            .firestore()
            .collectionGroup("fcm_tokens")
            .where("fcm_token", "==", tokenA1)
            .get();
        expect(snapshot.docs.length).equals(1);

        await Messaging.removeTokens([tokenA1, tokenB2]);


        snapshot = await admin
            .firestore()
            .collectionGroup("fcm_tokens")
            .where("fcm_token", "==", tokenA1)
            .get();
        expect(snapshot.docs.length).equals(0);
        snapshot = await admin
            .firestore()
            .collectionGroup("fcm_tokens")
            .where("fcm_token", "==", tokenA2)
            .get();
        expect(snapshot.docs.length).equals(1);
        snapshot = await admin
            .firestore()
            .collectionGroup("fcm_tokens")
            .where("fcm_token", "==", tokenB1)
            .get();
        expect(snapshot.docs.length).equals(1);
        snapshot = await admin
            .firestore()
            .collectionGroup("fcm_tokens")
            .where("fcm_token", "==", tokenB2)
            .get();
        expect(snapshot.docs.length).equals(0);


        await Messaging.removeTokens([tokenA1, tokenA2, tokenB1, tokenB2]);

    });
});
