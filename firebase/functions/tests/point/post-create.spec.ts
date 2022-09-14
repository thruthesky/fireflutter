import "mocha";
// import * as admin from "firebase-admin";

import { FirebaseAppInitializer } from "../firebase-app-initializer";

import { expect } from "chai";
import { Point } from "../../src/classes/point";
// import { EventName } from "../../src/interfaces/point.interface";
// import { Utils } from "../../src/utils/utils";
// import { Ref } from "../../src/utils/ref";
import { Test } from "../test";
import { Category } from "../../src/classes/category";
// import { Ref } from "../../src/utils/ref";
import { Post } from "../../src/classes/post";
import { User } from "../../src/classes/user";
import { EventName, pointEvent } from "../../src/interfaces/point.interface";
import { Utils } from "../../src/utils/utils";
import { Ref } from "../../src/utils/ref";
// import { EventName } from "../../src/interfaces/point.interface";

new FirebaseAppInitializer();

describe("Point", () => {
  it("Post create point", async () => {
    const user = await Test.createUser();
    await Category.set("qna", { point: 10 });
    const post = await Test.createPost(user!.id, "qna");

    // console.log(post);
    expect(post).to.be.an("object");
    expect(post?.point).to.be.undefined;

    await Point.postCreate(post, post.id);

    // const lastDoc = await Point.getLastDoc(user!.id, EventName.postCreate);
    // console.log(user?.id, "lastDoc", lastDoc);

    const postAfter = await Post.get(post.id);

    // console.log(post);
    // console.log(postAfter);
    expect(postAfter).haveOwnProperty("point");

    const point = await User.point(user!.id);

    expect(point).equals(postAfter.point);

    // Create another post and see if the point did not increased.
    // Point must not be increased due to the `within` time.

    const anotherPost = await Test.createPost(user!.id, "qna", {});
    await Point.postCreate(anotherPost, anotherPost.id);
    const anotherPostAfter = await Post.get(anotherPost.id);
    expect(anotherPostAfter.point ?? 0).equals(0);
    expect(point).equals((postAfter.point ?? 0) + (anotherPostAfter.point ?? 0));

    // console.log("point; ", point);
    // console.log("after point; ", anotherPoint);

    // expect(point).greaterThan(0);
    // expect(point).equals(anotherPoint);
  });

  it("Within time test", async () => {
    // Create user, post, and increase point.
    const post = await Test.createPost(undefined, "qna");

    await Point.postCreate(post, post.id);
    const postWithPoint = await Post.get(post.id);

    // Create post and increase point again.
    const anotherPost = await Test.createPost(post.uid, "qna", {});
    await Point.postCreate(anotherPost, anotherPost.id);

    // Two post create but only one got point.
    // Prove it.
    const point = await User.point(post.uid);
    expect(point).equals(postWithPoint.point);

    // Change within and increase point.
    // Set post create `within` time to 1 seconds. and wait 2 seconds.
    pointEvent[EventName.postCreate].within = 1;
    await Utils.delay(2000);
    const p = await Test.createPost(post.uid, "qna", {});
    await Point.postCreate(p, p.id);
    const pWithPoint = await Post.get(p.id);

    const increased = await User.point(post.uid);
    expect(increased).equals((postWithPoint?.point ?? 0) + (pWithPoint.point ?? 0));
    console.log(p.uid, increased);

    const snapshot = await Ref.pointHistoryCol(post.uid).get();
    expect(snapshot.size).equals(2);
  });
});
