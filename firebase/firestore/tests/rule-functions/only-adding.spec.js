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
  usersColName,
  randomString,
  createUserOnlyXxx,
} = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

/// See the security rules. This test is for onlyRemoving rule.
/// It can only add 'b' in users field.
describe("Rule tests", () => {
  it("Add an element on a document that is not existing, yet - failure", async () => {
    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyAdding")
        .doc(randomString())
        .update({
          users: firebase.firestore.FieldValue.arrayUnion("b"),
        })
    );
  });

  it("add an element that is already exist in the array - success", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyAdding")
      .add({ users: ["b"] });

    await firebase.assertSucceeds(
      db(a)
        .collection("rule-test-onlyAdding")
        .doc(ref.id)
        .update({ users: firebase.firestore.FieldValue.arrayUnion("b") })
    );
  });

  it("add an element that is already exist in the array - success", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyAdding")
      .add({ users: ["b"] });

    await firebase.assertFails(
      db(a)
        .collection("rule-test-onlyAdding")
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayUnion("b"),
          name: "abc",
        })
    );
  });

  it("likes add on non-existen document - fails", async () => {
    const userA = await createUser(a);
    await firebase.assertFails(
      db(a)
        .collection("only-xxx")
        .doc(randomString())
        .update({
          likes: firebase.firestore.FieldValue.arrayUnion(a.uid),
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

  it("Add a like on an array that is already existing - success", async () => {
    const uid = await createUserOnlyXxx({ likes: ["xxx"] });
    await firebase.assertSucceeds(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayUnion(a.uid),
        })
    );
  });

  it("Add a like with wrong uid on an array that is already existing - fails", async () => {
    const uid = await createUserOnlyXxx({ likes: ["xxx"] });
    await firebase.assertFails(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayUnion(c.uid),
        })
    );
  });

  it("likes add on empty array field - success", async () => {
    const uid = await createUserOnlyXxx({ likes: [] });
    await firebase.assertSucceeds(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayUnion(a.uid),
        })
    );
  });

  it("likes with other field updating - fails", async () => {
    const uid = await createUserOnlyXxx({ likes: [] });
    await firebase.assertFails(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayUnion(a.uid),
          navigator: "chrome",
        })
    );
  });

  it("likes - add an element which is already exists", async () => {
    const uid = await createUserOnlyXxx({ likes: [a.uid] });
    await firebase.assertSucceeds(
      db(a)
        .collection("only-xxx")
        .doc(uid)
        .update({
          likes: firebase.firestore.FieldValue.arrayUnion(a.uid),
        })
    );
  });
});
