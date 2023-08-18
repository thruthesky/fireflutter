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
    it("User A update her post - successful", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // create post
        const postRef = await db(a).collection(postsColName).add({
            'categoryId': categoryRef.id,
            'title': 'Sample Title',
            'content': 'Sample Content',
            'uid': a.uid,
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'likers': []
        });

        // update post
        await firebase.assertSucceeds(
            db(a).collection(postsColName).doc(postRef.id).update({
                'title': 'Updated my Title',
                'content': 'Updated my content',
                'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            })
        );
    });
    it("User B updates her User A's post - failure", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // create post
        const postRef = await db(a).collection(postsColName).add({
            'categoryId': categoryRef.id,
            'title': 'Sample Title',
            'content': 'Sample Content',
            'uid': a.uid,
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'likers': []
        });

        // B update A's post
        await firebase.assertFails(
            db(b).collection(postsColName).doc(postRef.id).update({
                'title': 'Updated my Title',
                'content': 'Updated my content',
                'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            })
        );
    });
    it("User B updates A's post's likers (B liked the post) - successful", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // create post
        const postRef = await db(a).collection(postsColName).add({
            'categoryId': categoryRef.id,
            'title': 'Sample Title',
            'content': 'Sample Content',
            'uid': a.uid,
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'likers': []
        });

        // B update A's post
        await firebase.assertSucceeds(
            db(b).collection(postsColName).doc(postRef.id).update({
                'likers': firebase.firestore.FieldValue.arrayUnion(b.uid),
            })
        );
    });
    it("User B updates A's post's likers (but adding c) - failure", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // create post
        const postRef = await db(a).collection(postsColName).add({
            'categoryId': categoryRef.id,
            'title': 'Sample Title',
            'content': 'Sample Content',
            'uid': a.uid,
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'likers': []
        });

        // B update A's post and adds C in likers - fail
        await firebase.assertFails(
            db(b).collection(postsColName).doc(postRef.id).update({
                'likers': firebase.firestore.FieldValue.arrayUnion(c.uid),
            })
        );
    });
    it("User B updates A's post's likers (but also adding c) - failure", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // create post
        const postRef = await db(a).collection(postsColName).add({
            'categoryId': categoryRef.id,
            'title': 'Sample Title',
            'content': 'Sample Content',
            'uid': a.uid,
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'likers': []
        });

        // B update A's post and adds C in likers - fail
        await firebase.assertFails(
            db(b).collection(postsColName).doc(postRef.id).update({
                'likers': firebase.firestore.FieldValue.arrayUnion(c.uid, b.uid),
            })
        );
    });
    it("User B removes C  in likers from post by A - failure", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // create post
        const postRef = await db(a).collection(postsColName).add({
            'categoryId': categoryRef.id,
            'title': 'Sample Title',
            'content': 'Sample Content',
            'uid': a.uid,
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'likers': []
        });

        // C liked the post
        db(c).collection(postsColName).doc(postRef.id).update({
            'likers': firebase.firestore.FieldValue.arrayUnion(c.uid),
        })

        // B update A's post and adds C in likers - fail
        await firebase.assertFails(
            db(b).collection(postsColName).doc(postRef.id).update({
                'likers': firebase.firestore.FieldValue.arrayRemove(c.uid),
            })
        );
    });
    it("User B removes himself in likers from post by A - success", async () => {
        // Prepare
        // create category
        const categoryRef = await admin().collection(categoriesColName).add({
            'name': 'Test',
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'addedBy': 'test-uid-admin',
        });

        // create post
        const postRef = await db(a).collection(postsColName).add({
            'categoryId': categoryRef.id,
            'title': 'Sample Title',
            'content': 'Sample Content',
            'uid': a.uid,
            'createdAt': firebase.firestore.FieldValue.serverTimestamp(),
            'updatedAt': firebase.firestore.FieldValue.serverTimestamp(),
            'likers': []
        });

        // B liked the post
        db(b).collection(postsColName).doc(postRef.id).update({
            'likers': firebase.firestore.FieldValue.arrayUnion(b.uid),
        })

        // B update A's post and removes himself in likers - success
        await firebase.assertSucceeds(
            db(b).collection(postsColName).doc(postRef.id).update({
                'likers': firebase.firestore.FieldValue.arrayRemove(b.uid),
            })
        );
    });
});