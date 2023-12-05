const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  d,
  tempChatRoomData,
  chatsColName,
  createChatRoom,
  admin,
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

  it("Sending a message in Chat Room but user's isDisabled = true -> fails", async () => {
    // create a chat room
    const roomRef = await createChatRoom(a, {
      master: a.uid,
      users: [a.uid, d.uid],
    });

    // admin disables the user d
    await admin()
      .collection("users")
      .doc(d.uid)
      .set({ isDisabled: true }, { merge: true });

    // User D sends a message and it should fail
    await firebase.assertFails(
      db(d)
        .collection(chatsColName)
        .doc(roomRef.id)
        .collection("messages")
        .add({ uid: d.uid, message: "test" })
    );

  });

});
