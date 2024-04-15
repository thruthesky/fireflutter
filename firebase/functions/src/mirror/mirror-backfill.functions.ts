import * as admin from "firebase-admin";

// TODO this should be setable upon running the script
if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
        projectId: "withcenter-test-3",
    });
}

/**
 * Mirror backfill posts.
 *
 * This can be used to Mirror Posts in RTDB
 * to Firestore for posts that were not mirrored
 * before applying a post mirroring cloud functions.
 */
function mirrorBackfillPosts(postCollection: string = "posts") {
    // 1. Get all posts
    // 2. For each Post
    // 3. Set each Post into Firestore
}