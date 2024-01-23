import * as admin from "firebase-admin";
import { setTimeout } from "timers/promises";
import { describe, it } from "mocha";
import assert = require("assert");
// import { getDatabase } from "firebase-admin/database";
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
describe("Indexing Posts (typesense/post-indexing.spec.ts)", () => {
    it("Index a post document", async () => {
        // 1. create a database document for the new post.
        // 2. call the index method.
        // 3. make sure if there is a proper error.
        try {
            const postData = {
                id: randomString(),
                type: "post",
                uid: randomString(),
                title: "title-post",
                content: "content-post",
                deleted: false,
                createdAt: 12345,
            } as TypesenseDoc;
            await TypesenseService.upsert(postData);
             assert.ok(true);
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "it should succeed. check the required values: " + message);
        }
    });
    it("Index a newly created post from RTDB", async () => {
        // 1. set post in RTDB
        const id = randomString();
        const postData = {
            // do not add "id" here
            type: "post",
            uid: randomString(),
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(postData);

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
    it("Reindex an exisiting post upon edit in RTDB", async () => {
        try {
            // 1. create new post in RTDB
            const id = randomString();
            const user = generateUser();
            const postData = {
                // do not add "id" here
                type: "post",
                uid: user.uid,
                title: "title-post",
                content: "content-post",
                // do not add "category" here
                noOfLikes: 1,
                noOfCommments: 2,
                deleted: false,
                createdAt: 12345,
            } as TypesenseDoc;
            await admin.database().ref("posts/" + category + "/" + id).set(postData);

            // 2. wait for 5 seconds
            await setTimeout(5000);

            // 3. update the doc in RTDB
            const updatedPostData = {
                // do not add "id" here
                type: "post",
                uid: user.uid,
                title: "updated-title-post",
                content: "updated-content-post",
                // do not add "category" here
                noOfLikes: 1,
                noOfCommments: 2,
                deleted: false,
                createdAt: 12345,
            } as TypesenseDoc;
            await admin.database().ref("posts/" + category + "/" + id).set(updatedPostData);

            // 4. wait for 10 seconds
            await setTimeout(10000);

            // 5. search for the document in typesense
            const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;

            // 6. check if the doc is the updated info
            if (retrieveResult.id === id) {
                // means user exist in Typesense
                if (retrieveResult.title === updatedPostData.title && retrieveResult.content === updatedPostData.content) {
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

    // 1. Update only title,
    // title should be updated,
    // content should not be affected,
    // createdAt should not be affected,
    // uid should not be affected,
    // deleted should not be affected
    it("Update only title and only title should be affected", async () => {
        // 1. Create a post
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            type: "post",
            uid: user.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            noOfLikes: 1,
            noOfCommments: 2,
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(postData);

        // 2. Wait for 5 seconds
        await setTimeout(10000);

        // 3. Update title
        await admin.database().ref("posts/" + category + "/" + id + "/title").set("updated title");

        // 4. Wait for 5 seconds
        await setTimeout(10000);

        // 5. Retrieve values

        // 6. Check the following in Typesense:
        //    - title should be updated,
        //    - content should not be affected,
        //    - createdAt should not be affected,
        //    - uid should not be affected,
        //    - deleted should not be affected,
        //    Otherwise, the test failed.
    },);

    // 2. Update only content,
    // content should be updated,
    // title should not be affected,
    // createdAt should not be affected,
    // uid should not be affected,
    // deleted should not be affected,
    // 3. Update only deleted into false,
    // deleted should be false,
    // title should not be updated,
    // content should not be affected,
    // createdAt should not be affected,
    // uid should not be affected,
    // 4. Set title as "", content as "", deleted as true
    // it should properly be deleted in typesense without problems.
    // do this multiple times.
    // 5. Update both title and content,
    // should not update other than title and content,
    // both updates should be corrrect.


    it("Remove document in Typesense when it was hard deleted in RTDB", async () => {
        // 1. Create a new post record in RTDB
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            type: "post",
            uid: user.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            noOfLikes: 1,
            noOfCommments: 2,
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(postData);

        // 2. Wait for 5 seconds
        await setTimeout(5000);

        // 3. Delete the record in RTDB
        await admin.database().ref("posts/" + category + "/" + id).set(null);

        // 4. Wait for 10 seconds
        await setTimeout(10000);

        // 5. Check that record should not exist in Typesense
        const searchResult = await TypesenseService.searchPost({ filterBy: "id:=" + id });
        if (searchResult.hits?.length == 0) {
            assert.ok(true);
        } else {
            assert.ok(false, "Should have no results");
        }
    });
    it("Delete in Typesense when record in RTDB is tagged deleted = true", async () => {
        // 1. Create new post in RTDB
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            type: "post",
            uid: user.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            noOfLikes: 1,
            noOfCommments: 2,
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(postData);

        // 2. Wait for 5 seconds
        await setTimeout(5000);

        // 3. Tag delete = true in RTDB
        const updatedPostData = {
            // do not add "id" here
            type: "post",
            uid: user.uid,
            // do not add "category" here
            noOfLikes: 1,
            noOfCommments: 2,
            deleted: true,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(updatedPostData);

        // 4. Wait for 5  seconds
        await setTimeout(5000);

        // 5. Check that record should not exist in Typesense
        const searchResult = await TypesenseService.searchPost({ filterBy: "id:=" + id });
        if (searchResult.hits?.length == 0) {
            assert.ok(true);
        } else {
            assert.ok(false, "Should have no results");
        }
    });
});

