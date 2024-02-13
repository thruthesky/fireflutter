import { describe, it } from "mocha";
import * as admin from "firebase-admin";
import assert = require("assert");
import { PostCreateEvent, PostSummary } from "../../src/forum/forum.interface";
import { randomString } from "../firebase-test-functions";
import { setTimeout } from "timers/promises";
import { getDatabase } from "firebase-admin/database";
import { Config } from "../../src/config";
import { PostService } from "../../src/forum/post.service";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

const millisecondsToWait = 5000;

/**
 *
 * To test if the post written in `posts-summaries` will be written into `post-summary-all`
 */
describe("Post Summary All write from `posts-summaries` test (forum/post-summary-all-test-from-summaries.spec.ts)", () => {
    it("Create new post in posts, check it in post-summary-all (managePostsAllSummary)", async () => {
        // Create post directly in posts-summaries
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Title Test",
            content: "Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-flower";
        const postId = randomString();
       PostService.setSummary(postData, category, postId);
        // Wait for some seconds to make sure the data is written to DB
        await setTimeout(millisecondsToWait);
        // Check if the data is written to post-summary
        const db = getDatabase();
        const summarySnapshot = await db.ref(`${Config.postAllSummaries}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.uid === postData.uid &&
            summary.title === postData.title &&
            summary.content === postData.content &&
            summary.createdAt === postData.createdAt &&
            summary.order === postData.order
        ) {
            // PostService.setSummary also updates `posts-summaries`
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-all-summaries and has correct data.");
        }
    });
    it("Update post in posts-summaries, check it in post-summary-all", async () => {
        // Create post directly in post-summaries
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Title Test",
            content: "Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "juice-schwa";
        const postId = randomString();
        PostService.setSummary(postData, category, postId);
        // Set the post again in post-summaries with updatedTitle
        const updatedPostData: PostCreateEvent = {
            uid: postData.uid,
            title: "Updated Title Test",
            content: "Updated Content Test",
            createdAt: postData.createdAt,
            order: postData.order,
        };
        PostService.setSummary(updatedPostData, category, postId);
        // Wait for some seconds
        await setTimeout(millisecondsToWait);
        // Check if the updated data is written to post-summary
        const db = getDatabase();
        const summarySnapshot = await db.ref(`${Config.postAllSummaries}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.uid === updatedPostData.uid &&
            summary.title === updatedPostData.title &&
            summary.content === updatedPostData.content &&
            summary.createdAt === updatedPostData.createdAt &&
            summary.order === postData.order
        ) {
            // PostService.setSummary also updates `posts-summaries`
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-all-summaries and has correct data.");
        }
    });
    it("Delete post in posts-summaries, it should not be existing in post-summaries-all", async () => {
        // Create post in posts-summaries
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Title Test",
            content: "Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "Know-eh";
        const postId = randomString();
        PostService.setSummary(postData, category, postId);
        // Delete post in post-summaries
        const db = getDatabase();
        await db.ref(`${Config.postSummaries}/${category}/${postId}`).set(null);
        // Wait
        await setTimeout(millisecondsToWait);
        // Check if not exist
        const summarySnapshot = await db.ref(`${Config.postAllSummaries}/${postId}`).get();
        if (
            summarySnapshot.exists()
        ) {
            assert.ok(true);
            // NOTE: We are not listening to `${Config.postSummaries}/${category}/${postId}`
            // we are only listening to `posts`
        } else {
            assert.ok(false, "We are not listening to `${Config.postSummaries}/${category}/${postId}`, so it should exist.");
        }
    });
});

