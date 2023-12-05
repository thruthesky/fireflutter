const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  d,
  usersColName,
  admin,
  createUser,
  userDoc,
} = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("User update", async () => {
  it("Update name -> success", async () => {
    const uid = await createUser();
    await firebase.assertSucceeds(
      userDoc(uid).update({
        name: "abc",
      })
    );
  });

  it("Update isVerified -> fails", async () => {
    const uid = await createUser();
    await firebase.assertFails(
      userDoc(uid).update({
        isVerified: true,
      })
    );
  });
  it("Update isAdmin -> fails", async () => {
    const uid = await createUser();
    await firebase.assertFails(
      userDoc(uid).update({
        isAdmin: true,
      })
    );
  });
  it("Update isDisabled -> fails", async () => {
    const uid = await createUser();
    await firebase.assertFails(
      userDoc(uid).update({
        isDisabled: false,
      })
    );
  });

  it("Login as admin and update other user's isVerified -> succeeds", async () => {
    const uid = await createUser();
    await firebase.assertSucceeds(
      db({ uid: "admin" }).collection(usersColName).doc(uid).update({
        isVerified: true,
      })
    );
  });
  it("Login as admin and update other user's isAdmin -> succeeds", async () => {
    const uid = await createUser();
    await firebase.assertSucceeds(
      db({ uid: "admin" }).collection(usersColName).doc(uid).update({
        isAdmin: true,
      })
    );
  });
  it("Login as admin and update other user's isDisabled -> succeeds", async () => {
    const uid = await createUser();
    await firebase.assertSucceeds(
      db({ uid: "admin" }).collection(usersColName).doc(uid).update({
        isDisabled: true,
      })
    );
  });
});
