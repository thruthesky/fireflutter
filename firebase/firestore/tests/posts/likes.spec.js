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
  createPost,
} = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Post Update Test", () => {
  //
  it("User B updates A's post's likes (B liked the post) - successful", async () => {
    // Prepare

    const postRef = await createPost();

    // B update A's post
    await firebase.assertSucceeds(
      db(b)
        .collection(postsColName)
        .doc(postRef.id)
        .update({
          likes: firebase.firestore.FieldValue.arrayUnion(b.uid),
        })
    );
  });
});
