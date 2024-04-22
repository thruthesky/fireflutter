import { describe, it } from "mocha";
import * as admin from "firebase-admin";
import assert = require("assert");
import { PostCreateEvent, PostSummary } from "../../src/forum/forum.interface";

import { setTimeout } from "timers/promises";
import { getDatabase } from "firebase-admin/database";
import { Config } from "../../src/config";
import { randomString } from "../firebase-test-functions";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

const millisecondsToWait = 30000;

describe("Test when post title, content and urls are null at first (post-null-fields.spec.ts)", () => {
    it("Begin with null title, then update the title. Check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            content: "This is a content",
        };
        const category = "null-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title
        const updatedTitle = "Now it has Title";
        await db.ref(`posts/${category}/${postId}/title`).set(updatedTitle);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Check if record in post summary is updated
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (!summarySnapshot.exists()) {
            assert.ok(false, "It should exist.");
        } else if (summary.content !== postData.content ||
            summary.url !== postData.urls?.[0] ||
            summary.order !== postData.order ||
            summary.createdAt !== postData.createdAt ||
            summary.uid !== postData.uid
        ) {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Other records should not be affected.");
        } else if (summarySnapshot.exists() && summary.title === updatedTitle) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Expected title: ", updatedTitle);
            assert.ok(false, "It should exist and should have proper values.");
        }
    });
    it("Begin with null content, then update the content. Check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            title: "This is a title",
        };
        const category = "null-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title
        const updatedContent = "Now it has Content";
        await db.ref(`posts/${category}/${postId}/content`).set(updatedContent);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Check if record in post summary is updated
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (!summarySnapshot.exists()) {
            assert.ok(false, "It should exist.");
        } else if (summary.title !== postData.title ||
            summary.url !== postData.urls?.[0] ||
            summary.order !== postData.order ||
            summary.createdAt !== postData.createdAt ||
            summary.uid !== postData.uid
        ) {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Other records should not be affected.");
        } else if (summarySnapshot.exists() && summary.content === updatedContent) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Expected content: ", updatedContent);
            assert.ok(false, "It should exist and should have proper values.");
        }
    });
    it("Begin with null urls, then update the urls. Check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            title: "This is a title",
            content: "This is a content",
        };
        const category = "null-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title
        const url1 = "url1";
        const url2 = "url2";
        const updatedUrls = [url1, url2];
        await db.ref(`posts/${category}/${postId}/urls`).set(updatedUrls);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Check if record in post summary is updated
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (!summarySnapshot.exists()) {
            assert.ok(false, "It should exist.");
        } else if (summary.title !== postData.title ||
            summary.content !== postData.content ||
            summary.order !== postData.order ||
            summary.createdAt !== postData.createdAt ||
            summary.uid !== postData.uid
        ) {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Other records should not be affected.");
        } else if (summarySnapshot.exists() && summary.url === url1) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Updated urls: ", updatedUrls);
            assert.ok(false, "It should exist and should have proper values.");
        }
    });
    it("Update post multiple null fields at multiple times, check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
        };
        const category = "null-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title without await
        const updatedTitle = "Updated Title";
        await db.ref(`posts/${category}/${postId}/title`).set(updatedTitle);
        // Update content without await
        const updatedContent = "Updated Content";
        await db.ref(`posts/${category}/${postId}/content`).set(updatedContent);
        // Update urls without await
        const updateUrls = ["url1", "url2", "url3"];
        await db.ref(`posts/${category}/${postId}/urls`).set(updateUrls);
        // Wait for some time
        await setTimeout(millisecondsToWait * 4.5);
        // Check the values
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.title === updatedTitle &&
            summary.content === updatedContent &&
            summary.url === updateUrls[0] &&
            summary.order === postData.order &&
            summary.createdAt === postData.createdAt
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
});

