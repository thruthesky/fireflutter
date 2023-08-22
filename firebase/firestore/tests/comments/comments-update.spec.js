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

describe("Comments Update Test (comments-update.spec.js)", () => {
    it("User updates own comment - success", async () => {
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
        await firebase.assertSucceeds(
            db(b).collection(commentsColsName).doc(commentRef.id).update({
                'content': 'Update The Comment',
            })
        );
    });
    it("User updates others comment - failure", async () => {
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

        // User C updates the comment of User B
        await firebase.assertFails(
            db(c).collection(commentsColsName).doc(commentRef.id).update({
                'content': 'Update The Comment',
            })
        );
    });
    it("User updates own comment (using set) - success", async () => {
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
        await firebase.assertSucceeds(
            db(b).collection(commentsColsName).doc(commentRef.id).set({
                'content': 'Update The Comment',
            })
        );
    });
    it("User updates others comment (using set) - failure", async () => {
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

        // User C updates the comment of User B
        await firebase.assertFails(
            db(c).collection(commentsColsName).doc(commentRef.id).set({
                'content': 'Update The Comment',
            })
        );
    });
});