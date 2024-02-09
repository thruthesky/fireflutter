import { describe, it } from "mocha";
import * as admin from "firebase-admin";
import assert = require("assert");
import { PostCreateEvent } from "../../src/forum/forum.interface";
import { randomString } from "../firebase-test-functions";
import { PostService } from "../../src/forum/post.service";
import { getDatabase } from "firebase-admin/database";
import { Config } from "../../src/config";


if (admin.apps.length === 0) {
    admin.initializeApp({
        databaseURL: "http://127.0.0.1:6004?ns=withcenter-test-3",
    });
}

describe("Post Service Test (forum/post-service.spec.ts)", () => {
    it("Setting post summary must have no errors", async () => {
        try {
           const postData: PostCreateEvent = {
                uid: randomString(),
                title: "Title Test",
                content: "Content Test",
                createdAt: 12312,
                order: 12312,
            };
            const category = "test-category";
            const postId = randomString();
            await PostService.setSummary(postData, category, postId);
            assert.ok(true);
        } catch (e) {
            const message = (e as Error).message;
            assert.ok(false, "It should succeed. Check the required values. " + message);
        }
    });
    it("Post summary must exist in the database", async () => {
        const postData: PostCreateEvent = {
            uid: randomString(),
            title: "Title Test",
            content: "Content Test",
            createdAt: 12312,
            order: -12312,
        };
        const category = "test-category";
        const postId = randomString();
        await PostService.setSummary(postData, category, postId);
        const db = getDatabase();
        const summary = await db.ref(`${Config.postSummaries}/${category}/${postId}`).get();
        if (
            summary.exists() &&
            summary.val().uid === postData.uid &&
            summary.val().title === postData.title &&
            summary.val().content === postData.content &&
            summary.val().createdAt === postData.createdAt &&
            summary.val().order === postData.order
        ) {
            assert.ok(true);
        } else {
            assert.ok(false, "It should exists in DB. Check the required values. ");
        }
    });
});

