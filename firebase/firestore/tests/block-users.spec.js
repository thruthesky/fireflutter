const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  d,
  createChatRoom,
  createOpenGroupChat,
  invite,
  block,
  setAsModerator,
} = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Blocked users", () => {
  it("Master A blocks User B - success", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // A blocks B -> Success
    await firebase.assertSucceeds(block(a, b, roomRef.id));
  });

  it("Master A blocks Moderator B - success", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // Master A setting B as Moderator
    await setAsModerator(a, b, roomRef.id);

    // A blocks B -> Success
    await firebase.assertSucceeds(block(a, b, roomRef.id));
  });

  it("Moderator B blocks User C - success", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // Master A inviting C
    await invite(a, c, roomRef.id);

    // Master A setting B as Moderator
    await setAsModerator(a, b, roomRef.id);

    // B blocks C -> Success
    await firebase.assertSucceeds(block(b, c, roomRef.id));
  });

  it("User B blocks Master A - failure", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // B blocks A -> Failure
    await firebase.assertFails(block(b, a, roomRef.id));
  });

  it("User B blocks Moderator C - failure", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // Master A inviting C
    await invite(a, c, roomRef.id);

    // Master A set User C as Moderator
    await setAsModerator(a, c, roomRef.id);

    // B blocks A -> Failure
    await firebase.assertFails(block(b, c, roomRef.id));
  });

  it("Regular User B blocks Regular User C - failure", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // Master A inviting C
    await invite(a, c, roomRef.id);

    // B blocks A -> Failure
    await firebase.assertFails(block(b, c, roomRef.id));
  });

  it("Block C -> success -> Even if the user C is not in the room, master can block. Don't care since it's not a security problem.", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A, Invite B,
    await invite(a, b, roomRef.id);

    // A blocks C --> Success. C is not in room.
    await firebase.assertSucceeds(block(a, c, roomRef.id));
  });

  it("A invite B and set him as a moderator. And moderator can block master? yes. Don't care as long as it's not a security problem. Master can unblock himself.", async () => {

    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A, Invite B,
    await invite(a, b, roomRef.id);

    // Master A made B a moderator,
    await setAsModerator(a, b, roomRef.id);

    // B blocks A --> success
    await firebase.assertSucceeds(setAsModerator(b, a, roomRef.id));
  });

});
