import "mocha";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { expect } from "chai";
import { Post } from "../../src/classes/post";

new FirebaseAppInitializer();

describe("Post", () => {
  it("get posts with empty options", async () => {
    // 게시글 목록을 가져온다.
    const res = await Post.posts({});
    expect(res).to.be.an("array");
  });

  it("get posts with wrong category", async () => {
    const res = await Post.posts({ category: "wrong-category" });
    expect(res).to.be.an("array").lengthOf(0);
  });

  it("posts", async () => {
    // discussion 카테고리의 게시글 목록을 가져온다.
    const res = await Post.posts({ category: "discussion" });
    expect(res).to.be.an("array");
  });

  it("posts", async () => {
    // discussion 카테고리의 게시글 목록으로 pagination 한다.
    const page1 = await Post.posts({ category: "discussion", limit: "2", startAfter: "" });
    expect(page1).to.be.an("array").lengthOf(2);

    const page2 = await Post.posts({
      category: "discussion",
      limit: "2",
      startAfter: page1.pop()?.createdAt.seconds.toString(),
    });
    expect(page2).to.be.an("array").lengthOf(2);
  });
});
