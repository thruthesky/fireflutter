import { describe, it } from "mocha";
import * as admin from "firebase-admin";
// import assert = require("assert");
// import { PostCreateEvent, PostSummary } from "../../src/forum/forum.interface";
// import { randomString } from "../firebase-test-functions";
// import { setTimeout } from "timers/promises";
// import { getDatabase } from "firebase-admin/database";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

const millisecondsToWait = 12000;

describe("Post Write Test for Summary All (forum/post-write-summary-all.spec.ts)", () => {
    // TODO
    it("Create new post in posts, check it in post-summary-all (postSetSummary)", async () => {
        // Create post
        // const postData: PostCreateEvent = {
        //     uid: randomString(),
        //     title: "Title Test",
        //     content: "Content Test",
        //     createdAt: 12312,
        //     order: -12312,
        // };
        // const category = "test-category-animal";
        // const postId = randomString();
        // const db = getDatabase();
        // await db.ref(`posts/${category}/${postId}`).set(postData);
        // // Wait for some seconds to make sure the data is written to DB
        // await setTimeout(millisecondsToWait);
        // // Check if the data is written to post-summary
        // const summarySnapshot = await db.ref(`posts-summary/${category}/${postId}`).get();
        // const summary = summarySnapshot.val() as PostSummary;
        // if (
        //     summarySnapshot.exists() &&
        //     summary.uid === postData.uid &&
        //     summary.title === postData.title &&
        //     summary.content === postData.content &&
        //     summary.createdAt === postData.createdAt &&
        //     summary.order === postData.order
        // ) {
        //     assert.ok(true);
        // } else {
        //     assert.ok(false, "It should exists in post-summary and has correct data.");
        // }
    });
});

