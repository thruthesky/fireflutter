/**
 *
 * To test, run the following command:
 * ```
 * npm run test:userDeleteAccount
 * ```
 */
import * as admin from "firebase-admin";
import { describe, it } from "mocha";
import assert = require("assert");
import { UserService } from "../../src/user/user.service";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "https://withcenter-test-3-default-rtdb.firebaseio.com",
    });
}

describe("user delete account test", () => {
    it("delete with undefined uid -> no-uid", async () => {
        const re = await UserService.deleteAccount(undefined);
        assert.ok(re.code === "no-uid", re.message);
    });
    it("delete with empty uid -> no-uid", async () => {
        const re = await UserService.deleteAccount("");
        assert.ok(re.code === "no-uid", re.message);
    });


    it("delete with wrong user uid -> auth/user-not-found", async () => {
        const uid = "wrong-user-uid";
        const re = await UserService.deleteAccount(uid);
        assert.ok(re.code === "auth/user-not-found", "user not found by that uid");
    });

    it("delete with real user uid", async () => {
        // 1. Create user account with email/password in Firebase Auth
        const auth = admin.auth();
        const userRecord = await auth.createUser({
            email: "test" + (new Date).getTime() + "@email.com",
            password: "password12345a,*",
        });

        const re = await UserService.deleteAccount(userRecord.uid);
        assert.ok(re.code === "ok", "user account deleted");
    });
});

