const assert = require("assert");
const {
  db,
  a,
  b,
  c,
  d,
  categoriesColName,
  postsColName,
  admin,
} = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Post Create Test", () => {
  it("All can create own posts - successful", async () => {
    // Prepare
    // create category
    const categoryRef = await admin().collection(categoriesColName).add({
      name: "Test",
      createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
      createdBy: "test-uid-admin",
    });

    // create post - successful
    await firebase.assertSucceeds(
      db(a).collection(postsColName).add({
        categoryId: categoryRef.id,
        title: "Sample Title",
        content: "Sample Content",
        uid: a.uid,
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
        updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
        likes: [],
      })
    );
  });
  it("Should not create posts for others - failure", async () => {
    // Prepare
    // create category
    const categoryRef = await admin().collection(categoriesColName).add({
      name: "Test",
      createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
      createdBy: "test-uid-admin",
    });

    // A create post for B - fail
    await firebase.assertFails(
      db(a).collection(postsColName).add({
        categoryId: categoryRef.id,
        title: "Sample Title",
        content: "Sample Content",
        uid: b.uid,
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
        updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
        likes: [],
      })
    );
  });
});
