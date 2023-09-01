const assert = require("assert");
const { db, a, b, c, d, tempChatRoomData, admin } = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

/// See the security rules. This test is for onlyRemoving rule.
/// It can only add 'b' in users field.
describe("Only removing tests", () => {
  it("remove an element that is not exist in the array - success", async () => {
    // Set doc by admin
    const ref = await admin()
      .collection("rule-test-onlyRemoving")
      .add({ users: ["a"] });

    // Connect to doc by user
    const docRef = db(a).collection("rule-test-onlyRemoving").doc(ref.id);

    // Update other field(s)
    await firebase.assertFails(
      docRef.update({ users: firebase.firestore.FieldValue.arrayRemove("b") })
    );
  });
});
