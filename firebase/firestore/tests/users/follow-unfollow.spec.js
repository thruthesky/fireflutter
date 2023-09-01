const assert = require("assert");
const { db, a, b, c, d, usersColName, admin, createUser } = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("User Follow/Unfollow Test (follow-unfollow.spec.js)", async () => {
  it("User A follow B - successful", async () => {
    // Prepare user records
    await createUser(a);
    await createUser(b);
    // A follows B
    await firebase.assertSucceeds(
      db(a)
        .collection(usersColName)
        .doc(b.uid)
        .update({
          followers: firebase.firestore.FieldValue.arrayUnion(a.uid),
        })
    );
  });

  it("User A follow B - failure since he is already following?", async () => {
    // Prepare user records
    await createUser(a);
    await createUser(b);
    // A follows B
    await firebase.assertSucceeds(
      db(a)
        .collection(usersColName)
        .doc(b.uid)
        .update({
          followers: firebase.firestore.FieldValue.arrayUnion(a.uid),
        })
    );
    await firebase.assertSucceeds(
      db(a)
        .collection(usersColName)
        .doc(b.uid)
        .update({
          followers: firebase.firestore.FieldValue.arrayUnion(a.uid),
        })
    );
  });

  it("User A asigned C as following B - failure", async () => {
    // Prepare user records
    await createUser(a);
    await createUser(b);
    await createUser(c);
    const ref = db(a).collection(usersColName).doc(b.uid);

    // console.log(
    //   "-------> before update; ",
    //   (await admin().collection(usersColName).doc(b.uid).get()).data()
    // );

    // await ref.update({
    //   followers: firebase.firestore.FieldValue.arrayUnion(c.uid),
    // });

    // console.log(
    //   "-------> after update; ",
    //   (await admin().collection(usersColName).doc(b.uid).get()).data()
    // );

    // A assigned C to follow B
    await firebase.assertFails(
      ref.update({
        followers: firebase.firestore.FieldValue.arrayUnion(c.uid),
      })
    );
  });

  it("User A unfollow B - successful", async () => {
    // Prepare user records
    await createUser(a);
    await createUser(b);
    // A follows B
    await db(a)
      .collection(usersColName)
      .doc(b.uid)
      .update({
        followers: firebase.firestore.FieldValue.arrayUnion(a.uid),
      });
    // A unfollows B
    await firebase.assertSucceeds(
      db(a)
        .collection(usersColName)
        .doc(b.uid)
        .update({
          followers: firebase.firestore.FieldValue.arrayRemove(a.uid),
        })
    );
  });
  it("User A forced C to unfollow B - failure", async () => {
    // Prepare user records
    await createUser(a);
    await createUser(b);
    await createUser(c);
    // C follows B
    await db(c)
      .collection(usersColName)
      .doc(b.uid)
      .update({
        followers: firebase.firestore.FieldValue.arrayUnion(c.uid),
      });
    // A force C to unfollow B
    await firebase.assertFails(
      db(a)
        .collection(usersColName)
        .doc(b.uid)
        .update({
          followers: firebase.firestore.FieldValue.arrayRemove(c.uid),
        })
    );
  });
});
