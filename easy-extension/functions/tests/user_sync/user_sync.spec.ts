import admin from "firebase-admin";
import { describe, it } from "mocha";


import { expect } from "chai";
import { createTestUserDocument, initFirebaseAdminSDK } from "../setup";
import { UserModel } from "../../src/models/user.model";
import { Config } from "../../src/config";



initFirebaseAdminSDK();

//
describe("User sync", () => {
    it("User sync", async () => {
        const doc = await createTestUserDocument({ displayName: 'test' });
        expect(doc).to.be.an("object");

        await UserModel.sync(await UserModel.ref(doc.uid).get());

        const user = await UserModel.getDocument(doc.uid);
        expect(user!['uid']).equal(doc.uid);


        // Generate a code to delay(or wait) for 1 seconds
        // await new Promise((resolve) => setTimeout(resolve, 3000));


        Config.userSyncFields = 'displayName,photoUrl,phoneNumber,firstName,createdAt';
        await UserModel.sync(await UserModel.ref(doc.uid).get());

        const snapshot = await admin.firestore().collection('user_search_data').doc(doc.uid).get();
        expect(snapshot.data()!['displayName']).equal(doc.displayName);

        const databaseSnapshot = await admin.database().ref(`users/${doc.uid}`).get();
        expect(databaseSnapshot.val()['displayName']).equal(doc.displayName);

    });

});

