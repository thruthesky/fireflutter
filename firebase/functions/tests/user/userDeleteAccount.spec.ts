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
import { Config } from "../../src/config";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "https://withcenter-test-3-default-rtdb.firebaseio.com",
    });
}

describe("user delete account test", () => {
    it("delete with wrong user uid -> auth/user-not-found", async () => {
        const uid = "wrong-user-uid";
        const db = admin.database();
        try {
            await UserService.deleteAccount(uid);
            const snapshot = await db.ref(`${Config.commands}/${uid}`).get();
            console.log('snapshot.val()', snapshot.val());
            assert.ok(snapshot.val()['deleteAccountResult'] === false, "...");
        } catch (e) {
            // console.error(e);
            assert.ok((e as any).code === "auth/user-not-found", "...");
        }
    });

    it("delete with real user uid", async () => {
        // 1. Create user account with email/password in Firebase Auth
        const auth = admin.auth();
        const userRecord = await auth.createUser({
            email: "test" + (new Date).getTime() + "@email.com",
            password: "password12345a,*",
        });

        // console.log('userRecord', userRecord);


        const db = admin.database();
        try {
            await UserService.deleteAccount(userRecord.uid);

            const snapshot = await db.ref(`${Config.commands}/${userRecord.uid}`).get();
            console.log('snapshot.val()', snapshot.val());
            assert.ok(snapshot.val()['deleteAccountResult'] === true, "...");

        } catch (e) {
            // console.error(e);
            assert.ok((e as any).code === "----", "...");
        }
    });
});

