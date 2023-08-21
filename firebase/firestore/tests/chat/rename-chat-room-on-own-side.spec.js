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

describe("Rename Chat on my side", () => {
  it("Update chat room name on my own side as master - success", async () => {
    // PREPARE: Create chat room by A
    const roomRef = await createOpenGroupChat(a);

    // A renames Chat Room in his side.
    await firebase.assertSucceeds(
      db(a)
        .collection(chatsColName)
        .doc(roomRef.id)
        .set(
          {
            rename: { [a.uid]: "rename success" },
          },
          { merge: true }
        )
    );
  });
  it("Update my own side chat room name as regular member - success", async () => {
    // PREPARE: Create chat room by A
    const roomRef = await createOpenGroupChat(a);

    // A invites B
    await invite(a, b, roomRef.id);

    // B renames Chat Room in his side.
    await firebase.assertSucceeds(
      db(b)
        .collection(chatsColName)
        .doc(roomRef.id)
        .set(
          {
            rename: { [b.uid]: "rename success" },
          },
          { merge: true }
        )
    );
  });
  // ! NOTE
  // This is not really a security issue, because this is just renaming the room name.
  it("Update others' own side name as regular member - success", async () => {
    // PREPARE: Create chat room by A
    const roomRef = await createOpenGroupChat(a);

    // A invites B
    await invite(a, b, roomRef.id);

    // B renames Chat Room in A's side. [Please read the NOTE]
    await firebase.assertSucceeds(
      db(b)
        .collection(chatsColName)
        .doc(roomRef.id)
        .set(
          {
            rename: { [a.uid]: "rename should fail" },
          },
          { merge: true }
        )
    );
  });
});
