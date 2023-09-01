const assert = require("assert");
const { db, a, b, c, d, tempChatRoomData, admin } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Rule tests", () => {
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
});
