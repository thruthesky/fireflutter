const assert = require("assert");
const { db, a, b, tempChatRoomData } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Firestore security test chat room", () => {
  it("1:1 chat -> failure due to 1 user in users list", async () => {
    const ref = await firebase.assertFails(
      db(a)
        .collection("easychat")
        .add(tempChatRoomData({ master: a.uid, users: [a.uid] }))
    );
  });

  it("1:1 chat -> success", async () => {
    const ref = await firebase.assertSucceeds(
      db(a)
        .collection("easychat")
        .add(tempChatRoomData({ master: a.uid, users: [a.uid, b.uid] }))
    );
  });

  it("Creating a group chat room -> success", async () => {
    await firebase.assertSucceeds(
      db(a)
        .collection("easychat")
        .add(tempChatRoomData({ master: a.uid, users: [a.uid], group: true }))
    );
  });

  it("Creating a group chat room with wrong master uid -> fail", async () => {
    await firebase.assertFails(
      db(a)
        .collection("easychat")
        .add(tempChatRoomData({ master: b.uid, users: [a.uid], group: true }))
    );
  });

  it("Creating a chat room without master uid in users -> fail", async () => {
    await firebase.assertFails(
      db(b)
        .collection("easychat")
        .add(tempChatRoomData({ master: b.uid, users: [a.uid, a.uid] }))
    );
  });

  it("Creating chat room without master -> fail", async () => {
    const testDoc = db().collection("easychat").doc();
    await firebase.assertFails(testDoc.set({ users: [a.uid, b.uid] }));
  });

  it("Creating chat room with wrong master uid -> fail", async () => {
    await firebase.assertFails(
      db(a)
        .collection("easychat")
        .add(tempChatRoomData({ master: b.uid, users: [a.uid, b.uid] }))
    );
  });

  it("Check if the group chat must have only 1 user on creation -> success", async () => {
    await firebase.assertSucceeds(
      db(b)
        .collection("easychat")
        .add(tempChatRoomData({ master: b.uid, users: [b.uid], group: true }))
    );
  });

  it("Check if the group chat must have only 1 user on creation -> failure", async () => {
    await firebase.assertFails(
      db(a)
        .collection("easychat")
        .add(tempChatRoomData({ master: a.uid, users: [a.uid, b.uid], group: true }))
    );
  });

  it("One can chat to himeself. -> failure", async () => {
    await firebase.assertSucceeds(
      db(a)
        .collection("easychat")
        .add(tempChatRoomData({ master: a.uid, users: [a.uid, a.uid], group: false }))
    );
  });
});

