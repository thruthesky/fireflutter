import "mocha";
// import * as admin from "firebase-admin";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { expect } from "chai";
import { Test } from "../test";
import { Comment } from "../../src/classes/comment";

new FirebaseAppInitializer();

describe("Comment - getAncestorsUid()", () => {
  it("Create comments", async () => {
    // Create user, post, and increase point.
    const commentA = await Test.createComment(undefined, "qna");

    expect(commentA).to.be.an("object");

    const commentAA = await Test.createComment(undefined, "qna", {
      postId: commentA.postId,
      parentId: commentA.id,
    });

    const commentB = await Test.createComment(undefined, "qna", {
      postId: commentA.postId,
      content: "B",
    });
    // const commentC = await Test.createComment(undefined, "qna", { postId: commentA.postId });

    const commentBA = await Test.createComment(undefined, "qna", {
      postId: commentB.postId,
      parentId: commentB.id,
      content: "BA",
    });
    const commentBAA = await Test.createComment(undefined, "qna", {
      postId: commentB.postId,
      parentId: commentBA.id,
      content: "BAA",
    });

    const aa = await Comment.getAncestorsUid(commentAA.id, commentAA.uid);
    expect(aa).to.be.an("array");
    expect(aa).lengthOf(1);
    expect(aa[0]).equals(commentA.uid);

    const uids = await Comment.getAncestorsUid(commentBAA.id, commentBA.uid);
    // console.log(uids);
    expect(uids).to.be.an("array");
    expect(uids).lengthOf(2);
    expect(uids[0]).equals(commentBAA.uid);
    // expect(uids[1]).equals(commentBA.uid);
    expect(uids[1]).equals(commentB.uid);
  });
});
