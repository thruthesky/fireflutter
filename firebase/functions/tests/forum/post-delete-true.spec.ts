import { describe, it } from "mocha";
import * as admin from "firebase-admin";
import assert = require("assert");
import { PostCreateEvent, PostSummary, PostUpdateEvent } from "../../src/forum/forum.interface";
import { randomString } from "../firebase-test-functions";
import { setTimeout } from "timers/promises";
import { getDatabase } from "firebase-admin/database";
import { Config } from "../../src/config";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

const millisecondsToWait = 10000;

describe("Setting delete == true, other fields delete. (post-delete-true.spec.ts)", () => {
    it("Set delete == true, other fields delete. Record should be updated in post summary.", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            content: "This is a content",
            title: "This is a title",
        };
        const category = "deleted-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Tag as Deleted
        const updateData: PostUpdateEvent = {
            deleted: true,
            title: null,
            content: null,
            urls: null,
        };
        await db.ref(`posts/${category}/${postId}`).update(updateData);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Check if record in post summary is updated
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (!summarySnapshot.exists()) {
            assert.ok(false, "It should exist.");
        } else if (
            summary.content !== undefined ||
            summary.url !== undefined ||
            summary.title !== undefined
            ) {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Content, url and title should be deleted.");
        } else if (
            summary.order != postData.order ||
            summary.createdAt != postData.createdAt ||
            summary.uid !== postData.uid
            ) {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Other records should not be affected.");
        } else if (summarySnapshot.exists() && summary.deleted === true) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Something is wrong. It should exist and should have proper values.");
        }
    });
    it("2nd Set delete == true, other fields delete. Sudden delete", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            content: "This is a content",
            title: "This is a title",
        };
        const category = "deleted-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Tag as Deleted
        const updateData: PostUpdateEvent = {
            deleted: true,
            title: null,
            content: null,
            urls: null,
        };
        await db.ref(`posts/${category}/${postId}`).update(updateData);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Check if record in post summary is updated
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (!summarySnapshot.exists()) {
            assert.ok(false, "It should exist.");
        } else if (
            summary.content !== undefined ||
            summary.url !== undefined ||
            summary.title !== undefined
            ) {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Content, url and title should be deleted.");
        } else if (
            summary.order != postData.order ||
            summary.createdAt != postData.createdAt ||
            summary.uid !== postData.uid
            ) {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Other records should not be affected.");
        } else if (summarySnapshot.exists() && summary.deleted === true) {
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary);
            assert.ok(false, "Something is wrong. It should exist and should have proper values.");
        }
    });
});

