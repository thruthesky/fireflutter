
import { describe, it } from "mocha";


import { expect } from "chai";
import { createTestUser, initFirebaseAdminSDK } from "../setup";
import { UserModel } from "../../src/models/user.model";
import { getFirestore } from "firebase-admin/firestore";
import { Command } from "../../src/interfaces/command.interface";
import { CommandModel } from "../../src/models/command.model";


initFirebaseAdminSDK();

//
describe("User create & delete", () => {

    it("User create", async () => {

        /// generate random string email with math random
        const email = Math.random().toString(36).substring(7) + '@gmail.com';

        const user = await createTestUser({ email });
        await UserModel.createDocument(user.uid, UserModel.popuplateUserFields(user));
        const data = await UserModel.getDocument(user.uid);

        expect(data?.email).equal(email);
    });

    it("User delete document", async () => {
        /// generate random string email with math random
        const email = Math.random().toString(36).substring(7) + '@gmail.com';

        const user = await createTestUser({ email });
        await UserModel.createDocument(user.uid, UserModel.popuplateUserFields(user));
        const data = await UserModel.getDocument(user.uid);
        expect(data?.email).equal(email);

        await UserModel.deleteDocument(user.uid);
        const data2 = await UserModel.getDocument(user.uid);
        expect(data2).equal(undefined);
    });


    it("User delete account by command", async () => {
        /// generate random string email with math random
        const email = Math.random().toString(36).substring(7) + '@gmail.com';

        const user = await createTestUser({ email });
        // Disable the user
        const db = getFirestore();
        const ref = await db.collection("easy-commands").add({
            command: 'delete_user',
            uid: user.uid
        } satisfies Command);
        await CommandModel.execute(await ref.get());

        // !Warning - Test on real Firebase will not work if the 'deleteUserDocument' cloud function is not deployed
        // await new Promise(resolve => setTimeout(resolve, 100));
        // const data2 = await UserModel.getDocument(user.uid);
        // expect(data2).equal(undefined);
    });

});


