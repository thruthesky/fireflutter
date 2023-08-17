
import { describe, it } from "mocha";


import { expect } from "chai";
import { createTestUser, initFirebaseAdminSDK } from "../setup";
// import { UserModel } from "../../src/models/user.model";
import { getFirestore } from "firebase-admin/firestore";
import { Command } from "../../src/interfaces/command.interface";
import { CommandModel } from "../../src/models/command.model";


initFirebaseAdminSDK();

//
describe("Get user", () => {

    it("Get user - failure - invalid-field", async () => {

        /// generate random string email with math random
        const email = Math.random().toString(36).substring(7) + '@gmail.com';

        const user = await createTestUser({ email });
        // Disable the user
        const db = getFirestore();
        const ref = await db.collection("easy-commands").add({
            command: 'get_user',
            by: '---xxx---',
            value: user.email
        } satisfies Command);

        await CommandModel.execute(await ref.get());

        const commandDocSnapshot = await ref.get();
        const data = commandDocSnapshot.data();

        expect(data?.response?.status).equal('error');
        expect(data?.response?.code).equal('get_user/invalid-field');
    });

    it("Get user - failure - invalid value", async () => {

        /// generate random string email with math random
        const email = Math.random().toString(36).substring(7) + '@gmail.com';

        await createTestUser({ email });
        // Disable the user
        const db = getFirestore();
        const ref = await db.collection("easy-commands").add({
            command: 'get_user',
            by: 'email',
            value: 'xxxxxxxxx@email.com',
        } satisfies Command);

        await CommandModel.execute(await ref.get());

        const commandDocSnapshot = await ref.get();
        const data = commandDocSnapshot.data();


        expect(data?.response?.status).equal('error');
        expect(data?.response?.code).equal('auth/user-not-found');
    });

    it("Get user - success - by email", async () => {

        /// generate random string email with math random
        const email = Math.random().toString(36).substring(7) + '@gmail.com';

        const user = await createTestUser({ email });
        // Disable the user
        const db = getFirestore();
        const ref = await db.collection("easy-commands").add({
            command: 'get_user',
            by: 'email',
            value: user.email
        } satisfies Command);

        await CommandModel.execute(await ref.get());

        const commandDocSnapshot = await ref.get();
        const data = commandDocSnapshot.data();
        console.log('doc', data);

        expect(data?.response?.data?.email).equal(email);
    });

    it("Get user - success - by uid", async () => {

        /// generate random string email with math random
        const email = Math.random().toString(36).substring(7) + '@gmail.com';

        const user = await createTestUser({ email });
        // Disable the user
        const db = getFirestore();
        const ref = await db.collection("easy-commands").add({
            command: 'get_user',
            by: 'uid',
            value: user.uid
        } satisfies Command);

        await CommandModel.execute(await ref.get());

        const commandDocSnapshot = await ref.get();
        const data = commandDocSnapshot.data();
        console.log('doc', data);

        expect(data?.response?.data?.uid).equal(user.uid);
    });

    it("Get user - success - by phoneNumber", async () => {

        const user = await createTestUser();
        // Disable the user
        const db = getFirestore();
        const ref = await db.collection("easy-commands").add({
            command: 'get_user',
            by: 'phoneNumber',
            value: user.phoneNumber
        } satisfies Command);

        await CommandModel.execute(await ref.get());

        const commandDocSnapshot = await ref.get();
        const data = commandDocSnapshot.data();
        console.log('doc', data);

        expect(data?.response?.data?.phoneNumber).equal(user.phoneNumber);
    });




});


