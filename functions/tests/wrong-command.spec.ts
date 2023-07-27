
import { describe, it } from "mocha";


import { initFirebaseAdminSDK } from "./setup";
import {
    // QueryDocumentSnapshot,
    // WriteResult,
    getFirestore,
} from "firebase-admin/firestore";

import { Command } from "./../src/interfaces/command.interface";
import { CommandModel } from "./../src/models/command.model";
import { expect } from "chai";



initFirebaseAdminSDK();

//
describe("Wrong command", () => {



    it("Test on wrong command", async () => {


        const db = getFirestore();

        // Create command doc
        const ref = await db.collection("easy-commands").add({
            command: '...wrong-command...'
        });

        // Get doc
        const snapshot = await ref.get();


        // Execute command
        await CommandModel.execute(snapshot);

        const afterSnapshot = await ref.get();

        // console.log('afterSnapshot.data() ', afterSnapshot.data());

        const data = afterSnapshot.data() as Command;
        const response = data.response;
        expect(response?.status).equal('error');
        expect(response?.code).equal('execution/command-not-found');


    });
});



