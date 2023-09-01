import "mocha";
import "../firebase.init";



import { Test } from "../test";
import { User } from "../../src/models/user.model";

import { expect } from "chai";


describe("Save token", () => {
    it("Save a token under /users/fcm_tokens/a-token-1", async () => {
        const a = await Test.createUser();
        await User.SetFcmToken({
            fcm_token: 'a-token-1',
            device_type: 'android',
            uid: a.uid,
        });


        const re = await User.GetFcmToken({
            fcm_token: 'a-token-1',
            uid: a.uid,
        });

        expect(re.device_type).to.be.eq('android');

    });
});