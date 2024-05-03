import { describe, it } from "mocha";
import { Comment, Post } from "../../src/forum/forum.interface";
import { randomString } from "../firebase-test-functions";
import { firebaseWithcenterTest2OnlineInit } from "../firebase-withcenter-test-2-online.init";
import { PostService } from "../../src/forum/post.service";
import { CommentService } from "../../src/forum/comment.service";

firebaseWithcenterTest2OnlineInit();


describe("CommentService.create test", () => {
    it("Create a post and a comment", async () => {
        // Create a post
        const postData: Post = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            title: "c",
        };
        const postRef = await PostService.create("test", postData);

        // Create a comment
        const commentData: Comment = {
            uid: randomString(),
            postId: postRef.key!,
            category: "test",
            createdAt: 12312,
            order: -12312,
            content: "comment content",
        };
        const commentRef = await CommentService.create(postRef.key!, commentData);

        // Get the comment
        const comment = await CommentService.get(postRef.key!, commentRef.key!);

        if (comment?.content !== commentData.content) {
            throw new Error("Content is not same");
        }
    });
});

