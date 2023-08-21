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

describe("Post Update Test", () => {
    it("No non-admin user CANNOT hard delete - failure", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            name: "Test",
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
            createdBy: "test-uid-admin",
        });

        // create post
        const postRef = await db(a).collection(postsColName).add({
            categoryId: categoryRef.id,
            title: "Sample Title",
            content: "Sample Content",
            uid: a.uid,
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
            likes: [],
        });

        // update post
        await firebase.assertFails(
            db(a).collection(postsColName).doc(postRef.id).delete()
        );
    });
});
