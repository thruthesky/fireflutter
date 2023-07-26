
import { describe, it } from "mocha";


import { expect } from "chai";
import { createTestUser, initFirebaseAdminSDK } from "../setup";
import { UserModel } from "../../src/models/user.model";

initFirebaseAdminSDK();

//
describe("User custom claims", () => {


    it("claim level test", async () => {
        const user = await createTestUser();
        await UserModel.setCustomClaims(user.uid, { level: 12 });
        const claims = await UserModel.getCustomClaims(user.uid);
        expect(claims?.level).equal(12);
    });

});
