
import { describe, it } from "mocha";


import { initFirebaseAdminSDK } from "../setup";
import {
    // QueryDocumentSnapshot,
    // WriteResult,
    getFirestore,
} from "firebase-admin/firestore";

import { Command } from "../../src/interfaces/command.interface";
import { CommandModel } from "../../src/models/command.model";
import { expect } from "chai";



initFirebaseAdminSDK();

//
describe("User custom claims - wrong uid", () => {



    it("Test on wrong uid", async () => {


        const db = getFirestore();

        // Create command doc
        const ref = await db.collection("easy-commands").add({
            command: 'update_custom_claims',
            uid: '.... wrong uid ....',
            claims: {
                level: 13
            }
        } satisfies Command);

        // Get doc
        const snapshot = await ref.get();


        // Execute command
        await CommandModel.execute(snapshot);

        const afterSnapshot = await ref.get();

        const response = afterSnapshot.data()?.response;
        expect(response?.status).equal('error');
        expect(response?.code).equal('auth/user-not-found');

    });
});


