import * as admin from "firebase-admin";
import { setTimeout } from "timers/promises";
import { describe, it } from "mocha";
import assert = require("assert");
import { randomString } from "../firebase-test-functions";
import { PostCreateEvent, PostUpdateEvent } from "../../src/forum/forum.interface";
import { FirestorePost } from "../../src/mirror/firestore.interface";

if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
        projectId: "withcenter-test-3",
    });
}

const category = "category";
const postCollection = "posts";

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Mirroring Posts (mirror/01.post-mirroring.spec.ts)", () => {
    it("Mirror a newly created post from RTDB", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "title-post",
            content: "content-post",
            deleted: false,
            createdAt: 12345,
            order: 1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();

        if (retrieveResult.exists) {
            // means doc exist in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The Mirrored post in Firestore must have the same values in RTDB", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData: PostCreateEvent= {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            urls: ["url1", "url2"],
            createdAt: 12345,
            order: -1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data() as FirestorePost;
        if (retrievePost.uid === postData.uid &&
            retrievePost.title === postData.title &&
            retrievePost.content === postData.content &&
            retrievePost.deleted === postData.deleted &&
            retrievePost.createdAt === postData.createdAt &&
            retrievePost.order === postData.order &&
            retrievePost.urls?.[0] === postData.urls?.[0] &&
            retrievePost.urls?.[1] === postData.urls?.[1]) {
            // means doc exist as same value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The Mirrored post from RTDB must have the category field in Firestore", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData: PostCreateEvent= {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
            order: -1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data() as FirestorePost;
        if (retrievePost.category === category) {
            // means doc exist and has the correct category value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The Mirrored post from RTDB must have the category field in Firestore", async () => {
        const qnaCategory = "qna";

        // 1. Set post in RTDB
        const id = randomString();
        const postData: PostCreateEvent= {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
            order: -1,
        };
        await admin.database().ref(postCollection + "/" + qnaCategory + "/" + id).set(postData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data() as FirestorePost;
        if (retrievePost.category === qnaCategory) {
            // means doc exist and has the correct category value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The Updated post in RTDB, so it must be updated in Firestore as well", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData: PostCreateEvent = {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
            order: -1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Update the record in Firebase
        const updatePostData: PostUpdateEvent = {
            title: "updated-post-title",
            content: "updated-post-content",
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).update(updatePostData);

        // 4. Wait for 10 seconds.
        await setTimeout(10000);

        // 5. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data() as FirestorePost;
        if (retrievePost.uid === postData.uid &&
            retrievePost.title === updatePostData.title &&
            retrievePost.content === updatePostData.content &&
            retrievePost.deleted === postData.deleted &&
            retrievePost.createdAt === postData.createdAt &&
            retrievePost.order === postData.order) {
            // means doc was updated in Firestore properly
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The Deleted post in RTDB, so it must be deleted in Firestore as well", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData: PostCreateEvent= {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
            order: -1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Delete the record in Firebase
        await admin.database().ref(postCollection + "/" + category + "/" + id).remove();

        // 4. Wait for 10 seconds.
        await setTimeout(10000);

        // 5. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        if (!retrieveResult.exists) {
            // means doc does not exist in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The post was tagged in RTDB as deleted = true, and it must be mirrored the same way", async () => {
        // 1. Set post in RTDB
        const id = randomString();
        const postData: PostCreateEvent = {
            // do not add "id" here
            // do not add "type" here
            uid: randomString(),
            title: "title-post-test",
            content: "content-posttest",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
            order: -1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(postData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Update the record in Firebase to be set as deleted = true
        const updatePostData: PostUpdateEvent = {
            deleted: true,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + id).set(updatePostData);

        // 4. Wait for 10 seconds.
        await setTimeout(10000);

        // 5. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(postCollection).doc(id).get();
        const retrievePost = retrieveResult.data() as FirestorePost;
        if (retrieveResult.exists && retrievePost.deleted === true) {
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
});

