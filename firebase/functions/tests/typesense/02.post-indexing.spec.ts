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
describe("Indexing Posts (typesense/02.post-indexing.spec.ts)", () => {
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
            // do not add "type" here
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
                // do not add "type" here
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
                // do not add "type" here
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

            // 4. wait for 50 seconds
            await setTimeout(50000);

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
            // do not add "type" here
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

        // 3. Update title
        const updatedTitle = "updated title";
        await admin.database().ref("posts/" + category + "/" + id + "/title").set(updatedTitle);

        // 4. Wait for 30 seconds
        await setTimeout(30000);

        // 5. Retrieve values
        const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;

        // 6. Check the following in Typesense:
        //    - title should be updated,
        //    - content should not be affected,
        //    - createdAt should not be affected,
        //    - uid should not be affected
        //    Otherwise, the test failed.
        if (retrieveResult.id === id) {
            // means doc exist in Typesense
            if (retrieveResult.title === updatedTitle &&
                retrieveResult.content === postData.content &&
                retrieveResult.createdAt === postData.createdAt &&
                retrieveResult.uid === postData.uid
                ) {
                assert.ok(true);
            } else {
                assert.ok(false, "Either there is an error, more latency, or the data saved is wrong. Check: title should be updated, content should not be affected, createdAt should not be affected, uid should not be affected, deleted should not be affected.");
            }
        } else {
            assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
        }
    },);

    // 2. Update only content,
    // content should be updated,
    // title should not be affected,
    // createdAt should not be affected,
    // uid should not be affected,
    it("Update only content then only content should be affected", async () => {
        // 1. Create a post
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
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

        // 3. Update content
        const updatedContent = "updated content";
        await admin.database().ref("posts/" + category + "/" + id + "/content").set(updatedContent);

        // 4. Wait for 5 seconds
        await setTimeout(5000);

        // 5. Retrieve values
        const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;
        // 6. Check the following in Typesense:
        //    - title should be updated,
        //    - content should not be affected,
        //    - createdAt should not be affected,
        //    - uid should not be affected
        //    Otherwise, the test failed.
        if (retrieveResult.id === id) {
            // means doc exist in Typesense
            if (retrieveResult.content === updatedContent &&
                retrieveResult.title === postData.title &&
                retrieveResult.createdAt === postData.createdAt &&
                retrieveResult.uid === postData.uid &&
                retrieveResult.deleted === postData.deleted
                ) {
                assert.ok(true);
            } else {
                assert.ok(false, "Either there is an error, more latency, or the data saved is wrong. Check: content should be updated, title should not be affected, createdAt should not be affected, uid should not be affected, deleted should not be affected.");
            }
        } else {
            assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
        }
    });

    it("Update only urls then only urls should be affected", async () => {
        // 1. Create a post
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: user.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            urls: ["url1"],
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(postData);

        // 2. Wait for 5 seconds
        await setTimeout(5000);

        // 3. Update content
        const updatedUrl = ["new url", "second url"];
        await admin.database().ref("posts/" + category + "/" + id + "/urls").set(updatedUrl);

        // 4. Wait for 25 seconds
        await setTimeout(25000);

        // 5. Retrieve values
        const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;
        // 6. Check the following in Typesense:
        //    - title should be updated,
        //    - content should not be affected,
        //    - createdAt should not be affected,
        //    - uid should not be affected
        //    Otherwise, the test failed.
        if (retrieveResult.id === id) {
            if ( JSON.stringify(retrieveResult.urls??[]) === JSON.stringify(updatedUrl) &&
                retrieveResult.content === postData.content &&
                retrieveResult.title === postData.title &&
                retrieveResult.createdAt === postData.createdAt &&
                retrieveResult.uid === postData.uid &&
                retrieveResult.deleted === postData.deleted
                ) {
                assert.ok(true);
            } else {
                console.log("retrieveResult.urls " + retrieveResult.urls);
                console.log("updatedUrl " + updatedUrl);
                assert.ok(false, "Either there is an error, more latency, or the data saved is wrong. Check: urls should be updated, content should not be updated, title should not be affected, createdAt should not be affected, uid should not be affected, deleted should not be affected.");
            }
        } else {
            assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
        }
    });

    // 3. Update only deleted into false,
    // (deleted will not be in typesense anyway)
    // title should not be updated,
    // content should not be affected,
    // createdAt should not be affected,
    // uid should not be affected,
    it("Update only deleted into false, and it should not affect other fields", async () => {
        // 1. Create a post
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
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

        // 3. Update content
        const updatedDeleted = false;
        await admin.database().ref("posts/" + category + "/" + id + "/deleted").set(updatedDeleted);

        // 4. Wait for 25 seconds
        await setTimeout(25000);

        // 5. Retrieve values
        const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;
        // 6. Check the following in Typesense:
        //    - title should not be updated,
        //    - content should not be affected,
        //    - createdAt should not be affected,
        //    - uid should not be affected,
        //    Otherwise, the test failed.
        if (retrieveResult.id === id) {
            // means user exist in Typesense
            if (retrieveResult.content === postData.content &&
                retrieveResult.title === postData.title &&
                retrieveResult.createdAt === postData.createdAt &&
                retrieveResult.uid === postData.uid &&
                retrieveResult.deleted === postData.deleted
                ) {
                assert.ok(true);
            } else {
                assert.ok(false, "Either there is an error, more latency, or the data saved is wrong. Check: title should not be affected, content should not be updated, createdAt should not be affected, uid should not be affected, deleted should not be affected.");
            }
        } else {
            assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
        }
    });

    // 4. Set title as "", content as "", deleted as true
    // it should properly be deleted in typesense without problems.
    // do this multiple times.
    it("Set title and content as empty, and deleted as true at the same time [1st]", async () => {
        // 1. Create new post in RTDB
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: user.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(postData);

        // 2. Wait for 5 seconds
        await setTimeout(5000);

        // 3. Set title as "", content as "", deleted as true
        const updatedPostData = {
            title: "",
            content: "",
            deleted: true,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).update(updatedPostData);

        // 4. Wait for 30 seconds
        await setTimeout(30000);

        // 5. Check that record should not exist in Typesense
        const searchResult = await TypesenseService.searchPost({ filterBy: "id:=" + id });
        if (searchResult.hits?.length == 0) {
            assert.ok(true);
        } else {
            assert.ok(false, "Should have no results. It means, it is not deleted.");
        }
    });

    // 5. Update both title and content,
    // should not update other than title and content,
    // both updates should be corrrect.
    it("Update both title and content, then should not update other than title and content", async () => {
        // 1. Create a post
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
            uid: user.uid,
            title: "title-post",
            content: "content-post",
            // do not add "category" here
            deleted: false,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(postData);

        // 2. Wait for 5 seconds
        await setTimeout(5000);

        // 3. Update content
        const updatedPostData = {
            title: "updated-title-post",
            content: "updated-content-post",
        } as TypesenseDoc;
            await admin.database().ref("posts/" + category + "/" + id).update(updatedPostData);

        // 4. Wait for 20 seconds
        await setTimeout(20000);

        // 5. Retrieve values
        const retrieveResult = await TypesenseService.retrieve(id) as TypesenseDoc;
        // 6. Check the update for both title and content,
        // should not update other than title and content,
        // both updates should be corrrect.
        if (retrieveResult.id === id) {
            // means user exist in Typesense
            if (retrieveResult.content === updatedPostData.content &&
                retrieveResult.title === updatedPostData.title &&
                retrieveResult.createdAt === postData.createdAt &&
                retrieveResult.uid === postData.uid &&
                retrieveResult.deleted === postData.deleted
                ) {
                assert.ok(true);
            } else {
                assert.ok(false, "Either there is an error, more latency, or the data saved is wrong. Check: title should not be affected, content should not be updated, createdAt should not be affected, uid should not be affected, deleted should not be affected.");
            }
        } else {
            assert.ok(false, "Either there is an error, more latency, or the user is not in Typesense");
        }
    });


    it("Remove document in Typesense when it was hard deleted in RTDB", async () => {
        // 1. Create a new post record in RTDB
        const id = randomString();
        const user = generateUser();
        const postData = {
            // do not add "id" here
            // do not add "type" here
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

        // 4. Wait for 20 seconds
        await setTimeout(20000);

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
            // do not add "type" here
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
            // do not add "type" here
            uid: user.uid,
            // do not add "category" here
            noOfLikes: 1,
            noOfCommments: 2,
            deleted: true,
            createdAt: 12345,
        } as TypesenseDoc;
        await admin.database().ref("posts/" + category + "/" + id).set(updatedPostData);

        // 4. Wait for 20 seconds
        await setTimeout(20000);

        // 5. Check that record should not exist in Typesense
        const searchResult = await TypesenseService.searchPost({ filterBy: "id:=" + id });
        if (searchResult.hits?.length == 0) {
            assert.ok(true);
        } else {
            assert.ok(false, "Should have no results");
        }
    });
});

