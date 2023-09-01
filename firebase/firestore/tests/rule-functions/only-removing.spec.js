const assert = require("assert");
const { db, a, b, c, d, tempChatRoomData, admin } = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

/// See the security rules. This test is for onlyRemoving rule.
/// It can only add 'b' in users field.
describe("Only removing tests", () => {
  /**
   * Rules
   * ```json
   *      match /rule-test-onlyRemoving/{documentId} {
   *          allow read: if true;
   *          allow update: if onlyRemoving('users', 'b');
   *     }
   * ```
   */
  it("onlyRemoving", async () => {
    const ref = await admin()
      .collection("rule-test-onlyRemoving")
      .add({ users: ["a", "b", "c"] });

    // console.log((await ref.get()).data());

    // 잘못된 (없는) 사용자 uid 나, 빈 uid 를 해도 실패. 반드시 'b' 를 제거 해야 한다.
    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(""),
        })
    );

    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove("xxx"),
        })
    );

    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove("a"),
        })
    );
    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove("c"),
        })
    );
    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove("a", "b"),
        })
    );
    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove("a", "c"),
        })
    );
    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove("a", "b", "c"),
        })
    );

    // 성공 b 가 빠졌음. 그렇다면, 다시 문서를 만들고, b 추가하고 테스트 해야 함.
    await firebase.assertSucceeds(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove("b"),
        })
    );
  });

  it("onlyRemoving - by array update", async () => {
    const ref = await admin()
      .collection("rule-test-onlyRemoving")
      .add({ users: ["a", "b", "c"] });

    await firebase.assertSucceeds(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: ["a", "c"],
        })
    );
  });

  it("onlyRemoving - adding is not allowed", async () => {
    const ref = await admin()
      .collection("rule-test-onlyRemoving")
      .add({ users: ["a", "b", "c"] });

    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: ["a", "c", "d"],
        })
    );

    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyRemoving")
        .doc(ref.id)
        .update({
          users: ["c", "d"],
        })
    );
  });

  it("remove an element that is not exist in the array - fail", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyRemoving")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyRemoving").doc(ref.id);

    console.log((await docRef.get()).data());

    // Update other field(s)
    await firebase.assertFails(
      docRef.update({ users: firebase.firestore.FieldValue.arrayRemove("b") })
    );
  });
});
