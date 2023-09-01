const assert = require("assert");
const { db, a, b, c, d, tempChatRoomData, admin } = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

/// See the security rules. This test is for onlyRemoving rule.
/// It can only add 'b' in users field.
describe("Rule tests", () => {
  it("onlyRemoving - failure - by adding other field.", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyAdding")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyAdding").doc(ref.id);

    // Update other field(s)
    await firebase.assertFails(docRef.update({ aaa: ["c"] }));
  });
  it("onlyRemoving - failure - by adding 'c' in users field.", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyAdding")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyAdding").doc(ref.id);

    // Update other field(s)
    await firebase.assertFails(docRef.update({ users: ["c"] }));
  });
  it("onlyRemoving - failure - by adding 'b' but removing a in users field.", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyAdding")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyAdding").doc(ref.id);

    // Update other field(s)
    await firebase.assertFails(docRef.update({ users: ["b"] }));
  });
  it("onlyRemoving - success - by adding 'b' NOT replalcing a in users field.", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyAdding")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyAdding").doc(ref.id);

    // Update other field(s)
    await firebase.assertSucceeds(docRef.update({ users: ["a", "b"] }));
  });

  it("onlyRemoving - success - by adding 'b' with arrayUnion in users field.", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyAdding")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyAdding").doc(ref.id);

    // Update other field(s)

    await firebase.assertSucceeds(
      docRef.update({ users: firebase.firestore.FieldValue.arrayUnion("b") })
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
});
