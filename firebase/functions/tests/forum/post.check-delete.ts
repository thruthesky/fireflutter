import "mocha";
import { expect } from "chai";
import * as admin from "firebase-admin";
import { Ref } from "../../src/utils/ref";
import "../firebase.init";
import { Library } from "../../src/utils/library";
import { PostDocument } from "../../src/interfaces/forum.interface";
import { Post } from "../../src/models/post.model";

// 글 작성자 UID
const testUid = "mdpJvOjfn4VIoa2gbFoxnzBmMuN2";

// 사진이 있는 글 ID
const testPostIdWithPhoto = "oJVYYDf90rm2HZY7UDgo";

describe("Post.checkDelete", () => {
  it("Create and Delete", async () => {
    // 글 생성
    const ref = await Ref.postCol.add({
      userDocumentReference: Ref.userDoc(testUid),
      title: "title",
      content: "content",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      category: "qna",
    });

    // 글 생성 후, 메타 업데이트 대기
    await Library.delay(1500);
    const doc = await ref.get();
    const post = doc.data() as PostDocument;
    expect(post).to.be.an("object");

    // 생성 된 글, checkDelete 테스트
    const re = await Post.checkDelete(
      doc as admin.firestore.QueryDocumentSnapshot
    );
    expect(re).to.be.null;

    // 생성 된 글 삭제 표시를 위해 deleted: true 로 업데이트
    await ref.update({ deleted: true });
    const updated = await ref.get();

    const re2 = await Post.checkDelete(
      updated as admin.firestore.QueryDocumentSnapshot
    );
    expect(re2).to.be.an("object");

    // 생성 된 글 삭제 표시 후, 확인. noOfComments = 0 이므로, 글 삭제
    const after = await ref.get();
    expect(after.exists).to.be.false;
  });

  it("Create and Delete", async () => {
    // 사진이 있는 글 ref
    const ref = Ref.postDoc(testPostIdWithPhoto);

    // 삭제 표시를 위해 deleted: true 로 업데이트. 이 때, noOfPostComment 를 1 로 주어, 글 문서는 남아 있게 함.
    await ref.update({ deleted: true, noOfComments: 1 });
    const updated = await ref.get();

    // 삭제 로직 실행. 사진이 있으므로, 글 삭제를 해야 함.
    const re2 = await Post.checkDelete(
      updated as admin.firestore.QueryDocumentSnapshot
    );
    expect(re2).to.be.an("object");

    // 생성 된 글 삭제 표시 후, 확인. noOfComments = 0 이므로, 글 삭제
    const after = await ref.get();
    expect(after.exists).to.be.true;
    console.log(after.data());
  });
});
