import * as admin from "firebase-admin";
import { describe, it } from "mocha";
import assert = require("assert");
// import { getDatabase } from "firebase-admin/database";
import { TypesenseService } from "../../src/typesense/typesense.service";

if (admin.apps.length === 0) {
    admin.initializeApp();
}


/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Index a new user", () => {
    it("Index newly created user document", async () => {
        try {
            await TypesenseService.upsertUser({ displayName: "new-name" });
            assert.ok(false, "It must throw an error");
        } catch (e: any) {
            const message = e.message;
            if (message.indexOf("createddAt") > 0) {
                assert.ok(true, "createdAt is missing");
            } else {
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
    it("Failure test for newly created user document", async () => {
        // 1. create a database document for the new user with wrong data.
        // 2. call the index method.
        // 3. make sure if there is a proper error.
    });
});

