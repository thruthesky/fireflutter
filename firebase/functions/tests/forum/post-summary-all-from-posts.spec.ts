import { describe, it } from "mocha";
import * as admin from "firebase-admin";
import assert = require("assert");
import { PostCreateEvent, PostSummary, PostSummaryAll, PostUpdateEvent } from "../../src/forum/forum.interface";
import { randomString } from "../firebase-test-functions";
import { setTimeout } from "timers/promises";
import { getDatabase } from "firebase-admin/database";
import { Config } from "../../src/config";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

const millisecondsToWait = 35000;

/**
 * To test if the post written in `posts` will be written into `post-summary-all`
 */
describe("Post Summary All write from post test (forum/post-summary-all-from-posts.spec.ts)", () => {
    it("Create new post in posts, check it in post-summary-all (managePostsAllSummary)", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Title Test",
            content: "Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-animal";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Wait for some seconds to make sure the data is written to DB
        await setTimeout(millisecondsToWait * 2);
        // Check if the data is written to post-summary
        const summarySnapshot = await db.ref(`${Config.postAllSummaries}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.uid === postData.uid &&
            summary.title === postData.title &&
            summary.content === postData.content &&
            summary.createdAt == postData.createdAt &&
            summary.order == postData.order
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-all-summaries and has correct data.");
        }
    });
    // Test to check category exist
    it("Check if category exists in post-all-summaries", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Title Test",
            content: "Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-snake";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Wait for some seconds to make sure the data is written to DB
        await setTimeout(millisecondsToWait * 2);
        // Check if the data is written to post-summary
        const summarySnapshot = await db.ref(`${Config.postAllSummaries}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummaryAll;
        if (
            summarySnapshot.exists() &&
            summary.category === category
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-all-summaries and has correct category. Actual: " + summary.category + " Expected: " + category);
        }
    });
    it("Update a post, it must reflect in post-all-summaries", async () => {
        // Create a post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Title Test",
            content: "Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-all";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update the post
        const updatedPostData: PostUpdateEvent = {
            title: "Title Test Updated",
            content: "Content Test Updated",
        };
        await db.ref(`posts/${category}/${postId}`).update(updatedPostData);
        // Wait for some time
        await setTimeout(millisecondsToWait * 2.5);
        // Check if the data is written to post-all-summaries
        const summarySnapshot = await db.ref(`${Config.postAllSummaries}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (summarySnapshot.exists() &&
            summary.title === updatedPostData.title &&
            summary.content === updatedPostData.content
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-all-summaries and has correct data.");
        }
    });
    it("Update a post, the order and createdAt must not be affected", async () => {
        // Create a post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Title Test",
            content: "Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-all";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title and content
        const updatedPostData: PostUpdateEvent = {
            title: "Title Test Updated",
            content: "Content Test Updated",
        };
        await db.ref(`posts/${category}/${postId}`).update(updatedPostData);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Check if order and createdAt is not affected
        const summarySnapshot = await db.ref(`${Config.postAllSummaries}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (summarySnapshot.exists() &&
            summary.order == postData.order &&
            summary.order !== null &&
            summary.createdAt == postData.createdAt &&
            summary.createdAt !== null
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-all-summaries and has correct data.");
        }
    });
    it("Delete a post, it must not exist in post-all-summaries", async () => {
        // Create a post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Delete Test",
            content: "Delete Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-delete";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Delete the post
        await db.ref(`posts/${category}/${postId}`).set(null);
        // Wait for some time
        await setTimeout(millisecondsToWait * 2);
        // Check if the data is written to post-all-summaries
        const summarySnapshot = await db.ref(`${Config.postAllSummaries}/${postId}`).get();
        if (!summarySnapshot.exists()) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should not exists in post-all-summaries.");
        }
    });
});

