import * as admin from "firebase-admin";
import { describe, it } from "mocha";
import assert = require("assert");
// import { getDatabase } from "firebase-admin/database";
import { TypesenseService } from "../../src/typesense/typesense.service";
import { generateUser, randomString } from "../firebase-test-functions";
import { TypesenseDoc } from "../../src/typesense/typesense.interface";

if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Typsense Upsert, Update, Emplace Test (typesense/00.upsert.spec.ts)", () => {
    it("Index a document with at least the required (id, type) using Upsert", async () => {
        try {
            const uid = randomString();
            await TypesenseService.upsert({
                id: uid,
                type: "user",
             });
             assert.ok(true);
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "It should succeed. Check the required values. " + message);
        }
    });
    it("Upsert Test for newly created document - createdAt is optional", async () => {
        try {
            await TypesenseService.upsert({
                id: randomString(),
                type: "user",
            });
            assert.ok(true);
        } catch (e) {
            const message = (e as Error).message;
            if (message.indexOf("createdAt") > 0) {
                assert.ok(false, "createdAt is already optional, it should no longer be an error");
            } else {
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
    it("Upsert Failure test for newly created document (missing type)", async () => {
        try {
            await TypesenseService.upsert({
                id: randomString(),
            });
            assert.ok(false, "It must throw an error, since type is required");
        } catch (e) {
            const message = (e as Error).message;
            if (message.indexOf("`type`") > 0) {
                assert.ok(true, "type is missing");
            } else {
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
    it("Upsert Test for newly created document (missing uid)", async () => {
        try {
            await TypesenseService.upsert({
                id: randomString(),
                type: "user",
                createdAt: 12345,
            });
            assert.ok(true);
        } catch (e) {
            const message = (e as Error).message;
            if (message.indexOf("`uid`") > 0) {
                assert.ok(false, "uid is already optional, it should no longer be an error");
            } else {
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
    it("Upsert using generateUser()", async () => {
        try {
            const user = generateUser();
            await TypesenseService.upsert(user);
            const retrieveResult = await TypesenseService.retrieve(user.uid ?? "") as TypesenseDoc;
            if (retrieveResult.id === user.uid) {
                assert.ok(true);
            } else {
                assert.ok(false, "Something is wrong since the retrieved value is not the same. user.uid: " + user.uid + ", retrieved result id: " + retrieveResult.id);
            }
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "Unknown error: " + message);
        }
    });
    it("Emplace should have no problem if document doesn't exist", async () => {
        try {
            const id = randomString();
            const createdAt = 1919;
            await TypesenseService.emplace({ id: id, type: "user", createdAt: createdAt });
            const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;
            if (retrieveResult.createdAt === createdAt) {
                assert.ok(true);
            } else {
                assert.ok(false, "Something is wrong since the retrieved value is not the same. createdAt: " + createdAt + ", retrieveResult.createdAt: " + retrieveResult.createdAt);
            }
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "Unknown error: " + message);
        }
    });
    it("Emplace should have no problem if document already exists", async () => {
        try {
            const user = generateUser();
            const updateDisplayName = "displayName";

            await TypesenseService.upsert(user);
            await TypesenseService.emplace({ id: user.id, type: "user", displayName: updateDisplayName });

            const retrieveResult = await TypesenseService.retrieve(user.id ?? "") as TypesenseDoc;
            if (retrieveResult.displayName === updateDisplayName) {
                assert.ok(true);
            } else {
                assert.ok(false, "Something is wrong since the retrieved value is not the same. updateDisplayName: " + updateDisplayName + ", retrieveResult.displayName: " + retrieveResult.displayName);
            }
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "Unknown error: " + message);
        }
    });
    it("Emplace should not affect other fields if document already exists", async () => {
        try {
            const user = generateUser();
            const updateDisplayName = "displayName";

            await TypesenseService.upsert(user);
            await TypesenseService.emplace({ id: user.id, type: "user", displayName: updateDisplayName });

            const retrieveResult = await TypesenseService.retrieve(user.id ?? "") as TypesenseDoc;
            if (retrieveResult.displayName === updateDisplayName && retrieveResult.createdAt == user.createdAt) {
                assert.ok(true);
            } else {
                assert.ok(
                    false,
                    "Something is wrong since the retrieved value is not the same." +
                    "updateDisplayName: " + updateDisplayName +
                    ", retrieveResult.displayName: " + retrieveResult.displayName +
                    ", expected createdAt: " + user.createdAt +
                    ", retrieved createdAt: " + retrieveResult.createdAt,
                );
            }
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "Unknown error: " + message);
        }
    });
    it("Update should fail if document does not exist yet", async () => {
        try {
            const user = generateUser();
            await TypesenseService.update(user.uid ?? "", user);
            assert.ok(false, "it should be failing since document doesn't exist yet");
        } catch (e) {
            const message = (e as Error).message;
            if (message.indexOf("Could not find a document") > 0) {
                assert.ok(true);
            } else {
                console.log("Error: " + e);
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
    it("Update should succeed if document does exist yet", async () => {
        try {
            const user = generateUser();
            const updateDisplayName = "displayName";
            await TypesenseService.upsert(user);
            await TypesenseService.update(user.uid ?? "", { displayName: updateDisplayName });
            const retrieveResult = await TypesenseService.retrieve(user.id ?? "") as TypesenseDoc;
            if (retrieveResult.displayName === updateDisplayName && retrieveResult.createdAt == user.createdAt) {
                assert.ok(true);
            } else {
                assert.ok(
                    false,
                    "Something is wrong since the retrieved value is not the same." +
                    "updateDisplayName: " + updateDisplayName +
                    ", retrieveResult.displayName: " + retrieveResult.displayName +
                    ", expected createdAt: " + user.createdAt +
                    ", retrieved createdAt: " + retrieveResult.createdAt,
                );
            }
        } catch (e) {
            const message = (e as Error).message;
            if (message.indexOf("Could not find a document") > 0) {
                assert.ok(false, "Something is wrong since the document isn't found. Check upsert also.");
            } else {
                console.log("Error: " + e);
                assert.ok(false, "Unknown error: " + message);
            }
        }
    });
});

