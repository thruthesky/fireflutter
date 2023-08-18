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
  unblock,
} = require("./../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Unblocking users", () => {
  it("User B unblocks himself - failure", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // A blocks B -> Success
    await block(a, b, roomRef.id);

    // A blocks B -> Success
    await firebase.assertFails(unblock(b, b, roomRef.id));
  });

  it("Moderator B unblocks himself - failure", async () => {
    // ! For confirmation if failure or not
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // Master A set B as Moderator
    await setAsModerator(a, b, roomRef.id);

    // A blocks B -> Success
    await block(a, b, roomRef.id);

    // A blocks B -> Success
    await firebase.assertSucceeds(unblock(b, b, roomRef.id));
  });

  it("Master A unblocks herself - success", async () => {
    // PREPARE
    const roomRef = await createOpenGroupChat(a);

    // Master A inviting B
    await invite(a, b, roomRef.id);

    // A blocks B -> Success
    await block(a, b, roomRef.id);

    // A blocks B -> Success
    await firebase.assertFails(unblock(b, b, roomRef.id));
  });

  // TEST Master Unblocking himself

  // it("Master A unblocks D.- D is not in room", async () => {
  //   // PREPARE
  //   const roomRef = await createOpenGroupChat(a);
  //   // Master A, Invite B,
  //   await invite(a, b, roomRef.id);
  // });

  //   it("B unblocks C - failure - C is not a master or moderator", async () => {});
  //   it("Master A unblocks B - success", async () => {});
});
