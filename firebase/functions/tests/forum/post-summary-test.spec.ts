import { describe, it } from "mocha";
import * as admin from "firebase-admin";
import assert = require("assert");
import { PostCreateEvent, PostSummary } from "../../src/forum/forum.interface";
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

describe("Post Write Test (forum/post-write-summary.spec.ts)", () => {
    it("Create new post in posts, check it in post-summary (postSetSummary)", async () => {
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
        await setTimeout(millisecondsToWait);
        // Check if the data is written to post-summary
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.uid === postData.uid &&
            summary.title === postData.title &&
            summary.content === postData.content &&
            summary.createdAt === postData.createdAt &&
            summary.order === postData.order
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-summary and has correct data.");
        }
    });
    // it must not have problem
    it("Update post's title in posts, check it in post-summary if updated (postUpdatedSummaryTitle)", async ()=>{
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postUpdatedSummaryTitle Test",
            content: "postUpdatedSummaryTitle Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-postUpdatedSummaryTitle";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update post's title
        const updatedTitle = "Updated Title";
        await db.ref(`posts/${category}/${postId}/title`).set(updatedTitle);
        // Wait for some seconds
        await setTimeout(millisecondsToWait);
        // Check if the updated title is written to post-summary
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.title === updatedTitle
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-summary and has correct updated title. Expected: " + updatedTitle + ", Actual: " + summary.title);
        }
    });
    it("Update post's title and other fields should not be affected (postUpdatedSummaryTitle)", async () => {
        // Create a post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postUpdatedSummaryTitle Test",
            content: "postUpdatedSummaryTitle Test",
            urls: ["https://google.com"],
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-postUpdatedSummaryTitle";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title
        const updatedTitle = "Updated Only Title";
        await db.ref(`posts/${category}/${postId}/title`).set(updatedTitle);
        // Wait
        await setTimeout(millisecondsToWait);
        // Check if other values are not affected
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.content === postData.content &&
            summary.order === postData.order &&
            summary.createdAt === postData.createdAt &&
            summary.url === postData.urls?.[0]
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exist and should not affect other fields than title.");
        }
    });
    it("Update post's content, check it in post-summary if updated (postUpdateSummaryContent)", async ()=> {
        // Create a post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postUpdateSummaryContent Test",
            content: "postUpdateSummaryContent Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-postUpdateSummaryContent";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update Content
        const updatedContent = "Updated Content";
        await db.ref(`posts/${category}/${postId}/content`).set(updatedContent);
        // Wait for some seconds
        await setTimeout(millisecondsToWait);
        // Check if the updated content is written to post-summary
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.content === updatedContent
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-summary and has correct updated content. Expected: " + updatedContent + ", Actual: " + summary.content);
        }
    });
    it("Update post's content and other fields should not be affected (postUpdateSummaryContent)", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postUpdateSummaryContent Test",
            content: "postUpdateSummaryContent Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-postUpdateSummaryContent";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update content
        const updatedContent = "Updated Content";
        await db.ref(`posts/${category}/${postId}/content`).set(updatedContent);
        // Wait
        await setTimeout(millisecondsToWait);
        // Check if other values are not affected
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.title === postData.title &&
            summary.order == postData.order &&
            summary.createdAt == postData.createdAt &&
            summary.url === undefined
        ) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "It should exist and should not affect other fields than content.");
        }
    });
    it("Update post's URL, check it in post-summary if updated (postUpdateSummaryURL)", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postUpdateSummaryURL Test",
            content: "postUpdateSummaryURL Test",
            createdAt: 12312,
            order: -12312,
            urls: ["old-url1", "old-url2"],
        };
        const category = "test-category-postUpdateSummaryURL";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update URL
        const updatedURLs = ["url1", "url2"];
        await db.ref(`posts/${category}/${postId}/urls`).set(updatedURLs);
        // Wait for some seconds
        await setTimeout(millisecondsToWait);
        // Check if the updated URL is written to post-summary
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.url === updatedURLs[0]
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-summary and has correct updated urls. Expected: " + updatedURLs[0] + ", Actual: " + summary.url);
        }
    });
    it("Update post's URL and other fields should not be affected (postUpdateSummaryURL)", async () => {
        // Create a post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postUpdateSummaryURL Test",
            content: "postUpdateSummaryURL Test",
            urls: ["https://google.com"],
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category-postUpdateSummaryURL";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title
        const updatedURLs = ["url1", "url2"];
        await db.ref(`posts/${category}/${postId}/urls`).set(updatedURLs);
        // Wait
        await setTimeout(millisecondsToWait);
        // Check if other values are not affected
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.title === postData.title &&
            summary.content === postData.content &&
            summary.order === postData.order &&
            summary.createdAt === postData.createdAt
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exist and should not affect other fields than URL.");
        }
    });
    it("Update post multiple fields at multiple times, check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postUpdateSummaryContent Test",
            content: "postUpdateSummaryContent Test",
            urls: ["differenturl"],
            createdAt: 12312,
            order: -12312,
        };
        const category = "charisu";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title without await
        const updatedTitle = "Updated Title";
        db.ref(`posts/${category}/${postId}/title`).set(updatedTitle);
        // Update content without await
        const updatedContent = "Updated Content";
        db.ref(`posts/${category}/${postId}/content`).set(updatedContent);
        // Update urls without await
        const updateUrls = ["url1", "url2", "url3"];
        db.ref(`posts/${category}/${postId}/urls`).set(updateUrls);
        // Wait for some time
        await setTimeout(millisecondsToWait * 2.5);
        // Check the values
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.title === updatedTitle &&
            summary.content === updatedContent &&
            summary.url === updateUrls[0] &&
            summary.order == postData.order &&
            summary.createdAt == postData.createdAt
        ) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary);
            console.log("(summary.url ?? \"\") :", summary.url ?? "");
            console.log("(updateUrls[0] ?? \"\") :", updateUrls[0] ?? "");
            console.log("(summary.url ?? \"\") === (updateUrls[0] ?? \"\") :", (summary.url ?? "") === (updateUrls[0] ?? ""));
            assert.ok(false, "It should exist and should have proper values.");
        }
    });
    it("Tag post as deleted, it should be deleted in post-summary (postUpdateDeletedSummary)", async () => {
        // Create Post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postUpdateDeletedSummary Test",
            content: "postUpdateDeletedSummary Test",
            createdAt: 12312,
            order: -12312,
            urls: ["old-url1", "old-url2"],
        };
        const category = "test-category-postUpdateDeletedSummary";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update deleted as true
        await db.ref(`posts/${category}/${postId}/deleted`).set(true);
        // Wait for some seconds
        await setTimeout(millisecondsToWait * 2);
        // Check if it is deleted in post-summary
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val();
        // Please Check if this should be actual deletion in post-summary
        if (summarySnapshot.exists() && (summary.deleted === true)) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in post-summary and deleted is true.");
        }
    });
    it("Delete post, it should be deleted in post-summary (postDeleteSummary)", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "postDeleteSummary Test",
            content: "postDeleteSummary Test",
            createdAt: 12312,
            order: -12312,
            urls: ["old-url1", "old-url2"],
        };
        const category = "test-category-postDeleteSummary";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Delete post
        await db.ref(`posts/${category}/${postId}`).remove();
        // Wait for some seconds
        await setTimeout(millisecondsToWait * 4);
        // Check if it is deleted in post-summary
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        if (summarySnapshot.exists()) {
            assert.ok(false, "It should not exists in post-summary.");
        } else {
            assert.ok(true);
        }
    });
});

