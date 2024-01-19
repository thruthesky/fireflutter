import * as admin from "firebase-admin";
import { setTimeout } from "timers/promises";
import { describe, it } from "mocha";
import assert = require("assert");
// import { getDatabase } from "firebase-admin/database";
import { TypesenseService } from "../../src/typesense/typesense.service";
import { TypesenseUser } from "../../src/typesense/typesense.interface";
import { randomString } from "../firebase-functions";

if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Index a new user", () => {
    it("Index a user document", async () => {
        // 1. create a database document for the new user with wrong data.
        // 2. call the index method.
        // 3. make sure if there is a proper error.

        try {
            await TypesenseService.upsertUser({
                type: "user",
                uid: "uid-a",
                displayName: "new-name",
                createdAt: 12345,
             });
             assert.ok(true);
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "it should succeed. check the required values: " + message);
        }
    });
    it("Failure test for newly created user document (missing createdAt)", async () => {
        try {
            await TypesenseService.upsertUser({ displayName: "new-name" });
            assert.ok(false, "It must throw an error");
        } catch (e) {
            const message = (e as Error).message;
            if (message.indexOf("createdAt") > 0) {
                assert.ok(true, "createdAt is missing");
            } else {
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
    it("Failure test for newly created user document (missing type)", async () => {
        try {
            await TypesenseService.upsertUser({ displayName: "new-name", createdAt: 12345 });
            assert.ok(false, "It must throw an error");
        } catch (e) {
            const message = (e as Error).message;
            if (message.indexOf("`type`") > 0) {
                assert.ok(true, "type is missing");
            } else {
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
    it("Failure test for newly created user document (missing uid)", async () => {
        try {
            await TypesenseService.upsertUser({
            type: "user",
            displayName: "new-name",
            createdAt: 12345,
         });
            assert.ok(false, "It must throw an error");
        } catch (e) {
            const message = (e as Error).message;
            if (message.indexOf("`uid`") > 0) {
                assert.ok(true, "uid is missing");
            } else {
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
    it("Index a newly created user from RTDB", async () => {
        // 1. set user uid in RTDB
        const userUid = randomString();
        const userData = {
            uid: userUid,
            displayName: "name-b",
            createdAt: 123123,
            type: "user",
        } as TypesenseUser;
        await admin.database().ref("users/" + userUid).set(userData);

        // 2. wait for 5 seconds
        await setTimeout(5000);

        // 3. search for the document in Typesense
        const searchResult = await TypesenseService.searchUser({ filterBy: "uid:=" + userUid });
        if (searchResult.hits?.length == 1) {
            // means user exist in Typesense
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
        }
    });
    it("Reindex an exisiting user upon edit in RTDB", async () => {
        // 1. create new user in RTDB
        const userUid = randomString();
        const userData = {
            uid: userUid,
            displayName: "name-b",
            createdAt: 123123,
            type: "user",
        } as TypesenseUser;
        await admin.database().ref("users/" + userUid).set(userData);

        // 2. wait for 5 seconds
        await setTimeout(5000);

        // 3. update the user in RTDB
        const updatedUserData = {
            uid: userUid,
            displayName: "name-c",
            createdAt: 123123,
            type: "user",
        } as TypesenseUser;
        await admin.database().ref("users/" + userUid).update(updatedUserData);

        // 4. wait for 5 seconds
        await setTimeout(8000);

        console.log("user uid: " + userUid);

        // 5. search for the document in typesense
        const searchResult = await TypesenseService.searchUser({ filterBy: "uid:=" + userUid });

        // 6. check if the doc is the updated info
        if (searchResult.hits?.length == 1) {
            // means user exist in Typesense
            const resultDoc = searchResult.hits[0].document as TypesenseUser;
            if (resultDoc.uid === userUid && resultDoc.displayName === updatedUserData.displayName) {
                assert.ok(true);
            } else {
                assert.ok(false, "Either there is an error, more latency, or the data saved is wrong");
            }
        } else {
            assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
        }
    });
});

