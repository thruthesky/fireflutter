const assert = require("assert");

// 파이어베이스 Unit test 모듈
const firebase = require("@firebase/testing");
// 테스트를 할 실제 파이어베이스 프로젝트 ID. 파이어베이스 콘솔에서 가져온다.
const TEST_PROJECT_ID = "withcenter-test-project";

const A = "user_A";
const B = "user_B";
const C = "user_C";
const userA = { uid: A, email: A + "@gmail.com" };
const userB = { uid: B, email: B + "@gmail.com" };
const userC = { uid: C, email: C + "@gmail.com" };

// 사용자 권한이 있는 (사용자 auth 로 로그인을 한) DB 커넥션을 가져온다.
function db(auth = null) {
  return firebase.initializeTestApp({ projectId: TEST_PROJECT_ID, auth: auth }).firestore();
}

// 관리자 권한이 있는 DB 커넥션을 가져온다.
// 주의, 관리자로 로그인을 한 경우는 Secuirty 검사를 하지 않고 통과한다.
function admin() {
  return firebase.initializeAdminApp({ projectId: TEST_PROJECT_ID }).firestore();
}

async function getUser(uid) {
  const snapshot = await admin().collection("users").doc(uid).get();
  return snapshot.data();
}
async function setUser(uid, data) {
  return await admin().collection("users").doc(uid).set(data, { merge: true });
}

// 사용자 A 블럭
function disableUser(uid) {
  return admin().collection("users").doc(uid).set(
    {
      disabled: true,
    },
    { merge: true }
  );
}

function enableUser(uid) {
  return admin().collection("users").doc(uid).set(
    {
      disabled: false,
    },
    { merge: true }
  );
}

async function setCategory(id, data) {
  return admin().collection("categories").doc(id).set(data, { merge: true });
}

// 테스트 전에, 이전의 데이터를 모두 지운다.
// 참고, 여기서 하지 말고, describe() 에서 하도록 한다.
beforeEach(async () => {
  await firebase.clearFirestoreData({ projectId: TEST_PROJECT_ID });
});

// before(async () => {
//   await firebase.clearFirestoreData({ projectId: TEST_PROJECT_ID });
// });

describe("Firestore security test", () => {
  it("Readonly", async () => {
    const testDoc = db().collection("test").doc("abc");
    await firebase.assertSucceeds(testDoc.get());
  });
  it("Write fail", async () => {
    const testDoc = db().collection("test").doc("abc");
    await firebase.assertFails(testDoc.set({}));
  });
});

describe("Disable test", () => {
  it("Disabled user", async () => {
    // A 사용자 블럭 후, 블럭된 사용자만 읽을 수 있는 문서 읽기.
    // 블럭된 사용자만 읽을 수 있으니 성공.
    await disableUser(A);
    const get = db(userA).collection("test").doc("col1").collection("disabled").doc("doc1").get();
    await firebase.assertSucceeds(get);
  });

  it("Enabled user", async () => {
    // B 사용자 블럭하지 않고, 블럭된 사용자만 읽을 수 있는 문서 읽기.
    // 블럭된 사용자만 읽을 수 있는데, 블럭되지 않은 사용자가 읽으려니 실패.
    await enableUser(B);
    const u = await getUser(B);
    const get2 = db(userB).collection("test").doc("col1").collection("disabled").doc("doc1").get();
    await firebase.assertFails(get2);
  });

  it("Non-existence of `disabled` field", async () => {
    // C 사용자 문서 자체가 존재하지 않는다.
    const get3 = db(userC).collection("test").doc("col1").collection("disabled").doc("doc1").get();
    await firebase.assertFails(get3);

    // C 사용자는 `disabled` 필드 자체가 존재하지 않는다.
    await setUser(C, { name: "C" });
    const get4 = db(userC).collection("test").doc("col1").collection("disabled").doc("doc1").get();
    await firebase.assertFails(get4);
  });
});

describe("Forum security rules test", () => {
  it("No input data on post create", async () => {
    const col = db(userA).collection("posts");
    // 각종 입력 값 없으면 실패.
    await firebase.assertFails(col.add({}));
  });
  it("No category on post create", async () => {
    await enableUser(A);
    const col = db(userA).collection("posts");
    await firebase.assertFails(
      col.add({
        category: "qna",
        uid: A,
        createdAt: 1,
        updatedAt: 1,
        noOfComments: 0,
        deleted: false,
      })
    );
  });

  it("Success on post create", async () => {
    await enableUser(A);
    await setCategory("qna", { title: "Q&A" });

    const col = db(userA).collection("posts");
    await firebase.assertSucceeds(
      col.add({
        category: "qna",
        uid: A,
        createdAt: 1,
        updatedAt: 1,
        noOfComments: 0,
        deleted: false,
      })
    );
  });

  it("Success on post create", async () => {
    // A 사용자가 B 사용자의 UID 로 글을 작성할 수 없다.
    await enableUser(A);
    await setCategory("qna", { title: "Q&A" });

    const col = db(userA).collection("posts");
    await firebase.assertFails(
      col.add({
        category: "qna",
        uid: B,
        createdAt: 1,
        updatedAt: 1,
        noOfComments: 0,
        deleted: false,
      })
    );
  });

  it("User without disabled field on post create", async () => {
    // 사용자 문서는 존재하는데, disabled 필드가 없는 경우,

    await admin().collection("users").doc(C).set({ name: "C" });
    await setCategory("qna", { title: "Q&A" });

    const col = db(userC).collection("posts");
    await firebase.assertSucceeds(
      col.add({
        category: "qna",
        uid: C,
        createdAt: 1,
        updatedAt: 1,
        noOfComments: 0,
        deleted: false,
      })
    );
  });
  it("User without disabled field on post create", async () => {
    // disabled 된 사용자 테스트
    await disableUser(C);
    await setCategory("qna", { title: "Q&A" });

    const col = db(userC).collection("posts");
    await firebase.assertFails(
      col.add({
        category: "qna",
        uid: C,
        createdAt: 1,
        updatedAt: 1,
        noOfComments: 0,
        deleted: false,
      })
    );
  });
});
