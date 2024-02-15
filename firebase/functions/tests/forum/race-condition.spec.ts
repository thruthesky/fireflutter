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

const millisecondsToWait = 5000;

describe("Race Condition Test in Forum. (race-condition.spec.ts)", () => {
    it("Update title multiple times, one by one.", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            content: "This is a content",
            title: "This is a title",
        };
        const category = "race-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Update title multiple times
        const finalTitle = "fireship";
        await db.ref(`posts/${category}/${postId}/title`).set("a");
        await db.ref(`posts/${category}/${postId}/title`).set("b");
        await db.ref(`posts/${category}/${postId}/title`).set("c");
        await db.ref(`posts/${category}/${postId}/title`).set("d");
        await db.ref(`posts/${category}/${postId}/title`).set("e");
        await db.ref(`posts/${category}/${postId}/title`).set("f");
        await db.ref(`posts/${category}/${postId}/title`).set("g");
        await db.ref(`posts/${category}/${postId}/title`).set("h");
        await db.ref(`posts/${category}/${postId}/title`).set("i");
        await db.ref(`posts/${category}/${postId}/title`).set("j");
        await db.ref(`posts/${category}/${postId}/title`).set("k");
        await db.ref(`posts/${category}/${postId}/title`).set(finalTitle);
        // Wait for some time
        await setTimeout(millisecondsToWait * 5);
        // Check if record in post summary is updated
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (!summarySnapshot.exists()) {
            assert.ok(false, "It should exist.");
        } else if (summarySnapshot.exists() && summary.title === finalTitle) {
            assert.ok(true);
        } else if (summarySnapshot.exists() && ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"].includes(summary.title ?? "")) {
            // NOTE: This is okay, per Sir Song. This is expected to not be consistent
            //       since we will have race condition.
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Expected Title: ", finalTitle);
            assert.ok(false, "Something is wrong. It should exist and should have proper values.");
        }
    });
    it("Update content multiple times, one by one.", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            content: "This is a content",
            title: "This is a title",
        };
        const category = "race-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Update title multiple times
        const finalContent = "fireship";
        await db.ref(`posts/${category}/${postId}/content`).set("a");
        await db.ref(`posts/${category}/${postId}/content`).set("b");
        await db.ref(`posts/${category}/${postId}/content`).set("c");
        await db.ref(`posts/${category}/${postId}/content`).set("d");
        await db.ref(`posts/${category}/${postId}/content`).set("e");
        await db.ref(`posts/${category}/${postId}/content`).set("f");
        await db.ref(`posts/${category}/${postId}/content`).set("g");
        await db.ref(`posts/${category}/${postId}/content`).set("h");
        await db.ref(`posts/${category}/${postId}/content`).set("i");
        await db.ref(`posts/${category}/${postId}/content`).set("j");
        await db.ref(`posts/${category}/${postId}/content`).set("k");
        await db.ref(`posts/${category}/${postId}/content`).set(finalContent);
        // Wait for some time
        await setTimeout(millisecondsToWait * 5);
        // Check if record in post summary is updated
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (!summarySnapshot.exists()) {
            assert.ok(false, "It should exist.");
        } else if (summarySnapshot.exists() && summary.content === finalContent) {
            assert.ok(true);
        } else if (summarySnapshot.exists() && ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"].includes(summary.content ?? "")) {
            // NOTE: This is okay, per Sir Song. This is expected to not be consistent
            //       since we will have race condition.
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Expected Content: ", finalContent);
            assert.ok(false, "Something is wrong. It should exist and should have proper values.");
        }
    });
    it("Update urls multiple times, one by one.", async () => {
        // Create post
        const postData: PostCreateEvent = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            urls: ["url1", "url2"],
            content: "This is a content",
            title: "This is a title",
        };
        const category = "race-test";
        const postId = randomString();
        const db = getDatabase();
        await db.ref(`posts/${category}/${postId}`).set(postData);
        // Wait for some time
        await setTimeout(millisecondsToWait);
        // Update content multiple times
        const finalUrls = ["fireship", "url2", "url3"];
        await db.ref(`posts/${category}/${postId}/urls`).set(["a"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["b"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["c"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["d"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["e"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["f"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["g"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["h"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["i"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["j"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(["k"]);
        await db.ref(`posts/${category}/${postId}/urls`).set(finalUrls);
        // Wait for some time
        await setTimeout(millisecondsToWait * 5);
        // Check if record in post summary is updated
        const summarySnapshot = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        const summary = summarySnapshot.val() as PostSummary;
        if (!summarySnapshot.exists()) {
            assert.ok(false, "It should exist.");
        } else if (summarySnapshot.exists() && summary.url === finalUrls[0]) {
            assert.ok(true);
        } else if (summarySnapshot.exists() && ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k"].includes(summary.url ?? "")) {
            // NOTE: This is okay, per Sir Song. This is expected to not be consistent
            //       since we will have race condition.
            assert.ok(true);
        } else {
            console.log("Original: ", postData, "Retireved: ", summary, "Expected url: ", finalUrls[0]);
            assert.ok(false, "Something is wrong. It should exist and should have proper values.");
        }
    });
});

