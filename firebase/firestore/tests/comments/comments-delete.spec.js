const assert = require("assert");
const {
    db,
    a,
    b,
    c,
    d,
    commentsColsName,
    categoriesColName,
    postsColName,
    admin,
} = require("../setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Comments Delete Test (comments-delete.spec.js)", () => {
    it("User deletes - failure", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            name: "Test",
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
            createdBy: "test-uid-admin",
        });

        // User A created a post
        const postRef = await db(a).collection(postsColName).add({
            categoryId: categoryRef.id,
            title: "Sample Title",
            content: "Sample Content",
            uid: a.uid,
            createdAt: firebase.firestore.FieldValue.serverTimestamp(),
            updatedAt: firebase.firestore.FieldValue.serverTimestamp(),
            likes: [],
        });

        // User B created a comment
        const commentRef = await db(b).collection(commentsColsName).add({
            'content': 'Sample Comment',
            'postId': postRef.id,
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'uid': b.uid,
        })

        // user B updated his own comment
        await firebase.assertFails(
            db(b).collection(commentsColsName).doc(commentRef.id).delete()
        );
    });
});