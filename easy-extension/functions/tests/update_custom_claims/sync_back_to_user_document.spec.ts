
import { describe, it } from "mocha";


import { expect } from "chai";
import { createTestUser, initFirebaseAdminSDK } from "../setup";
import { UserModel } from "../../src/models/user.model";

import {
    // QueryDocumentSnapshot,
    // WriteResult,
    getFirestore,
} from "firebase-admin/firestore";

import { Command } from "../../src/interfaces/command.interface";
import { CommandModel } from "../../src/models/command.model";
import { Config } from "../../src/config";



initFirebaseAdminSDK();

//
describe("Sync back custom claims", () => {



    it("Update claims and sync back test", async () => {

        const user = await createTestUser();


        Config.userCollectionName = 'users';
        Config.setDisabledUserField = true;
        Config.syncCustomClaimsToUserDocument = true;

        const db = getFirestore();


        // Create command doc
        const ref = await db.collection("easy-commands").add({
            command: 'update_custom_claims',
            uid: user.uid,
            claims: {
                a: 'apple',
                b: 'banana',
                level: 13
            }
        } satisfies Command);

        await CommandModel.execute(await ref.get());

        const userData = await UserModel.getDocument(user.uid);
        expect(userData?.claims?.level).equal(13);
    });



    it("Update claims but no sync back", async () => {

        const user = await createTestUser();


        Config.userCollectionName = 'users';
        Config.setDisabledUserField = true;
        Config.syncCustomClaimsToUserDocument = false;

        const db = getFirestore();


        // Create command doc
        const ref = await db.collection("easy-commands").add({
            command: 'update_custom_claims',
            uid: user.uid,
            claims: {
                a: 'apple',
                b: 'banana',
                level: 13
            }
        } satisfies Command);

        await CommandModel.execute(await ref.get());
        const userData = await UserModel.getDocument(user.uid);
        expect(userData?.claims).equal(undefined);
    });



});


