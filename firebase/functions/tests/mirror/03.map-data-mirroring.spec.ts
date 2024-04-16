import * as admin from "firebase-admin";
import { setTimeout } from "timers/promises";
import { describe, it } from "mocha";
import assert = require("assert");
import { randomString } from "../firebase-test-functions";
import { FirestorePostWithExtra } from "../../src/mirror/firestore.interface";

if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
        projectId: "withcenter-test-3",
    });
}

const category = "map-test";
const postCollection = "posts";

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Mirroring Posts (mirror/03.map-data-mirroring.spec.ts)", () => {
    it("The Mirrored post with a Map in Firestore must have the same values in RTDB", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData: FirestorePostWithExtra = {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            urls: ["url1", "url2"],
            createdAt: 12345,
            order: -1,
            mapField: {
                test: 1,
            },
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data() as FirestorePostWithExtra;
        if (retrievePost.uid === postData.uid &&
            retrievePost.title === postData.title &&
            retrievePost.content === postData.content &&
            retrievePost.createdAt === postData.createdAt &&
            retrievePost.order === postData.order &&
            retrievePost.urls?.[0] === postData.urls?.[0] &&
            retrievePost.urls?.[1] === postData.urls?.[1] &&
            retrievePost.mapField?.test == postData.mapField?.test &&
            retrievePost.mapField?.test == 1) {
            // means doc exist as same value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("Update a value in the map and it should be updated in Firestore as well", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            urls: ["url1", "url2"],
            createdAt: 12345,
            order: -1,
            mapField: {
                test: 1,
                test2: {
                    mapVal1: 1,
                    mapVal2: 2,
                },
            },
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Update a value in the map
        const updatePostData = {
            mapField: {
                test: 1,
                test2: {
                    mapVal1: 3,
                    mapVal2: 4,
                },
            },
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).update(updatePostData);

        // 3. Wait for 10 seconds
        await setTimeout(10000);

        // 4. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data();
        if (retrievePost?.uid === postData.uid &&
            retrievePost.title === postData.title &&
            retrievePost.content === postData.content &&
            retrievePost.createdAt === postData.createdAt &&
            retrievePost.order === postData.order &&
            retrievePost.urls?.[0] === postData.urls?.[0] &&
            retrievePost.urls?.[1] === postData.urls?.[1] &&
            retrievePost.mapField?.test == updatePostData.mapField?.test &&
            retrievePost.mapField?.test2.mapVal1 == updatePostData.mapField?.test2.mapVal1 &&
            retrievePost.mapField?.test2.mapVal2 == updatePostData.mapField?.test2.mapVal2) {
            // means doc exist as same value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("Update a value in the map and it should be updated in Firestore as well (2)", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            urls: ["url1", "url2"],
            createdAt: 12345,
            order: -1,
            mapField: {
                test: 1,
                test2: {
                    mapVal1: 1,
                    mapVal2: 2,
                },
            },
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Update a value in the map
        const newValue = 59;
        await admin.database().ref(postCollection + "/" + category + "/" + id +"/mapField/test2/mapVal2").set(newValue);

        // 3. Wait for 10 seconds
        await setTimeout(10000);

        // 4. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data();
        if (retrievePost?.uid === postData.uid &&
            retrievePost.title === postData.title &&
            retrievePost.content === postData.content &&
            retrievePost.createdAt === postData.createdAt &&
            retrievePost.order === postData.order &&
            retrievePost.urls?.[0] === postData.urls?.[0] &&
            retrievePost.urls?.[1] === postData.urls?.[1] &&
            retrievePost.mapField?.test == postData.mapField?.test &&
            retrievePost.mapField?.test2.mapVal1 == postData.mapField?.test2.mapVal1 &&
            retrievePost.mapField?.test2.mapVal2 == newValue) {
            // means doc exist as same value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("Add a map field by updating an existing post in RTDB and it should be updated in Firestore as well", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData: FirestorePostWithExtra = {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            urls: ["url1", "url2"],
            createdAt: 12345,
            order: -1,
            mapField: {
                test: 88,
            },
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Update a value in the map
        const fieldValue = 79;
        await admin.database().ref(postCollection + "/" + category + "/" + id +"/mapField/test2/mapVal/lastField").set(fieldValue);

        // 3. Wait for 10 seconds
        await setTimeout(10000);

        // 4. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data();
        if (retrievePost?.uid === postData.uid &&
            retrievePost?.title === postData.title &&
            retrievePost?.content === postData.content &&
            retrievePost?.createdAt === postData.createdAt &&
            retrievePost?.order === postData.order &&
            retrievePost?.urls?.[0] === postData.urls?.[0] &&
            retrievePost?.urls?.[1] === postData.urls?.[1] &&
            retrievePost?.mapField?.test == postData.mapField?.test &&
            retrievePost?.mapField?.test2.mapVal.lastField == fieldValue &&
            retrievePost?.mapField?.test2.mapVal.lastField !== undefined
        ) {
            // means doc exist as same value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("Add a map field by updating an existing post in RTDB and it should be updated in Firestore as well (2)", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            urls: ["url1", "url2"],
            createdAt: 12345,
            order: -1,
            mapField: {
                test: {
                    mapVal: {
                        lastField: "Test-123",
                    },
                },
            },
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Update a value in the map
        const fieldValue = 49;
        await admin.database().ref(postCollection + "/" + category + "/" + id +"/mapField/test/mapVal/lastField2").set(fieldValue);

        // 3. Wait for 10 seconds
        await setTimeout(10000);

        // 4. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data();
        if (retrievePost?.uid === postData.uid &&
            retrievePost?.title === postData.title &&
            retrievePost?.content === postData.content &&
            retrievePost?.createdAt === postData.createdAt &&
            retrievePost?.order === postData.order &&
            retrievePost?.urls?.[0] === postData.urls?.[0] &&
            retrievePost?.urls?.[1] === postData.urls?.[1] &&
            retrievePost?.mapField?.test.mapVal.lastField == postData.mapField?.test.mapVal.lastField &&
            retrievePost?.mapField?.test.mapVal.lastField2 == fieldValue &&
            retrievePost?.mapField?.test.mapVal.lastField2 !== undefined
        ) {
            // means doc exist as same value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
});

