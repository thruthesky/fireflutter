const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  d,
  tempChatRoomData,
  admin,
  chatsColName,
} = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Chat room leave, and kickout", () => {
  it("Chat room leave - failure test: b removes a", async () => {
    // create a chat room
    const ref = await admin()
      .collection(chatsColName)
      .add(tempChatRoomData({ master: a.uid, users: [a.uid, b.uid] }));
    snapshot = await ref.get();

    // chat room leave
    await firebase.assertFails(
      db(b)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });

  it("Chat room leave - failure test: b removes a from users araay that has manu muliple users. -fails", async () => {
    // create a chat room
    const ref = await admin()
      .collection(chatsColName)
      .add(
        tempChatRoomData({
          master: a.uid,
          users: [
            a.uid,
            b.uid,
            c.uid,
            d.uid,
            a.uid,
            b.uid,
            b.uid,
            b.uid,
            b.uid,
            c.uid,
            c.uid,
            c.uid,
            c.uid,
          ],
        })
      );
    snapshot = await ref.get();

    // chat room leave
    await firebase.assertFails(
      db(b)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });

  it("Chat room leave - failure test: b removes b from users araay that has manu muliple users. succeeds", async () => {
    // create a chat room
    const ref = await admin()
      .collection(chatsColName)
      .add(
        tempChatRoomData({
          master: a.uid,
          users: [a.uid, b.uid, c.uid, d.uid, b.uid, b.uid],
        })
      );

    // chat room leave
    await firebase.assertSucceeds(
      db(b)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(b.uid),
        })
    );
  });

  it("Master can remove a user from user list - succeed", async () => {
    // create a chat room
    const ref = await admin()
      .collection(chatsColName)
      .add(
        tempChatRoomData({
          master: a.uid,
          users: [a.uid, b.uid, c.uid, d.uid, b.uid, b.uid],
        })
      );

    // chat room leave
    await firebase.assertSucceeds(
      db(a)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(b.uid),
        })
    );
  });

  it("Moderator can remove a user from user list - succeed", async () => {
    // create a chat room
    // b is moderator
    const ref = await admin()
      .collection(chatsColName)
      .add(
        tempChatRoomData({
          master: a.uid,
          moderators: [b.uid],
          users: [a.uid, b.uid, c.uid, d.uid],
        })
      );

    // chat room remove b
    await firebase.assertSucceeds(
      db(b)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(c.uid),
        })
    );
  });

  it("Moderator should not be able to remove the master from user list - fail", async () => {
    // create a chat room
    const ref = await admin()
      .collection(chatsColName)
      .add(
        tempChatRoomData({
          master: a.uid,
          moderators: [d.uid],
          users: [a.uid, b.uid, c.uid, d.uid, b.uid, b.uid],
        })
      );

    // chat room leave
    await firebase.assertFails(
      db(d)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });

  it("Moderator should not be able to remove the master from user list - fail", async () => {
    // create a chat room
    const ref = await admin()
      .collection(chatsColName)
      .add(
        tempChatRoomData({
          master: a.uid,
          moderators: [d.uid],
          users: [a.uid, b.uid, c.uid, d.uid],
        })
      );

    // chat room leave
    await firebase.assertFails(
      db(d)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });

  it("User should not be able to remove the moderator from user list - fail", async () => {
    // create a chat room
    const ref = await admin()
      .collection(chatsColName)
      .add(
        tempChatRoomData({
          master: a.uid,
          moderators: [d.uid],
          users: [a.uid, b.uid, c.uid, d.uid],
        })
      );

    // chat room leave
    await firebase.assertFails(
      db(c)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(d.uid),
        })
    );
  });

  it("User should not be able to remove the master from user list - fail", async () => {
    // create a chat room
    const ref = await admin()
      .collection(chatsColName)
      .add(
        tempChatRoomData({
          master: a.uid,
          moderators: [d.uid],
          users: [a.uid, b.uid, c.uid, d.uid],
        })
      );

    // chat room leave
    await firebase.assertFails(
      db(c)
        .collection(chatsColName)
        .doc(ref.id)
        .update({
          users: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });
});
