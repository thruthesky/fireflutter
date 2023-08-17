
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
describe("Disable command", () => {



    it("Disable with sync back", async () => {

        const user = await createTestUser();


        Config.userCollectionName = 'users';
        Config.setDisabledUserField = true;

        const db = getFirestore();

        // Create command doc
        const ref = await db.collection("easy-commands").add({
            command: 'disable_user',
            uid: user.uid
        } satisfies Command);

        await CommandModel.execute(await ref.get());

        const userData = await UserModel.getDocument(user.uid);
        expect(userData?.disabled).equal(true);
    });




    it("Disable without sync back", async () => {

        const user = await createTestUser();


        Config.userCollectionName = 'users';
        Config.setDisabledUserField = false;

        const db = getFirestore();

        // Create command doc
        const ref = await db.collection("easy-commands").add({
            command: 'disable_user',
            uid: user.uid
        } satisfies Command);

        await CommandModel.execute(await ref.get());

        const userData = await UserModel.getDocument(user.uid);
        expect(userData?.disabled).equal(void 0);
    });





});


