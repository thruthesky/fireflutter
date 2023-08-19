const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  d,
  createChatRoom,
  createOpenGroupChat,
  tempChatRoomData,
  invite,
  block,
  setAsModerator,
  chatsColName,
} = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Change default chat room name", () => {
  it("Update the default chat room name as master - success", async () => {
    // PREPARE: Create chat room by A
    const roomRef = await createOpenGroupChat(a);

    // A change the default chat room name.
    await firebase.assertSucceeds(
      db(a).collection(chatsColName).doc(roomRef.id).update({
        name: "Name 1",
      })
    );
  });
  it("Update the default chat room name as regular member - failure", async () => {
    // PREPARE: Create chat room by A
    const roomRef = await createOpenGroupChat(a);

    // A invites B
    await invite(a, b, roomRef.id);

    // B change the default chat room name.
    await firebase.assertFails(
      db(b).collection(chatsColName).doc(roomRef.id).update({
        name: "Name 2",
      })
    );
  });
  it("Update the default chat room name as moderator - success", async () => {
    // PREPARE: Create chat room by A
    const roomRef = await createOpenGroupChat(a);

    // A invites B
    await invite(a, b, roomRef.id);

    // A assigned B as moderator
    await setAsModerator(a, b, roomRef.id);

    // B change the default chat room name.
    await firebase.assertSucceeds(
      db(b).collection(chatsColName).doc(roomRef.id).update({
        name: "Name 3",
      })
    );
  });
  it("Update the default chat room name as blocked member - failure", async () => {
    // PREPARE: Create chat room by A
    const roomRef = await createOpenGroupChat(a);

    // A invites B
    await invite(a, b, roomRef.id);

    // A blocks B
    await block(a, b, roomRef.id);

    // B change the default chat room name.
    await firebase.assertFails(
      db(b).collection(chatsColName).doc(roomRef.id).update({
        name: "Name 4",
      })
    );
  });
});
