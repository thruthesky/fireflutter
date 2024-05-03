import { describe, it } from "mocha";
import { Comment, Post } from "../../src/forum/forum.interface";
import { randomString } from "../firebase-test-functions";
import { firebaseWithcenterTest2OnlineInit } from "../firebase-withcenter-test-2-online.init";
import { PostService } from "../../src/forum/post.service";
import { CommentService } from "../../src/forum/comment.service";
import * as assert from "assert";


firebaseWithcenterTest2OnlineInit();


describe("CommentService.getAncestorsUid test", () => {
    it("Create a post and nested comments", async () => {
        const postUid = randomString();
        const comment1Uid = randomString();
        const comment2Uid = randomString();
        // Create a post
        const postData: Post = {
            uid: postUid,
            createdAt: 12312,
            order: -12312,
            title: "c",
        };
        const postRef = await PostService.create("test", postData);
        const postId = postRef.key!;
        console.log("postId: ", postId);

        // Create a comment
        const commentData: Comment = {
            uid: comment1Uid,
            postId,
            category: "test",
            createdAt: 12312,
            order: -12312,
            content: "comment content",
        };
        const commentRef = await CommentService.create(postId, commentData);
        const comment1Id = commentRef.key!;

        // Create a nested comment
        commentData["uid"] = comment2Uid;
        commentData["parentId"] = comment1Id;
        const commentRef2 = await CommentService.create(postId, commentData);
        const comment2Id = commentRef2.key!;

        console.log("commentRef2: ", commentRef2.key);


        const uids = await CommentService.getAncestorsUid(postId, comment1Id, comment2Uid);
        console.log("uids: ", uids);

        if (uids.length !== 1) {
            throw new Error("uids should have 2 elements.");
        }


        // Create a comment by 3 under comment2
        const comment3Uid = randomString();
        commentData["uid"] = comment3Uid;
        commentData["parentId"] = comment2Id;
        const commentRef3 = await CommentService.create(postId, commentData);
        const comment3Id = commentRef3.key!;


        const uids2 = await CommentService.getAncestorsUid(postId, comment3Id, comment3Uid);
        console.log("uids2: ", uids2);

        assert.equal(uids2.length, 2);


        // / 1 -> 2 -> 3 -> 4
        const comment4Uid = randomString();
        commentData["uid"] = comment4Uid;
        commentData["parentId"] = comment3Id;
        const commentRef4 = await CommentService.create(postId, commentData);
        const comment4Id = commentRef4.key!;
        console.log("comment4Id: ", comment4Id);
        const uids3 = await CommentService.getAncestorsUid(postId, comment4Id, comment4Uid);
        console.log("uids3: ", uids3);
        assert.equal(uids3.length, 3);


        // / 1 -> 2 -> 3 -> 4 -> 5
        const comment5Uid = randomString();
        commentData["uid"] = comment5Uid;
        commentData["parentId"] = comment4Id;
        const commentRef5 = await CommentService.create(postId, commentData);
        const comment5Id = commentRef5.key!;
        console.log("comment5Id: ", comment5Id);
        const uids4 = await CommentService.getAncestorsUid(postId, comment5Id, comment5Uid);
        console.log("uids4: ", uids4);
        assert.equal(uids4.length, 4);


        // / 1 -> 2 -> 3 -> 4 -> 5 -> 2
        commentData["uid"] = comment2Uid;
        commentData["parentId"] = comment5Id;
        const commentRef6 = await CommentService.create(postId, commentData);
        const comment6Id = commentRef6.key!;
        console.log("comment6Id: ", comment6Id);
        const uids5 = await CommentService.getAncestorsUid(postId, comment6Id, comment2Uid);
        console.log("uids5: ", uids5);
        assert.equal(uids5.length, 4);

        // / Result will be [5, 4, 3, 1]
        assert.equal(uids5[0], comment5Uid);
        assert.equal(uids5[1], comment4Uid);
        assert.equal(uids5[2], comment3Uid);
        assert.equal(uids5[3], comment1Uid);

        // / 1 -> 2 -> 3 -> 4 -> 5 -> 2 -> 1
        commentData["uid"] = comment1Uid;
        commentData["parentId"] = comment6Id;
        const commentRef7 = await CommentService.create(postId, commentData);
        const comment7Id = commentRef7.key!;
        console.log("comment7Id: ", comment7Id);
        const uids6 = await CommentService.getAncestorsUid(postId, comment7Id, comment1Uid);
        console.log("uids6: ", uids6);
        assert.equal(uids6.length, 4);

        // / 1 -> 2 -> 3 -> 4 -> 5 -> 2 -> 1 -> 6
        const comment8Uid = randomString();
        commentData["uid"] = comment8Uid;
        commentData["parentId"] = comment7Id;
        const commentRef8 = await CommentService.create(postId, commentData);
        const comment8Id = commentRef8.key!;
        console.log("comment8Id: ", comment8Id);
        const uids7 = await CommentService.getAncestorsUid(postId, comment8Id, comment8Uid);
        console.log("uids7: ", uids7);
        assert.equal(uids7.length, 5);
    });
});

