
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



initFirebaseAdminSDK();

//
describe("User custom claims", () => {



    it("Update claims with command", async () => {

        const user = await createTestUser();

        const db = getFirestore();

        // Create command doc
        const ref = await db.collection("easy-commands").add({
            command: 'update_custom_claims',
            uid: user.uid,
            claims: {
                level: 13
            }
        } satisfies Command);

        // Get doc
        const snapshot = await ref.get();

        // Execute command
        await CommandModel.execute(snapshot);

        // Check claims
        const claims = await UserModel.getCustomClaims(user.uid);

        // Test
        expect(claims?.level).equal(13);



        // Do it again with different options
        const againRef = await db.collection("easy-commands").add({
            command: 'update_custom_claims',
            uid: user.uid,
            claims: {
                level: 14,
                groupName: 'writer'
            }
        } satisfies Command);


        // Execute command
        await CommandModel.execute(await againRef.get());

        // Get doc after command execution
        const afterSnapshot = await againRef.get();
        const afterDocData = afterSnapshot.data() as Command;
        const response = afterDocData.response!;

        // Test
        expect(response.status).equal('success');
        expect(response.claims?.level).equal(14);
        // expect(response.code).equal('auth/user-not-found');

    });
});


