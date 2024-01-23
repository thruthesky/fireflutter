import * as admin from "firebase-admin";
import { setTimeout } from "timers/promises";
import { describe, it } from "mocha";
import assert = require("assert");
// import { getDatabase } from "firebase-admin/database";
import { TypesenseService } from "../../src/typesense/typesense.service";
import { TypesenseDoc } from "../../src/typesense/typesense.interface";
import { randomString } from "../firebase-test-functions";

if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Indexing Users (typesense/user-indexing.spec.ts)", () => {
    it("Index a user document (TypesenseService.upsert test)", async () => {
        // 1. create a database document for the new user.
        // 2. call the index method.
        // 3. make sure if there is a proper error.

        try {
            await TypesenseService.upsert({
                id: randomString(),
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
    it("Index a newly created user from RTDB", async () => {
        // 1. set user uid in RTDB
        const userUid = randomString();
        const userData = {
            id: userUid,
            uid: userUid,
            displayName: "name-b",
            createdAt: 123123,
            type: "user",
        } as TypesenseDoc;
        await admin.database().ref("users/" + userUid).set(userData);

        // 2. wait for 5 seconds
        await setTimeout(5000);

        // 3. search for the document in Typesense
        // const searchResult = await TypesenseService.searchUser({ filterBy: "id:=" + userUid });
        const retrieveResult = await TypesenseService.retrieve(userUid) as TypesenseDoc;
        if (retrieveResult.id === userUid) {
            // means user exist in Typesense
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
        }
    });
    it("Reindex an exisiting user upon edit in RTDB", async () => {
        try {
            // 1. create new user in RTDB
            const userUid = randomString();
            const userData = {
                id: userUid,
                uid: userUid,
                displayName: "name-b",
                createdAt: 123123,
                type: "user",
            } as TypesenseDoc;
            await admin.database().ref("users/" + userUid).set(userData);
            // console.log("Expecting insert. user uid: " + userUid);

            // 2. wait for 5 seconds
            await setTimeout(5000);

            // 3. update the user in RTDB
            const updatedUserData = {
                id: userUid,
                uid: userUid,
                displayName: "updated-name-c",
                createdAt: 123123,
                type: "user",
            } as TypesenseDoc;
            await admin.database().ref("users/" + userUid).set(updatedUserData);
            // console.log("Expecting update. user uid: " + userUid);

            // 4. wait for 10 seconds
            await setTimeout(10000);

            // 5. search for the document in typesense
            // const searchResult = await TypesenseService.searchUser({ filterBy: "id:=" + userUid });
            const retrieveResult = await TypesenseService.retrieve(userUid) as TypesenseDoc;

            // 6. check if the doc is the updated info
            if (retrieveResult.id === userUid) {
                // console.log("search result: " + retrieveResult.displayName);
                // console.log("userData: " + userData.displayName);
                // console.log("updatedUserData: " + updatedUserData.displayName);

                // means user exist in Typesense
                // const resultDoc = searchResult.hits[0].document as TypesenseDoc;
                if (retrieveResult.displayName === updatedUserData.displayName) {
                    assert.ok(true);
                } else {
                    // assert.ok(false, "Either there is an error, more latency, or the data saved is wrong.");
                    assert.ok(false);
                }
            } else {
                assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
            }
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "it should succeed. Something went wrong. " + message);
        }
    });
    it("Remove document in Typesense when it was deleted in RTDB", async () => {
        // 1. Create a new user record in RTDB
        const userUid = randomString();
        const userData = {
            id: userUid,
            uid: userUid,
            displayName: "name-b",
            createdAt: 123123,
            type: "user",
        } as TypesenseDoc;
        await admin.database().ref("users/" + userUid).set(userData);
        // console.log("Expecting insert. user uid: " + userUid);

        // 2. Wait for 5 seconds
        await setTimeout(5000);

        // 3. Delete the record in RTDB
        await admin.database().ref("users/" + userUid).set(null);

        // 4. Wait for 5 seconds
        await setTimeout(5000);

        // 5. Check if record exist
        const searchResult = await TypesenseService.searchUser({ filterBy: "id:=" + userUid });
        // const retrieveResult = await TypesenseService.retrieveUser(userUid);
        // console.log("Should be deleted: " + searchResult.hits?.length);

        if (searchResult.hits?.length == 0) {
            assert.ok(true);
        } else {
            assert.ok(false, "Should have no results");
        }
    });
});

