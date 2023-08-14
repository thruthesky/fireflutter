const assert = require("assert");
const { db, a, b, c, d, tempChatRoomData, admin } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Rule tests", () => {
  it("onlyUpdating", async () => {
    const ref = await admin()
      .collection("rule-test-onlyUpdating")
      .add({ a: 1, b: 2, c: 3 });

    // snapshot = await ref.get();

    // 아무것도 업데이트 안해도 성공
    await firebase.assertSucceeds(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({})
    );
    await firebase.assertSucceeds(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        a: 10,
      })
    );
    await firebase.assertSucceeds(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        b: 20,
      })
    );
    await firebase.assertSucceeds(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        a: 11,
        b: 22,
      })
    );
    await firebase.assertFails(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        a: 10,
        b: 20,
        c: 30,
      })
    );
    await firebase.assertFails(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        c: 33,
      })
    );
  });
  it("notUpdating", async () => {
    const ref = await admin()
      .collection("rule-test-notUpdating")
      .add({ a: 1, b: 2, c: 3 });

    // snapshot = await ref.get();

    await firebase.assertSucceeds(
      db(a).collection("rule-test-notUpdating").doc(ref.id).update({})
    );
    await firebase.assertSucceeds(
      db(a).collection("rule-test-notUpdating").doc(ref.id).update({
        c: 33,
      })
    );

    await firebase.assertFails(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        a: 10,
      })
    );
    await firebase.assertFails(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        b: 20,
      })
    );
    await firebase.assertFails(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        a: 11,
        b: 22,
      })
    );
    await firebase.assertFails(
      db(a).collection("rule-test-onlyUpdating").doc(ref.id).update({
        a: 10,
        b: 20,
        c: 30,
      })
    );
  });

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
});
