const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  tempChatRoomData,
  createChatRoom,
  chatsColName,
} = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Read and Update number of unread messages", () => {
  it("Update no of unread message if you are not a member, 1:1 chat - failure", async () => {
    const roomRef = await createChatRoom(a, {
      master: a.uid,
      users: [a.uid, b.uid],
    });

    await firebase.assertFails(
      db(c)
        .collection(chatsColName)
        .doc(roomRef.id)
        .update({
          noOfNewMessages: {
            [a.uid]: 1,
            [b.uid]: 0,
          },
        })
    );
  });

  it("Update no of unread message if you are  a member, 1:1 chat - success", async () => {
    const roomRef = await createChatRoom(a, {
      master: a.uid,
      users: [a.uid, b.uid],
    });

    await firebase.assertSucceeds(
      db(b)
        .collection(chatsColName)
        .doc(roomRef.id)
        .update({
          noOfNewMessages: {
            [a.uid]: 1,
            [b.uid]: 0,
          },
        })
    );
  });
});
