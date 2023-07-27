
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
describe("Enable user command", () => {

    it("Disable with sync back", async () => {

        const user = await createTestUser();
        Config.userCollectionName = 'users';
        Config.setDisabledUserField = true;

        // Disable the user
        const db = getFirestore();
        const ref = await db.collection("easy-commands").add({
            command: 'disable_user',
            uid: user.uid
        } satisfies Command);
        await CommandModel.execute(await ref.get());

        // Check the user is disabled
        const userData = await UserModel.getDocument(user.uid);
        expect(userData?.disabled).equal(true);

        // Enable the user
        const ref2 = await db.collection("easy-commands").add({
            command: 'enable_user',
            uid: user.uid
        } satisfies Command);
        await CommandModel.execute(await ref2.get());


        const userAfterData = await UserModel.getDocument(user.uid);
        expect(userAfterData?.disabled).equal(void 0);
    });

});


