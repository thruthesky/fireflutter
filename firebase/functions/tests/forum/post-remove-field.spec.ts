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

const millisecondsToWait = 30000;

describe("When fields are removed from post (post-null-fields.spec.ts)", () => {
    it("Begin with non-null title, then update the title into null. Check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            content: "This is a content",
            title: "This is a title to be removed",
        };
        const category = "null-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Remove title
        await db.ref(`posts/${category}/${postId}/title`).set(null);
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
        } else if (summarySnapshot.exists() && summary.title === undefined) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Expected title to be undefined.");
            assert.ok(false, "It should exist and should have proper values.");
        }
    });
    it("Begin with non-null content, then update the content into null. Check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            title: "This is a title",
            content: "This is a content to be removed",
        };
        const category = "null-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Nullify content
        await db.ref(`posts/${category}/${postId}/content`).set(null);
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
        } else if (summarySnapshot.exists() && summary.content === undefined) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Expected content should be undefined.");
            assert.ok(false, "It should exist and should have proper values.");
        }
    });
    it("Begin with non-null urls, then update the urls. Check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            title: "This is a title",
            content: "This is a content",
            urls: ["url1", "url2"],
        };
        const category = "null-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Update title
        await db.ref(`posts/${category}/${postId}/urls`).set(null);
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
        } else if (summarySnapshot.exists() && summary.url === undefined) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Updated urls should be undefined.");
            assert.ok(false, "It should exist and should have proper values.");
        }
    });
    it("Update post multiple non-null fields at multiple times, check if it is updated in post-summary", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            title: "This is a title",
            content: "This is a content",
            urls: ["url1", "url2"],
        };
        const category = "null-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        const promises = [
            // Update title
            db.ref(`posts/${category}/${postId}/title`).set(null),
            // Update content
            db.ref(`posts/${category}/${postId}/content`).set(null),
            // Update urls
            db.ref(`posts/${category}/${postId}/urls`).set(null),
        ];
        await Promise.all(promises);
        // Wait for some time
        await setTimeout(millisecondsToWait * 3);
        // Check the values
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (
            summarySnapshot.exists() &&
            summary.title === undefined &&
            summary.content === undefined &&
            summary.url === undefined &&
            summary.order === postData.order &&
            summary.createdAt === postData.createdAt
        ) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary);
            console.log("(summary.url ?? \"\") :", summary.url ?? "");
            console.log("summary.url === null :", (summary.url) === undefined);
            assert.ok(false, "It should exist and should have proper values.");
        }
    });
});

