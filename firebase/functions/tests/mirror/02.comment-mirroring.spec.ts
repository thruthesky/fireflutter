import * as admin from "firebase-admin";
import { setTimeout } from "timers/promises";
import { describe, it } from "mocha";
import assert = require("assert");
import { randomString } from "../firebase-test-functions";
import { PostCreateEvent } from "../../src/forum/forum.interface";
import { CommentCreateEvent, CommentUpdateEvent, FirestoreComment } from "../../src/mirror/firestore.interface";

if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
        projectId: "withcenter-test-3",
    });
}

const category = "category";
const postCollection = "posts";
const commentCollection = "comments";

/**
 * This test is not reliable because the tokens may be invalid after a while.
 */
describe("Mirroring Comments (mirror/02.comment-mirroring.spec.ts)", () => {
    it("Mirror a newly created comment from RTDB", async () => {
        // 1. Set post in RTDB
        const postId = randomString();
        const uid = randomString();
        const postData: PostCreateEvent = {
            uid: uid,
            title: "title-post",
            content: "content-post",
            deleted: false,
            createdAt: 12345,
            order: 1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + postId).set(postData);

        // 2. Set comment in RTDB
        const commentId = randomString();
        const commentData: CommentCreateEvent = {
            uid: uid,
            content: "comment-content",
            createdAt: 12345,
        };
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).set(commentData);

        // 3. Wait for 10 seconds
        await setTimeout(10000);

        // Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(commentCollection).doc(commentId).get();

        if (retrieveResult.exists) {
            // means doc exist in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The Mirrored comments in Firestore but have the same values in RTDB", async () => {
        // 1. Set post in RTDB
        const postId = randomString();
        const uid = randomString();
        const postData: PostCreateEvent = {
            uid: uid,
            title: "title-post",
            content: "content-post",
            deleted: false,
            createdAt: 12345,
            order: 1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + postId).set(postData);

        // 2. Set comment in RTDB
        const commentId = randomString();
        const commentData: CommentCreateEvent = {
            uid: uid,
            content: "comment-content",
            createdAt: 12345,
            urls: ["url1", "url2"],
        };
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).set(commentData);

        // 3. Wait for 10 seconds
        await setTimeout(10000);

        // 4. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(commentCollection).doc(commentId).get();
        const retrieveComment = retrieveResult.data() as FirestoreComment;
        if (retrieveComment.uid === commentData.uid &&
            retrieveComment.content === commentData.content &&
            retrieveComment.deleted === commentData.deleted &&
            retrieveComment.createdAt === commentData.createdAt &&
            retrieveComment.urls?.[0] === commentData.urls?.[0] &&
            retrieveComment.urls?.[1] === commentData.urls?.[1] ) {
            // means doc exist as same value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The Mirrored comments from RTDB must have the postId field in Firestore", async () => {
        // 1. Set post in RTDB
        const postId = randomString();
        const uid = randomString();
        const postData: PostCreateEvent = {
            uid: uid,
            title: "title-post",
            content: "content-post",
            deleted: false,
            createdAt: 12345,
            order: 1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + postId).set(postData);

        // 2. Set comment in RTDB
        const commentId = randomString();
        const commentData: CommentCreateEvent = {
            uid: uid,
            content: "comment-content",
            createdAt: 12345,
            urls: ["url1", "url2"],
        };
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).set(commentData);

        // 3. Wait for 10 seconds
        await setTimeout(10000);

        // 4. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(commentCollection).doc(commentId).get();
        const retrievePost = retrieveResult.data() as FirestoreComment;
        if (retrievePost.postId === postId) {
            // means doc exist and has the correct category value in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The Updated comment in RTDB, so it must be updated in Firestore as well", async () => {
        // 1. Set post in RTDB
        const postId = randomString();
        const uid = randomString();
        const postData: PostCreateEvent = {
            uid: uid,
            title: "title-post",
            content: "content-post",
            deleted: false,
            createdAt: 12345,
            order: 1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + postId).set(postData);

        // 2. Set comment in RTDB
        const commentId = randomString();
        const commentData: CommentCreateEvent = {
            uid: uid,
            content: "comment-content",
            createdAt: 12345,
            urls: ["url1", "url2"],
        };
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).set(commentData);

        // 3. Update the comment in RTDB
        const updateCommentData: CommentUpdateEvent = {
            content: "updated-comment-test",
            urls: ["updated-url1", "updated-url2"],
        };
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).update(updateCommentData);

        // 4. Wait for 10 seconds.
        await setTimeout(10000);

        // 5. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(commentCollection).doc(commentId).get();
        const retrieveComment = retrieveResult.data() as FirestoreComment;
        if (retrieveComment.uid === commentData.uid &&
            retrieveComment.content === updateCommentData.content &&
            retrieveComment.deleted === commentData.deleted &&
            retrieveComment.createdAt === commentData.createdAt &&
            retrieveComment.urls?.[0] === updateCommentData.urls?.[0] &&
            retrieveComment.urls?.[1] === updateCommentData.urls?.[1]) {
            // means doc was updated in Firestore properly
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });

    it("The Deleted comment in RTDB, so it must be deleted in Firestore as well", async () => {
        // 1. Set post in RTDB
        const postId = randomString();
        const uid = randomString();
        const postData: PostCreateEvent = {
            uid: uid,
            title: "title-post",
            content: "content-post",
            deleted: false,
            createdAt: 12345,
            order: 1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + postId).set(postData);

        // 2. Set comment in RTDB
        const commentId = randomString();
        const commentData: CommentCreateEvent = {
            uid: uid,
            content: "comment-content",
            createdAt: 12345,
            urls: ["url1", "url2"],
        };
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).set(commentData);

        // 3. Wait for 10 seconds
        await setTimeout(10000);

        // 4. Delete the record in Firebase
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).remove();

        // 5. Wait for 10 seconds.
        await setTimeout(10000);

        // 6. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(commentCollection).doc(commentId).get();
        if (!retrieveResult.exists) {
            // means doc does not exist in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
    it("The comment was tagged in RTDB as deleted = true, so it must be deleted in Firestore as well", async () => {
        // 1. Set post in RTDB
        const postId = randomString();
        const uid = randomString();
        const postData: PostCreateEvent = {
            uid: uid,
            title: "title-post",
            content: "content-post",
            deleted: false,
            createdAt: 12345,
            order: 1,
        };
        await admin.database().ref(postCollection + "/" + category + "/" + postId).set(postData);

        // 2. Set comment in RTDB
        const commentId = randomString();
        const commentData: CommentCreateEvent = {
            uid: uid,
            content: "comment-content",
            createdAt: 12345,
            urls: ["url1", "url2"],
        };
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).set(commentData);

        // 2. Wait for 10 seconds
        await setTimeout(10000);

        // 3. Update the record in Firebase to be set as deleted = true
        const updateCommentData: CommentUpdateEvent = {
            deleted: true,
        };
        await admin.database().ref(commentCollection + "/" + postId + "/" + commentId).update(updateCommentData);

        // 4. Wait for 10 seconds.
        await setTimeout(10000);

        // 5. Search for the document in Firestore
        const retrieveResult = await admin.firestore().collection(commentCollection).doc(commentId).get();
        if (!retrieveResult.exists) {
            // means doc does not exist in Firestore
            assert.ok(true);
        } else {
            assert.ok(false, "Either there is an error, more latency, or the doc is not in Firestore.");
        }
    });
});

