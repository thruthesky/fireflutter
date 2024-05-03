import { describe, it } from "mocha";
import { Post } from "../../src/forum/forum.interface";
import { randomString } from "../firebase-test-functions";
import { firebaseWithcenterTest2OnlineInit } from "../firebase-withcenter-test-2-online.init";
import { PostService } from "../../src/forum/post.service";

firebaseWithcenterTest2OnlineInit();


describe("PostService.create test", () => {
    it("Create a post and get its field", async () => {
        const data: Post = {
            uid: randomString(),
            createdAt: 12312,
            order: -12312,
            title: "c",
        };

        const ref = await PostService.create("test", data);
        const snapshot = await ref.get();
        if (snapshot.val().title !== data.title) {
            throw new Error("Title is not same");
        }
    });
});

