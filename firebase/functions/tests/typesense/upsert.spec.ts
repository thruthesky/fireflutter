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
describe("Upserting in Typsense (typesense/upsert.spec.ts)", () => {
    it("Index a document with at least the required (id, type, createdAt)", async () => {
        try {
            const uid = randomString();
            await TypesenseService.upsert({
                id: uid,
                uid: uid,
                type: "user",
                createdAt: 12345,
             });
             assert.ok(true);
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "It should succeed. Check the required values. " + message);
        }
    });
    it("Failure test for newly created document (missing createdAt)", async () => {
        try {
            await TypesenseService.upsert({
                id: randomString(),
            });
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
    it("Failure test for newly created document (missing type)", async () => {
        try {
            await TypesenseService.upsert({
                id: randomString(),
                createdAt: 12345,
            });
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
    it("Failure test for newly created document (missing uid)", async () => {
        try {
            await TypesenseService.upsert({
                id: randomString(),
                type: "user",
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
    // it("Upsert using generatePost()", async () => {
    //     try {
    //         const post = generatePost();
    //         await TypesenseService.upsert(post);
    //         const retrieveResult = await TypesenseService.retrieve(post.id ?? "") as TypesenseDoc;
    //         if (retrieveResult.id === post.id) {
    //             assert.ok(true);
    //         } else {
    //             assert.ok(false, "Something is wrong since the retrieved value is not the same. post.id: " + post.id + ", retrieved result id: " + retrieveResult.id);
    //         }
    //     } catch (e) {
    //         const message = (e as Error).message;
    //         assert.ok(false, "Unknown error: " + message);
    //     }
    // });
    // it("Upsert using generateComment()", async () => {
    //     try {
    //         const comment = generateComment();
    //         await TypesenseService.upsert(comment);
    //         const retrieveResult = await TypesenseService.retrieve(comment.id ?? "") as TypesenseDoc;
    //         if (retrieveResult.id === comment.id) {
    //             assert.ok(true);
    //         } else {
    //             assert.ok(false, "Something is wrong since the retrieved value is not the same. comment.id: " + comment.id + ", retrieved result id: " + retrieveResult.id);
    //         }
    //     } catch (e) {
    //         const message = (e as Error).message;
    //         assert.ok(false, "Unknown error: " + message);
    //     }
    // });
});

