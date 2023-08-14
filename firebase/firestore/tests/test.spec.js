const assert = require("assert");
const { db, a, b, tempChatRoomData } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Firestore security test", () => {
  it("Readonly", async () => {
    // Get doc
    const testDoc = db(a).collection("readonly").doc();

    // Test success on doc
    await firebase.assertSucceeds(testDoc.get());
  });
  it("Writing on readonly collection -> should be failed.", async () => {
    const testDoc = db(b).collection("readonly").doc();

    // Test error on doc
    await firebase.assertFails(testDoc.set({ test: "test" }));
  });

  // it("Add a user to chat room without master & moderator -> fail", async () => {});
  // it("Add a user to chat room as a member -> fail", async () => {});
});
