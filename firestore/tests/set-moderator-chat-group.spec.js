const assert = require("assert");
const { db, a, b, c, createChatRoom } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Firestore security test setting the moderators chat room", () => {
    it("User A setting user B to be moderator in a room by A -> succeed", async () => {
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
        // A setting B as moderator
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ moderators: firebase.firestore.FieldValue.arrayUnion(b.uid) })
        );
        const doc2 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(doc2.data().moderators.includes(b.uid));
    });

    it("User A removing user B as moderator in a room by A -> succeed", async () => {
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
        // A setting B as moderator
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ moderators: firebase.firestore.FieldValue.arrayUnion(b.uid) })
        );
        const doc2 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(doc2.data().moderators.includes(b.uid));
        // A removing B as moderator
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ moderators: firebase.firestore.FieldValue.arrayRemove(b.uid) })
        );
        const doc3 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(!doc3.data().moderators.includes(b.uid));
    });

    it("User A setting user C to be moderator in an open room by A, who was invited by B -> succeed", async () => {
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
        // B inviting C
        await firebase.assertSucceeds(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
        );
        const doc2 = await db(b)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(doc2.data().users.includes(c.uid));
        // A setting C as moderator
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ moderators: firebase.firestore.FieldValue.arrayUnion(c.uid) })
        );
        const doc3 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(doc3.data().moderators.includes(c.uid));
    });

    // TODO failure - add as moderator but not in the room
});

