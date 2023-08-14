const assert = require("assert");
const { db, a, b, c, createChatRoom } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Kicking Out users in Chat Room Test", () => {
    it("Master A kicking out User B -> succeed", async () => {
        // A creating open room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: true, group: true });
        // A inviting B
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(b.uid) })
        );
        const doc1 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(doc1.data().users.includes(b.uid));
        // A kicking B out in the room
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayRemove(b.uid) })
        );
        const doc2 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        // B should no longer be in the room
        assert.ok(!doc2.data().users.includes(b.uid));
    });

    it("Regular User B kicking out User A -> failure", async () => {
        // A creating open room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: true, group: true });
        // A inviting B
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(b.uid) })
        );
        const doc1 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(doc1.data().users.includes(b.uid));
        // B kicking A out in the room
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayRemove(a.uid) })
        );
    });
});

