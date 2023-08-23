import admin from "firebase-admin";
import { describe, it } from "mocha";


import { expect } from "chai";
import { initFirebaseAdminSDK } from "../setup";
import { Config } from "../../src/config";
import { UserModel } from "../../src/models/user.model";



initFirebaseAdminSDK();

//
describe("User sync backfill", () => {
    it("User sync backfill", async () => {


        // Get all users
        const snapshot = await admin.firestore().collection(Config.userCollectionName).get();
        const users: Record<string, Record<string, any>> = {};
        for (const doc of snapshot.docs) {
            users[doc.id] = doc.data();
        }

        Config.userSyncFields = 'displayName,name, firstName ,photoUrl,phoneNumber,createdAt';
        await UserModel.syncBackfill();


        // Check if all users are synced to user_search_data
        const syncedSnapshot = await admin.firestore().collection('user_search_data').get();
        expect(syncedSnapshot.docs.length).to.be.eq(snapshot.docs.length);

    });

});

