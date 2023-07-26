const assert = require("assert");
const { db, a, b, c, d, createChatRoom, tempChatRoomData, admin } = require("./setup");

// load firebase-functions-test SDK
const firebase = require("@firebase/testing");

describe("Firestore security test adding a user in chat room", () => {
    it("User A inviting user B to an open room made by user A -> succeed", async () => {
        // A creating open room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: true, group: true });
        // A inviting B
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(b.uid) })
        );
        const doc = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(doc.data().users.includes(b.uid));
    });

    it("User A inviting user B to a closed room made by user A -> succeed", async () => {
        // A creating open room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: false, group: true });
        // A inviting B
        await firebase.assertSucceeds(
            db(a)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(b.uid) })
        );
        const doc = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        // Master can still invite a user even if the Group is closed
        assert.ok(doc.data().users.includes(b.uid));
    });

    it("User B inviting user C to an open room made by user A -> succeed", async () => {
        // create a chat room
        const roomRef = await admin()
            .collection("easychat")
            .add(tempChatRoomData({ master: a.uid, moderators: [d.uid], users: [a.uid, b.uid, d.uid], open: true, group: true }));
        // B inviting C
        await firebase.assertSucceeds(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
        );
    });

    it("User B inviting user C to an open room where B does not belong in this room -> failure", async () => {
        // A creating open room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: true, group: true });
        // B inviting C to an open room created by A
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
        );
        const doc1 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(!doc1.data().users.includes(c.uid));
    });

    it("User A inviting user B to an closed room by user A -> success", async () => {
        // A creating open room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: false, group: true });
        // B inviting C to an open room created by A
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
        // Since A the master, A can invite anyone
        assert.ok(doc1.data().users.includes(b.uid));
    });

    it("User B inviting user C to a 1:1 room -> failure", async () => {
        // A creating closed room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid, b.uid], group: false });
        // B inviting C
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
        );
        const doc1 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        assert.ok(!doc1.data().users.includes(c.uid));
    });

    it("User B inviting user C to an close room -> failure", async () => {
        // A creating closed room
        const roomRef = await createChatRoom(a, { master: a.uid, users: [a.uid], open: false, group: true });
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
        await firebase.assertFails(
            db(b)
                .collection("easychat")
                .doc(roomRef.id)
                .update({ users: firebase.firestore.FieldValue.arrayUnion(c.uid) })
        );
        const doc2 = await db(a)
            .collection("easychat")
            .doc(roomRef.id)
            .get();
        // C should not be here because B can't invite because GC is closed
        assert.ok(!doc1.data().users.includes(c.uid));
    });
});

