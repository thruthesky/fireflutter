
import { describe, it } from "mocha";


import { expect } from "chai";
import { createTestUserDocument, initFirebaseAdminSDK } from "../setup";
import { UserModel } from "../../src/models/user.model";


initFirebaseAdminSDK();

//
describe("User sync", () => {
    it("User sync", async () => {
        const doc = await createTestUserDocument();
        console.log('user doc', doc);

        expect(doc).to.be.an("object");

        await UserModel.sync(await UserModel.ref(doc.uid).get());

        // TODO check if the sync user document is created.
        // TODO - 1. Read /user_search_data and check
        // TODO - 2. Read /users in rtdb and check.


    });

});
