import * as admin from "firebase-admin";
import { setTimeout } from "timers/promises";
import { describe, it } from "mocha";
import assert = require("assert");
import { TypesenseService } from "../../src/typesense/typesense.service";
import { TypesenseDoc } from "../../src/typesense/typesense.interface";
import { generateUser, randomString } from "../firebase-test-functions";

if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

const category = "category";

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Indexing Comments (03.typesense/comment-indexing.spec.ts)", () => {
    it("Index a comment document", async () => {
        // 1. create a database document for the new post.
        // 2. call the index method.
        // 3. make sure if there is a proper error.
        try {
            const commentData = {
                id: randomString(),
                type: "comment",
                uid: randomString(),
                content: "content-comment",
                createdAt: 12345,
            } as TypesenseDoc;
            await TypesenseService.upsert(commentData);
             assert.ok(true);
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "it should succeed. check the required values: " + message);
        }
    });
    it("Index a newly created post from RTDB", async () => {
        // Pre-requisite. Create the post first before making the comment.
        const postId = randomString();
        const userData = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: userData.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + postId).set(postData);

        // 1. set comment in RTDB
        const id = randomString();
        const commentData = {
            // do not add "id" here
            // do not add "comment" here
            uid: userData.uid,
            content: "content-comment",
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + postId + "/comments/" + id).set(commentData);

        // 2. wait for 5 seconds
        await setTimeout(5000);

        // 3. search for the document in Typesense
        const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;
        if (retrieveResult.id === id) {
            // means doc exist in Typesense
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Typesense");
        }
    });
    it("Reindex an exisiting comment upon edit in RTDB", async () => {
        try {
            // Pre-requisite. Create the post first before making the comment.
            const postId = randomString();
            const userData = generateUser();
            const postData = {
                // do not add "id" here
                // do not add "type" here
                uid: userData.uid,
                title: "title-post",
                content: "content-post",
                // do not add "category" here
                deleted: false,
                createdAt: 12345,
            } as TypesenseDoc;
            await admin.database().ref("posts/" + category + "/" + postId).set(postData);

            // 1. create new comment in RTDB
            const id = randomString();
            const commentData = {
                // do not add "id" here
                // do not add "comment" here
                uid: userData.uid,
                content: "content-comment",
                createdAt: 12345,
            } as TypesenseDoc;
            const path = "posts/" + category + "/" + postId + "/comments/" + id;
            await admin.database().ref(path).set(commentData);

            // 2. wait for 5 seconds
            await setTimeout(5000);

            // 3. update the doc in RTDB
            const updatedCommentData = {
                // do not add "id" here
                // do not add "comment" here
                uid: userData.uid,
                content: "updated-content-comment",
                createdAt: 12345,
            } as TypesenseDoc;
            await admin.database().ref(path).set(updatedCommentData);

            // 4. wait for 20 seconds
            await setTimeout(20000);

            // 5. search for the document in typesense
            const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;

            // 6. check if the doc is the updated info
            if (retrieveResult.id === id) {
                // means user exist in Typesense
                // const resultDoc = searchResult.hits[0].document as TypesenseDoc;
                if (retrieveResult.content === updatedCommentData.content) {
                    assert.ok(true);
                } else {
                    assert.ok(false, "Either there is an error, more latency, or the data saved is wrong.");
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
        // Pre-requisite. Create the post first before making the comment.
        const postId = randomString();
        const userData = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: userData.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + postId).set(postData);

        // 1. create new comment in RTDB
        const id = randomString();
        const commentData = {
            // do not add "id" here
            // do not add "comment" here
            uid: userData.uid,
            content: "content-comment",
            createdAt: 12345,
        } as TypesenseDoc;
        const path = "posts/" + category + "/" + postId + "/comments/" + id;
        await admin.database().ref(path).set(commentData);

        // 2. Wait for 5 seconds
        await setTimeout(5000);

        // 3. Delete the record in RTDB
        await admin.database().ref(path).set(null);

        // 4. Wait for 5 seconds
        await setTimeout(5000);

        // 5. Check that record should not exist in Typesense
        const searchResult = await TypesenseService.searchComment({ filterBy: "id:=" + id });
        if (searchResult.hits?.length == 0) {
            assert.ok(true);
        } else {
            assert.ok(false, "Should have no results");
        }
    });
    it("Delete in Typesense when record in RTDB is tagged deleted = true", async () => {
        // Pre-requisite. Create the post first before making the comment.
        const postId = randomString();
        const userData = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: userData.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + postId).set(postData);

        // 1. create new comment in RTDB
        const id = randomString();
        const commentData = {
            // do not add "id" here
            // do not add "comment" here
            uid: userData.uid,
            content: "content-comment",
            createdAt: 12345,
        } as TypesenseDoc;
        const path = "posts/" + category + "/" + postId + "/comments/" + id;
        await admin.database().ref(path).set(commentData);

        // 2. Wait for 5 seconds
        await setTimeout(5000);

        // 3. Tag delete = true in RTDB
        const updatedCommentData = {
            // do not add "id" here
            // do not add "comment" here
            uid: userData.uid,
            content: "updated-content-comment",
            // do not add "category" here
            createdAt: 12345,
            deleted: true,
        } as TypesenseDoc;
        await admin.database().ref(path).set(updatedCommentData);

        // 4. Wait for 5  seconds
        await setTimeout(5000);

        // 5. Check that record should not exist in Typesense
        const searchResult = await TypesenseService.searchComment({ filterBy: "id:=" + id });
        if (searchResult.hits?.length == 0) {
            assert.ok(true);
        } else {
            assert.ok(false, "Should have no results");
        }
    });
});

