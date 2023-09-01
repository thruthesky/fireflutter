// import "mocha";
// import "../firebase.init";


// import { expect } from "chai";
// import { Test } from "../test";

// import { Ref } from "../../src/utils/ref";
// import { Comment } from "../../src/models/comment.model";

// describe("Comment - getAncestorsUid()", () => {
//   it("Create comments", async () => {
//     // Create user, post, and increase point.
//     const commentA = await Test.createComment(undefined, "qna");

//     expect(commentA).to.be.an("object");

//     const commentAA = await Test.createComment(undefined, "qna", {
//       postDocumentReference: commentA.postDocumentReference,
//       parentCommentDocumentReference: Ref.commentDoc(commentA.id)
//     });

//     const commentB = await Test.createComment(undefined, "qna", {
//       postDocumentReference: commentA.postDocumentReference,
//       content: "B",
//     });
//     // const commentC = await Test.createComment(undefined, "qna", { postId: commentA.postId });

//     const commentBA = await Test.createComment(undefined, "qna", {
//       postDocumentReference: commentB.postDocumentReference,
//       parentCommentDocumentReference: Ref.commentDoc(commentB.id),
//       content: "BA",
//     });
//     const commentBAA = await Test.createComment(undefined, "qna", {

//       postDocumentReference: commentB.postDocumentReference,
//       parentCommentDocumentReference: Ref.commentDoc(commentB.id),
//       content: "BAA",
//     });

//     const aa = await Comment.getAncestorsUid(commentAA.id, commentAA.userDocumentReference.id);
//     expect(aa).to.be.an("array");
//     expect(aa).lengthOf(1);
//     expect(aa[0]).equals(commentA.userDocumentReference.id);

//     const uids = await Comment.getAncestorsUid(commentBAA.id, commentBA.userDocumentReference.id);
//     expect(uids).to.be.an("array");
//     expect(uids).lengthOf(2);
//     expect(uids[0]).equals(commentBAA.userDocumentReference.id);
//     expect(uids[1]).equals(commentB.userDocumentReference.id);
//   });
// });
