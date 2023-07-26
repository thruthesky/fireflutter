const assert = require("assert");
const { db, a, b, c, admin, tempChatRoomData } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Join test", () => {

  it("Join to the 1:1 room, group false, open false -> error test", async () => {
    // create a chat room
    const ref = await admin()
      .collection("easychat")
      .add(tempChatRoomData({ master: a.uid, users: [a.uid, b.uid], group: false, open: false }));

    // Join the room as C.
    await firebase.assertFails(
      db(c)
        .collection("easychat")
        .doc(ref.id)
        .set({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
    );
  });

  it("Join the room, group true, open true -> success test", async () => {
    // create a chat room
    const ref = await admin()
      .collection("easychat")
      .add(tempChatRoomData({ master: a.uid, users: [a.uid, b.uid], group: true, open: true }));

    // Join the room as C.
    await firebase.assertSucceeds(
      db(c)
        .collection("easychat")
        .doc(ref.id)
        .update({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
    );
  });

  it("Joining to the closed room, group true, open false -> fail test", async () => {
    // create a chat room
    const ref = await admin()
      .collection("easychat")
      .add(tempChatRoomData({ master: a.uid, users: [a.uid, b.uid], group: true, open: false }));
    // Join the room as C.
    await firebase.assertFails(
      db(c)
        .collection("easychat")
        .doc(ref.id)
        .set({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
    );
  });

  // ! This is for confirmation
  // Because, hackers may learn that they can actually join rooms that are not group but open (true)
  // it("Joining to the closed room, group false, open true -> fail test", async () => {
  //   // create a chat room
  //   const ref = await admin()
  //     .collection("easychat")
  //     .add(tempChatRoomData({ master: a.uid, users: [a.uid, b.uid], group: false, open: true }));
  //   // Join the room as C.
  //   await firebase.assertFails(
  //     db(c)
  //       .collection("easychat")
  //       .doc(ref.id)
  //       .set({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
  //   );
  // });


});
