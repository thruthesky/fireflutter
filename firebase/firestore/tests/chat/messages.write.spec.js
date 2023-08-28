const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  tempChatRoomData,
  chatsColName,
  createChatRoom,
} = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Sending messages in a chat room", () => {
  it("Sending a message in Chat Room as a member of a room - succeeds ", async () => {
    const roomRef = await createChatRoom(a, {
      master: a.uid,
      users: [a.uid, b.uid],
    });
    // console.log('reffy ' + roomRef.id);
    await firebase.assertSucceeds(
      db(a)
        .collection(chatsColName)
        .doc(roomRef.id)
        .collection("messages")
        .add({ uid: a.uid, message: "test" })
    );
  });

  it("Sending a message in Chat Room but not a member  -> fails", async () => {
    const roomRef = await createChatRoom(a, {
      master: a.uid,
      users: [a.uid, b.uid],
    });
    await firebase.assertFails(
      db(c)
        .collection(chatsColName)
        .doc(roomRef.id)
        .collection("messages")
        .add({ uid: c.uid, message: "test" })
    );
  });
  it("A sends B message pretending as B  -> fails", async () => {
    const roomRef = await createChatRoom(a, {
      master: a.uid,
      users: [a.uid, b.uid],
    });
    await firebase.assertFails(
      db(a)
        .collection(chatsColName)
        .doc(roomRef.id)
        .collection("messages")
        .add({ uid: b.uid, message: "test" })
    );
  });

  it("Updating my message -> succeeds", async () => {
    const roomRef = await createChatRoom(a, {
      master: a.uid,
      users: [a.uid, b.uid],
    });
    const messageRef = await db(a)
      .collection(chatsColName)
      .doc(roomRef.id)
      .collection("messages")
      .add({ uid: a.uid, message: "test" });
    await firebase.assertSucceeds(
      db(a)
        .collection(chatsColName)
        .doc(roomRef.id)
        .collection("messages")
        .doc(messageRef.id)
        .update({ message: "updated" })
    );
  });
});
