const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  d,
  tempChatRoomData,
  admin,
  createUser,
  createUserOnlyXxx,
  randomString,
} = require("../setup");

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
          users: firebase.firestore.FieldValue.arrayRemove(b.uid),
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

  it("remove an element from an array where the array does not exists - success", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyRemoving")
      .add({ users: [] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyRemoving").doc(ref.id);

    // Update other field(s)
    await firebase.assertSucceeds(
      docRef.update({ users: firebase.firestore.FieldValue.arrayRemove("b") })
    );
  });
  it("remove an element that is not exist in the array - success", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyRemoving")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyRemoving").doc(ref.id);

    // Update other field(s)
    await firebase.assertSucceeds(
      docRef.update({ users: firebase.firestore.FieldValue.arrayRemove("b") })
    );
  });
  it("remove an element that is not exist in the array with updating other field - fail", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyRemoving")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyRemoving").doc(ref.id);

    // Update other field(s)
    await firebase.assertFails(
      docRef.update({
        users: firebase.firestore.FieldValue.arrayRemove("b"),
        name: "test",
      })
    );
  });

  /// -----

  it("likes remove - on a non-existen document - fails", async () => {
    await firebase.assertFails(
      db(a)
        .collection("only-xxx")
        .doc(randomString())
        .update({
          likes: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });

  it("Add a like on an array that is not existing in the document - success", async () => {
    const uid = await createUserOnlyXxx();
    await firebase.assertSucceeds(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayUnion(a.uid),
        })
    );
  });

  it("Remove a like of [wrong uid] on an array that is already existing - success", async () => {
    const uid = await createUserOnlyXxx({ likes: ["xxx"] });
    await firebase.assertSucceeds(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });

  it("Remove a like of [wrong uid] on an array that is already existing with updating other document - fails", async () => {
    const uid = await createUserOnlyXxx({ likes: ["xxx"] });
    await firebase.assertFails(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayRemove(a.uid),
          name: "test",
        })
    );
  });

  it("Remove a like from an empty array field - success", async () => {
    const uid = await createUserOnlyXxx({ likes: [] });
    await firebase.assertSucceeds(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });

  it("Don't remove any likes but updating other fields - fails", async () => {
    const uid = await createUserOnlyXxx({ likes: [] });
    await firebase.assertFails(
      db(a).collection("only-xxx").doc(uid).update({
        navigator: "chrome",
      })
    );
  });

  it("Remove an element which is already exists", async () => {
    const uid = await createUserOnlyXxx({ likes: [a.uid] });
    await firebase.assertSucceeds(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });

  it("Remove an element which is already exists with other fields - fails", async () => {
    const uid = await createUserOnlyXxx({ likes: [a.uid] });
    await firebase.assertFails(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayRemove(a.uid),
          name: "update",
        })
    );
  });
});
