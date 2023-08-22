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

describe("Comments Create Test (comments-create.spec.js)", () => {

    it("User tried to commment with other user uid - failure", async () => {
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

        // User A created a comment with User B's uid
        await firebase.assertFails(
            db(a).collection(commentsColsName).add({
                'content': 'Sample Comment',
                'postId': postRef.id,
                'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
                'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
                'uid': b.uid,
            })
        );
    });

    it("User created comment with own uid - success", async () => {
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
        await firebase.assertSucceeds(
            db(b).collection(commentsColsName).add({
                'content': 'Sample Comment',
                'postId': postRef.id,
                'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
                'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
                'uid': b.uid,
            })
        );
    });
});